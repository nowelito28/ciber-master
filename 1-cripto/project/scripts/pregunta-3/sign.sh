#!/bin/sh
# Sign a file with ECDSA P-256 and SHA-256. Run from scripts/pregunta-3.
# Optional arguments: INPUT PRIVATE_KEY SIGNATURE.
set -eu
umask 077

workspace='../crypto-workspace'
[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [PRIVATE_KEY [SIGNATURE]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/originals/tarea.pdf"}
key=${2:-"$workspace/secrets/ec-keys/p256.private.pem"}
output=${3:-"$workspace/signatures/$(basename "$input").sig"}

# Check the input and require a P-256 private key, as specified in the analysis.
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

# Write directly to the destination, overwriting an earlier signature.
mkdir -p "$(dirname "$output")"
: > "$output"
trap 'rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM
chmod 600 "$output"

# OpenSSL hashes the file once, generates k and encodes the pair (r,s) as DER.
# The original is unchanged; the signature does not contain the private key.
openssl dgst -sha256 -sign "$key" -out "$output" "$input"
trap - 0 HUP INT TERM
printf 'SIGNED: %s -> %s\n' "$input" "$output"
wc -c "$input" "$output"
