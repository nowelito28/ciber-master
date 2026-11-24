# Shared practice workspace

Run `./prepare-inputs.sh` from this `scripts/` directory to prepare
`crypto-workspace/`. It creates the working directories and copies the assignment
PDF to `originals/tarea.pdf` if it is absent. It does not generate keys and can
be rerun without deleting existing resources.

Question-specific scripts are executed from their own folders and use
`../crypto-workspace` for all default inputs and outputs:

```text
scripts/
  prepare-inputs.sh
  crypto-workspace/
    secrets/master_key.bin
    secrets/derived-keys/
    secrets/ec-keys/
    metadata/salts/
    metadata/public-keys/
    originals/tarea.pdf
    encrypted/
    decrypted/
    signatures/
  pregunta-1/
    gen-keys.sh
    check-inputs.sh
    derive-keys.sh
  pregunta-2/
    encrypt.sh
    decrypt.sh
  pregunta-3/
    gen-keys.sh
    sign.sh
    verify.sh
```

For a fresh start, run:

```sh
./prepare-inputs.sh
cd pregunta-1
./gen-keys.sh
./derive-keys.sh
```

For the existing workspace, keep the current keys and continue with the desired
question. `pregunta-1/check-inputs.sh` checks existing inputs without changing
them. Question 2 uses the first derived encryption key and the copied PDF.

If `gen-keys.sh` detects existing key material, it requires typing `DELETE`
before resetting the entire shared workspace, including other questions' files.
It delegates directory preparation back to the central script. Other responses
cancel and preserve the existing resources. A generation/validation failure
requires the same confirmation before cleanup and retry. `derive-keys.sh`
refuses to overwrite an existing derived-key directory.

Question 3 uses a separate P-256 key pair and detached SHA-256/ECDSA signatures.
See `pregunta-3/README.md` for the execution order and the modified-file check.
