-- Add onesignal_id column to users table
-- This column stores the OneSignal player ID for push notifications

begin;

-- Add onesignal_id column to users table
alter table public.users
  add column if not exists onesignal_id text;

-- Add index for faster lookups
create index if not exists users_onesignal_id_idx on public.users (onesignal_id);

-- Add comment for documentation
comment on column public.users.onesignal_id is 'OneSignal player ID for push notifications';

commit;

