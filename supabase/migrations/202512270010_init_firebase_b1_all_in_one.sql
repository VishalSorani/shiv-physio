-- Shiv Physio App - Firebase Auth (Plan B1) - ALL IN ONE schema
--
-- What this schema does:
-- - Uses Firebase UID as `public.users.id` (TEXT primary key)
-- - Removes any dependency on `auth.users` (Supabase Auth)
-- - Disables RLS and grants anon full access (Plan B1 / development only)
-- - Keeps scheduling logic, slot generation, and overlap constraints
--
-- WARNING:
-- Plan B1 is NOT production-safe. Anyone with anon key can read/write tables.
-- Use only for early development.

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

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Prevent changing is_doctor via normal client writes (Plan B1).
create or replace function public.prevent_is_doctor_change()
returns trigger
language plpgsql
as $$
begin
  if (new.is_doctor is distinct from old.is_doctor)
     and current_user not in ('postgres', 'service_role') then
    raise exception 'is_doctor cannot be changed from client';
  end if;
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

-- -----------------------------------------------------------------------------
-- Core tables
-- -----------------------------------------------------------------------------

-- Users table (Firebase UID as text primary key)
create table if not exists public.users (
  id text primary key, -- Firebase UID
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

-- Backwards-compatible view (optional)
create or replace view public.profiles as
select * from public.users;

-- Get the single doctor id (Firebase UID string). Returns NULL if not yet set.
create or replace function public.get_doctor_id()
returns text
language sql
stable
as $$
  select u.id
  from public.users u
  where u.is_doctor = true
  limit 1;
$$;

-- Supabase Auth is not used in Plan B1; keep for compatibility.
create or replace function public.is_current_user_doctor()
returns boolean
language sql
stable
as $$
  select false;
$$;

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references public.users(id) on delete restrict,
  doctor_id text not null references public.users(id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status public.appointment_status not null default 'pending',
  patient_note text,
  doctor_note text,
  cancelled_by text references public.users(id),
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
  uploaded_by text not null references public.users(id) on delete restrict,
  title text not null,
  description text,
  category text,
  thumbnail_url text,
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
  doctor_id text not null references public.users(id) on delete restrict,
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
  doctor_id text not null references public.users(id) on delete restrict,
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

create or replace function public.get_available_slots(
  p_days_ahead int default null,
  p_doctor_id text default null
)
returns table (
  doctor_id text,
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
  v_doctor_id text;
  v_exists boolean;
begin
  v_slot_minutes := public.get_slot_minutes();
  v_tz := public.get_clinic_timezone();
  v_doctor_id := public.get_doctor_id();

  if v_doctor_id is null then
    raise exception 'Doctor profile not configured yet';
  end if;
  if new.doctor_id <> v_doctor_id then
    raise exception 'Invalid doctor_id';
  end if;

  v_expected_end := new.start_at + (v_slot_minutes || ' minutes')::interval;
  if new.end_at <> v_expected_end then
    raise exception 'Appointment must be exactly % minutes', v_slot_minutes;
  end if;

  v_start_local := (new.start_at at time zone v_tz);
  v_end_local := (new.end_at at time zone v_tz);
  if extract(second from v_start_local) <> 0 or extract(second from v_end_local) <> 0 then
    raise exception 'Appointment must be aligned to minute boundary';
  end if;
  if (extract(minute from v_start_local)::int % v_slot_minutes) <> 0 then
    raise exception 'Appointment start must align to % minute slots', v_slot_minutes;
  end if;

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

-- -----------------------------------------------------------------------------
-- Plan B1 access model: disable RLS everywhere + grant anon full access
-- -----------------------------------------------------------------------------

alter table public.users disable row level security;
alter table public.appointments disable row level security;
alter table public.videos disable row level security;
alter table public.doctor_availability_windows disable row level security;
alter table public.doctor_time_off disable row level security;
alter table public.clinic_settings disable row level security;

grant select, insert, update, delete on table public.users to anon, authenticated;
grant select, insert, update, delete on table public.appointments to anon, authenticated;
grant select, insert, update, delete on table public.videos to anon, authenticated;
grant select, insert, update, delete on table public.doctor_availability_windows to anon, authenticated;
grant select, insert, update, delete on table public.doctor_time_off to anon, authenticated;
grant select, insert, update, delete on table public.clinic_settings to anon, authenticated;

grant execute on function public.get_available_slots(int, text) to anon, authenticated;
grant execute on function public.get_doctor_id() to anon, authenticated;
grant execute on function public.get_clinic_timezone() to anon, authenticated;
grant execute on function public.get_slot_minutes() to anon, authenticated;

commit;


