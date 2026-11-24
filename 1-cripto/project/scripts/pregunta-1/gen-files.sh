#!/bin/sh
# Generate ten random binary files. Run from scripts/pregunta-1.
# Optional argument: initial file size in bytes (default: 1024).
set -eu
umask 077

workspace='../crypto-workspace'
output="$workspace/originals/pregunta-1"

[ "$#" -le 1 ] || { printf 'Usage: %s [BYTES]\n' "$0" >&2; exit 1; }

size=${1:-1024}
case "$size" in ''|*[!0-9]*) printf '%s\n' 'Error: BYTES must be a positive integer.' >&2; exit 1;; esac
[ "$size" -gt 0 ] || { printf '%s\n' 'Error: BYTES must be positive.' >&2; exit 1; }

command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'Error: OpenSSL not found.' >&2; exit 1; }

# Preserve existing originals; a fresh directory is required for this batch.
mkdir "$output"
current=''

trap '[ -z "$current" ] || rm -f -- "$current"' 0
trap 'exit 1' HUP INT TERM

for id in 01 02 03 04 05 06 07 08 09 10; do

    current="$output/file-$id.bin"

    openssl rand -out "$current" "$size"
    printf 'GENERATED: file-%s\n' "$id"

    wc -c "$current"
    current=''

    # Vary the lengths to exercise CBC padding with different input sizes.
    size=$((size + 1))

done

trap - 0 HUP INT TERM
