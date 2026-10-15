-- Pokediction backend foundation (Supabase / PostgreSQL)
-- Safe starting point for accounts and prediction records.
-- No real-money balances or payouts are modeled here.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Trainer',
  created_at timestamptz not null default now(),
  constraint display_name_length check (char_length(display_name) between 1 and 24)
);

create table if not exists public.rounds (
  id uuid primary key default gen_random_uuid(),
  asset_ticker text not null,
  opens_at timestamptz not null,
  closes_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'open', 'settled', 'cancelled')),
  opening_value numeric(14,4),
  closing_value numeric(14,4),
  outcome text check (outcome in ('UP', 'DOWN', 'TIE')),
  created_at timestamptz not null default now(),
  constraint round_time_order check (closes_at > opens_at),
  constraint settled_round_has_outcome check (
    status <> 'settled' or outcome is not null
  )
);

create table if not exists public.predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  round_id uuid not null references public.rounds(id) on delete cascade,
  choice text not null check (choice in ('UP', 'DOWN')),
  created_at timestamptz not null default now(),
  unique (user_id, round_id)
);

create index if not exists predictions_user_created_idx
  on public.predictions (user_id, created_at desc);
create index if not exists predictions_round_idx
  on public.predictions (round_id);

alter table public.profiles enable row level security;
alter table public.rounds enable row level security;
alter table public.predictions enable row level security;

-- Public can see only the non-sensitive round information.
drop policy if exists "Rounds are readable" on public.rounds;
create policy "Rounds are readable"
  on public.rounds for select
  to anon, authenticated
  using (true);

-- A signed-in user can see and change only their own profile.
drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Users insert own profile" on public.profiles;
create policy "Users insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users update own profile" on public.profiles;
create policy "Users update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Predictions are private to their owner. The client cannot write scores,
-- settle rounds, or edit/delete submitted predictions.
drop policy if exists "Users read own predictions" on public.predictions;
create policy "Users read own predictions"
  on public.predictions for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users submit prediction for open round" on public.predictions;
create policy "Users submit prediction for open round"
  on public.predictions for insert
  to authenticated
  with check (
    auth.uid() = user_id
    and exists (
      select 1
      from public.rounds r
      where r.id = round_id
        and r.status = 'open'
        and r.opens_at <= now()
        and r.closes_at > now()
    )
  );

-- Intentionally no client policies for creating/updating/deleting rounds,
-- settling outcomes, or changing prediction records after insertion.
-- Those actions must be performed by a trusted server/Edge Function.
