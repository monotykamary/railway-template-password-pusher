FROM docker.io/pglombardo/pwpush:2.14.3@sha256:4b46570c65b9f4d6bd098d8790211eeacafded4d889b1ecdeabf31e009c60377

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
