# Pokediction backend setup

The live GitHub Pages site is still the static demo. The repository contains a proposed Supabase schema, but the live site is not yet connected to Supabase.

## Current state

- `supabase/schema.sql` is the readable schema reference.
- `supabase/migrations/202610150001_initial_pokediction_schema.sql` is the initial versioned migration. It creates profiles, rounds, predictions, RLS policies, and explicit client grants.
- `supabase/migrations/20261015_harden_round_data.sql` is a follow-up hardening migration. Its constraint checks are written to skip constraints already created by the initial migration.
- Signed-in users are intended to read only their own profile and predictions and submit one prediction per open round.
- Anonymous/authenticated clients are not granted write access to rounds. Clients cannot update or delete submitted predictions.
- These changes are on the review branch `zero-cost-backend-prep` only. They have **not** been applied to Supabase or merged into the default branch.

## What is not connected yet

- The live site still saves demo progress in browser local storage.
- No shared user accounts, trusted settlement worker, server-side scoring, scheduled price collector, or shared prediction history is connected.
- No Stripe checkout, real-money balance, cash-out, or prize payout system is implemented.
- The schema is not a production launch. Abuse controls, server-side settlement, operational monitoring, backup/restore testing, and legal/compliance review are still needed before anything involving money or prizes.

## Safe setup procedure

**Do not run these migrations against the production project yet.** The current low-cost path is to review the migration files and run static checks first. A separate Supabase staging project or branch has not been created because we are keeping ongoing costs at zero.

When an isolated test database becomes available:

1. Enable MFA on the Supabase owner account and keep the database password private.
2. Apply `supabase/migrations/202610150001_initial_pokediction_schema.sql` first.
3. Apply `supabase/migrations/20261015_harden_round_data.sql` second.
4. Run the Supabase security and performance advisors.
5. Test anonymous access and two separate signed-in users. Verify users cannot read each other's predictions or update/delete submitted predictions.
6. Verify anonymous/authenticated clients cannot create, update, or delete rounds, or alter settlement outcomes.
7. Test failure cases and verify a backup can actually be restored before storing real user data.

## Client credentials

The browser may use the project URL and a publishable/anon key only for operations allowed by RLS. Never put a service-role key or database password in browser code, GitHub commits, or public issues. Service credentials must remain in trusted server-side environments.

## Safe rollout order

1. Review and test the schema and RLS policies in an isolated database.
2. Connect authentication and profiles.
3. Implement trusted server-side round creation, market-data validation, settlement, and score calculation.
4. Add rate limits, anti-abuse controls, audit logs, monitoring, and a tested backup/restore process.
5. Confirm provider terms, licensing, privacy, consumer-protection, minors' privacy, and payment/prize implications with qualified professionals.
6. Only then evaluate monetization or real-money features separately.

The current public demo remains available at https://travel-gravel-7.github.io/Token-pokepredictor/.

Automated or static checks of migration text do **not** execute PostgreSQL and cannot prove deployed RLS behavior. No Supabase project was changed by preparing this branch.
