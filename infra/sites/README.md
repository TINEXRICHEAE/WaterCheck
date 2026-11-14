# Other sites on this server

Caddy also serves any `*.caddy` file placed in this folder, beside FieldQuire's own sites
(ADR-036). It lets another application on the same server use Caddy's HTTPS and certificates
without its details entering this repository.

- The files are kept on the server only; git ignores everything here except this README.
- A site reaches a service running on the server itself as `host.docker.internal:<port>`.
- After adding or changing a file, run `docker compose up -d --force-recreate caddy`.
- Each application documents its own site file in its own repository.
