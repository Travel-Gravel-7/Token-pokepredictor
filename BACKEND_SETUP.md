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
