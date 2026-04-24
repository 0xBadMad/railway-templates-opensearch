# OpenSearch — Railway Template

A single-node, development-friendly OpenSearch cluster on Railway, powered by the official `opensearchproject/opensearch` Docker image. Security plugin is disabled for easy local access.

---

## Features

| Feature | Details |
|---|---|
| **Port** | `9200` (REST API), `9600` (performance analyzer) |
| **Security** | Disabled (anonymous access, no TLS) |
| **Mode** | Single-node (`discovery.type=single-node`) |
| **Persistence** | `/opensearch/data` (Railway volume) |
| **Heap** | 1 GB JVM heap (`-Xms1g -Xmx1g`) |
| **Health check** | OpenSearch cluster health API on port 9200 |

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `OPENSEARCH_INITIAL_ADMIN_PASSWORD` | `DevPassword123!` | Admin password for the REST API |
| `OPENSEARCH_JAVA_OPTS` | `-Xms1g -Xmx1g` | JVM heap settings |
| `discovery.type` | `single-node` | Must be single-node when security is disabled |

> **Security note:** The security plugin is disabled for development convenience. Do not use these settings in production or expose the service publicly.

---

## How to Deploy

### Via Railway UI
1. Connect your GitHub repo or create a new project on [railway.app](https://railway.app)
2. Add/upload these template files
3. Railway auto-detects `railway.json` and builds from `Dockerfile`
4. Deploy — first boot takes ~30–90 seconds

### Via CLI
```bash
npm install -g @railway/cli
railway login
railway link <project-id>
railway init
railway up
```

---

## Connecting

### Endpoint
```
http://<host>:9200
```

### Authentication
```
admin:<OPENSEARCH_INITIAL_ADMIN_PASSWORD>
```
Credentials are passed via HTTP Basic Auth. Since security is disabled, in practice any request is accepted, but the admin user is still created with the configured password.

### OpenSearch Dashboards
```
http://<host>:5601
```
Not included in this template — add a separate service if you need the UI.

### Quick Health Check
```bash
curl -s -k -u "admin:DevPassword123!" http://localhost:9200/_cluster/health
```

---

## Index Management

### Create an Index

```bash
curl -X PUT "http://<host>:9200/my-index" \
  -H "Content-Type: application/json" \
  -u "admin:DevPassword123!"
```

### Create an Index with Settings
```bash
curl -X PUT "http://<host>:9200/my-index" \
  -H "Content-Type: application/json" \
  -u "admin:DevPassword123!" \
  -d '{
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }'
```

### Delete an Index
```bash
curl -X DELETE "http://<host>:9200/my-index" \
  -u "admin:DevPassword123!"
```

### List All Indices
```bash
curl -s -u "admin:DevPassword123!" "http://<host>:9200/_cat/indices?v"
```

---

## Document CRUD

### Index a Document
```bash
curl -X PUT "http://<host>:9200/my-index/_doc/1" \
  -H "Content-Type: application/json" \
  -u "admin:DevPassword123!" \
  -d '{
    "title": "Hello OpenSearch",
    "tags": ["search", "devops"],
    "created_at": "2026-01-01",
    "views": 42
  }'
```

### Get a Document
```bash
curl -s -u "admin:DevPassword123!" \
  "http://<host>:9200/my-index/_doc/1"
```

### Search Documents
```bash
curl -X POST "http://<host>:9200/my-index/_search" \
  -H "Content-Type: application/json" \
  -u "admin:DevPassword123!" \
  -d '{
    "query": {
      "match": { "title": "Hello" }
    }
  }'
```

### Delete a Document
```bash
curl -X DELETE "http://<host>:9200/my-index/_doc/1" \
  -u "admin:DevPassword123!"
```

---

## Client Examples

### JavaScript / TypeScript (opensearch-js)
```bash
npm install @opensearch-project/opensearch
```

```typescript
import { Client } from '@opensearch-project/opensearch';

const client = new Client({
  node: 'http://<host>:9200',
  auth: {
    username: 'admin',
    password: process.env.OPENSEARCH_INITIAL_ADMIN_PASSWORD || 'DevPassword123!'
  },
  tls: { rejectUnauthorized: false }
});

const { body } = await client.search({
  index: 'my-index',
  body: {
    query: { match: { title: 'Hello' } }
  }
});

console.log(body.hits.hits);
```

### Python (opensearch-py)
```bash
pip install opensearch-py
```

```python
from opensearchpy import OpenSearch

client = OpenSearch(
    hosts=[{'host': '<host>', 'port': 9200, 'scheme': 'http'}],
    http_auth=('admin', 'DevPassword123!'),
    verify_certs=False
)

# Index a document
client.index(index='my-index', doc_type='_doc', id='1', body={
    'title': 'Hello OpenSearch',
    'tags': ['search', 'devops']
})

# Search
result = client.search(index='my-index', body={
    'query': {'match': {'title': 'Hello'}}
})

print(result['hits']['hits'])
```

### curl (shell)
```bash
# Set convenience vars
OPENSEARCH_HOST=<your-service-name>.railway.app
OPENSEARCH_PASS=DevPassword123!

# Cluster health
curl -s -k -u "admin:$OPENSEARCH_PASS" \
  "http://$OPENSEARCH_HOST:9200/_cluster/health?pretty"

# Search
curl -X POST "http://$OPENSEARCH_HOST:9200/my-index/_search" \
  -H "Content-Type: application/json" \
  -u "admin:$OPENSEARCH_PASS" \
  -d '{"query": {"match_all": {}}}'
```

---

## Production Checklist

- [ ] Set a strong `OPENSEARCH_INITIAL_ADMIN_PASSWORD` (min 14 chars, mixed case + digits + symbol)
- [ ] Re-enable the security plugin for production (remove `plugins.security.disabled=true`)
- [ ] Configure TLS/SSL and roles/permissions
- [ ] Increase JVM heap if indexing large datasets
- [ ] Set `number_of_replicas >= 1` for data durability
- [ ] Enable and test backups (snapshot API to object storage)
- [ ] Use private networking instead of public exposure

---

## More Resources

- [OpenSearch Docs](https://opensearch.org/docs/latest/)
- [OpenSearch JavaScript Client](https://github.com/opensearch-project/opensearch-js)
- [OpenSearch Python Client](https://github.com/opensearch-project/opensearch-py)
- [Official Docker Image](https://hub.docker.com/r/opensearchproject/opensearch)
- [Railway Docs](https://docs.railway.app/)
