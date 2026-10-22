-- Run this once in Supabase: SQL Editor > New query > paste > Run

create table products (
  id bigint generated always as identity primary key,
  slug text unique not null,
  title text not null,
  category text not null,
  price text not null,
  badge text,
  description text,
  img text not null,
  affiliate_url text not null,
  clicks integer not null default 0,
  created_at timestamptz not null default now()
);

create table stats (
  id int primary key,
  visits bigint not null default 0
);
insert into stats (id, visits) values (1, 0);

alter table products enable row level security;
alter table stats enable row level security;

-- Everyone can read products and the visit count
create policy "public read products" on products for select using (true);
create policy "public read stats" on stats for select using (true);

-- Only a signed-in admin can add, edit, or delete
create policy "admin insert products" on products for insert to authenticated with check (true);
create policy "admin update products" on products for update to authenticated using (true) with check (true);
create policy "admin delete products" on products for delete to authenticated using (true);
create policy "admin update stats" on stats for update to authenticated using (true) with check (true);

-- Visitors can only add +1 to clicks and visits through these functions
create function increment_clicks(p_slug text) returns void
language sql security definer set search_path = public as
$$ update products set clicks = clicks + 1 where slug = p_slug; $$;

create function increment_visits() returns void
language sql security definer set search_path = public as
$$ update stats set visits = visits + 1 where id = 1; $$;

grant execute on function increment_clicks(text) to anon, authenticated;
grant execute on function increment_visits() to anon, authenticated;
