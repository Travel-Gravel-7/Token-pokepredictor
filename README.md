# Pokediction Arcade

A static, mobile-friendly Pokediction prototype with a live Pokémon card market lookup and browser-local price tracker.

## Current features
- Neon arcade prediction demo with play coins, streak, score, and browser-local progress.
- Pokémon card search through the public TCGdex REST API.
- Displays available TCGplayer USD market pricing and Cardmarket EUR pricing included in the card record.
- Tracks a selected card + price variant and records snapshots when the user refreshes tracked prices.
- Price snapshots and tracked-card lists are stored in the current browser's local storage only.

## Live card pricing
The Market Intel panel calls the public TCGdex API:
- Card search: `https://api.tcgdex.net/v2/en/cards?name=PIKACHU`
- Card detail/pricing: `https://api.tcgdex.net/v2/en/cards/{cardId}`

TCGdex includes available TCGplayer and Cardmarket market data in card records. The provider's pricing refresh schedule varies by source. Missing prices are possible, and the provider documents known card/variant matching issues. Always confirm set, collector number, language, condition, and finish before using a price for a sale or prediction.

Tracked history currently consists of snapshots collected when this browser refreshes the cards. It is not a shared database, and it does not provide historical data that was never captured. The static site does not have background refresh while closed.

## Important limits
- The Prediction Arena still uses simulated prices and random outcomes. It is not yet driven by the market tracker.
- No accounts, shared leaderboard, server-side price history, settlement service, or real-money transactions are connected.
- The market data is informational and may be stale or mismatched; it is not financial advice or a guarantee of resale value.
- Do not enable paid predictions, cash-outs, or prize features without backend security and legal/payment-provider review.

## Deploy
The repository includes a GitHub Actions workflow at `.github/workflows/deploy.yml`. It deploys on pushes to `main` and manual workflow dispatch.

Public demo: https://travel-gravel-7.github.io/Token-pokepredictor/
