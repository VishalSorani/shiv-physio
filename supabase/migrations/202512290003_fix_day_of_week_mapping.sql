-- Fix day_of_week mapping in get_available_slots function
-- Database convention: 0 = Monday, 1 = Tuesday, ..., 6 = Sunday
-- PostgreSQL extract(dow): 0 = Sunday, 1 = Monday, ..., 6 = Saturday
-- We need to map: DB day = (extract(dow) + 6) % 7

begin;

-- Update get_available_slots function (text version) to use correct day_of_week mapping
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
     -- Map PostgreSQL extract(dow) to database day_of_week convention
     -- PostgreSQL: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
     -- Database: 0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, 4=Friday, 5=Saturday, 6=Sunday
     -- Formula: (extract(dow) + 6) % 7 converts PostgreSQL to database convention
     and w.day_of_week = ((extract(dow from d.clinic_date)::int + 6) % 7)
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

-- Drop the uuid version to avoid function overloading conflicts
-- We only need the text version since doctor_id is stored as text
drop function if exists public.get_available_slots(int, uuid);

-- Add comment explaining the day_of_week mapping
comment on function public.get_available_slots(int, text) is 
  'Returns available appointment slots for a doctor. 
   Day of week mapping: Database uses 0=Monday, 1=Tuesday, ..., 6=Sunday.
   PostgreSQL extract(dow) returns 0=Sunday, 1=Monday, ..., 6=Saturday.
   The function maps using: (extract(dow) + 6) % 7';

commit;

