# OpenSearch — Railway Template

Single-node OpenSearch cluster on Railway.

## Quick Start

1. **Deploy** — Railway auto-detects the Dockerfile and Nixpacks config.
2. **Auth** — OpenSearch ships with security **enabled by default**.
   - Railway provisions a secret for `OPENSEARCH_ADMIN_PASSWORD` automatically via `${{secret()}}`.
   - If no secret exists, one is created and injected into the container at deploy time.
3. **Access** — Connect on port **9200**:
   ```
   https://your-service.up.railway.app/
   ```

## Security

OpenSearch security is **on by default** (SSL disabled for local networking).

Default credentials (from env):
- **User:** `admin`
- **Password:** the value of `OPENSEARCH_ADMIN_PASSWORD`

### Disable Security (Dev Only)

If you don't need auth during development, set the `DISABLE_SECURITY` variable to `true` in the Railway variables panel.

> ⚠️ **Never disable security in production.**

## Volumes

Data persists at `/usr/share/opensearch/data` across restarts.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DISABLE_SECURITY` | `false` | Set `true` to disable security plugin |
| `OPENSEARCH_ADMIN_PASSWORD` | auto-generated | Admin password for security |
| `OPENSEARCH_JAVA_OPTS` | `-Xmx1G -Xms1G` | JVM heap settings |

## Local Development

```bash
# Run locally via Docker
docker run -e DISABLE_SECURITY=false \
  -e OPENSEARCH_INITIAL_ADMIN_PASSWORD=my-secret-password \
  -p 9200:9200 \
  opensearchproject/opensearch:latest

# Or disable security for quick dev
docker run -e DISABLE_SECURITY=true -p 9200:9200 opensearchproject/opensearch:latest
```
