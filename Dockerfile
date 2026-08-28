FROM docker.io/pglombardo/pwpush:2.11.5@sha256:39ad515fced205dfbe0a63730b37ae5be5b4d5d8ae11b5b14d69afd935f433ab

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
