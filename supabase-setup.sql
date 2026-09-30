-- TheMazterDesing portfolio: database, Row Level Security and public thumbnail bucket.
-- Run this file in Supabase SQL Editor before connecting the site.

create table if not exists public.portfolio_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_portfolio_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.portfolio_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_portfolio_admin() from public;
grant execute on function public.is_portfolio_admin() to anon, authenticated;

create table if not exists public.portfolio_works (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 100),
  category text not null check (char_length(category) between 1 and 40),
  image_path text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.portfolio_creators (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  url text not null default '',
  created_at timestamptz not null default now()
);

alter table public.portfolio_admins enable row level security;
alter table public.portfolio_works enable row level security;
alter table public.portfolio_creators enable row level security;

drop policy if exists "portfolio admins can read own row" on public.portfolio_admins;
create policy "portfolio admins can read own row"
  on public.portfolio_admins for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "works are publicly readable" on public.portfolio_works;
create policy "works are publicly readable"
  on public.portfolio_works for select to anon, authenticated using (true);
drop policy if exists "admins insert works" on public.portfolio_works;
create policy "admins insert works"
  on public.portfolio_works for insert to authenticated
  with check ((select public.is_portfolio_admin()));
drop policy if exists "admins update works" on public.portfolio_works;
create policy "admins update works"
  on public.portfolio_works for update to authenticated
  using ((select public.is_portfolio_admin()))
  with check ((select public.is_portfolio_admin()));
drop policy if exists "admins delete works" on public.portfolio_works;
create policy "admins delete works"
  on public.portfolio_works for delete to authenticated
  using ((select public.is_portfolio_admin()));

drop policy if exists "creators are publicly readable" on public.portfolio_creators;
create policy "creators are publicly readable"
  on public.portfolio_creators for select to anon, authenticated using (true);
drop policy if exists "admins insert creators" on public.portfolio_creators;
create policy "admins insert creators"
  on public.portfolio_creators for insert to authenticated
  with check ((select public.is_portfolio_admin()));
drop policy if exists "admins update creators" on public.portfolio_creators;
create policy "admins update creators"
  on public.portfolio_creators for update to authenticated
  using ((select public.is_portfolio_admin()))
  with check ((select public.is_portfolio_admin()));
drop policy if exists "admins delete creators" on public.portfolio_creators;
create policy "admins delete creators"
  on public.portfolio_creators for delete to authenticated
  using ((select public.is_portfolio_admin()));

grant select on public.portfolio_works, public.portfolio_creators to anon, authenticated;
grant select, insert, update, delete on public.portfolio_works, public.portfolio_creators to authenticated;
grant select on public.portfolio_admins to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('portfolio-thumbnails', 'portfolio-thumbnails', true, 10485760, array['image/jpeg'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "thumbnails are publicly readable" on storage.objects;
create policy "thumbnails are publicly readable"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'portfolio-thumbnails');
drop policy if exists "admins upload thumbnails" on storage.objects;
create policy "admins upload thumbnails"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'portfolio-thumbnails' and (select public.is_portfolio_admin()));
drop policy if exists "admins update thumbnails" on storage.objects;
create policy "admins update thumbnails"
  on storage.objects for update to authenticated
  using (bucket_id = 'portfolio-thumbnails' and (select public.is_portfolio_admin()))
  with check (bucket_id = 'portfolio-thumbnails' and (select public.is_portfolio_admin()));
drop policy if exists "admins delete thumbnails" on storage.objects;
create policy "admins delete thumbnails"
  on storage.objects for delete to authenticated
  using (bucket_id = 'portfolio-thumbnails' and (select public.is_portfolio_admin()));

-- After creating the admin user in Supabase Auth > Users, add their UUID here:
-- insert into public.portfolio_admins (user_id) values ('PASTE_AUTH_USER_UUID_HERE');
