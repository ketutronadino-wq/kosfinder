-- ==============================================================================
-- Migrasi Awal: Skema Tabel dan Policy RLS KosFinder V1
-- Berkas: supabase/migrations/001_init.sql
-- ==============================================================================

-- 1. Buat Tabel `kosts`
create table if not exists public.kosts (
  id uuid default gen_random_uuid() primary key,
  owner_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  gender_type text not null check (gender_type in ('putra', 'putri', 'campur')),
  area_campus text not null,
  address text not null,
  price_monthly numeric not null check (price_monthly >= 0),
  whatsapp_number text not null,
  image_url text,
  facilities text[] not null default '{}',
  description text,
  status text not null default 'tersedia' check (status in ('tersedia', 'penuh')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. Buat Index untuk Optimasi Pencarian dan Filter
create index if not exists idx_kosts_active on public.kosts (is_active);
create index if not exists idx_kosts_owner on public.kosts (owner_id);
create index if not exists idx_kosts_area_campus on public.kosts (area_campus);
create index if not exists idx_kosts_gender on public.kosts (gender_type);
create index if not exists idx_kosts_price on public.kosts (price_monthly);

-- 3. Fungsi & Trigger Otomatis Pembaruan `updated_at`
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trigger_kosts_updated_at on public.kosts;
create trigger trigger_kosts_updated_at
before update on public.kosts
for each row
execute function public.handle_updated_at();

-- 4. Aktifkan Row Level Security (RLS)
alter table public.kosts enable row level security;

-- 5. Kebijakan Keamanan RLS
-- Policy SELECT: Publik dan pengguna melihat kos aktif, atau pemilik melihat kos miliknya sendiri
create policy "select_kosts_policy"
on public.kosts for select
using (is_active = true or auth.uid() = owner_id);

-- Policy INSERT: Hanya user terautentikasi yang dapat menambah kos dengan owner_id miliknya
create policy "insert_kosts_policy"
on public.kosts for insert
to authenticated
with check (auth.uid() = owner_id);

-- Policy UPDATE: Pemilik hanya dapat mengubah kos miliknya sendiri
create policy "update_kosts_policy"
on public.kosts for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- Policy DELETE: Pemilik hanya dapat menghapus kos miliknya sendiri
create policy "delete_kosts_policy"
on public.kosts for delete
to authenticated
using (auth.uid() = owner_id);
