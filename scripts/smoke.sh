#!/bin/sh
set -eu

: "${BASE_URL:?Set BASE_URL to the deployed Password Pusher origin}"
base=${BASE_URL%/}

health=$(curl -fsS "$base/up")
printf '%s' "$health" | grep -q "background:green"

home=$(curl -fsSL "$base/")
printf '%s' "$home" | grep -q "Password Pusher"

setup=$(curl -fsS -c /tmp/pwpush-cookies "$base/first_run")
if printf '%s' "$setup" | grep -q 'user_boot_code'; then
  token=$(printf '%s' "$setup" | sed -n 's/.*name="authenticity_token" value="\([^"]*\)".*/\1/p' | head -n 1)
  [ -n "$token" ]
  status=$(curl -sS -b /tmp/pwpush-cookies -o /tmp/pwpush-invalid -w '%{http_code}' \
    --data-urlencode "authenticity_token=$token" \
    --data-urlencode 'user[boot_code]=definitely-invalid-template-probe' \
    --data-urlencode 'user[email]=invalid-template-probe@example.invalid' \
    --data-urlencode 'user[password]=NotARealPassword123!' \
    "$base/first_run")
  [ "$status" = "422" ]
  grep -qi 'invalid' /tmp/pwpush-invalid
else
  status=$(curl -sS -o /tmp/pwpush-invalid -w '%{http_code}' "$base/p/not-a-valid-template-probe.json")
  [ "$status" = "404" ]
  grep -q 'not-found' /tmp/pwpush-invalid
fi
rm -f /tmp/pwpush-cookies /tmp/pwpush-invalid

printf '%s\n' "Password Pusher smoke checks passed"
