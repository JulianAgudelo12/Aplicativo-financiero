create table if not exists public.app_kv_store (
  profile_id text not null default 'global',
  store_key text not null,
  value_json jsonb,
  value_text text,
  value_int bigint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (profile_id, store_key)
);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_app_kv_store_updated_at on public.app_kv_store;
create trigger trg_app_kv_store_updated_at
before update on public.app_kv_store
for each row
execute function public.touch_updated_at();

alter table public.app_kv_store enable row level security;

drop policy if exists "app_kv_store_select" on public.app_kv_store;
create policy "app_kv_store_select"
on public.app_kv_store
for select
to anon, authenticated
using (true);

drop policy if exists "app_kv_store_insert" on public.app_kv_store;
create policy "app_kv_store_insert"
on public.app_kv_store
for insert
to anon, authenticated
with check (true);

drop policy if exists "app_kv_store_update" on public.app_kv_store;
create policy "app_kv_store_update"
on public.app_kv_store
for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "app_kv_store_delete" on public.app_kv_store;
create policy "app_kv_store_delete"
on public.app_kv_store
for delete
to anon, authenticated
using (true);
