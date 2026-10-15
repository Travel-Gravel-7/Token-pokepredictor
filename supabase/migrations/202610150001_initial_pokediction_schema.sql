-- Pokediction initial database schema
-- Prepared on a non-production Git branch for review.
-- Applying this migration to Supabase is a separate, explicit step.

begin;

create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Trainer',
  created_at timestamptz not null default now(),
  constraint display_name_length check (char_length(display_name) between 1 and 24)
);

create table public.rounds (
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
  constraint round_asset_ticker_length
    check (char_length(trim(asset_ticker)) between 1 and 64),
  constraint round_opening_value_positive
    check (opening_value is null or opening_value > 0),
  constraint round_closing_value_positive
    check (closing_value is null or closing_value > 0),
  constraint settled_round_has_values
    check (
      status <> 'settled'
      or (opening_value is not null and closing_value is not null and outcome is not null)
    )
);

create table public.predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  round_id uuid not null references public.rounds(id) on delete cascade,
  choice text not null check (choice in ('UP', 'DOWN')),
  created_at timestamptz not null default now(),
  constraint predictions_one_per_user_round unique (user_id, round_id)
);

create index predictions_user_created_idx
  on public.predictions (user_id, created_at desc);
create index predictions_round_idx
  on public.predictions (round_id);

alter table public.profiles enable row level security;
alter table public.rounds enable row level security;
alter table public.predictions enable row level security;

create policy "Rounds are readable"
  on public.rounds for select
  to anon, authenticated
  using (true);

create policy "Users read own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Users insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users read own predictions"
  on public.predictions for select
  to authenticated
  using (auth.uid() = user_id);

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

-- Defense in depth: explicit SQL privileges plus RLS policies.
revoke all on table public.rounds from anon, authenticated;
grant select on table public.rounds to anon, authenticated;

revoke all on table public.predictions from anon, authenticated;
grant select, insert on table public.predictions to authenticated;

revoke all on table public.profiles from anon, authenticated;
grant select, insert, update on table public.profiles to authenticated;

commit;

-- Deliberately absent: client-side round creation/settlement and prediction
-- updates/deletes. A trusted server function must own those operations.
-- No real-money balance, payout, or prize functionality is defined here.
