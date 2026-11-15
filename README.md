# Password Pusher on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/password-pusher-secure?referralCode=ZqgrJ0)

Deploy Password Pusher 2.17.2 on Railway with encrypted secret sharing, the built-in background worker, and persistent SQLite storage.

## What this deploys

- Password Pusher `2.17.2`, pinned to the upstream Linux/AMD64 image digest
- The web process and Solid Queue worker from the official image
- One Railway volume mounted at `/opt/PasswordPusher/storage`
- Railway-managed HTTPS on public port `5100`

## First administrator

Open the deployed site. Password Pusher redirects to `/first_run` and prints a one-time boot code in the application deployment logs. Use that code to create the first administrator. The code is removed after successful setup.

## Required configuration

The template generates and preserves:

- `PWPUSH_MASTER_KEY`: 64 hexadecimal characters used to encrypt pushes
- `SECRET_KEY_BASE`: persistent Rails session-signing secret

Changing `PWPUSH_MASTER_KEY` after creating pushes makes existing encrypted data unreadable. Do not replace it without following the upstream key-rotation procedure.

## Persistence and backups

The application database, boot code, and local file pushes live in `/opt/PasswordPusher/storage`. The template attaches a daily-backed-up Railway volume there. Redeploying the service does not remove stored pushes or users.

For larger installations, Password Pusher also supports PostgreSQL and S3, but this template intentionally uses the upstream-supported single-container SQLite topology.

## Limitations

- The upstream `2.17.2` image publishes Linux/AMD64 only.
- SMTP is optional and must be configured before enabling account email features.
- Railway terminates TLS; the image listens on unprivileged HTTP port `5100` internally.

## Updating

Back up the storage volume and retain `PWPUSH_MASTER_KEY` and `SECRET_KEY_BASE` before upgrading. The release checks preserved the original encrypted push across the image update and exact-version redeployment. For rollback, restore the matching database and storage backup rather than assuming an older binary can read a migrated database.

Version updates are deliberate. Update both the image tag and immutable digest in `Dockerfile`, review upstream release notes and migrations, then repeat create/retrieve, worker, persistence, redeploy, and log-soak tests.

## Validation

```bash
npm test
BASE_URL=https://your-domain.example ./scripts/smoke.sh
```

## Upstream

- Source: https://github.com/pglombardo/PasswordPusher
- Release: https://github.com/pglombardo/PasswordPusher/releases/tag/v2.17.2
- Documentation: https://docs.pwpush.com/
- License: Apache License 2.0

This repository contains a small Railway port adapter and deployment documentation. Password Pusher remains copyright its upstream contributors and is not affiliated with Railway.

## Stateful validation

`python3 scripts/smoke.py` reads `BASE_URL` and `SMOKE_PHASE` (`boot`, `upgrade`, `redeploy`). It creates the first administrator only at boot and verifies the same encrypted push payload after upgrades and redeploys. Validation state stays private and must not be published. Live first-run validation takes `PWPUSH_BOOT_CODE`, `PWPUSH_ADMIN_EMAIL`, and `PWPUSH_ADMIN_PASSWORD` from the environment. Boat validation may read the generated boot code from the exact isolated service container; no production HTTPS or secure-cookie setting is changed.
