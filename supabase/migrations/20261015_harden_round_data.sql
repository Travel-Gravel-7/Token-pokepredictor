-- Pokediction backend hardening migration
-- Run only in a Supabase staging project first. This does not connect or deploy
-- anything by itself. Review any existing data before validating constraints.

begin;

-- Explicit grants make the intended client surface clear even if project defaults
-- have previously been changed. RLS remains mandatory as a second layer.
revoke all on table public.rounds from anon, authenticated;
grant select on table public.rounds to anon, authenticated;

revoke all on table public.predictions from anon, authenticated;
grant select, insert on table public.predictions to authenticated;

revoke all on table public.profiles from anon, authenticated;
grant select, insert, update on table public.profiles to authenticated;

-- Reject nonsensical values on new writes immediately. NOT VALID avoids a full
-- scan of existing rows during initial rollout; validate after inspecting data.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'round_asset_ticker_length'
      and conrelid = 'public.rounds'::regclass
  ) then
    alter table public.rounds
      add constraint round_asset_ticker_length
      check (char_length(trim(asset_ticker)) between 1 and 64) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'round_opening_value_positive'
      and conrelid = 'public.rounds'::regclass
  ) then
    alter table public.rounds
      add constraint round_opening_value_positive
      check (opening_value is null or opening_value > 0) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'round_closing_value_positive'
      and conrelid = 'public.rounds'::regclass
  ) then
    alter table public.rounds
      add constraint round_closing_value_positive
      check (closing_value is null or closing_value > 0) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'settled_round_has_values'
      and conrelid = 'public.rounds'::regclass
  ) then
    alter table public.rounds
      add constraint settled_round_has_values
      check (
        status <> 'settled'
        or (opening_value is not null and closing_value is not null and outcome is not null)
      ) not valid;
  end if;
end $$;

commit;

-- After reviewing existing data in staging, validate constraints with:
-- alter table public.rounds validate constraint round_asset_ticker_length;
-- alter table public.rounds validate constraint round_opening_value_positive;
-- alter table public.rounds validate constraint round_closing_value_positive;
-- alter table public.rounds validate constraint settled_round_has_values;

-- Never grant the browser client UPDATE/DELETE on predictions or write access to
-- rounds. A trusted server/Edge Function must own round lifecycle and settlement.
