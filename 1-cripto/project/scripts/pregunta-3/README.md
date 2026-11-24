# Question 3: detached ECDSA signatures with P-256 and SHA-256

Run the question-specific scripts from `scripts/pregunta-3/`. They are POSIX
shell scripts with English comments and use the shared `../crypto-workspace`.
They write directly to their destinations without temporary files.

## Scripts

- `gen-keys.sh [PRIVATE_KEY [PUBLIC_KEY]]`: generates and validates a new P-256
  pair with OpenSSL. Existing keys are preserved; use different paths for another
  pair. The displayed key details are public only.
- `sign.sh [INPUT [PRIVATE_KEY [SIGNATURE]]]`: signs the file bytes with SHA-256
  and ECDSA. An existing signature output is overwritten. On failure or handled
  interruption, the incomplete signature is removed. Input and key are preserved.
- `verify.sh [INPUT [PUBLIC_KEY [SIGNATURE]]]`: verifies the supplied combination
  and returns zero with `ACCEPT`, or nonzero with `REJECT` after a failed signature
  check. Missing/invalid inputs return an error. It never requires the private key
  and does not delete the file, key or signature.

The scripts require P-256 (`prime256v1`) and SHA-256, matching the analysis.
They accept other file/key/signature paths, not an alternate signing algorithm.
The verifier must obtain the public key from a trusted source; the script cannot
establish a person's identity by itself.

## Default resources

```text
crypto-workspace/
  originals/tarea.pdf
  secrets/ec-keys/p256.private.pem
  metadata/public-keys/p256.public.pem
  signatures/tarea.pdf.sig
```

The EC pair is independent of the master and derived symmetric keys from question 1.
PEM key files contain encoding/metadata, so their file sizes are not 32 bytes.
The detached signature is a DER sequence containing the two integers r and s;
its encoded size can vary slightly between signatures. OpenSSL computes the
hash internally: do not hash the file separately before passing it to sign.sh.

## Execute in order

From the project's `scripts/` directory:

```sh
./prepare-inputs.sh
cd pregunta-3
./gen-keys.sh
./sign.sh
./verify.sh
```

The preparer adds the necessary directories without deleting or regenerating
existing resources. Run key generation once; subsequent signing runs reuse the pair.
Inspect the public signature values if desired:

```sh
openssl asn1parse -inform DER -in ../crypto-workspace/signatures/tarea.pdf.sig
```

Create a modified copy, and check it against the original signature:

```sh
cp ../crypto-workspace/originals/tarea.pdf ../crypto-workspace/originals/tarea-modified.pdf
printf '\nModified copy for signature validation.\n' >> ../crypto-workspace/originals/tarea-modified.pdf
./verify.sh ../crypto-workspace/originals/tarea-modified.pdf \
    ../crypto-workspace/metadata/public-keys/p256.public.pem \
    ../crypto-workspace/signatures/tarea.pdf.sig
./verify.sh
```

The modified copy must be rejected (nonzero exit status); the original must still
be accepted. This validation uses no new signature for the modified copy.
Do not regenerate the key pair between signing and verification.

## Validation and report

Developer checks run in isolated project copies with test keys: correct and wrong
keys, modified documents/signatures, public-only verification, P-256 enforcement,
repeated signing, empty/binary inputs, space-containing paths and failure cleanup.
The implementation section includes the user-supplied generation, signing, ASN.1
inspection and positive/negative verification outputs.

Official documentation: https://docs.openssl.org/3.6/man1/openssl-genpkey/,
https://docs.openssl.org/3.6/man1/openssl-pkey/ and
https://docs.openssl.org/3.6/man1/openssl-dgst/.
