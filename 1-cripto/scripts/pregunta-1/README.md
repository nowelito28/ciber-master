# Question 1: preparation and key derivation

Run every command from the project `scripts/pregunta-1/` directory. All paths are relative
to that directory, and data stays in `crypto-workspace/`. Names and
terminal messages are in English. Check which OpenSSL executable is in PATH:

```sh
command -v openssl
openssl version
```

The current phase implements preparation and PBKDF2 derivation. File encryption,
authenticated packaging and verified recovery are the next phase.

## Existing workspace

Use the 16-byte master key already available in the workspace. Each active
per-file salt must contain 16 bytes. Run:

```sh
wc -c crypto-workspace/secrets/master_key.bin
sh prepare-inputs.sh
./derive-keys.sh
wc -c crypto-workspace/secrets/derived-keys/*.bin
```

`prepare-inputs.sh` is a read-only check: it requires the master key and the ten
expected per-file salts, checks that each contains 16 bytes, and compares every
pair of salts to detect duplicates. It prints `OK` for each valid file and
`PASS` when all checks succeed. Missing or invalid inputs stop execution.
Generation is performed by `gen-keys.sh`.

`derive-keys.sh` uses the inputs already validated during initialization. It
applies PBKDF2-HMAC-SHA-256 with 600000 iterations and derives 48 bytes per file. Two
`dd` commands separate bytes 0-15 (encryption) and bytes 16-47 (authentication).
The intermediate 48-byte file is removed after splitting. The result is 20 key
files plus `iterations.txt` in `secrets/derived-keys`. New files are private.
A plain `mkdir` refuses to reuse an existing output directory. On failure the
script stops and leaves any partial output for inspection. After each pair is generated, `wc -c` displays the actual sizes of that file's
encryption and authentication keys. Expect 16 and 32 bytes, respectively, with
a 48-byte subtotal per file. This displays sizes; checking them against expectations and checking
for duplicate keys remain verification steps.

`od` and `tr` encode binary inputs as hexadecimal; OpenSSL `hexpass` and
`hexsalt` decode those strings back to the original bytes. The CLI receives
secret input through arguments, so avoid shell tracing or logging expanded
arguments. No key bytes need to be printed or shared. Run the script directly;
no timing command is needed.

## New workspace

To create a workspace or explicitly replace an existing one:

```sh
sh gen-keys.sh
sh derive-keys.sh
```

`gen-keys.sh` creates a new master key and ten salts, then invokes
`prepare-inputs.sh` automatically. Generation and validation must both succeed.
If a workspace exists, the script displays its path and requires the exact
answer `DELETE` before removing all of its contents, including any keys and
files. A different answer, an empty answer or end of input cancels and preserves
the workspace. After a failed generation or validation, the same confirmation
is required before cleanup and automatic retry. If creation fails without
leaving a workspace, the script stops. Missing OpenSSL or a missing checker
stops execution before any deletion prompt.

Replacing the workspace creates a new master key. Keep the existing workspace
when you intend to continue with its keys rather than restart.

## Validation performed on the scripts

Tests use temporary workspaces and separate inputs. The checker is tested for
missing files, wrong lengths and duplicate salts, without modifying inputs.
Derivation is compared with Python PBKDF2 for all ten key pairs; tests also
check sizes, private permissions, exclusive output creation and stopping on
failure. These checks are not the user's practice execution results.

Initializer tests cover automatic validation, confirmed replacement,
generation/validation failures followed by confirmed retry, cancellation and
end-of-input without deletion, missing-checker preflight, and preserving a
symlink target when replacing a workspace link. All use temporary workspaces.
