#!/bin/sh
set -eu
umask 077

workspace='../crypto-workspace'
[ "$#" -le 2 ] || { printf 'Usage: %s [PRIVATE_KEY [PUBLIC_KEY]]\n' "$0" >&2; exit 1; }
private=${1:-"$workspace/secrets/ec-keys/p256.private.pem"}
public=${2:-"$workspace/metadata/public-keys/p256.public.pem"}

command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
[ "$private" != "$public" ] || { printf '%s\n' 'Error: key paths must differ.' >&2; exit 1; }
for file in "$private" "$public"; do
    [ ! -e "$file" ] && [ ! -L "$file" ] || {
        printf 'Error: key already exists: %s\n' "$file" >&2; exit 1;
    }
done
mkdir -p "$(dirname "$private")" "$(dirname "$public")"

trap 'rm -f -- "$private" "$public"' 0
trap 'exit 1' HUP INT TERM

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 \
    -out "$private"
openssl pkey -in "$private" -pubout -out "$public"
chmod 600 "$private" "$public"

openssl pkey -in "$private" -check -noout
openssl pkey -pubin -in "$public" -pubcheck -noout
trap - 0 HUP INT TERM
printf 'KEYS GENERATED: %s ; %s\n' "$private" "$public"
openssl pkey -pubin -in "$public" -text -noout
