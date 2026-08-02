#!/bin/sh
set -eu

: "${BASE_URL:?Set BASE_URL to the deployed Password Pusher origin}"
base=${BASE_URL%/}

health=$(curl -fsS "$base/up")
printf '%s' "$health" | grep -q "background:green"

home=$(curl -fsS "$base/")
printf '%s' "$home" | grep -q "Password Pusher"

status=$(curl -sS -o /tmp/pwpush-invalid.json -w '%{http_code}' "$base/p/not-a-valid-template-probe.json")
[ "$status" = "404" ]
grep -q 'not-found' /tmp/pwpush-invalid.json
rm -f /tmp/pwpush-invalid.json

printf '%s\n' "Password Pusher smoke checks passed"
