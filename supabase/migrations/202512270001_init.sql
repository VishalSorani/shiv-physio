-- Shiv Physio App - Supabase schema (single-doctor physio clinic)
-- Includes: profiles, appointments, videos, availability windows, time off, clinic settings,
-- slot generation + booking validation, RLS policies, and optional storage bucket/policies.
--
-- Assumptions (from requirements):
-- - Auth: Google Sign-In via Supabase Auth (auth.users)
-- - Roles: only one doctor, modeled via users.is_doctor = true (enforced by partial unique index)
-- - Booking flow: patient creates appointment as 'pending', doctor approves/declines
-- - Scheduling model: weekly availability windows; slots are 60 minutes; clinic timezone is authoritative
-- - Videos: uploaded by doctor; visible to all authenticated users if published

begin;

-- Extensions needed for UUID generation and exclusion constraints
create extension if not exists pgcrypto;
create extension if not exists btree_gist;

-- -----------------------------------------------------------------------------
-- Types
-- -----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'appointment_status') then
    create type public.appointment_status as enum (
      'pending',
      'confirmed',
      'completed',
      'cancelled',
      'no_show'
    );
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Utility functions
-- -----------------------------------------------------------------------------

-- updated_at helper (must exist before any triggers that call it)
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Scheduling tables (created early because utility functions depend on them)
-- -----------------------------------------------------------------------------

create table if not exists public.clinic_settings (
  id boolean primary key default true,
  clinic_timezone text not null default 'Asia/Kolkata',
  slot_minutes int not null default 60,
  min_booking_notice_minutes int not null default 0,
  max_booking_days_ahead int not null default 30,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint clinic_settings_single_row_chk check (id = true),
  constraint clinic_settings_slot_minutes_chk check (slot_minutes > 0 and slot_minutes <= 240)
);

insert into public.clinic_settings (id)
values (true)
on conflict (id) do nothing;

drop trigger if exists clinic_settings_set_updated_at on public.clinic_settings;
create trigger clinic_settings_set_updated_at
before update on public.clinic_settings
for each row execute function public.set_updated_at();

-- Get the clinic timezone (single-row table); fallback to Asia/Kolkata if missing.
create or replace function public.get_clinic_timezone()
returns text
language sql
stable
as $$
  select coalesce(
    (select clinic_timezone from public.clinic_settings where id = true),
    'Asia/Kolkata'
  );
$$;

create or replace function public.get_slot_minutes()
returns int
language sql
stable
as $$
  select coalesce(
    (select slot_minutes from public.clinic_settings where id = true),
    60
  );
$$;

-- Prevent changing is_doctor via normal client writes (bootstrap doctor via service role / SQL editor).
create or replace function public.prevent_is_doctor_change()
returns trigger
language plpgsql
as $$
begin
  -- In the SQL editor / server context, auth.uid() is typically NULL; allow bootstrapping.
  if auth.uid() is not null and (new.is_doctor is distinct from old.is_doctor) then
    raise exception 'is_doctor cannot be changed from client';
  end if;
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Core tables
-- -----------------------------------------------------------------------------

-- Users table (app-level profile data). This is the primary table you should use from Flutter.
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  is_doctor boolean not null default false,
  full_name text,
  email text,
  phone text,
  age int,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Only one doctor allowed
create unique index if not exists users_single_doctor_unique
  on public.users ((is_doctor))
  where is_doctor = true;

create index if not exists users_is_doctor_idx on public.users (is_doctor);

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
before update on public.users
for each row execute function public.set_updated_at();

drop trigger if exists users_prevent_is_doctor_change on public.users;
create trigger users_prevent_is_doctor_change
before update of is_doctor on public.users
for each row execute function public.prevent_is_doctor_change();

-- Backwards-compatible view (optional): exposes the same shape as earlier "profiles"
create or replace view public.profiles as
select * from public.users;

-- Current user is doctor?
create or replace function public.is_current_user_doctor()
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.is_doctor = true
  );
$$;

-- Get the single doctor id (uuid). Returns NULL if not yet set.
create or replace function public.get_doctor_id()
returns uuid
language sql
stable
as $$
  select u.id
  from public.users u
  where u.is_doctor = true
  limit 1;
