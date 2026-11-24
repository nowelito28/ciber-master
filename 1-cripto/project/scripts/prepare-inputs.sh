#!/bin/sh
# Prepare the shared workspace without generating or replacing any keys.
# Run from scripts: ./prepare-inputs.sh
set -eu
umask 077

workspace='./crypto-workspace'
[ ! -L "$workspace" ] || { printf '%s\n' 'Error: workspace must not be a symbolic link.' >&2; exit 1; }
mkdir -p "$workspace/secrets" "$workspace/metadata/salts" \
    "$workspace/originals" "$workspace/encrypted" "$workspace/decrypted" \
    "$workspace/secrets/ec-keys" "$workspace/metadata/public-keys" \
    "$workspace/signatures"

# Keep an existing original; copy the assignment only when it is missing.
if [ ! -e "$workspace/originals/tarea.pdf" ] && [ ! -L "$workspace/originals/tarea.pdf" ]; then
    cp ../tarea.pdf "$workspace/originals/tarea.pdf"
fi
[ -f "$workspace/originals/tarea.pdf" ] || {
    printf '%s\n' 'Error: the assignment PDF is not available in originals.' >&2; exit 1;
}
printf 'Workspace ready: %s\n' "$workspace"
