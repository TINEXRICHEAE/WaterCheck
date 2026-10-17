# WaterCheck Deployment Guide

This guide documents the WaterCheck deployment from local development to an
Azure VM. It is intended as a learning reference and as a repeatable procedure
when moving the project to another VM, host, region, or domain.

## 1. Deployment architecture

The deployment uses one Ubuntu Azure VM running the complete Docker Compose
stack:

- **Caddy**: public HTTPS entry point and reverse proxy.
- **API**: FastAPI application on the internal Docker network at port `8000`.
- **Worker**: background jobs.
- **PostgreSQL/PostGIS**: application database.
- **SeaweedFS**: S3-compatible object storage for photos and other objects.
- **Tile server**: map tile service.
- **Mailpit**: development-only mail catcher.

Public names:

```text
https://watercheck.cooptconnect.app
https://api.watercheck.cooptconnect.app
```

The Console web application uses the first URL. Browser API requests use the
same-origin path `/api`; Android and Windows clients can use the API hostname
with the `/api` path.

## 2. Azure subscription and region

Azure for Students applies an allowed-region policy. The deployment could not
use East US. The allowed regions were:

```text
India South Central
South Africa North
Poland Central
Spain Central
Italy North
```

South Africa North was selected because it is geographically suitable for the
project's expected users.

VM configuration:

- Resource group: `watercheck-azure-2026`
- VM name: `watercheck-VM`
- OS: Ubuntu Server 24.04 LTS x64 Gen2
- Size: `Standard_B2als_v2`
- CPU/RAM: 2 vCPU / 4 GiB
- OS disk: 30 GiB Standard SSD
- Public IP: static
- Inbound ports: SSH `22`, HTTP `80`, HTTPS `443`
- Azure Spot, backups, extra data disks, and unnecessary monitoring were
  disabled to control cost.

The selected VM is approximately `$35.62/month` at the time of setup. The
Azure for Students credit is limited, so stop/deallocate the VM when it is not
needed and configure a budget alert in Cost Management.

## 3. Domain and DNS

The domain was registered through Name.com:

```text
cooptconnect.app
```

DNS records point to the VM's static public IP:

```text
watercheck.cooptconnect.app      A      <VM_PUBLIC_IP>
api.watercheck.cooptconnect.app  A      <VM_PUBLIC_IP>
```

Verify DNS from Windows PowerShell:

```powershell
nslookup watercheck.cooptconnect.app
nslookup api.watercheck.cooptconnect.app
```

The `.app` top-level domain requires HTTPS. Caddy obtains and renews
Let's Encrypt certificates automatically after both DNS records resolve and
ports `80` and `443` are reachable.

## 4. SSH access from Windows

The Azure VM username is `azureuser`.

The private key is stored locally with restricted permissions:

```text
C:\Users\ocenr\.ssh\watercheck-VM_key.pem
```

Connect with:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP>
```

Common problems:

- Put a space between the closing key-path quote and `azureuser`.
- Azure created the user `azureuser`; do not substitute the VM resource name.
- OpenSSH rejects keys that are readable by broad Windows groups. Remove
  inheritance and broad permissions with `icacls`, or copy the key into
  `C:\Users\<user>\.ssh` and restrict it to the current user, Administrators,
  and SYSTEM.

## 5. Install Docker on Ubuntu

Docker Engine and Compose were installed from Docker's Ubuntu repository. The
installation was verified with:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

Add the login user to the Docker group, then start a new SSH session or reboot
before relying on passwordless Docker commands:

```bash
sudo usermod -aG docker "$USER"
```

Useful capacity checks:

```bash
df -h /
free -h
docker system df
```

The selected VM initially had approximately 29 GiB usable root disk space and
approximately 26 GiB free. The tile data and Docker images consume part of this
space, so monitor disk usage.

## 6. Clone the repository

On the VM:

```bash
cd ~
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
cd ~/WaterCheck
git status
```

The repository is deployed under:

```text
/home/azureuser/WaterCheck
```

## 7. Production environment file

The Compose stack reads its environment from:

```text
~/WaterCheck/infra/.env
```

Create it on the VM only. Never commit it or put it in the repository:

```bash
cd ~/WaterCheck/infra
cp .env.example .env
chmod 600 .env
nano .env
```

The production file must define these values:

```dotenv
POSTGRES_DB=watercheck
POSTGRES_USER=watercheck
POSTGRES_PASSWORD=<random-password>
API_DB_PASSWORD=<different-random-password>

WC_JWT_SECRET=<random-token>
WC_SECRET_KEY=<Fernet-key>

WC_ENVIRONMENT=production
WC_LOG_LEVEL=INFO
HTTP_PORT=80
HTTPS_PORT=443

WC_S3_ACCESS_KEY=watercheck-prod
WC_S3_SECRET_KEY=<random-secret>
WC_SMS_WEBHOOK_TOKEN=<random-token>

