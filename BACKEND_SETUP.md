# Pokediction backend setup

The live GitHub Pages site is still the static demo. This repository now includes a first-pass Supabase schema for moving toward real accounts and server-controlled prediction records.

## What is ready
- `supabase/schema.sql`: profiles, rounds, and predictions tables with row-level security.
- Public clients can read round data.
- Signed-in users can read their own profile and predictions and submit one prediction per open round.
- Client-side users cannot create/settle rounds or edit/delete submitted predictions.

## What is not connected yet
- The live site does not yet use Supabase. It still saves demo progress in the browser's local storage.
- No real market feed, settlement worker, trusted scoring service, leaderboard, Stripe checkout, or cash/token payouts are implemented.
- The schema alone is not a production launch. It needs testing, abuse controls, server-side settlement, and appropriate legal/compliance review before anything involving money or prizes.

## Set up Supabase
1. Create a project at https://supabase.com/ and keep its database password private.
2. In the Supabase dashboard, open **SQL Editor** and run the contents of `supabase/schema.sql`.
3. In **Project Settings → API**, copy the Project URL and the publishable/anon client key.
4. Do not put a service-role key or database password in browser code, GitHub commits, or a public issue. Those credentials bypass important protections.
5. The next code step is to add a small client integration using the Project URL and publishable/anon key, then implement sign-in and profile creation. A trusted server-side function must handle round creation/settlement and score calculation.

## Safe rollout order
1. Connect authentication and profiles.
2. Add a server-side round creation/settlement process with tests.
3. Store and verify prediction submissions on the server.
4. Add rate limits, anti-abuse controls, monitoring, backups, and a privacy policy.
5. Only then evaluate monetization and any real-money features separately.

The current public demo remains available at https://travel-gravel-7.github.io/Token-pokepredictor/.


## Additional hardening migration (staging first)

A follow-up migration is available at `supabase/migrations/20261015_harden_round_data.sql`. It explicitly narrows client table grants and adds checks for non-empty asset tickers, positive market values, and required values on settled rounds.

1. Do **not** run this directly against production without a backup.
2. Create a Supabase staging project and enable MFA on the owner account.
3. Run `supabase/schema.sql` first, then the hardening migration in the SQL Editor.
4. Inspect existing `rounds` rows for violations before validating the new constraints.
5. Test with separate anonymous, User A, and User B sessions. Confirm a user cannot read another user's predictions or update/delete submitted predictions.
6. Confirm anonymous/authenticated clients cannot insert/update/delete rounds, and that the public client cannot change settlement outcomes.
7. Record a backup and test restoring it before moving any real user data.

The repository's automated checks inspect the migration text and intended grants; they do **not** execute PostgreSQL or prove that deployed Supabase policies behave correctly. No Supabase project was accessed or changed by this commit.
