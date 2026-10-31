# Pokediction Stripe Readiness Audit

**Audit date:** 2026-10-30  
**Status:** Not ready for live payments  
**Repository:** `Travel-Gravel-7/Token-pokepredictor`

## Executive summary

Pokediction's current repository describes a static prototype. Its README says that accounts, shared leaderboards, server-side price history, settlement services, and real-money transactions are not connected.

The connected GraveX Studios Stripe account being in Live mode does **not** mean Pokediction has a working live checkout or that coin purchases are enabled.

The Supabase Edge Functions previously inspected for this project are test-only:

| Function | Observed behavior | Live readiness |
|---|---|---|
| `create-coin-checkout-test` | Requires a Stripe secret key beginning with `sk_test_`; otherwise returns “Test mode only. Live coin sales are disabled.” | Test only |
| `stripe-webhook-test` | Validates the Stripe signature and rejects events where `event.livemode !== false`. | Test only |
| `stripe-webhook` | Validates the Stripe signature and rejects live-mode events. | Test only |

No working live Pokediction checkout endpoint or live coin-purchase flow was verified during this audit.

## Current conclusion

- Do not advertise coin purchases as active.
- Do not switch the existing test functions to live mode by simply changing a secret key.
- Do not put Stripe secret keys, webhook signing secrets, or Supabase service-role keys in this repository's frontend, GitHub Pages files, or client-side JavaScript.
- Keep virtual/demo coins clearly distinguished from purchased coins until server-side fulfillment is implemented and tested.

## Work required before launch

1. **Define the purchase model**
   - Confirm the coin packages, prices, and what purchased coins can be used for.
   - Confirm whether coins are consumable one-time purchases or part of a subscription. These require different Stripe product and fulfillment designs.
   - Document refund, chargeback, and account-support handling.

2. **Build a server-side checkout endpoint**
   - Create a dedicated Pokediction checkout function; do not repurpose unrelated GraveX InkLab or other app functions.
   - Create Stripe Checkout Sessions server-side using approved product and price IDs.
   - Validate the authenticated user and requested package on the server. Never trust a client-supplied amount or coin quantity.
   - Use test-mode credentials and test products first.

3. **Implement secure fulfillment**
   - Verify webhook signatures using the raw request body and the endpoint's webhook signing secret.
   - Process only successful, relevant payment events.
   - Make fulfillment idempotent so Stripe retries cannot credit the same purchase twice.
   - Record Stripe event/payment identifiers and a durable purchase ledger.
   - Credit coins only on the server after verified payment; never from a browser success redirect.

4. **Secure the coin balance**
   - Store balances and transaction history server-side.
   - Prevent users from changing their own balances or ledger entries.
   - Apply database access policies so each user can access only their own records.
   - Add checks for duplicate events, replay attempts, invalid package IDs, and insufficient balances.

5. **Test the full lifecycle**
   - Successful test payment and exactly-once coin credit.
   - Cancelled checkout and failed payment.
   - Duplicate and out-of-order webhook delivery.
   - Refunds and disputes, including the agreed coin-reversal policy.
   - Unauthenticated requests and attempts to alter price or coin quantity.
   - User isolation and database policy tests.

6. **Live launch gate**
   - Review the finished test flow and obtain explicit approval before creating or activating live products/prices or deploying live payment secrets.
   - Configure production secrets only in Supabase's server-side secrets store.
   - Configure the live webhook endpoint in Stripe and verify its signing secret.
   - Run a controlled live purchase only after the user approves the launch.
   - Update the README and in-app UI only after the live flow is verified end to end.

## Separation and safety

This repository is Pokediction. Keep its database objects and Edge Functions namespaced for Pokediction. The existing Supabase project also contains functions used by other work; do not overwrite or rename those functions as part of this implementation.

**No live products, prices, charges, or production payment credentials were created or changed as part of this audit.**

## Audit limitations

This document records the function behavior and repository state observed during the audit. It is not a certification that every Stripe or Supabase setting has been reviewed. Before launch, re-check deployed function code, Supabase secrets and database policies, Stripe webhook configuration, and the complete checkout-to-coin-credit path.
