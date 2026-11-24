#!/bin/sh
set -eu
umask 077

workspace='../crypto-workspace'
[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [PRIVATE_KEY [SIGNATURE]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/originals/tarea.pdf"}
key=${2:-"$workspace/secrets/ec-keys/p256.private.pem"}
output=${3:-"$workspace/signatures/$(basename "$input").sig"}

command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
[ -f "$input" ] && [ -f "$key" ] || {
    printf '%s\n' 'Error: input or private key not found.' >&2; exit 1;
}
openssl pkey -in "$key" -text_pub -noout | grep -q 'ASN1 OID: prime256v1' || {
    printf '%s\n' 'Error: expected a P-256 private key.' >&2; exit 1;
}
if [ "$output" -ef "$input" ] || [ "$output" -ef "$key" ]; then
    printf '%s\n' 'Error: signature output must differ from the input and key.' >&2
    exit 1
fi

mkdir -p "$(dirname "$output")"
: > "$output"
trap 'rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM
chmod 600 "$output"

openssl dgst -sha256 -sign "$key" -out "$output" "$input"
trap - 0 HUP INT TERM
printf 'SIGNED: %s -> %s\n' "$input" "$output"
wc -c "$input" "$output"