$$;

-- Auto-create profile row on sign up (Google auth)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_full_name text;
  v_avatar_url text;
  v_email text;
begin
  v_email := new.email;
  v_full_name := coalesce(
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'name'
  );
  v_avatar_url := coalesce(
    new.raw_user_meta_data->>'avatar_url',
    new.raw_user_meta_data->>'picture'
  );

  insert into public.users (id, full_name, email, avatar_url)
  values (new.id, v_full_name, v_email, v_avatar_url)
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.users(id) on delete restrict,
  doctor_id uuid not null references public.users(id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status public.appointment_status not null default 'pending',
  patient_note text,
  doctor_note text,
  cancelled_by uuid references public.users(id),
  cancel_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint appointments_time_order_chk check (end_at > start_at)
);

create index if not exists appointments_patient_start_idx
  on public.appointments (patient_id, start_at desc);
create index if not exists appointments_doctor_start_idx
  on public.appointments (doctor_id, start_at desc);
create index if not exists appointments_status_start_idx
  on public.appointments (status, start_at desc);

-- Prevent overlapping pending/confirmed appointments for the doctor
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'appointments_no_overlap_doctor'
  ) then
    alter table public.appointments
      add constraint appointments_no_overlap_doctor
      exclude using gist (
        doctor_id with =,
        tstzrange(start_at, end_at, '[)') with &&
      )
      where (status in ('pending', 'confirmed'));
  end if;
end $$;

drop trigger if exists appointments_set_updated_at on public.appointments;
create trigger appointments_set_updated_at
before update on public.appointments
for each row execute function public.set_updated_at();

create table if not exists public.videos (
  id uuid primary key default gen_random_uuid(),
  uploaded_by uuid not null references public.users(id) on delete restrict,
  title text not null,
  description text,
  category text,
  thumbnail_url text,
  -- Prefer Storage: store the storage path (e.g. videos/<uuid>.mp4) OR a direct URL if you host elsewhere
  storage_path text,
  video_url text,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  constraint videos_path_or_url_chk check (storage_path is not null or video_url is not null)
);

create index if not exists videos_published_created_idx
  on public.videos (is_published, created_at desc);

-- -----------------------------------------------------------------------------
-- Scheduling tables
-- -----------------------------------------------------------------------------

create table if not exists public.doctor_availability_windows (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.users(id) on delete restrict,
  day_of_week smallint not null,
  start_time time not null,
  end_time time not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint doctor_availability_dow_chk check (day_of_week between 0 and 6),
  constraint doctor_availability_time_order_chk check (end_time > start_time)
);

create index if not exists doctor_availability_doctor_dow_idx
  on public.doctor_availability_windows (doctor_id, day_of_week, is_active);

drop trigger if exists doctor_availability_set_updated_at on public.doctor_availability_windows;
create trigger doctor_availability_set_updated_at
before update on public.doctor_availability_windows
for each row execute function public.set_updated_at();

create table if not exists public.doctor_time_off (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.users(id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint doctor_time_off_time_order_chk check (end_at > start_at)
);

create index if not exists doctor_time_off_doctor_start_idx
  on public.doctor_time_off (doctor_id, start_at desc);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'doctor_time_off_no_overlap'
  ) then
    alter table public.doctor_time_off
      add constraint doctor_time_off_no_overlap
      exclude using gist (
        doctor_id with =,
        tstzrange(start_at, end_at, '[)') with &&
      );
  end if;
end $$;

drop trigger if exists doctor_time_off_set_updated_at on public.doctor_time_off;
create trigger doctor_time_off_set_updated_at
before update on public.doctor_time_off
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Slot generation (clinic timezone) + booking validation
-- -----------------------------------------------------------------------------

