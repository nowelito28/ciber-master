#!/bin/sh
set -eu
umask 077

workspace='../crypto-workspace'
ids='01 02 03 04 05 06 07 08 09 10'
command -v openssl >/dev/null 2>&1 || { printf 'Error: OpenSSL not found.\n' >&2; exit 1; }
[ -f ./check-inputs.sh ] && [ -f ../prepare-inputs.sh ] || {
    printf '%s\n' 'Error: required preparation/checking script not found.' >&2; exit 1;
}
[ -d "$workspace/secrets" ] && [ -d "$workspace/metadata/salts" ] &&
[ -f "$workspace/originals/tarea.pdf" ] || {
    printf '%s\n' 'Error: run ./prepare-inputs.sh from scripts first.' >&2; exit 1;
}

has_keys() {
    for file in "$workspace/secrets/master_key.bin" \
        "$workspace"/metadata/salts/file-*.bin "$workspace/secrets/derived-keys"; do
        if [ -e "$file" ] || [ -L "$file" ]; then return 0; fi
    done
    return 1
}

generate() {
    openssl rand -out "$workspace/secrets/master_key.bin" 16 || return 1
    for id in $ids; do
        openssl rand -out "$workspace/metadata/salts/file-$id.bin" 16 || return 1
    done
    sh ./check-inputs.sh || return 1
    wc -c "$workspace/secrets/master_key.bin" \
        "$workspace"/metadata/salts/file-*.bin || return 1
}

while :; do
    if has_keys; then
        [ -f ../../tarea.pdf ] || { printf 'Error: assignment PDF required for reset.\n' >&2; exit 1; }
        printf 'Workspace to delete: %s/%s\n' "$(pwd -P)" "$workspace"
        printf '%s\n' 'All keys and files inside the shared workspace will be permanently deleted.'
        printf 'Type DELETE to remove it and generate new keys: '
        IFS= read -r answer || answer=''
        if [ "$answer" != DELETE ]; then
            printf '%s\n' 'Cancelled. The existing workspace was preserved.'
            exit 1
        fi
        rm -rf -- "$workspace" || exit 1
        (cd .. && sh ./prepare-inputs.sh) || exit 1
    fi
    if generate; then
        printf '%s\n' 'Keys generated and validated successfully.'
        break
    fi
    printf '%s\n' 'Generation or validation failed. Confirmation is required before cleanup and retry.' >&2
    if ! has_keys; then exit 1; fi
done
