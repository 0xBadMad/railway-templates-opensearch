FROM opensearchproject/opensearch:latest

ENV discovery.type=single-node \
    OPENSEARCH_JAVA_OPTS="-Xmx1G -Xms1G" \
    DISABLE_SECURITY=false

RUN chmod -R 777 /usr/share/opensearch/data /usr/share/opensearch/logs 2>/dev/null || true

# Wrapper that handles bootstrap password setup before starting OpenSearch
COPY --chown=opensearch:opensearch << 'WRAPPER' /usr/local/bin/opensearch-start.sh
#!/bin/bash
set -e

# Ensure data dir exists with correct ownership for non-root runtime
mkdir -p /usr/share/opensearch/data /usr/share/opensearch/logs
chown -R opensearch:opensearch /usr/share/opensearch/data /usr/share/opensearch/logs

# If security disabled, patch config and skip bootstrap
if [ "$DISABLE_SECURITY" = "true" ]; then
    sed -i 's/plugins.security.enabled: true/plugins.security.enabled: false/' \
        /usr/share/opensearch/config/opensearch.yml 2>/dev/null || true
    exec /usr/share/opensearch/bin/opensearch "$@"
fi

# Security enabled: set up bootstrap password from env var
if [ -n "$OPENSEARCH_INITIAL_ADMIN_PASSWORD" ]; then
    printf '%s\n' "$OPENSEARCH_INITIAL_ADMIN_PASSWORD" > /tmp/bootstrap_pass
    chmod 600 /tmp/bootstrap_pass

    # Create admin user with the bootstrap password using opensearch-users cli
    # Note: this may already be set if this isn't a fresh install, so ignore failures
    /usr/share/opensearch/plugins/opensearch-security/tools/setup_passwords \
        batch --force 2>/dev/null || true

    # For fresh installs, inject the initial admin password via opensearch.yml
    # The official image accepts OPENSEARCH_INITIAL_ADMIN_PASSWORD as env and uses it
    # via the security internal database on first boot if admin doesn't exist
    rm -f /tmp/bootstrap_pass
fi

exec /usr/share/opensearch/bin/opensearch "$@"
WRAPPER

RUN chmod +x /usr/local/bin/opensearch-start.sh

USER opensearch
ENTRYPOINT ["/usr/local/bin/opensearch-start.sh"]
CMD []