-- Generate available slots for next N days.
-- Note: returns timestamptz boundaries.
create or replace function public.get_available_slots(
  p_days_ahead int default null,
  p_doctor_id uuid default null
)
returns table (
  doctor_id uuid,
  slot_start_at timestamptz,
  slot_end_at timestamptz
)
language sql
stable
as $$
  with settings as (
    select
      public.get_clinic_timezone() as tz,
      public.get_slot_minutes() as slot_minutes,
      coalesce(p_days_ahead, (select max_booking_days_ahead from public.clinic_settings where id = true), 30) as days_ahead,
      (select min_booking_notice_minutes from public.clinic_settings where id = true) as min_notice,
      coalesce(p_doctor_id, public.get_doctor_id()) as doc_id
  ),
  clinic_today as (
    select
      (now() at time zone (select tz from settings))::date as today_clinic
  ),
  days as (
    select
      (select doc_id from settings) as doctor_id,
      (select tz from settings) as tz,
      (select slot_minutes from settings) as slot_minutes,
      (select min_notice from settings) as min_notice,
      d::date as clinic_date
    from clinic_today,
      generate_series(
        today_clinic,
        today_clinic + ((select days_ahead from settings) * interval '1 day'),
        interval '1 day'
      ) as d
    where (select doc_id from settings) is not null
  ),
  windows as (
    select
      d.doctor_id,
      d.tz,
      d.slot_minutes,
      d.min_notice,
      d.clinic_date,
      w.start_time,
      w.end_time
    from days d
    join public.doctor_availability_windows w
      on w.doctor_id = d.doctor_id
     and w.is_active = true
     and w.day_of_week = extract(dow from d.clinic_date)::int
  ),
  window_bounds as (
    select
      doctor_id,
      tz,
      slot_minutes,
      min_notice,
      -- create timestamptz in clinic timezone for this date+time
      make_timestamptz(
        extract(year from clinic_date)::int,
        extract(month from clinic_date)::int,
        extract(day from clinic_date)::int,
        extract(hour from start_time)::int,
        extract(minute from start_time)::int,
        extract(second from start_time)::int,
        tz
      ) as window_start_at,
      make_timestamptz(
        extract(year from clinic_date)::int,
        extract(month from clinic_date)::int,
        extract(day from clinic_date)::int,
        extract(hour from end_time)::int,
        extract(minute from end_time)::int,
        extract(second from end_time)::int,
        tz
      ) as window_end_at
    from windows
  ),
  slots as (
    select
      wb.doctor_id,
      s as slot_start_at,
      s + (wb.slot_minutes || ' minutes')::interval as slot_end_at,
      wb.min_notice
    from window_bounds wb,
      generate_series(
        wb.window_start_at,
        wb.window_end_at - (wb.slot_minutes || ' minutes')::interval,
        (wb.slot_minutes || ' minutes')::interval
      ) as s
  ),
  slots_filtered as (
    select
      doctor_id,
      slot_start_at,
      slot_end_at
    from slots
    where slot_start_at >= (now() + (min_notice || ' minutes')::interval)
  ),
  no_time_off as (
    select sf.*
    from slots_filtered sf
    left join public.doctor_time_off t
      on t.doctor_id = sf.doctor_id
     and tstzrange(t.start_at, t.end_at, '[)') && tstzrange(sf.slot_start_at, sf.slot_end_at, '[)')
    where t.id is null
  ),
  no_appt_conflicts as (
    select nt.*
    from no_time_off nt
    left join public.appointments a
      on a.doctor_id = nt.doctor_id
     and a.status in ('pending', 'confirmed')
     and tstzrange(a.start_at, a.end_at, '[)') && tstzrange(nt.slot_start_at, nt.slot_end_at, '[)')
    where a.id is null
  )
  select * from no_appt_conflicts
  order by slot_start_at;
$$;

-- Validate that an appointment matches a currently-available slot (duration + availability + conflicts).
create or replace function public.validate_appointment_slot()
returns trigger
language plpgsql
as $$
declare
  v_slot_minutes int;
  v_tz text;
  v_start_local timestamp;
  v_end_local timestamp;
  v_expected_end timestamptz;
  v_doctor_id uuid;
  v_exists boolean;
