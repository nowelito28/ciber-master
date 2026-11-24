#!/bin/sh
set -eu
umask 077

workspace='../crypto-workspace'

[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [KEY [OUTPUT]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/originals/tarea.pdf"}
key=${2:-"$workspace/secrets/derived-keys/file-01.encryption.bin"}
output=${3:-"$workspace/encrypted/$(basename "$input").cms"}

command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
[ -f "$input" ] || { printf 'Error: input not found: %s\n' "$input" >&2; exit 1; }
[ -f "$key" ] && [ "$(wc -c < "$key")" -eq 16 ] || {
    printf '%s\n' 'Error: the binary key must contain exactly 16 bytes.' >&2; exit 1;
}

if [ "$output" -ef "$input" ] || [ "$output" -ef "$key" ]; then
    printf '%s\n' 'Error: output must differ from the input and key.' >&2
    exit 1
fi

kek_hex=$(od -An -v -tx1 "$key" | tr -d '[:space:]')

mkdir -p "$(dirname "$output")"
: > "$output"

trap 'rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM
chmod 600 "$output"

openssl cms -encrypt -binary -aes-128-gcm \
    -secretkey "$kek_hex" -secretkeyid 01 \
    -in "$input" -outform DER -out "$output"

trap - 0 HUP INT TERM
printf 'ENCRYPTED: %s -> %s\n' "$input" "$output"

wc -c "$input" "$output"
