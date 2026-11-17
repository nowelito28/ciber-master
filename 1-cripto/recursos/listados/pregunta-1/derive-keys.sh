#!/bin/sh

set -eu
umask 077

workspace='./crypto-workspace'
output="$workspace/secrets/derived-keys"
iterations=600000

master_hex=$(od -An -v -tx1 "$workspace/secrets/master_key.bin" | tr -d '[:space:]')

mkdir "$output"
printf '%s\n' "$iterations" > "$output/iterations.txt"

for id in 01 02 03 04 05 06 07 08 09 10; do
    salt_hex=$(od -An -v -tx1 "$workspace/metadata/salts/file-$id.bin" | tr -d '[:space:]')

    derived="$output/file-$id.derived.bin"
    encryption="$output/file-$id.encryption.bin"
    authentication="$output/file-$id.authentication.bin"

    openssl kdf -binary -keylen 48 \
        -kdfopt digest:SHA256 \
        -kdfopt "hexpass:$master_hex" \
        -kdfopt "hexsalt:$salt_hex" \
        -kdfopt "iter:$iterations" \
        -out "$derived" PBKDF2

    dd if="$derived" of="$encryption" \
        bs=1 count=16 2>/dev/null

    dd if="$derived" of="$authentication" \
        bs=1 skip=16 count=32 2>/dev/null

    rm "$derived"

    printf 'Derived keys for file-%s:\n' "$id"
    wc -c "$encryption" "$authentication"
done
