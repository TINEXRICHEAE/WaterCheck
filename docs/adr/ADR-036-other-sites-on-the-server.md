# ADR-036: Other sites on the same server

- **Status:** Accepted (2026-11-15)
- **Context:** DEVLOG entry 79. Another application is to run on the FieldQuire server and needs
  HTTPS on its own domain. FieldQuire's Caddy already holds ports 80 and 443.

## Decision

- **Caddy serves extra sites from `infra/sites/*.caddy`.** `Caddyfile.prod` and `Caddyfile.dev`
  end with `import /etc/caddy/sites/*.caddy`; the folder is mounted read-only into the container.
- **The site files stay on the server.** Git ignores everything in `infra/sites/` except its
  README, so another application's names, ports and settings never enter this repository. Each
  application keeps its site file in its own repository.
- **They reach services on the server itself** through `host.docker.internal`, mapped to the
  host's gateway (`extra_hosts: host.docker.internal:host-gateway`).
- **Certificates:** Caddy obtains and renews one for each extra site, as for FieldQuire's.
- An empty folder is fine: Caddy logs a warning and serves FieldQuire's sites as before.

## Consequences

- A broken site file stops Caddy from loading, and with it FieldQuire's sites. Validate before
  recreating Caddy:
  `docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile`.
- A service reached this way must listen on an address the container can reach (the Docker
  gateway), and stay closed to the internet in the Azure network security group.
- The server gained a 2 GB swap file (`/swapfile`, swappiness 10) to make room for a second
  application.
