FROM opensearchproject/opensearch:latest
ENV discovery.type=single-node
ENV plugins.security.disabled=true
ENV OPENSEARCH_JAVA_OPTS=-Xmx1G -Xms1G
