FROM docker.io/pglombardo/pwpush:2.15.1@sha256:5c31b1292886acfc6e39ba8dd3d85574d9f0bf89ecf1c59bde8dde38fcdb46c7

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
