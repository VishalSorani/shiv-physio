-- Create notifications table to store sent notifications
-- This table tracks all notifications sent via OneSignal

begin;

-- Create notifications table
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.users(id) on delete cascade,
  title text not null,
  message text not null,
  notification_type text not null, -- 'appointment_booked', 'appointment_cancelled', 'appointment_approved', 'appointment_rejected', etc.
  related_id text, -- ID of related entity (e.g., appointment_id)
  data jsonb, -- Additional notification data
  onesignal_id text, -- OneSignal player ID that received the notification
  sent_at timestamptz not null default now(),
  read_at timestamptz, -- When user read the notification
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Add indexes for faster queries
create index if not exists notifications_user_id_idx on public.notifications (user_id);
create index if not exists notifications_sent_at_idx on public.notifications (sent_at desc);
create index if not exists notifications_read_at_idx on public.notifications (read_at);
create index if not exists notifications_type_idx on public.notifications (notification_type);
create index if not exists notifications_related_id_idx on public.notifications (related_id);

-- Add comment for documentation
comment on table public.notifications is 'Stores all notifications sent to users via OneSignal';
comment on column public.notifications.notification_type is 'Type of notification: appointment_booked, appointment_cancelled, appointment_approved, appointment_rejected, etc.';
comment on column public.notifications.related_id is 'ID of related entity (e.g., appointment_id)';
comment on column public.notifications.data is 'Additional notification data in JSON format';
comment on column public.notifications.onesignal_id is 'OneSignal player ID that received the notification';

-- Add trigger to update updated_at
drop trigger if exists notifications_set_updated_at on public.notifications;
create trigger notifications_set_updated_at
before update on public.notifications
for each row execute function public.set_updated_at();

commit;

