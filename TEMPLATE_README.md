# Deploy and Host Password Pusher on Railway

## About Hosting Password Pusher

Password Pusher is an encrypted secret-sharing application. This template deploys upstream version 2.11.4 with its web process, expiration worker, and persistent local storage.

After deployment, open the application and read its deployment logs for the one-time boot code required by `/first_run`. The boot code creates the first administrator and is then removed.

## Common Use Cases

- Send passwords or API keys using links that expire by time or view count
- Share sensitive URLs, QR codes, and small files
- Maintain an internal, self-hosted secret handoff service

## Dependencies for Password Pusher Hosting

### Deployment Dependencies

- One Password Pusher service
- One daily-backed-up Railway volume
- Optional external SMTP service for account emails

### Implementation Details

The service uses the official Password Pusher 2.11.4 Linux/AMD64 image pinned by digest. Railway terminates HTTPS and routes traffic to unprivileged internal port 5100. The upstream web process and Solid Queue worker run together, which allows both processes to use the same SQLite database and local file storage safely.

`PWPUSH_MASTER_KEY` and `SECRET_KEY_BASE` are generated during template deployment. Never replace the master key casually: existing pushes depend on it. Cross-service references are not required in this single-service topology.

Persistent data is mounted at `/opt/PasswordPusher/storage` and receives daily Railway backups.

## Why Deploy Password Pusher on Railway?

Railway supplies managed HTTPS, durable storage, deployment logs for the secure first-run flow, health checks, and repeatable redeployment without introducing a separate reverse proxy or database for small installations.
