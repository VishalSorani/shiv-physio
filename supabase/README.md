# Supabase (Database)

This folder contains SQL migrations for the Shiv Physio App (single-doctor physiotherapy clinic).

## Apply migrations

You can apply [`supabase/migrations/202512270001_init.sql`](migrations/202512270001_init.sql) using either:

- Supabase Dashboard → **SQL Editor** (run the file contents), or
- Supabase CLI: `supabase db push` (if you have a local Supabase project initialized)

## What the migration includes

- `users` linked to `auth.users` (Google sign-in)
- Single doctor enforced via `users.is_doctor`
- `appointments` with pending approval flow + no overlap constraint
- Doctor-managed availability windows + time off
- Slot generation function `public.get_available_slots(...)`
- Appointment slot validation trigger (ensures bookings match an available slot)
- RLS policies for all tables
- Optional Supabase Storage bucket + policies for videos (`videos` bucket)

## Bootstrap the doctor

To set the single doctor, update exactly one profile row (run via **service role / SQL editor**):

```sql
update public.users
set is_doctor = true
where id = '<doctor-auth-user-uuid>';
```

Because of a partial unique index, only one row can have `is_doctor = true`.



