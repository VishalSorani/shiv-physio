-- Add gender and address fields to users table for patient profiles
-- These fields are used by patient users to complete their profile

begin;

-- Add new columns to users table for patient profile details
alter table public.users
  add column if not exists gender text,
  add column if not exists address text;

-- Add comments for documentation
comment on column public.users.gender is 'User gender (male, female, other)';
comment on column public.users.address is 'User home address';

-- Add constraint to ensure gender is one of the valid values
alter table public.users
  add constraint users_gender_check 
  check (gender is null or gender in ('male', 'female', 'other'));

commit;

