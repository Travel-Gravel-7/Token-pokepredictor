# Pokediction Launch Readiness

Audit snapshot: 2026-10-15. Source: public repository and connected Stripe live account read-only checks.

## Confirmed

- Public demo: https://travel-gravel-7.github.io/Token-pokepredictor/
- Repository: https://github.com/Travel-Gravel-7/Token-pokepredictor
- Latest checked Pages workflow run completed successfully: https://github.com/Travel-Gravel-7/Token-pokepredictor/actions/runs/38786678574
- Static app searches TCGdex and displays available TCGplayer USD and Cardmarket EUR pricing fields.
- Browser-local market tracking and market-based virtual prediction settlement exist.
- Supabase schema foundation exists at `supabase/schema.sql`.
- Current static page does not include Supabase or Stripe integration code.

## Not production-ready yet

- No connected Supabase database or authenticated accounts.
- No server-side price collector, shared price history, scheduled refresh, or trusted settlement service.
- No verified end-to-end tests across supported mobile browsers or automated browser test suite.
- No professional security assessment or penetration test.
- No verified restore drill for database or user records.
- No production privacy policy or terms of service reviewed by counsel.
- No confirmed third-party attribution/license review for card artwork and price data.
- No approved live payment flow or configured active Stripe price.
- No social accounts authorized for publishing in the connected workflow.

## Market-data accuracy

The application uses TCGdex's public REST API and pricing fields supplied with card records. It shows the provider's latest available quote; it is not a tick-level exchange feed. Data may be missing, stale, or mapped to a different printing/variant. The browser only records a snapshot when a user tracks or refreshes a card. No new snapshot is collected while the page is closed.

Before relying on a quote, validate card ID, set, collector number, language, condition, finish/variant, price source, currency, and provider update timestamp. Do not combine USD and EUR movement as though they were one price series.

## Recommended sequence

1. Keep the public demo virtual-only; do not enable cash-out or prizes.
2. Create a separate private backup repository or encrypted off-site backup and verify restore.
3. Create a Supabase project, run the schema in staging, enable MFA, verify RLS with multiple test users, and keep service credentials server-side.
4. Add server-side input validation, rate limiting, trusted settlement, audit logging, and scheduled collection with provider terms respected.
5. Add automated smoke tests for search failures, missing prices, malformed local storage, repeated picks, stale snapshots, network timeouts, and refresh failures.
6. Review licenses, provider terms, privacy, consumer protection, minors' privacy, and game-of-chance/payment implications with qualified counsel.
7. Obtain payment-provider confirmation before enabling any real-money features.
8. Run staged load, mobile, accessibility, and restore tests; then launch gradually.

## Backup note

The public GitHub repository is a source-of-truth copy, but it is not a private or password-protected backup. A private backup destination and restore test still need to be configured.
