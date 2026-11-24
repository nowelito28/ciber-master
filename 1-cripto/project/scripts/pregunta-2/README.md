# Question 2: AES-128-GCM using shell and OpenSSL CMS

Run all commands from `scripts/pregunta-2/`. Only POSIX shell scripts and
standard terminal tools are required. There is no C program or build step.

The assignment specifies OpenSSL and small scripts available in terminal
environments. OpenSSL's `cms` command supports AES-GCM and manages its
initialization vector, ciphertext and authentication tag in a standard CMS
(Cryptographic Message Syntax) container. `openssl enc` does not support GCM.

## Scripts and default inputs

All questions share `scripts/crypto-workspace/`. The central initializer is
`scripts/prepare-inputs.sh`; run it from `scripts/` to prepare or check the
working directories without deleting data. Key generation is performed by
`pregunta-1/gen-keys.sh` from its own directory.
Existing keys have already been moved and can be used without regeneration.

- `encrypt.sh`: encrypts `../crypto-workspace/originals/tarea.pdf` using AES-128-GCM inside CMS.
- `decrypt.sh`: checks the container, verifies authentication and recovers the PDF.

Both use the first 16-byte binary encryption key from question 1:

```text
../crypto-workspace/secrets/derived-keys/file-01.encryption.bin
```

The input key is read without modification. The master key and the auxiliary
HMAC keys are not used, regenerated or copied.

## Important: how CMS uses the derived key

With `openssl cms -encrypt -secretkey`, the supplied key is a KEK (Key Encryption
Key). It wraps a fresh content encryption key generated internally by OpenSSL.
The latter key encrypts the PDF with AES-128-GCM. The container stores the
wrapped content key, so the original derived key is required to recover it.
The content key is never exported as a separate plaintext file by these scripts.

Thus the first derived key protects the PDF through CMS key wrapping; it is
not used directly as the AES-GCM content key. This distinction must be reflected
when the implementation is documented. The standard CMS CLI does not allow the
caller to select the GCM content key in this encryption operation. A probe of
`-EncryptedData_encrypt` with GCM was rejected by the installed OpenSSL.

The identifier `01` is a public recipient/key identifier, not another key.
No certificates, private-key pairs or passwords need to be generated.

## Execute and validate

After reviewing the scripts:

```sh
./encrypt.sh
./decrypt.sh

cmp ../crypto-workspace/originals/tarea.pdf ../crypto-workspace/decrypted/tarea.pdf &&
    printf '%s\n' 'PASS: recovered PDF matches the original byte for byte.'

wc -c ../crypto-workspace/originals/tarea.pdf \
    ../crypto-workspace/encrypted/tarea.pdf.cms \
    ../crypto-workspace/decrypted/tarea.pdf
```

The recovered PDF must match the original exactly. CMS adds its own structural
metadata and the wrapped content key, so its overhead is not the old fixed
36-byte custom format.

## Generic arguments

Each script accepts optional arguments in the same order:

```sh
./encrypt.sh INPUT KEY OUTPUT
./decrypt.sh INPUT KEY OUTPUT
```

Omitted values use the defaults. Encryption defaults to
`../crypto-workspace/encrypted/INPUT_BASENAME.cms`. Decryption removes `.cms` and
uses `../crypto-workspace/decrypted/INPUT_BASENAME`. Quote paths containing spaces.
Existing output files are overwritten. The destination must differ from the
input and key files. Nothing in question 1 is removed or changed.

## Authentication and output handling

- `-binary` preserves the PDF bytes without text newline conversions.
- CMS generates and stores a fresh 12-byte initialization vector and a 16-byte
  authentication tag. The content encryption algorithm is AES-128-GCM.
- Decryption checks that the container is AuthEnvelopedData with AES-128-GCM,
  rejecting ordinary unauthenticated CMS envelopes.
- CMS handles the container fields automatically. These commands do not supply
  application AAD: the authenticated-attributes field is absent, so GCM uses
  empty AAD. The format is not the custom authenticated-header layout from the
  former program.
- OpenSSL writes directly to the requested destination, without temporary files.
  If encryption, decryption or authentication fails, the output is deleted.
  During decryption the destination may contain unverified plaintext until
  OpenSSL finishes; use it only after the script reports success.
- New directories and files use private permissions (`umask 077`). The output
  is created or truncated before OpenSSL writes to it, with permissions set
  to 600. Exit/signal traps remove an unsuccessful output; forced
  termination with SIGKILL or a power loss cannot run these cleanup traps.

A `.gcm` file from the former C helper is not a CMS container and cannot be
processed by these scripts. Such files, if present, are preserved; new
containers use the `.cms` extension.

## Development checks

Validation is performed only in temporary project copies with test keys,
never with the user's real derived key. It covers exact PDF recovery,
empty/partial/binary inputs, fresh IVs and content keys, private permissions,
overwriting outputs, protecting input/key files, wrong keys, altered ciphertext/IV/tag/wrapped keys,
truncation and rejecting non-GCM containers. These are developer checks, not
execution evidence for the practice report.

## Official references

- [OpenSSL CMS: AES-GCM, secretkey and secretkeyid](https://docs.openssl.org/3.6/man1/openssl-cms/)
- [OpenSSL enc: GCM limitation and CMS recommendation](https://docs.openssl.org/3.6/man1/openssl-enc/)
