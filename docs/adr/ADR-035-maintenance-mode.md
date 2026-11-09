# ADR-035: Maintenance mode for redeployments

- **Status:** Accepted (2026-11-10)
- **Context:** DEVLOG entry 75.

## Decision

- **The switch is a file on the server:** `infra/maintenance/on`. Caddy checks for it on every request, so it works while the API or database is restarting. It is not a setting in the database or the Console, which would be unavailable at the moment it matters.
- **While it exists:**
  - API calls, on both the web and API addresses, answer `503 {"detail": "maintenance"}` with `Retry-After: 300`;
  - the Console and shared form links answer a plain "being updated" page;
  - `/collect/`, map images and road routes stay available, and `/health` keeps answering for checks.
- **Collect keeps working.** It works offline and its work waits in its queue: a refused sync is retried, nothing is lost, and the Sync page says why. Blocking it would stop collectors in the field for no gain.
- **Open apps** show a banner above every page while the server answers "maintenance". It clears with the next answer that says otherwise. Signed-in users stay signed in.
- **In a deployment:** switch it on before the backup, so nothing is written between the backup and the migration, and off once the new version is checked:

```sh
touch ~/WaterCheck/infra/maintenance/on   # on
rm ~/WaterCheck/infra/maintenance/on      # off
```

## Consequences

- Backups taken in maintenance mode are consistent with the migration that follows.
- The `on` file is not in git; the page beside it is.
- Checks through the public address see the maintenance page until it is switched off; `/health` and the server's own logs do not depend on it.
