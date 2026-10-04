FROM docker.io/pglombardo/pwpush:2.14.1@sha256:79d2024f9ade18cf412bb39045309309e96fc5e9815eac8fa2ffd046018c2942

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
