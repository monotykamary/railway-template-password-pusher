FROM docker.io/pglombardo/pwpush:2.14.0@sha256:6865d759358cbd3cb4e3132c0ef5a58b09d9ff29726693595d5923ce82eee8a5

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