WC_SMTP_HOST=mailpit
WC_SMTP_PORT=1025
WC_SMTP_FROM=WaterCheck <no-reply@cooptconnect.app>
```

Generate values on the VM without manually inventing them:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(48))"
python3 -c "import base64, os; print(base64.urlsafe_b64encode(os.urandom(32)).decode())"
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Use different generated values for database passwords, JWT signing, S3
credentials, and webhook tokens. The Fernet value must be generated with the
base64 command above.

Check only the variable names without printing secrets:

```bash
grep -E '^[A-Z0-9_]+=' .env | sed 's/=.*$/=<configured>/'
chmod 600 .env
ls -l .env
```

The `3` in `WC_S3_*` is why the pattern includes `0-9`.

For this learning deployment, Mailpit is acceptable for testing. It does not
deliver mail to real recipients. Before production use, replace it with an
authenticated SMTP provider and wire the provider's credentials into Compose
and the backend settings.

Do not use `docker compose config` output in a public issue or chat: Compose
expands and prints secrets.

## 8. Production Caddy configuration

The production configuration is:

```text
infra/caddy/Caddyfile
```

It provides:

- Flutter Console at `watercheck.cooptconnect.app`.
- `/api/*` routed to `api:8000`.
- `/tiles/*` routed to `tiles:8080`.
- API hostname routed to `api:8000`.
- Automatic HTTPS and HTTP-to-HTTPS redirects.
- Security headers.
- Flutter history fallback to `/index.html`.
- One-day caching for stable Flutter engine assets.

The development `/console/` and `/collect/` routes are not used by the
production Console deployment.

Validate Caddy locally from the `infra` directory:

```powershell
docker run --rm `
  -v "${PWD}\caddy\Caddyfile:/etc/caddy/Caddyfile:ro" `
  caddy:2.11 `
  caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
```

Expected result:

```text
Valid configuration
```

## 9. Validate Compose before startup

From the repository's `infra` directory:

```bash
cd ~/WaterCheck/infra
docker compose config --quiet
```

Exit code `0` means Compose can parse the file and interpolate the environment.
This does not start containers and does not prove that every image or
application dependency is healthy.

## 10. Build the Flutter Console

Flutter must be run from the Console package directory, not from the monorepo
root. Running Flutter from the root produces:

```text
Target file "lib\main.dart" not found.
```

Build on the Windows development machine:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck\apps\console

flutter build web `
  --release `
  --base-href / `
  --dart-define=WC_API_URL=https://watercheck.cooptconnect.app/api `
  --no-web-resources-cdn `
  --no-pub
```

The API URL is a compile-time Flutter define. It is read by the shared data
package and embedded in the generated JavaScript.

Verify the local build:

```powershell
Test-Path .\build\web\index.html
Get-Item .\build\web\index.html
```

The command must finish with:

```text
Built build\web
```

## 11. Transfer the web build reliably

The web build is normally ignored by Git, so transfer it separately to the
VM. A recursive `scp` can be interrupted on large files such as
`canvaskit.wasm`. A compressed archive is more reliable.

From the repository root on Windows:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
tar -czf console-web.tar.gz -C apps\console\build web
```

Copy it:

```powershell
scp -C `
  -o IdentitiesOnly=yes `
  -o ServerAliveInterval=30 `
  -o ServerAliveCountMax=6 `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  ".\console-web.tar.gz" `
  azureuser@<VM_PUBLIC_IP>:~/console-web.tar.gz
```

Extract it on the VM, replacing any incomplete previous transfer:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "mkdir -p ~/WaterCheck/apps/console/build && rm -rf ~/WaterCheck/apps/console/build/web && tar -xzf ~/console-web.tar.gz -C ~/WaterCheck/apps/console/build"
```

Verify the important artifacts:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "ls -lh ~/WaterCheck/apps/console/build/web/index.html ~/WaterCheck/apps/console/build/web/main.dart.js ~/WaterCheck/apps/console/build/web/canvaskit/canvaskit.wasm"
```

Remove temporary archives after verification:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "rm -f ~/console-web.tar.gz"

Remove-Item -LiteralPath ".\console-web.tar.gz"
```

## 12. Commit source configuration, not deployment secrets

Review changes locally:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
git status --short
git diff --check
git diff
```

Commit only the intended source/configuration files:

```powershell
git add infra/caddy/Caddyfile
git commit -m "Configure production Caddy routing"
git push origin main
```

Never add:

```text
infra/.env
*.pem
console-web.tar.gz
apps/console/build/
```

If a build or archive is accidentally staged, unstage it before committing:

```powershell
git restore --staged <path>
```

After pushing source changes, update the VM:

```bash
cd ~/WaterCheck
git pull
```

The `.env` file remains on the VM and is not replaced by `git pull`.

## 13. Start the stack

Only start the stack after the environment, Caddy file, and web build are
ready:

```bash
cd ~/WaterCheck/infra
docker compose config --quiet
docker compose up -d --build
```

The first start builds the API image, runs migrations and seed data, starts
PostgreSQL and SeaweedFS, and then starts the API, worker, tile server, and
Caddy.

## 14. Inspect startup and health

```bash
docker compose ps
docker compose logs --tail=100 api
docker compose logs --tail=100 caddy
docker compose logs --tail=100 migrate
docker compose logs --tail=100 worker
```

Local VM checks:

```bash
curl -i http://127.0.0.1/health
docker compose exec api python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8000/health').read().decode())"
df -h /
free -h
docker system df
```

Public checks after Caddy obtains certificates:

```powershell
curl.exe -I https://watercheck.cooptconnect.app
curl.exe -i https://watercheck.cooptconnect.app/health
curl.exe -i https://api.watercheck.cooptconnect.app/health
```

Expected API health responses should have HTTP status `200`.

Healthy request logs look like:

```text
GET /health ... status 200
GET /v1/sync/pull ... status 200
```

## 15. Client API configuration

The Console web build uses:

```text
https://watercheck.cooptconnect.app/api
```

Android and Windows clients should use:

```text
https://api.watercheck.cooptconnect.app/api
```

The Collect application generally receives its API URL during activation or
setup and persists it with its installation credentials.

## 16. Email configuration

The initial Compose setup uses Mailpit:

```dotenv
WC_SMTP_HOST=mailpit
WC_SMTP_PORT=1025
```

Mailpit is useful for inspecting test messages but is not a public mail
provider. For real email:

1. Create an account with an SMTP provider.
2. Obtain the SMTP host, port, username, password, and sender address.
3. Add the provider values to the VM's `infra/.env`.
4. Ensure Compose passes all corresponding SMTP settings to `api` and `worker`.
5. Restart the affected services.
6. Send a test message and inspect the API/worker logs.

Do not put SMTP credentials in Git, Flutter build arguments, or browser code.

## 17. Updating the deployment

For a normal source/configuration update:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
git pull
# make and validate changes
git add <intended-files>
git commit -m "<change>"
git push origin main
```

On the VM:

```bash
cd ~/WaterCheck
git pull
cd infra
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

For a new web build, rebuild from `apps\console`, archive it, transfer it,
extract it over the old `build/web`, and then restart or recreate Caddy:

```bash
docker compose up -d --force-recreate caddy
```

## 18. Stop the deployment and control cost

Stop containers without deleting persistent volumes:

```bash
cd ~/WaterCheck/infra
docker compose down
```

Do not add `-v` unless intentionally deleting the database, object storage,
and Caddy certificate data.

To stop billing for VM compute when the project is inactive, deallocate the VM
from the Azure portal or CLI. Remember that a stopped/deallocated VM is not
reachable until started again.

## 19. Troubleshooting history

### Azure region policy error

`RequestDisallowedByAzure` means the subscription's allowed-region policy
rejected the selected region. Select one of the allowed regions listed above;
changing the resource name or disk type does not fix the policy.

### SSH private-key permission error

OpenSSH rejected the original key because a broad Windows group could read it.
Restrict the key ACL and use `IdentitiesOnly=yes`.

### SSH public-key authentication failure

The VM login user was `azureuser`, not `watercheck-user`.

### Docker repository command pasted twice

If a command is accidentally duplicated on one shell line, the shell may try
to resolve `curl` as a hostname. Re-run the intended command on a clean line.

### Compose configuration prints secrets

`docker compose config` is useful for diagnosis but expands secrets. Use
`docker compose config --quiet` for routine validation and do not share verbose
output.

### Interrupted web upload

If `scp -r` disconnects before `index.html` arrives, remove the incomplete
remote `build/web` directory and use the archive transfer procedure above.

### Flutter cannot find `lib/main.dart`

Run Flutter from `apps\console`, not from the repository root.

## 20. Current deployment status

At the time this guide was written:

- Azure VM is provisioned and reachable.
- DNS records resolve to the VM.
- Docker and Compose are installed and working.
- The repository is cloned at `~/WaterCheck`.
- The VM `infra/.env` exists with mode `600`.
- Production Caddy configuration is present in the Windows checkout and passed
  Caddy validation.
- Compose publishes Caddy on HTTP port `80` and HTTPS port `443` (TCP and UDP).
- The Console web build succeeded locally with the production API URL.
- The complete Console web build was transferred and verified on the VM.
- No Git commit or push has been performed for the Caddy change yet.
- The full Compose stack has not yet been started on this deployment.

Before starting Compose, confirm:

1. The intended Caddy change is committed and pushed.
2. The VM has pulled the latest source.
3. `docker compose config --quiet` returns exit code `0`.
4. The web files listed in the transfer section exist.
5. No secrets or private keys are staged for commit.
