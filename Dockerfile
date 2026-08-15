FROM docker.io/pglombardo/pwpush:2.11.0@sha256:1524ce45e7a9cbf0123f7753494978f67c843b814f93dc664266784dbb4f45a9

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
