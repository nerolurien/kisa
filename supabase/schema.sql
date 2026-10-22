-- =====================================================================
-- KISA (COUPLE COMPANION: COUPLE COMPANION) SUPABASE DATABASE SCHEMA
-- Fully Idempotent Script (Aman di-run berkali-kali tanpa error)
-- =====================================================================

create extension if not exists "uuid-ossp";

-- 1. USERS TABLE
create table if not exists public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    email text not null,
    name text not null,
    partner_id uuid references public.users(id) on delete set null,
    avatar_url text,
    pairing_code text unique not null,
    current_status text default 'Lagi santai ✨',
    status_emoji text default '✨',
    status_updated_at timestamptz default now(),
    bio text default 'Menciptakan cerita indah berdua ✨',
    anniversary_date timestamptz,
    created_at timestamptz default now()
);

-- Ensure columns exist if table was created previously
alter table public.users add column if not exists current_status text default 'Lagi santai ✨';
alter table public.users add column if not exists status_emoji text default '✨';
alter table public.users add column if not exists status_updated_at timestamptz default now();
alter table public.users add column if not exists bio text default 'Menciptakan cerita indah berdua ✨';
alter table public.users add column if not exists anniversary_date timestamptz;

-- 2. TODOS (SHARED TO-DO & BUCKET LIST) TABLE
create table if not exists public.todos (
    id uuid primary key default uuid_generate_v4(),
    created_by uuid references public.users(id) on delete cascade not null,
    text text not null,
    is_completed boolean default false,
    category text default '🍿 Movie',
    priority text default 'Med',
    created_at timestamptz default now()
);

-- 3. ACTIVITIES (PRIVATE SCRAPBOOK TIMELINE) TABLE
create table if not exists public.activities (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references public.users(id) on delete cascade not null,
    content text not null,
    mood_emoji text default '✨',
    photo_url text,
    location_tag text,
    likes_count integer default 0,
    created_at timestamptz default now()
);

-- 4. LOCATIONS (LIVE GPS & BACKGROUND TRACKING) TABLE
create table if not exists public.locations (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references public.users(id) on delete cascade unique not null,
    latitude double precision not null,
    longitude double precision not null,
    updated_at timestamptz default now()
);

-- =====================================================================
-- REALTIME PUBLICATION (Aman jika tabel sudah terdaftar sebelumnya)
-- =====================================================================
do $$
begin
  begin
    alter publication supabase_realtime add table public.users;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.todos;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.activities;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.locations;
  exception when duplicate_object then null;
  end;
end $$;

-- =====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================================
alter table public.users enable row level security;
alter table public.todos enable row level security;
alter table public.activities enable row level security;
alter table public.locations enable row level security;

-- Users Policies
drop policy if exists "Users can view self and partner" on public.users;
create policy "Users can view self and partner"
on public.users for select
using (
    auth.uid() = id or auth.uid() = partner_id
);

drop policy if exists "Users can update self" on public.users;
create policy "Users can update self"
on public.users for update
using (auth.uid() = id);

drop policy if exists "Users can insert self" on public.users;
create policy "Users can insert self"
on public.users for insert
with check (auth.uid() = id);

-- Auto-create user profile in public.users when signup occurs in auth.users
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.users (id, email, name, pairing_code)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
        upper(substring(coalesce(new.raw_user_meta_data->>'name', 'KIS'), 1, 3)) || '-' || floor(100 + random() * 899)::text
    )
    on conflict (id) do update set
        name = coalesce(excluded.name, public.users.name),
        email = coalesce(excluded.email, public.users.email);
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 1-on-1 Symmetric Pairing RPC
create or replace function public.pair_with_code(target_code text)
returns json as $$
declare
    current_user_id uuid;
    partner_record record;
begin
    current_user_id := auth.uid();
    
    if current_user_id is null then
        return json_build_object('success', false, 'message', 'Not authenticated');
    end if;

    select * into partner_record from public.users where upper(pairing_code) = upper(trim(target_code)) limit 1;

    if partner_record.id is null then
        return json_build_object('success', false, 'message', 'Kode pairing tidak ditemukan');
    end if;

    if partner_record.id = current_user_id then
        return json_build_object('success', false, 'message', 'Tidak bisa menghubungkan akun dengan diri sendiri');
    end if;

    -- Update both users symmetrically
    update public.users set partner_id = partner_record.id where id = current_user_id;
    update public.users set partner_id = current_user_id where id = partner_record.id;

    return json_build_object('success', true, 'partner_name', partner_record.name, 'partner_id', partner_record.id);
end;
$$ language plpgsql security definer;

-- Todos Policies
drop policy if exists "Couple can view shared todos" on public.todos;
create policy "Couple can view shared todos"
on public.todos for select
using (
    auth.uid() = created_by or 
    auth.uid() in (select partner_id from public.users where id = todos.created_by)
);

drop policy if exists "Couple can create todos" on public.todos;
create policy "Couple can create todos"
on public.todos for insert
with check (auth.uid() = created_by);

drop policy if exists "Couple can update shared todos" on public.todos;
create policy "Couple can update shared todos"
on public.todos for update
using (
    auth.uid() = created_by or 
    auth.uid() in (select partner_id from public.users where id = todos.created_by)
);

drop policy if exists "Couple can delete shared todos" on public.todos;
create policy "Couple can delete shared todos"
on public.todos for delete
using (
    auth.uid() = created_by or 
    auth.uid() in (select partner_id from public.users where id = todos.created_by)
);

-- Activities Policies
drop policy if exists "Couple can view shared activities" on public.activities;
create policy "Couple can view shared activities"
on public.activities for select
using (
    auth.uid() = user_id or 
    auth.uid() in (select partner_id from public.users where id = activities.user_id)
);

drop policy if exists "Users can insert own activities" on public.activities;
create policy "Users can insert own activities"
on public.activities for insert
with check (auth.uid() = user_id);

drop policy if exists "Couple can update activities (likes)" on public.activities;
create policy "Couple can update activities (likes)"
on public.activities for update
using (
    auth.uid() = user_id or 
    auth.uid() in (select partner_id from public.users where id = activities.user_id)
);

-- Locations Policies
drop policy if exists "Couple can view partner location" on public.locations;
create policy "Couple can view partner location"
on public.locations for select
using (
    auth.uid() = user_id or 
    auth.uid() in (select partner_id from public.users where id = locations.user_id)
);

drop policy if exists "User can upsert own location" on public.locations;
create policy "User can upsert own location"
on public.locations for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
