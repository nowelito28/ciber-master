#!/bin/sh
# Verify a detached ECDSA P-256/SHA-256 signature. Run from scripts/pregunta-3.
# Optional arguments: INPUT PUBLIC_KEY SIGNATURE.
set -eu

workspace='../crypto-workspace'
[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [PUBLIC_KEY [SIGNATURE]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/originals/tarea.pdf"}
key=${2:-"$workspace/metadata/public-keys/p256.public.pem"}
signature=${3:-"$workspace/signatures/$(basename "$input").sig"}

# Verification needs the file, signature and trusted public key, never the private key.
command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
for file in "$input" "$key" "$signature"; do
    [ -f "$file" ] || { printf 'Error: file not found: %s\n' "$file" >&2; exit 1; }
done
openssl pkey -pubin -in "$key" -text -noout | grep -q 'ASN1 OID: prime256v1' || {
    printf '%s\n' 'Error: expected a P-256 public key.' >&2; exit 1;
}

# Recompute SHA-256 and check (r,s) against the public key and curve parameters.
# A failure rejects this file/signature/key combination; no input is deleted.
if openssl dgst -sha256 -verify "$key" -signature "$signature" "$input"; then
    printf 'ACCEPT: valid signature for %s\n' "$input"
else
    printf 'REJECT: invalid signature for %s\n' "$input" >&2
    exit 1
fi
