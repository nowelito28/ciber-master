#!/bin/sh
# Authenticate and decrypt a CMS file; remove the output on failure.
# Optional arguments: INPUT KEY OUTPUT. Run from scripts/pregunta-2.
# Stop on command errors or unset variables; restrict new files to their owner.
set -eu
umask 077

# Use the workspace shared by all practice questions.
workspace='../crypto-workspace'

# Accept optional paths, otherwise use the assignment and the first derived key.
[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [KEY [OUTPUT]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/encrypted/tarea.pdf.cms"}
key=${2:-"$workspace/secrets/derived-keys/file-01.encryption.bin"}
output=${3:-"$workspace/decrypted/$(basename "$input" .cms)"}

# Check OpenSSL, the input file and the 16-byte binary key.
command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
[ -f "$input" ] || { printf 'Error: input not found: %s\n' "$input" >&2; exit 1; }
[ -f "$key" ] && [ "$(wc -c < "$key")" -eq 16 ] || {
    printf '%s\n' 'Error: the binary key must contain exactly 16 bytes.' >&2; exit 1;
}

# Protect the input and key, including symbolic links and hard links to them.
if [ "$output" -ef "$input" ] || [ "$output" -ef "$key" ]; then
    printf '%s\n' 'Error: output must differ from the input and key.' >&2
    exit 1
fi

# Read the same K_1^cif (KEK) used to protect the content key at encryption.
# Convert its binary bytes to the hexadecimal format required by OpenSSL.
kek_hex=$(od -An -v -tx1 "$key" | tr -d '[:space:]')

# Require the authenticated CMS format and AES-128-GCM, not an unauthenticated mode.
container=$(openssl cms -cmsout -print -inform DER -in "$input")
printf '%s\n' "$container" | grep -q '^  contentType: id-smime-ct-authEnvelopedData ' &&
printf '%s\n' "$container" | grep -q '^        algorithm: aes-128-gcm ' || {
    printf '%s\n' 'Error: expected an AES-128-GCM AuthEnvelopedData container.' >&2; exit 1;
}

# Create or overwrite the destination before starting the operation.
mkdir -p "$(dirname "$output")"
: > "$output"

# Delete this output if the operation fails or receives an interruption.
trap 'rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM
chmod 600 "$output"

# The KEK recovers K_i^GCM; CMS reads the original V_i, C_i and T_i.
# OpenSSL rebuilds the CTR stream and verifies T_i using GHASH and AES.
# It reuses the stored IV, requires no padding removal and handles AAD internally.
# The directly written plaintext remains provisional until authentication succeeds.
if ! openssl cms -decrypt -binary -inform DER \
    -secretkey "$kek_hex" -secretkeyid 01 \
    -in "$input" -out "$output"; then
    printf '%s\n' 'Error: decryption or authentication failed; the output will be removed.' >&2
    exit 1
fi

# Keep the recovered file only after successful authentication.
trap - 0 HUP INT TERM
printf 'DECRYPTED AND AUTHENTICATED: %s -> %s\n' "$input" "$output"

# Display the recovered file size in bytes.
wc -c "$output"
