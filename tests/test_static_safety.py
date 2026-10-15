"""Static safety smoke tests for the Pokediction prototype.

These checks are intentionally modest. Passing them does not replace browser,
security, accessibility, or load testing.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / "index.html").read_text(encoding="utf-8")
README = (ROOT / "README.md").read_text(encoding="utf-8")
SCHEMA = (ROOT / "supabase" / "schema.sql").read_text(encoding="utf-8")
GITIGNORE = (ROOT / ".gitignore").read_text(encoding="utf-8")


class StaticSafetyTests(unittest.TestCase):
    def test_game_has_market_data_source(self):
        self.assertIn('const TCGDEX="https://api.tcgdex.net/v2/en";', HTML)
        self.assertIn('TCGDEX+"/cards?name="', HTML)
        self.assertIn('TCGDEX+"/cards/"', HTML)
        self.assertIn("tcgplayer", HTML.lower())
        self.assertIn("cardmarket", HTML.lower())

    def test_demo_discloses_local_only_storage(self):
        self.assertRegex(README.lower(), r"local storage only")
        self.assertRegex(README.lower(), r"does not have background refresh")

    def test_browser_state_has_validation(self):
        self.assertIn("Array.isArray(tracked)", HTML)
        self.assertIn("Number.isFinite", HTML)
        self.assertIn("localStorage", HTML)

    def test_no_known_secret_key_literals_in_frontend(self):
        patterns = [
            r"sk_live_[A-Za-z0-9]{12,}",
            r"sk_test_[A-Za-z0-9]{12,}",
            r"sb_secret_[A-Za-z0-9_-]{12,}",
            r"service_role",
            r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
        ]
        for pattern in patterns:
            with self.subTest(pattern=pattern):
                self.assertIsNone(re.search(pattern, HTML, flags=re.IGNORECASE))

    def test_local_secrets_are_ignored(self):
        for pattern in (".env", ".env.*", "*.pem", "*.key", "secrets/"):
            self.assertIn(pattern, GITIGNORE)

    def test_backend_schema_enables_rls(self):
        for table in ("profiles", "rounds", "predictions"):
            self.assertRegex(
                SCHEMA,
                rf"alter table public\.{table} enable row level security",
            )

    def test_predictions_are_unique_per_user_and_round(self):
        self.assertIn("unique (user_id, round_id)", SCHEMA)

    def test_no_client_policy_for_settlement(self):
        self.assertIn("Intentionally no client policies", SCHEMA)
        self.assertIn("trusted server/Edge Function", SCHEMA)

    def test_zero_or_negative_prices_are_not_trackable(self):
        self.assertIn("Number(t.price)>0", HTML)
        self.assertIn("x.price>0", HTML)

    def test_hardening_migration_limits_client_grants(self):
        migration = (ROOT / "supabase" / "migrations" / "20261015_harden_round_data.sql").read_text(encoding="utf-8")
        self.assertIn("revoke all on table public.rounds from anon, authenticated", migration)
        self.assertIn("grant select on table public.rounds to anon, authenticated", migration)
        self.assertIn("grant select, insert on table public.predictions to authenticated", migration)
        self.assertIn("round_opening_value_positive", migration)
        self.assertIn("settled_round_has_values", migration)

    def test_no_old_random_outcome_logic(self):
        self.assertNotRegex(HTML, r"Math\.random\(\)\s*<\s*\.5")

    def test_public_disclaimer_exists(self):
        self.assertIn("not financial advice", README.lower())


if __name__ == "__main__":
    unittest.main(verbosity=2)
