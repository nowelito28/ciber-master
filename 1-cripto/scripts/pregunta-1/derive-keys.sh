#!/bin/sh
# Derive encryption and authentication keys from the master key and salts.
# Usage: chmod +x ./derive-keys.sh && ./derive-keys.sh

set -eu
umask 077

workspace='./crypto-workspace'
output="$workspace/secrets/derived-keys"
iterations=600000

# Read the binary master key as hexadecimal.
master_hex=$(od -An -v -tx1 "$workspace/secrets/master_key.bin" | tr -d '[:space:]')

# Create the output directory and save the iteration count.
mkdir "$output"
printf '%s\n' "$iterations" > "$output/iterations.txt"

for id in 01 02 03 04 05 06 07 08 09 10; do
    # Read each binary salt file as hexadecimal.
    salt_hex=$(od -An -v -tx1 "$workspace/metadata/salts/file-$id.bin" | tr -d '[:space:]')

    derived="$output/file-$id.derived.bin"
    encryption="$output/file-$id.encryption.bin"
    authentication="$output/file-$id.authentication.bin"

    # Derive 48 bytes using PBKDF2-HMAC-SHA-256.
    openssl kdf -binary -keylen 48 \
        -kdfopt digest:SHA256 \
        -kdfopt "hexpass:$master_hex" \
        -kdfopt "hexsalt:$salt_hex" \
        -kdfopt "iter:$iterations" \
        -out "$derived" PBKDF2

    # First 16 bytes: AES-128 encryption key for each file.
    dd if="$derived" of="$encryption" \
        bs=1 count=16 2>/dev/null

    # Remaining 32 bytes: HMAC-SHA-256 authentication key for each file.
    dd if="$derived" of="$authentication" \
        bs=1 skip=16 count=32 2>/dev/null

    # Remove the intermediate 48-byte key material.
    rm "$derived"

    # Show the actual sizes of this file's two keys.
    printf 'Derived keys for file-%s:\n' "$id"
    wc -c "$encryption" "$authentication"
done
