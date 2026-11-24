#!/bin/sh
# Reconstruct both keys with PBKDF2, verify HMAC, then decrypt with AES-128-CBC.
# Run from scripts/pregunta-1. Only the master key and protected files are needed.
set -eu
umask 077

workspace='../crypto-workspace'
master="$workspace/secrets/master_key.bin"
output_dir="$workspace/decrypted/pregunta-1"

[ "$#" -eq 0 ] || { printf 'Usage: %s\n' "$0" >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }
[ -f "$master" ] && [ "$(wc -c < "$master")" -eq 16 ] || {
    printf '%s\n' 'Error: the master key must contain 16 bytes.' >&2; exit 1;
}

master_hex=$(od -An -v -tx1 "$master" | tr -d '[:space:]')
mkdir -p "$output_dir"
output=''

trap '[ -z "$output" ] || rm -f -- "$output"' 0
trap 'exit 1' HUP INT TERM

for id in 01 02 03 04 05 06 07 08 09 10; do

    input="$workspace/encrypted/pregunta-1/file-$id.protected"
    [ -f "$input" ] || { printf 'Error: missing file: %s\n' "$input" >&2; exit 1; }
    size=$(wc -c < "$input")
    ciphertext_size=$((size - 48 - 32))
    [ "$ciphertext_size" -ge 16 ] && [ "$((ciphertext_size % 16))" -eq 0 ] &&
    [ "$(head -c 6 "$input")" = "P1E1$id" ] || {
        printf 'REJECT: invalid format for file-%s.\n' "$id" >&2; exit 1;
    }

    # Read the original derivation parameters from the fixed-width header.
    iterations=$(dd if="$input" bs=1 skip=6 count=10 2>/dev/null)
    case "$iterations" in ''|*[!0-9]*) printf '%s\n' 'REJECT: invalid iterations.' >&2; exit 1;; esac
    iterations=$(printf '%s' "$iterations" | sed 's/^0*//')

    # Bound the cost before processing a header that is not yet authenticated.
    [ -n "$iterations" ] && [ "$iterations" -le 10000000 ] || {
        printf '%s\n' 'REJECT: iteration count must be between 1 and 10000000.' >&2; exit 1;
    }
    salt_hex=$(od -An -v -j 16 -N 16 -tx1 "$input" | tr -d '[:space:]')
    iv_hex=$(od -An -v -j 32 -N 16 -tx1 "$input" | tr -d '[:space:]')

    # Reconstruct the same 48 bytes without creating any derived-key files.
    derived_hex=$(openssl kdf -keylen 48 \
        -kdfopt digest:SHA256 -kdfopt "hexpass:$master_hex" \
        -kdfopt "hexsalt:$salt_hex" -kdfopt "iter:$iterations" PBKDF2)
    derived_hex=$(printf '%s' "$derived_hex" | tr -d '[:space:]:')

    [ "${#derived_hex}" -eq 96 ] || exit 1
    encryption_hex=$(printf '%s' "$derived_hex" | cut -c 1-32)
    authentication_hex=$(printf '%s' "$derived_hex" | cut -c 33-96)

    # Authenticate the full header and ciphertext, excluding the stored 32-byte tag.
    expected=$(head -c "$((size - 32))" "$input" |
        openssl mac -digest SHA256 -macopt "hexkey:$authentication_hex" HMAC)
    received=$(tail -c 32 "$input" | od -An -v -tx1 | tr -d '[:space:]')
    [ "${#expected}" -eq 64 ] && [ "${#received}" -eq 64 ] || exit 1

    # Compare all 32 bytes without stopping at the first difference.
    # Fixed work avoids early exit; the shell still cannot guarantee constant-time execution.
    difference=0
    while [ -n "$expected" ]; do
        left=${expected%"${expected#??}"}
        right=${received%"${received#??}"}
        difference=$((difference | (0x$left ^ 0x$right)))
        expected=${expected#??}
        received=${received#??}
    done
    [ "$difference" -eq 0 ] || {
        printf 'REJECT: authentication failed for file-%s.\n' "$id" >&2; exit 1;
    }

    # Only authenticated ciphertext reaches AES; OpenSSL validates/removes PKCS#7 padding.
    output="$output_dir/file-$id.bin"
    [ ! -L "$output" ] || { output=''; printf '%s\n' 'Error: symbolic-link output.' >&2; exit 1; }
    : > "$output"
    chmod 600 "$output"

    dd if="$input" bs=1 skip=48 count="$ciphertext_size" 2>/dev/null |
        openssl enc -d -aes-128-cbc -nosalt -K "$encryption_hex" -iv "$iv_hex" -out "$output"

    printf 'VERIFIED AND DECRYPTED: file-%s (PBKDF2: %s iterations)\n' "$id" "$iterations"
    wc -c "$output"
    output=''

done

trap - 0 HUP INT TERM
