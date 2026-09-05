FROM docker.io/pglombardo/pwpush:2.11.6@sha256:782a80cff4fd378c375ce8becf850d369225df04ab5cb6c5eb009ee3e72a24e3

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
