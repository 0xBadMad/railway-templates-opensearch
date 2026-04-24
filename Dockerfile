FROM opensearchproject/opensearch:latest

# Persistence — mounted via Railway volume
VOLUME /opensearch/data

EXPOSE 9200 9600

# OpenSearch single-node, no-security dev config
ENV OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g
ENV discovery.type=single-node
ENV plugins.security.disabled=true
ENV OPENSEARCH_INITIAL_ADMIN_PASSWORD=${OPENSEARCH_INITIAL_ADMIN_PASSWORD:-DevPassword123!}

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -s -k -u "admin:${OPENSEARCH_INITIAL_ADMIN_PASSWORD:-DevPassword123!}" http://localhost:9200/_cluster/health > /dev/null 2>&1 || exit 1
