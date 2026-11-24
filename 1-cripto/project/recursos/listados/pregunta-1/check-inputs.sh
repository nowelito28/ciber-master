#!/bin/sh

set -eu

workspace='../crypto-workspace'
salts="$workspace/metadata/salts"
ids='01 02 03 04 05 06 07 08 09 10'

fail() { printf 'Error: %s\n' "$1" >&2; exit 1; }

check_file() {
    [ -f "$1" ] || fail "Missing file: $1"
    [ "$(wc -c < "$1")" -eq 16 ] || fail "Expected 16 bytes: $1"
    printf 'OK: %s (16 bytes)\n' "$1"
}

check_file "$workspace/secrets/master_key.bin"
for id in $ids; do
    check_file "$salts/file-$id.bin"
done

for left in $ids; do
    for right in $ids; do
        if [ "$left" -lt "$right" ] &&
           cmp -s "$salts/file-$left.bin" "$salts/file-$right.bin"; then
            fail "Duplicate salts: file-$left and file-$right"
        fi
    done
done

printf '%s\n' 'PASS: master key and ten salts are 16 bytes; all salts are distinct.'
