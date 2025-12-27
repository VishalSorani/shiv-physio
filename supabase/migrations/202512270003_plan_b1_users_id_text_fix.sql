-- Plan B1 (Firebase UID in public.users.id) - Fix migration
-- Purpose: Provide a clean, re-runnable migration that avoids the `profiles` view dependency
-- and safely converts UUID user ids to TEXT across referencing tables.
--
-- WARNING (B1): This disables RLS on `public.users` and grants anon read/write.
-- This is NOT production-safe. Use only for early development.

begin;

-- -----------------------------------------------------------------------------
-- 0) Drop dependent view first (blocks users.id type change)
-- -----------------------------------------------------------------------------
drop view if exists public.profiles;

-- -----------------------------------------------------------------------------
-- 1) Remove FK to auth.users and convert public.users.id to TEXT (firebase uid)
-- -----------------------------------------------------------------------------

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'users'
      and column_name = 'id'
  ) then
    -- Drop FK to auth.users if it exists
    if exists (
      select 1
      from pg_constraint
      where conrelid = 'public.users'::regclass
        and contype = 'f'
        and conname = 'users_id_fkey'
    ) then
      alter table public.users drop constraint users_id_fkey;
    end if;

    -- Convert id to text if not already text
    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'users'
        and column_name = 'id'
        and data_type <> 'text'
    ) then
      alter table public.users
        alter column id type text using id::text;
    end if;
  end if;
exception when undefined_table then
  -- ignore
end $$;

-- Recreate compatibility view
create or replace view public.profiles as
select * from public.users;

-- -----------------------------------------------------------------------------
-- 2) Update all referencing columns (uuid -> text) + re-add FKs
-- -----------------------------------------------------------------------------

-- Appointments
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='appointments') then
    -- Drop FKs if present
    if exists (select 1 from pg_constraint where conrelid='public.appointments'::regclass and contype='f' and conname='appointments_patient_id_fkey') then
      alter table public.appointments drop constraint appointments_patient_id_fkey;
    end if;
    if exists (select 1 from pg_constraint where conrelid='public.appointments'::regclass and contype='f' and conname='appointments_doctor_id_fkey') then
      alter table public.appointments drop constraint appointments_doctor_id_fkey;
    end if;
    if exists (select 1 from pg_constraint where conrelid='public.appointments'::regclass and contype='f' and conname='appointments_cancelled_by_fkey') then
      alter table public.appointments drop constraint appointments_cancelled_by_fkey;
    end if;

    -- Alter types if needed
    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='appointments' and column_name='patient_id' and data_type <> 'text'
    ) then
      alter table public.appointments alter column patient_id type text using patient_id::text;
    end if;
    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='appointments' and column_name='doctor_id' and data_type <> 'text'
    ) then
      alter table public.appointments alter column doctor_id type text using doctor_id::text;
    end if;
    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='appointments' and column_name='cancelled_by' and data_type <> 'text'
    ) then
      alter table public.appointments alter column cancelled_by type text using cancelled_by::text;
    end if;

    -- Re-add FKs (idempotent: drop above)
    alter table public.appointments
      add constraint appointments_patient_id_fkey foreign key (patient_id) references public.users(id) on delete restrict;
    alter table public.appointments
      add constraint appointments_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict;
    alter table public.appointments
      add constraint appointments_cancelled_by_fkey foreign key (cancelled_by) references public.users(id);
  end if;
exception when undefined_table then
end $$;

-- Videos
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='videos') then
    if exists (select 1 from pg_constraint where conrelid='public.videos'::regclass and contype='f' and conname='videos_uploaded_by_fkey') then
      alter table public.videos drop constraint videos_uploaded_by_fkey;
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='videos' and column_name='uploaded_by' and data_type <> 'text'
    ) then
      alter table public.videos alter column uploaded_by type text using uploaded_by::text;
    end if;

    alter table public.videos
      add constraint videos_uploaded_by_fkey foreign key (uploaded_by) references public.users(id) on delete restrict;
  end if;
exception when undefined_table then
end $$;

-- Availability windows
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='doctor_availability_windows') then
    if exists (select 1 from pg_constraint where conrelid='public.doctor_availability_windows'::regclass and contype='f' and conname='doctor_availability_windows_doctor_id_fkey') then
      alter table public.doctor_availability_windows drop constraint doctor_availability_windows_doctor_id_fkey;
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='doctor_availability_windows' and column_name='doctor_id' and data_type <> 'text'
    ) then
      alter table public.doctor_availability_windows alter column doctor_id type text using doctor_id::text;
    end if;

    alter table public.doctor_availability_windows
      add constraint doctor_availability_windows_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict;
  end if;
exception when undefined_table then
end $$;

-- Time off
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='doctor_time_off') then
    if exists (select 1 from pg_constraint where conrelid='public.doctor_time_off'::regclass and contype='f' and conname='doctor_time_off_doctor_id_fkey') then
      alter table public.doctor_time_off drop constraint doctor_time_off_doctor_id_fkey;
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='doctor_time_off' and column_name='doctor_id' and data_type <> 'text'
    ) then
      alter table public.doctor_time_off alter column doctor_id type text using doctor_id::text;
    end if;

    alter table public.doctor_time_off
      add constraint doctor_time_off_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict;
  end if;
exception when undefined_table then
end $$;

-- -----------------------------------------------------------------------------
-- 3) Update helper functions (doctor id type)
-- -----------------------------------------------------------------------------

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

create or replace function public.is_current_user_doctor()
returns boolean
language sql
stable
as $$
  -- Firebase-only auth (B1) has no Supabase auth.uid(), so always false here.
  select false;
$$;

-- -----------------------------------------------------------------------------
-- 4) Prevent changing is_doctor from anon clients
-- -----------------------------------------------------------------------------

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

drop trigger if exists users_prevent_is_doctor_change on public.users;
create trigger users_prevent_is_doctor_change
before update of is_doctor on public.users
for each row execute function public.prevent_is_doctor_change();

-- -----------------------------------------------------------------------------
-- 5) B1 access model: disable RLS on users and grant anon
-- -----------------------------------------------------------------------------

alter table public.users disable row level security;
grant select, insert, update on table public.users to anon, authenticated;

commit;


