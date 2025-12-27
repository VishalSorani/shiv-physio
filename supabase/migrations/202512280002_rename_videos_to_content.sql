-- Rename videos table to content and add type column
begin;

-- Rename the table
alter table if exists public.videos rename to content;

-- Add type column to distinguish between video and image
alter table if exists public.content
  add column if not exists type text default 'video' check (type in ('video', 'image'));

-- Update existing records: if storage_path exists and video_url is null, it's likely an image
-- Otherwise default to video
update public.content
set type = case
  when video_url is null and storage_path is not null then 'image'
  else 'video'
end
where type is null or type = 'video';

-- Update constraint name if it exists
do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'videos_path_or_url_chk'
  ) then
    alter table public.content
      drop constraint if exists videos_path_or_url_chk;
    
    alter table public.content
      add constraint content_path_or_url_chk
      check (storage_path is not null or video_url is not null);
  end if;
end $$;

-- Rename index if it exists
do $$
begin
  if exists (
    select 1 from pg_indexes
    where indexname = 'videos_published_created_idx'
  ) then
    alter index if exists public.videos_published_created_idx
      rename to content_published_created_idx;
  end if;
end $$;

-- Rename foreign key constraint if it exists
do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'videos_uploaded_by_fkey'
  ) then
    alter table public.content
      drop constraint if exists videos_uploaded_by_fkey;
    
    alter table public.content
      add constraint content_uploaded_by_fkey
      foreign key (uploaded_by) references public.users(id) on delete restrict;
  end if;
end $$;

commit;

