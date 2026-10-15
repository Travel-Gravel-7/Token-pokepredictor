# Security Policy

## Current security posture

Pokediction is a public, static GitHub Pages prototype. It currently stores demo progress and tracked-card snapshots in browser local storage. It does not currently provide user accounts, server-side authorization, a shared database, server-side prediction settlement, or payment processing.

Do not enter passwords, payment details, government identifiers, or other sensitive personal information into the current demo.

## Reporting a vulnerability

Please do not publish exploit details, credentials, tokens, or personal data in public issues. Contact the repository owner privately. If GitHub private vulnerability reporting is enabled for this repository, use that channel.

## Secrets and access

- Never commit Supabase service-role keys, database passwords, Stripe secret keys, webhook signing secrets, OAuth tokens, or private signing keys.
- Browser code may contain only intentionally public client identifiers/keys protected by strict Row Level Security (RLS) and least-privilege policies.
- Store server secrets in the hosting provider's secret manager, never in source files, browser storage, build logs, or public artifacts.
- Use multifactor authentication on GitHub, Stripe, and any future hosting/database provider.
- Keep permissions limited to the minimum required; require review for writes, billing changes, and deployments.
- Rotate any credential that may have been exposed. Do not paste replacement secrets into chat or commit them.

## Release requirements before accounts or money

1. Connect and test authentication and database policies in a non-production environment.
2. Move prediction settlement, scoring, and all privileged operations to a trusted server-side function.
3. Add request validation, rate limits, abuse controls, and server-side logging that excludes secrets.
4. Test access boundaries using separate user accounts and anonymous requests.
5. Configure backups and test restoring them.
6. Add privacy notice, terms, support/security contact, retention/deletion procedures, and required legal review.
7. Obtain payment-provider approval for the exact monetization model before charging users.
8. Run dependency, static-analysis, functional, accessibility, and mobile-device tests before release.

## Known limitations

This policy is not a certification that the application is secure. The current demo has not received a professional penetration test or complete browser/device test matrix. The price feed is a third-party provider snapshot, not guaranteed real-time exchange data.
