FROM docker.io/pglombardo/pwpush:2.13.0@sha256:d6b6dc57e71ad363f8f304efd70f529e7793739e6bb10f9c4ed480bfaf01b8fa

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
