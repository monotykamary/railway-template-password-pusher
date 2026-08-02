FROM docker.io/pglombardo/pwpush:2.9.7@sha256:39b98751577cdd9e79f2b9ff212434909bd42652634a85e40f340bf9ceeb7b01

USER root
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod +x /usr/local/bin/railway-entrypoint

ENV PORT=3000 \
    HTTP_PORT=5100

EXPOSE 5100
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