begin
  v_slot_minutes := public.get_slot_minutes();
  v_tz := public.get_clinic_timezone();
  v_doctor_id := public.get_doctor_id();

  -- Ensure doctor_id matches the configured doctor (single-doctor app)
  if v_doctor_id is null then
    raise exception 'Doctor profile not configured yet';
  end if;
  if new.doctor_id <> v_doctor_id then
    raise exception 'Invalid doctor_id';
  end if;

  -- Must be exactly slot_minutes
  v_expected_end := new.start_at + (v_slot_minutes || ' minutes')::interval;
  if new.end_at <> v_expected_end then
    raise exception 'Appointment must be exactly % minutes', v_slot_minutes;
  end if;

  -- Enforce alignment to slot boundary in clinic timezone
  v_start_local := (new.start_at at time zone v_tz);
  v_end_local := (new.end_at at time zone v_tz);
  if extract(second from v_start_local) <> 0 or extract(second from v_end_local) <> 0 then
    raise exception 'Appointment must be aligned to minute boundary';
  end if;
  if (extract(minute from v_start_local)::int % v_slot_minutes) <> 0 then
    raise exception 'Appointment start must align to % minute slots', v_slot_minutes;
  end if;

  -- Must exist in available slots at time of booking
  select exists (
    select 1
    from public.get_available_slots(null, new.doctor_id) s
    where s.slot_start_at = new.start_at
      and s.slot_end_at = new.end_at
  ) into v_exists;

  if not v_exists then
    raise exception 'Selected slot is not available';
  end if;

  return new;
end;
$$;

drop trigger if exists appointments_validate_slot on public.appointments;
create trigger appointments_validate_slot
before insert on public.appointments
for each row execute function public.validate_appointment_slot();

-- Prevent patients from modifying appointment times/doctor once created (they may only cancel).
create or replace function public.prevent_patient_appointment_edit()
returns trigger
language plpgsql
as $$
begin
  if auth.uid() is null then
    return new;
  end if;

  -- If the current user is the patient (and not the doctor), restrict updates to cancellation only.
  if old.patient_id = auth.uid() and not public.is_current_user_doctor() then
    if new.patient_id <> old.patient_id
      or new.doctor_id <> old.doctor_id
      or new.start_at <> old.start_at
      or new.end_at <> old.end_at
      or new.patient_note is distinct from old.patient_note
      or new.doctor_note is distinct from old.doctor_note
    then
      raise exception 'Patients cannot edit appointment details; only cancellation is allowed';
    end if;

    if new.status <> 'cancelled' then
      raise exception 'Patients can only cancel appointments';
    end if;

    return new;
  end if;

  return new;
end;
$$;

drop trigger if exists appointments_prevent_patient_edit on public.appointments;
create trigger appointments_prevent_patient_edit
before update on public.appointments
for each row execute function public.prevent_patient_appointment_edit();

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------

alter table public.users enable row level security;
alter table public.appointments enable row level security;
alter table public.videos enable row level security;
alter table public.doctor_availability_windows enable row level security;
alter table public.doctor_time_off enable row level security;
alter table public.clinic_settings enable row level security;

-- USERS
drop policy if exists users_select_own_or_doctor on public.users;
create policy users_select_own_or_doctor
on public.users
for select
to authenticated
using (id = auth.uid() or public.is_current_user_doctor());

drop policy if exists users_update_own on public.users;
create policy users_update_own
on public.users
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- APPOINTMENTS
drop policy if exists appointments_select_patient_or_doctor on public.appointments;
create policy appointments_select_patient_or_doctor
on public.appointments
for select
to authenticated
using (
  patient_id = auth.uid()
  or (public.is_current_user_doctor() and doctor_id = auth.uid())
);

-- Patient can create pending appointment for self (slot validation trigger runs too)
drop policy if exists appointments_insert_patient_pending on public.appointments;
create policy appointments_insert_patient_pending
on public.appointments
for insert
to authenticated
with check (
  patient_id = auth.uid()
  and status = 'pending'
  and doctor_id = public.get_doctor_id()
);

-- Patient can cancel own pending/confirmed appointments
drop policy if exists appointments_update_patient_cancel on public.appointments;
create policy appointments_update_patient_cancel
on public.appointments
for update
to authenticated
using (patient_id = auth.uid() and status in ('pending', 'confirmed'))
with check (
  patient_id = auth.uid()
  and status = 'cancelled'
);

-- Doctor can update appointments (approve/decline/cancel/complete)
drop policy if exists appointments_update_doctor on public.appointments;
create policy appointments_update_doctor
on public.appointments
for update
to authenticated
using (public.is_current_user_doctor() and doctor_id = auth.uid())
with check (public.is_current_user_doctor() and doctor_id = auth.uid());

