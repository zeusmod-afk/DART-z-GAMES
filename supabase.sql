-- Jalankan seluruh SQL ini di Supabase > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category text not null default 'Other',
  platform text not null default 'Other',
  version text not null default '1.0',
  label text not null default '',
  file_url text not null,
  file_name text not null,
  file_size bigint not null default 0,
  cover_url text,
  downloads bigint not null default 0,
  published boolean not null default true,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.admins enable row level security;
alter table public.games enable row level security;

create policy "admin can read admin list"
on public.admins for select to authenticated
using (user_id = auth.uid());

create policy "public can read published games and admin can read all"
on public.games for select to anon, authenticated
using (published = true or exists(select 1 from public.admins a where a.user_id = auth.uid()));

create policy "admins insert games"
on public.games for insert to authenticated
with check (exists(select 1 from public.admins a where a.user_id = auth.uid()));

create policy "admins update games"
on public.games for update to authenticated
using (exists(select 1 from public.admins a where a.user_id = auth.uid()))
with check (exists(select 1 from public.admins a where a.user_id = auth.uid()));

create policy "admins delete games"
on public.games for delete to authenticated
using (exists(select 1 from public.admins a where a.user_id = auth.uid()));

-- Counter hanya bisa dinaikkan melalui function ini, bukan update bebas dari browser.
create or replace function public.record_game_download(game_id uuid)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare new_count bigint;
begin
  update public.games
  set downloads = downloads + 1
  where id = game_id and published = true
  returning downloads into new_count;
  if new_count is null then
    raise exception 'Game tidak ditemukan atau tidak dipublikasikan';
  end if;
  return new_count;
end;
$$;
revoke all on function public.record_game_download(uuid) from public;
grant execute on function public.record_game_download(uuid) to anon, authenticated;

-- Buat dua bucket publik untuk file yang memang akan diunduh pengunjung.
insert into storage.buckets (id, name, public, file_size_limit)
values ('game-files','game-files',true,524288000),
       ('game-covers','game-covers',true,10485760)
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit;

-- Hanya admin yang boleh upload, mengganti, atau menghapus file.
create policy "admins upload game files"
on storage.objects for insert to authenticated
with check (bucket_id in ('game-files','game-covers')
  and exists(select 1 from public.admins a where a.user_id = auth.uid()));

create policy "admins update game files"
on storage.objects for update to authenticated
using (bucket_id in ('game-files','game-covers')
  and exists(select 1 from public.admins a where a.user_id = auth.uid()))
with check (bucket_id in ('game-files','game-covers')
  and exists(select 1 from public.admins a where a.user_id = auth.uid()));

create policy "admins delete game files"
on storage.objects for delete to authenticated
using (bucket_id in ('game-files','game-covers')
  and exists(select 1 from public.admins a where a.user_id = auth.uid()));
