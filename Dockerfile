FROM docker.io/pglombardo/pwpush:2.16.1@sha256:d24ecfacc4d902422ed828530cc370d18b750c391beddf790ebb0a67621ea8bd

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
