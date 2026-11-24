#!/bin/sh
# Encrypt ten files with AES-128-CBC, then authenticate with HMAC-SHA-256.
# Run from scripts/pregunta-1. Use the keys already derived in question 1.
set -eu
umask 077

workspace='../crypto-workspace'
keys="$workspace/secrets/derived-keys"
output_dir="$workspace/encrypted/pregunta-1"

[ "$#" -eq 0 ] || { printf 'Usage: %s\n' "$0" >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }

iterations=$(cat "$keys/iterations.txt")
case "$iterations" in ''|*[!0-9]*) printf '%s\n' 'Error: invalid iteration count.' >&2; exit 1;; esac
[ "$iterations" -gt 0 ] && [ "$iterations" -le 10000000 ] || {
    printf '%s\n' 'Error: iterations must be between 1 and 10000000.' >&2; exit 1;
}

mkdir -p "$output_dir"

# Remove only the current incomplete output if any operation fails.
output=''
trap '[ -z "$output" ] || rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM

for id in 01 02 03 04 05 06 07 08 09 10; do

    input="$workspace/originals/pregunta-1/file-$id.bin"
    encryption="$keys/file-$id.encryption.bin"
    authentication="$keys/file-$id.authentication.bin"
    salt="$workspace/metadata/salts/file-$id.bin"

    for file in "$input" "$encryption" "$authentication" "$salt"; do
        [ -f "$file" ] || { printf 'Error: missing file: %s\n' "$file" >&2; exit 1; }
    done

    [ "$(wc -c < "$encryption")" -eq 16 ] &&
    [ "$(wc -c < "$authentication")" -eq 32 ] &&
    [ "$(wc -c < "$salt")" -eq 16 ] || {
        printf 'Error: invalid key or salt size for file-%s.\n' "$id" >&2; exit 1;
    }

    encryption_hex=$(od -An -v -tx1 "$encryption" | tr -d '[:space:]')
    authentication_hex=$(od -An -v -tx1 "$authentication" | tr -d '[:space:]')

    output="$output_dir/file-$id.protected"

    # Never replace an original or key through a symbolic link.
    [ ! -L "$output" ] || { output=''; printf '%s\n' 'Error: symbolic-link output.' >&2; exit 1; }
    : > "$output"
    chmod 600 "$output"

    # Fixed 48-byte header: version (4), file ID (2), iterations (10), salt (16), IV (16).
    printf 'P1E1%s%010d' "$id" "$iterations" > "$output"
    cat "$salt" >> "$output"
    openssl rand 16 >> "$output"
    iv_hex=$(tail -c 16 "$output" | od -An -v -tx1 | tr -d '[:space:]')

    # Raw AES key and IV; OpenSSL adds PKCS#7 padding. No password KDF is repeated.
    openssl enc -aes-128-cbc -nosalt -K "$encryption_hex" -iv "$iv_hex" \
        -in "$input" >> "$output"

    # Authenticate the complete header and ciphertext; append the 32-byte tag.
    # dgst writes its result only after reading the existing file to the end.
    openssl dgst -sha256 -mac HMAC -macopt "hexkey:$authentication_hex" \
        -binary "$output" >> "$output"
    printf 'ENCRYPTED AND AUTHENTICATED: file-%s\n' "$id"

    wc -c "$input" "$output"
    output=''

done

trap - 0 HUP INT TERM
