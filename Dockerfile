FROM docker.io/pglombardo/pwpush:2.11.4@sha256:a25e98b537d7e64b1a85de7aee0f95ce8b79ad9cb7a06f6f54574c82d91dd607

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