-- VIDEOS
drop policy if exists videos_select_published_authenticated on public.videos;
create policy videos_select_published_authenticated
on public.videos
for select
to authenticated
using (is_published = true);

drop policy if exists videos_insert_doctor_only on public.videos;
create policy videos_insert_doctor_only
on public.videos
for insert
to authenticated
with check (public.is_current_user_doctor() and uploaded_by = auth.uid());

drop policy if exists videos_update_doctor_only on public.videos;
create policy videos_update_doctor_only
on public.videos
for update
to authenticated
using (public.is_current_user_doctor() and uploaded_by = auth.uid())
with check (public.is_current_user_doctor() and uploaded_by = auth.uid());

drop policy if exists videos_delete_doctor_only on public.videos;
create policy videos_delete_doctor_only
on public.videos
for delete
to authenticated
using (public.is_current_user_doctor() and uploaded_by = auth.uid());

-- AVAILABILITY WINDOWS (read all for booking UI; write only doctor)
drop policy if exists doctor_availability_select_authenticated on public.doctor_availability_windows;
create policy doctor_availability_select_authenticated
on public.doctor_availability_windows
for select
to authenticated
using (true);

drop policy if exists doctor_availability_write_doctor_only on public.doctor_availability_windows;
create policy doctor_availability_write_doctor_only
on public.doctor_availability_windows
for all
to authenticated
using (public.is_current_user_doctor() and doctor_id = auth.uid())
with check (public.is_current_user_doctor() and doctor_id = auth.uid());

-- TIME OFF (read all for booking UI; write only doctor)
drop policy if exists doctor_time_off_select_authenticated on public.doctor_time_off;
create policy doctor_time_off_select_authenticated
on public.doctor_time_off
for select
to authenticated
using (true);

drop policy if exists doctor_time_off_write_doctor_only on public.doctor_time_off;
create policy doctor_time_off_write_doctor_only
on public.doctor_time_off
for all
to authenticated
using (public.is_current_user_doctor() and doctor_id = auth.uid())
with check (public.is_current_user_doctor() and doctor_id = auth.uid());

-- CLINIC SETTINGS (read all authenticated; write only doctor)
drop policy if exists clinic_settings_select_authenticated on public.clinic_settings;
create policy clinic_settings_select_authenticated
on public.clinic_settings
for select
to authenticated
using (true);

drop policy if exists clinic_settings_update_doctor_only on public.clinic_settings;
create policy clinic_settings_update_doctor_only
on public.clinic_settings
for update
to authenticated
using (public.is_current_user_doctor())
with check (public.is_current_user_doctor());

-- Ensure clients can call the slot function
grant execute on function public.get_available_slots(int, uuid) to authenticated;

-- -----------------------------------------------------------------------------
-- Optional: Supabase Storage bucket + policies for video assets
-- -----------------------------------------------------------------------------
-- NOTE: These statements require privileges; on Supabase they typically work via SQL editor/service role.
-- If you prefer fully DB-only (no storage), ignore this section.

-- Create a private bucket named 'videos' (read via policy below)
insert into storage.buckets (id, name, public)
values ('videos', 'videos', false)
on conflict (id) do nothing;

-- Read: authenticated users can read from videos bucket
drop policy if exists "Videos bucket read (authenticated)" on storage.objects;
create policy "Videos bucket read (authenticated)"
on storage.objects
for select
to authenticated
using (bucket_id = 'videos');

-- Write: doctor only
drop policy if exists "Videos bucket write (doctor only)" on storage.objects;
create policy "Videos bucket write (doctor only)"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'videos' and public.is_current_user_doctor());

drop policy if exists "Videos bucket update (doctor only)" on storage.objects;
create policy "Videos bucket update (doctor only)"
on storage.objects
for update
to authenticated
using (bucket_id = 'videos' and public.is_current_user_doctor())
with check (bucket_id = 'videos' and public.is_current_user_doctor());

drop policy if exists "Videos bucket delete (doctor only)" on storage.objects;
create policy "Videos bucket delete (doctor only)"
on storage.objects
for delete
to authenticated
using (bucket_id = 'videos' and public.is_current_user_doctor());

commit;


