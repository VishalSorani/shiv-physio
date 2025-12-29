-- Create treatment_plans table
-- Stores treatment plans created by doctors for patients

begin;

create table if not exists public.treatment_plans (
  id uuid primary key default gen_random_uuid(),
  patient_id text not null references public.users(id) on delete cascade,
  doctor_id text not null references public.users(id) on delete restrict,
  diagnosis text, -- Medical diagnosis/condition
  medical_conditions text[], -- Array of medical conditions
  treatment_goals text, -- Treatment objectives/goals
  treatment_plan text not null, -- Detailed treatment plan (exercises, therapies, etc.)
  duration_weeks int, -- Expected duration in weeks
  frequency_per_week int, -- Number of sessions per week
  notes text, -- Additional notes/observations
  status text not null default 'active', -- active, completed, paused, cancelled
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for faster lookups
create index if not exists treatment_plans_patient_id_idx on public.treatment_plans (patient_id);
create index if not exists treatment_plans_doctor_id_idx on public.treatment_plans (doctor_id);
create index if not exists treatment_plans_status_idx on public.treatment_plans (status);
create index if not exists treatment_plans_created_at_idx on public.treatment_plans (created_at desc);

-- Trigger to update updated_at
drop trigger if exists treatment_plans_set_updated_at on public.treatment_plans;
create trigger treatment_plans_set_updated_at
before update on public.treatment_plans
for each row execute function public.set_updated_at();

-- Enable Row Level Security (RLS)
alter table public.treatment_plans enable row level security;

-- Policies for RLS
-- Doctors can view all treatment plans
create policy "Doctors can view all treatment plans" on public.treatment_plans
  for select using (
    exists (
      select 1 from public.users
      where id = (select id from public.users where is_doctor = true limit 1)
    )
  );

-- Doctors can insert treatment plans
create policy "Doctors can insert treatment plans" on public.treatment_plans
  for insert with check (
    exists (
      select 1 from public.users
      where id = (select id from public.users where is_doctor = true limit 1)
    )
  );

-- Doctors can update treatment plans
create policy "Doctors can update treatment plans" on public.treatment_plans
  for update using (
    exists (
      select 1 from public.users
      where id = (select id from public.users where is_doctor = true limit 1)
    )
  );

-- Doctors can delete treatment plans
create policy "Doctors can delete treatment plans" on public.treatment_plans
  for delete using (
    exists (
      select 1 from public.users
      where id = (select id from public.users where is_doctor = true limit 1)
    )
  );

comment on table public.treatment_plans is 'Stores treatment plans created by doctors for patients';
comment on column public.treatment_plans.diagnosis is 'Medical diagnosis or condition';
comment on column public.treatment_plans.medical_conditions is 'Array of medical conditions';
comment on column public.treatment_plans.treatment_goals is 'Treatment objectives and goals';
comment on column public.treatment_plans.treatment_plan is 'Detailed treatment plan including exercises, therapies, etc.';
comment on column public.treatment_plans.duration_weeks is 'Expected duration of treatment in weeks';
comment on column public.treatment_plans.frequency_per_week is 'Number of treatment sessions per week';
comment on column public.treatment_plans.notes is 'Additional notes and observations';
comment on column public.treatment_plans.status is 'Status of the treatment plan: active, completed, paused, cancelled';

commit;

