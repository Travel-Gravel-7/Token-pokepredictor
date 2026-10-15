# Pokediction Privacy Notice (DRAFT — NOT APPROVED FOR PRODUCTION)

**Status:** Working draft prepared 2026-10-15. This is not legal advice and must be reviewed against the deployed code, hosting configuration, provider terms, target markets, and actual business practices before publication.

## Current demo behavior

Pokediction is currently a static browser-based demo. The inspected application stores demo coins, score, streak, pending virtual predictions, tracked-card choices, and price snapshots in the user's browser local storage. These values are not currently synced to a Pokediction account or shared database.

The application requests Pokémon card catalog and pricing information from the TCGdex public API. Card images and price data may be supplied by third parties. Those providers may receive ordinary technical request information, such as the user's IP address and request metadata, under their own terms and privacy practices.

The public site is hosted using GitHub Pages. The hosting provider may process technical logs and other information under its own policies.

## Accounts and sensitive data

The current demo does not provide Pokediction account registration or password entry. Do not enter passwords, payment-card information, government identifiers, or other sensitive personal information into the demo.

If accounts, analytics, support forms, payments, or community features are added, this draft must be rewritten to describe each actual data flow before those features launch.

## Local storage and deletion

A user can remove local demo data by clearing site data/browser storage. Doing so may permanently erase tracked cards, snapshots, and demo progress. There is currently no server-side account export or recovery process for that local-only data.

## Children

The intended audience and age policy have not been legally reviewed. Because Pokémon-related products may attract children, the operator must assess applicable child privacy laws and age-related obligations before collecting personal information or launching accounts, advertising, or analytics.

## Security

Reasonable safeguards should be used, but no internet service can promise perfect security. Do not submit credentials through public issue trackers or chat. A documented incident response and data-deletion process must be established before collecting account data.

## Contact and changes

**Operator/contact details: TO BE ADDED AND VERIFIED BEFORE PUBLICATION.**

This notice must be updated when the app's data practices change. Do not publish this draft as final until reviewed by qualified counsel and reconciled with the actual deployed service.
