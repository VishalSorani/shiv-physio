-- Firebase UID auth (Plan B1)
-- Convert `public.users.id` to TEXT and allow anon reads/writes (no Supabase Auth).
-- WARNING: This is NOT secure for production. Use only for early development.

begin;

-- Extensions (needed for exclusion constraints if not already present)
create extension if not exists btree_gist;

-- -----------------------------------------------------------------------------
-- 1) Make `public.users.id` a TEXT (firebase uid) and remove Supabase Auth FK
-- -----------------------------------------------------------------------------

-- Drop dependent view first (it depends on users.id type via its underlying rule)
drop view if exists public.profiles;

-- Drop FK to auth.users (firebase auth does not populate auth.users)
do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'users_id_fkey'
  ) then
    alter table public.users drop constraint users_id_fkey;
  end if;
exception when undefined_table then
  -- ignore if table doesn't exist yet
end $$;

-- Change type: uuid -> text
do $$
begin
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
exception when undefined_table then
end $$;

-- Recreate compatibility view
create or replace view public.profiles as
select * from public.users;

-- -----------------------------------------------------------------------------
-- 2) Update all FKs that reference public.users(id) to TEXT too
-- -----------------------------------------------------------------------------

-- Appointments
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='appointments') then
    -- Drop FKs first (names are deterministic but vary; drop by introspection)
    if exists (select 1 from pg_constraint where conrelid = 'public.appointments'::regclass and contype='f' and conname='appointments_patient_id_fkey') then
      alter table public.appointments drop constraint appointments_patient_id_fkey;
    end if;
    if exists (select 1 from pg_constraint where conrelid = 'public.appointments'::regclass and contype='f' and conname='appointments_doctor_id_fkey') then
      alter table public.appointments drop constraint appointments_doctor_id_fkey;
    end if;
    if exists (select 1 from pg_constraint where conrelid = 'public.appointments'::regclass and contype='f' and conname='appointments_cancelled_by_fkey') then
      alter table public.appointments drop constraint appointments_cancelled_by_fkey;
    end if;

    -- Change types
    alter table public.appointments
      alter column patient_id type text using patient_id::text,
      alter column doctor_id type text using doctor_id::text,
      alter column cancelled_by type text using cancelled_by::text;

    -- Re-add FKs
    alter table public.appointments
      add constraint appointments_patient_id_fkey foreign key (patient_id) references public.users(id) on delete restrict,
      add constraint appointments_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict,
      add constraint appointments_cancelled_by_fkey foreign key (cancelled_by) references public.users(id);
  end if;
end $$;

-- Videos
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='videos') then
    if exists (select 1 from pg_constraint where conrelid = 'public.videos'::regclass and contype='f' and conname='videos_uploaded_by_fkey') then
      alter table public.videos drop constraint videos_uploaded_by_fkey;
    end if;
    alter table public.videos
      alter column uploaded_by type text using uploaded_by::text;
    alter table public.videos
      add constraint videos_uploaded_by_fkey foreign key (uploaded_by) references public.users(id) on delete restrict;
  end if;
end $$;

-- Availability windows
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='doctor_availability_windows') then
    if exists (select 1 from pg_constraint where conrelid = 'public.doctor_availability_windows'::regclass and contype='f' and conname='doctor_availability_windows_doctor_id_fkey') then
      alter table public.doctor_availability_windows drop constraint doctor_availability_windows_doctor_id_fkey;
    end if;
    alter table public.doctor_availability_windows
      alter column doctor_id type text using doctor_id::text;
    alter table public.doctor_availability_windows
      add constraint doctor_availability_windows_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict;
  end if;
end $$;

-- Time off
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='doctor_time_off') then
    if exists (select 1 from pg_constraint where conrelid = 'public.doctor_time_off'::regclass and contype='f' and conname='doctor_time_off_doctor_id_fkey') then
      alter table public.doctor_time_off drop constraint doctor_time_off_doctor_id_fkey;
    end if;
    alter table public.doctor_time_off
      alter column doctor_id type text using doctor_id::text;
    alter table public.doctor_time_off
      add constraint doctor_time_off_doctor_id_fkey foreign key (doctor_id) references public.users(id) on delete restrict;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- 3) Update helper SQL functions that previously returned/accepted uuid doctor ids
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
  -- With Firebase-only auth, auth.uid() is NULL, so this function is not meaningful.
  -- Kept for compatibility; always returns false.
  select false;
$$;

-- -----------------------------------------------------------------------------
-- 4) Harden is_doctor changes even for anon (prevent clients from toggling)
-- -----------------------------------------------------------------------------

create or replace function public.prevent_is_doctor_change()
returns trigger
language plpgsql
as $$
begin
  -- In Plan B1, clients typically run as role "anon". Prevent changing is_doctor
  -- for any non-privileged DB role.
  if (new.is_doctor is distinct from old.is_doctor)
     and current_user not in ('postgres', 'service_role') then
    raise exception 'is_doctor cannot be changed from client';
  end if;
  return new;
end;
$$;

-- Recreate trigger just in case
drop trigger if exists users_prevent_is_doctor_change on public.users;
create trigger users_prevent_is_doctor_change
before update of is_doctor on public.users
for each row execute function public.prevent_is_doctor_change();

-- -----------------------------------------------------------------------------
-- 5) B1 Access: disable RLS on users and grant anon read/write
-- -----------------------------------------------------------------------------

alter table public.users disable row level security;

grant select, insert, update on table public.users to anon, authenticated;

commit;


