# Backup and Recovery Runbook

**Scope:** Pokediction's current static demo and planned Supabase backend. This is an operational checklist, not proof that backups currently exist.

## Current verified position

- The source repository is public and can be downloaded as a ZIP.
- The demo stores progress in each browser's local storage; there is no server-side user progress to back up today.
- A Supabase schema is present in the repository, but no Supabase project was accessed or changed by this workflow.
- No private backup repository, database backup schedule, or successful restore drill has been verified.

## A. Source backup

1. Download the source ZIP from `https://github.com/Travel-Gravel-7/Token-pokepredictor/archive/refs/heads/main.zip`.
2. Save a copy in two places: one private cloud folder with MFA and one offline device or encrypted drive.
3. Do not put database passwords, service-role keys, Stripe secret keys, or personal customer exports in a source archive.
4. For a genuinely private GitHub backup, create a **separate private repository** in GitHub's website, import/push the source, and verify its visibility is Private. Do not change the public game repository to private unless intentionally taking the public game offline.
5. Restrict access to the minimum necessary and enable MFA.

## B. Supabase backup plan (only after a project exists)

1. Create staging first; keep production and staging projects separate.
2. Keep project owner MFA enabled and store privileged credentials only in a password manager or provider secret manager.
3. Configure database backups appropriate to the chosen Supabase plan. Verify the actual retention and point-in-time recovery options in the current dashboard; do not assume they are enabled.
4. Before migrations, export the schema and any data that must be preserved. Keep exports encrypted and access-restricted.
5. Restore the backup into a separate test project, not over production.
6. Verify row counts, key relationships, RLS policies, and app behavior using separate test users.
7. Record the restore date, operator, backup timestamp, and any errors. A backup is not proven until a restore has succeeded.

## C. Browser-local demo data

Users can currently lose tracked cards, snapshots, and virtual progress when clearing browser data or changing devices. There is no account-based restore. Until export/import is implemented, users should not treat local demo history as durable records.

## D. Recovery and incident response

- If a secret is exposed, revoke/rotate it at the provider immediately. Do not merely delete it from the latest source file because commit history may retain it.
- If the public demo breaks, roll back to a known-good source commit and verify the Pages workflow.
- If account data is introduced, suspend writes during suspected corruption, preserve logs without secrets, restore to a separate environment, verify integrity, and only then switch traffic.
- Document incidents, affected data, recovery actions, and any legally required notices.

## Completion checklist

- [ ] Private source backup exists and visibility has been verified.
- [ ] MFA enabled for GitHub and Supabase owner accounts.
- [ ] Database backup schedule and retention verified in the actual plan.
- [ ] Encrypted export stored outside the source repository.
- [ ] Restore into a separate environment succeeded.
- [ ] RLS tested with anonymous, User A, and User B sessions.
- [ ] Recovery notes and responsible contact recorded.
