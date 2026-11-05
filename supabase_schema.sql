-- =====================================================================
-- Erth Project - Supabase / PostgreSQL schema
-- Run in the Supabase SQL editor (or as a migration).
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------

create table public.profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  role            text not null check (role in ('tourist', 'expert')),
  full_name       text,
  professional_id text
);

create table public.artifacts (
  id          uuid primary key default gen_random_uuid(),
  name_ar     text not null,
  name_en     text not null,
  story_ar    text,
  video_url   text,
  qr_code_ref text not null unique
);

create table public.restoration_logs (
  id                 uuid primary key default gen_random_uuid(),
  artifact_id        uuid not null references public.artifacts (id) on delete cascade,
  expert_id          uuid not null references public.profiles (id),
  chemical_materials text,
  technical_report   text,
  created_at         timestamptz not null default now()
);

create index restoration_logs_artifact_id_idx on public.restoration_logs (artifact_id);
create index restoration_logs_expert_id_idx   on public.restoration_logs (expert_id);

-- ---------------------------------------------------------------------
-- Helper: is the current user an expert?
-- SECURITY DEFINER so it can read profiles without recursing into RLS.
-- ---------------------------------------------------------------------

create or replace function public.is_expert()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'expert'
  );
$$;

revoke all on function public.is_expert() from public, anon;
grant execute on function public.is_expert() to authenticated;

-- ---------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------

alter table public.profiles         enable row level security;
alter table public.artifacts        enable row level security;
alter table public.restoration_logs enable row level security;

-- profiles: each user manages only their own row.
create policy "profiles: read own"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

-- Self-signup may only create a 'tourist' profile. Promoting someone to
-- 'expert' must be done by an admin (service role / SQL editor), so users
-- cannot grant themselves expert access.
create policy "profiles: insert own as tourist"
  on public.profiles for insert to authenticated
  with check (id = (select auth.uid()) and role = 'tourist');

create policy "profiles: update own"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Users may edit their name / professional id but never their role.
revoke update on public.profiles from authenticated;
grant  update (full_name, professional_id) on public.profiles to authenticated;

-- artifacts: read-only for all signed-in users (tourists and experts).
-- No insert/update/delete policies => only the service role can write.
create policy "artifacts: read for authenticated"
  on public.artifacts for select to authenticated
  using (true);

-- restoration_logs: experts only, read + insert (no update/delete).
create policy "restoration_logs: experts read"
  on public.restoration_logs for select to authenticated
  using (public.is_expert());

create policy "restoration_logs: experts insert own"
  on public.restoration_logs for insert to authenticated
  with check (public.is_expert() and expert_id = (select auth.uid()));
