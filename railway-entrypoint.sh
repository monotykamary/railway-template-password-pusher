#!/bin/sh
set -eu

storage=/opt/PasswordPusher/storage
mkdir -p "$storage/db"
chown pwpusher:pwpusher "$storage" "$storage/db"

exec su-exec pwpusher:pwpusher /usr/local/bin/docker-entrypoint "$@"
