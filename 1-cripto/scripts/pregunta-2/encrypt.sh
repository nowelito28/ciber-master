#!/bin/sh
# Encrypt a binary file with AES-128-GCM in a CMS container.
# Optional arguments: INPUT KEY OUTPUT. Run from scripts/pregunta-2.
# Stop on command errors or unset variables; restrict new files to their owner.
set -eu
umask 077

# Use the workspace shared by all practice questions.
workspace='../crypto-workspace'

# Accept optional paths, otherwise use the assignment and the first derived key.
[ "$#" -le 3 ] || { printf 'Usage: %s [INPUT [KEY [OUTPUT]]]\n' "$0" >&2; exit 1; }
input=${1:-"$workspace/originals/tarea.pdf"}
key=${2:-"$workspace/secrets/derived-keys/file-01.encryption.bin"}
output=${3:-"$workspace/encrypted/$(basename "$input").cms"}

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

# K_1^cif from question 1 is the KEK (Key Encryption Key), not the GCM key.
# Convert the binary key to the hexadecimal format required by OpenSSL.
kek_hex=$(od -An -v -tx1 "$key" | tr -d '[:space:]')

# Create or overwrite the destination before starting the operation.
mkdir -p "$(dirname "$output")"
: > "$output"

# Delete this output if the operation fails or receives an interruption.
trap 'rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM
chmod 600 "$output"

# CMS generates K_i^GCM (16 bytes) and V_i (12 bytes) for this encryption.
# AES-GCM handles CTR, GHASH and T_i (16 bytes) internally, without padding.
# No application metadata is supplied: AAD (Additional Authenticated Data) is empty.
# Store the wrapped K_i^GCM, V_i, C_i and T_i in a binary DER CMS container.
openssl cms -encrypt -binary -aes-128-gcm \
    -secretkey "$kek_hex" -secretkeyid 01 \
    -in "$input" -outform DER -out "$output"

# Keep the completed container after successful encryption.
trap - 0 HUP INT TERM
printf 'ENCRYPTED: %s -> %s\n' "$input" "$output"

# Display the actual input and protected-container sizes in bytes.
wc -c "$input" "$output"
