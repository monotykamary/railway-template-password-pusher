FROM docker.io/pglombardo/pwpush:2.17.2@sha256:0fa747bb32c73141a54fc8584be7c092252d6fa631c6cab951df431e9d8e711a

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
