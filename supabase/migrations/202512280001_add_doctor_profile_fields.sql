-- Add additional doctor profile fields to users table
-- These fields are specific to doctor profiles

begin;

-- Add new columns to users table for doctor profile details
alter table public.users
  add column if not exists title text,
  add column if not exists qualifications text,
  add column if not exists specializations text,
  add column if not exists years_of_experience int,
  add column if not exists clinic_name text,
  add column if not exists clinic_address text,
  add column if not exists consultation_fee int;

-- Add comments for documentation
comment on column public.users.title is 'Doctor professional title (e.g., Physiotherapist)';
comment on column public.users.qualifications is 'Doctor qualifications (e.g., BPT, MPT)';
comment on column public.users.specializations is 'Doctor specializations (comma-separated)';
comment on column public.users.years_of_experience is 'Years of professional experience';
comment on column public.users.clinic_name is 'Name of the clinic/practice';
comment on column public.users.clinic_address is 'Full address of the clinic';
comment on column public.users.consultation_fee is 'Standard consultation fee in currency units';

commit;

