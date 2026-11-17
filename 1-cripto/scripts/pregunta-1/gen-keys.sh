#!/bin/sh
# Every deletion requires confirmation.
# Usage: chmod +x ./gen-keys.sh && ./gen-keys.sh

set -eu
umask 077

workspace='./crypto-workspace'
ids='01 02 03 04 05 06 07 08 09 10'

command -v openssl >/dev/null 2>&1 || { printf 'Error: OpenSSL not found.\n' >&2; exit 1; }
[ -f ./prepare-inputs.sh ] || { printf 'Error: prepare-inputs.sh not found.\n' >&2; exit 1; }

generate() {
    mkdir "$workspace" || return 1
    mkdir -p "$workspace/secrets" "$workspace/metadata/salts" \
        "$workspace/originals" "$workspace/encrypted" \
        "$workspace/decrypted" || return 1

    openssl rand -out "$workspace/secrets/master_key.bin" 16 || return 1
    for id in $ids; do
        openssl rand -out "$workspace/metadata/salts/file-$id.bin" 16 || return 1
    done

    sh ./prepare-inputs.sh || return 1
    wc -c "$workspace/secrets/master_key.bin" \
        "$workspace"/metadata/salts/file-*.bin || return 1
}

while :; do
    if [ -e "$workspace" ] || [ -L "$workspace" ]; then
        printf 'Workspace to delete: %s/%s\n' "$(pwd -P)" "$workspace"
        printf '%s\n' 'All keys and files inside will be permanently deleted.'
        printf 'Type DELETE to remove it and start again: '
        IFS= read -r answer || answer=''
        if [ "$answer" != DELETE ]; then
            printf '%s\n' 'Cancelled. The existing workspace was preserved.'
            exit 1
        fi
        rm -rf -- "$workspace" || exit 1
    fi

    if generate; then
        printf '%s\n' 'Workspace created and validated successfully.'
        break
    fi

    printf '%s\n' 'Generation or validation failed. Confirmation is required before cleanup and retry.' >&2
    if [ ! -e "$workspace" ] && [ ! -L "$workspace" ]; then
        exit 1
    fi
done
