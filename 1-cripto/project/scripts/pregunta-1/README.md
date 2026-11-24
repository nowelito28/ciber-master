# Question 1: derived keys and authenticated file encryption

Run this question's scripts from `scripts/pregunta-1/`. All use
`../crypto-workspace`, shared by the whole practice. The central
`scripts/prepare-inputs.sh` only prepares directories and the original PDF.

## Existing workspace

The current workspace and keys are already available. To check them without
regenerating anything:

```sh
./check-inputs.sh
wc -c ../crypto-workspace/secrets/derived-keys/*.bin
```

## Fresh setup

From `scripts/`, prepare the environment first. Then run key operations from
this question's folder:

```sh
./prepare-inputs.sh
cd pregunta-1
./gen-keys.sh
./derive-keys.sh
```

- `gen-keys.sh` generates a 16-byte random master key and ten 16-byte salts.
  It automatically runs `check-inputs.sh` and displays the resulting sizes.
- `check-inputs.sh` checks the existing files and compares all 45 salt pairs.
  Missing files, incorrect sizes and duplicate salts are rejected; no input is
  modified. It prints `PASS` only after every check succeeds.
- `derive-keys.sh` applies PBKDF2-HMAC-SHA-256 with 600000 iterations and 48 bytes
  of output per file. `dd` separates the first 16 bytes for encryption and the
  remaining 32 bytes for HMAC authentication. The intermediate output is removed;
  `wc -c` reports both key sizes. `iterations.txt` preserves the iteration count.

`gen-keys.sh` refuses an unprepared workspace. If key material already exists,
restarting requires the exact answer `DELETE` before removing the entire shared
workspace, including files from other questions. It then calls the central
preparer and starts key generation again. Any other response preserves all
resources and cancels. Failed generation/checking follows the same confirmation
and retry flow. Missing preparation/checking scripts stop before deletion.

`derive-keys.sh` uses the previously validated inputs, does not rerun the
preparer and refuses an existing derived-key directory. None of these commands
need to be rerun to continue with the user's current keys.

The report imports comment-free copies of the key-preparation, derivation and
batch-file scripts from `recursos/listados/`. Keep these copies synchronized
after source changes. The implementation includes the user-supplied results for
generation, authenticated encryption, reconstructed-key recovery and ten exact
byte-for-byte comparisons.
Saved terminal evidence retains its original execution paths and messages.


## Ten random files: encrypt, authenticate and recover

These new scripts are run from `scripts/pregunta-1/`, using the existing derived
keys. The central preparer already creates the required parent directories and
needs no change. The subfolders below keep this batch separate from question 2.

| Script | Action |
|---|---|
| `gen-files.sh [BYTES]` | Create ten random originals, starting at BYTES (default 1024) and increasing by one byte per file. Preserve any existing originals directory by refusing to replace it. |
| `encrypt-files.sh` | Use each file's 16-byte AES key and 32-byte HMAC key. Write AES-128-CBC ciphertext with a fresh 16-byte IV, then authenticate the complete header and ciphertext. |
| `decrypt-files.sh` | Reconstruct both keys from the master and stored header parameters, check the complete HMAC, then decrypt. OpenSSL validates and removes PKCS#7 padding. |

```text
crypto-workspace/
  originals/pregunta-1/file-01.bin ... file-10.bin
  encrypted/pregunta-1/file-01.protected ... file-10.protected
  decrypted/pregunta-1/file-01.bin ... file-10.bin
```

All comments, messages and names are in English. No extra programs or temporary
files are created. The scripts preserve the original PDF, existing master key,
salts, derived keys and other questions' results. Protected and recovered files
are overwritten on repeated encryption/decryption runs. Generation of originals
is intentionally separate; do not regenerate them for a decryption run.

### Execute in order

From `scripts/pregunta-1/`, with the keys already derived:

```sh
./gen-files.sh
./encrypt-files.sh
./decrypt-files.sh

for id in 01 02 03 04 05 06 07 08 09 10; do
    cmp "../crypto-workspace/originals/pregunta-1/file-$id.bin" \
        "../crypto-workspace/decrypted/pregunta-1/file-$id.bin" || break
    printf 'PASS: file-%s matches the original.\n' "$id"
done
```

All ten comparisons must print `PASS`. `gen-files.sh` expects the batch's
originals directory not to exist; for a new separate batch, first preserve or
move that directory yourself. There is no need to rerun `gen-keys.sh` or
`derive-keys.sh` for the existing keys.

### Protected-file format

The version marker `P1E1` fixes the algorithms as AES-128-CBC and HMAC-SHA-256,
with automatic PKCS#7 padding. All header fields have fixed widths; there is
no ambiguous concatenation. The package contains:

| Offset / location | Bytes | Field |
|---|---:|---|
| 0 | 4 | ASCII version marker `P1E1` |
| 4 | 2 | ASCII file ID `01` to `10` |
| 6 | 10 | Decimal PBKDF2 iteration count, padded with leading zeroes |
| 16 | 16 | Original binary salt for this file |
| 32 | 16 | Fresh random IV |
| 48 | multiple of 16 | CBC ciphertext |
| Final 32 bytes | 32 | HMAC of all preceding bytes |

The header is 48 bytes. The total length is
`48 + 16 * (floor(original_bytes / 16) + 1) + 32`.
The decryptor reads the 16-byte master key and the salt/iteration count stored
in each protected header, then reruns PBKDF2-HMAC-SHA-256 for 48 bytes. The first
16 bytes are the AES key and the remaining 32 are the HMAC key. Reconstruction
uses memory only: it does not read or recreate the derived-key files, the
external salts directory or iterations.txt. Iteration counts must be between
1 and 10000000; the limit bounds unauthenticated KDF work before checking HMAC. CBC receives the
raw AES key and IV with `-nosalt`; OpenSSL does not derive a second AES key or
add a separate `Salted__` prefix.

Before reconstruction, recovery checks the package size, version, file ID and
iteration bounds. The complete header is subsequently authenticated by HMAC.
On rejection no new plaintext is created; earlier successfully recovered files
are preserved. Failure after plaintext creation removes the incomplete current
output. A batch stops at its first error, preserving earlier successful items.

The tag check scans all 32 bytes, XORs each pair and combines the differences
with bitwise OR. It does not stop at the first mismatch and does not compare
hex strings with shell equality. It is a fixed-iteration comparison, **not a
guarantee of cryptographic constant-time execution**: shell interpretation and
arithmetic do not provide that guarantee. The report must keep this distinction
explicit. No Python call, C helper or additional runtime is introduced.

Development checks use isolated copies and disposable keys: independent HMAC
verification, header/tag tampering, wrong keys, fresh IVs, repeated runs,
empty/partial/full-block files, exact recovery and unchanged real resources.

The reconstructed-key path is tested with the derived-key directory and external
salt files removed from an isolated copy, while retaining the master and the
protected packages. All ten originals must still be recovered exactly.
