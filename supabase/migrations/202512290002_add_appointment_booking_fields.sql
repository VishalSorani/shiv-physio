-- Add booking details fields to appointments table
-- These fields store information about who the appointment is for and the reason

begin;

-- Add new columns to appointments table
alter table public.appointments
  add column if not exists booked_for text default 'self',
  add column if not exists other_person_name text,
  add column if not exists other_person_phone text,
  add column if not exists other_person_age int,
  add column if not exists reason text;

-- Add constraint to ensure booked_for is one of the valid values
alter table public.appointments
  add constraint appointments_booked_for_check 
  check (booked_for is null or booked_for in ('self', 'other'));

-- Add comments for documentation
comment on column public.appointments.booked_for is 'Who the appointment is for: self or other';
comment on column public.appointments.other_person_name is 'Name of the person if booking for someone else';
comment on column public.appointments.other_person_phone is 'Phone number of the person if booking for someone else';
comment on column public.appointments.other_person_age is 'Age of the person if booking for someone else';
comment on column public.appointments.reason is 'Reason for the appointment';

commit;

