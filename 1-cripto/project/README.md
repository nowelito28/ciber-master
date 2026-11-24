# Applied Cryptography and Steganography

Practical assignment for the **Master’s in Cybersecurity: Defensive and Offensive Security** at the **Complutense University of Madrid (UCM)**, academic year **2026–2027**.

**Language:** the assignment brief and report are written in **Spanish**. This README provides an overview in English; the scripts and their usage guide also use English.

## About the module

The module studies cryptographic mechanisms for protecting information at rest and in transit. It covers symmetric and asymmetric encryption, hash functions, key derivation, digital signatures and public key infrastructure, connecting these concepts to secure communications, identity management and cryptographic weaknesses.

It also introduces steganography: techniques for concealing the presence of information within a medium or channel, together with methods for detecting that concealment. The practical assignment in this directory focuses on cryptography, particularly confidentiality, integrity and authenticity.

## About the assignment

The assignment places the student in the role of a consultant for the fictional company **Crypto S.A.** The objective is to design and implement ways to protect its information using **OpenSSL** and small command-line scripts.

The [original assignment brief](tarea.pdf) defines three exercises:

| Exercise | Objective |
| --- | --- |
| **1. Key derivation and file encryption** | Starting from a 128-bit user key, derive ten different encryption keys and use them to encrypt and decrypt ten files. |
| **2. Authenticated encryption** | Encrypt a file using AES-GCM, combining confidentiality with integrity and authenticity checks. |
| **3. Elliptic-curve digital signatures** | Generate a public/private key pair, sign a document and verify its signature. |

The report brings together the problem statements, technical analysis, implementation procedures, diagrams and execution evidence.

## Implementation summary

All three exercises are implemented and documented with script source code and recorded terminal output.

- **Exercise 1:** workspace preparation, input checks and key derivation are implemented. The derivation uses PBKDF2-HMAC-SHA-256 with 600,000 iterations and a separate 16-byte salt for each file. Each 48-byte result is split into a 16-byte encryption key and a 32-byte authentication key. The report includes the AES-128-CBC/HMAC-SHA-256 Encrypt-then-MAC scripts and user-supplied results for ten random files, reconstruction from the master and authenticated headers, and ten exact recovery comparisons.
- **Exercise 2:** the report includes the analysis and diagrams of AES-GCM. The shell scripts use OpenSSL CMS. The report includes both scripts and the user-supplied execution evidence: input sizes, encryption, authenticated decryption and exact PDF recovery using cmp.
- **Exercise 3:** the analysis introduces asymmetric signatures, elliptic-curve key generation and ECDSA with P-256/SHA-256, supported by vector diagrams based on the teaching material. The report includes the three shell scripts and user-supplied evidence of key validation, signing, signature inspection, acceptance of the original and rejection of a modified copy.

Execution output for all three exercises is stored in `recursos/salidas/`. Working data is centralized in `scripts/crypto-workspace/`. The report uses source code and terminal output as execution evidence.

## Directory contents

```text
1-cripto/
├── README.md                 # Module, assignment and directory overview
├── tarea.pdf                 # Original assignment brief in Spanish
├── main.tex                  # Report entry point and section order
├── main.pdf                  # Report PDF stored in the repository
├── .latexmkrc                # Build configuration; output goes to build/
├── Makefile                  # Build and cleanup commands
├── .gitignore                # Excludes generated build and auxiliary files
├── config/                   # Report metadata, packages, style and commands
├── secciones/                # Spanish report chapters and exercise write-ups
│   └── ejercicios/           # Analysis and procedures for the three exercises
├── scripts/
│   ├── prepare-inputs.sh     # Shared environment preparation (no key generation)
│   ├── crypto-workspace/     # Shared keys, salts, originals and output files
│   ├── pregunta-1/           # Key derivation, file generation, CBC/HMAC and recovery
│   ├── pregunta-2/           # AES-GCM shell scripts using OpenSSL CMS
│   └── pregunta-3/           # P-256 key generation, signing and verification
├── recursos/
│   ├── esquemas/             # TikZ diagrams and their documentation
│   ├── salidas/              # Saved terminal output from the exercises
│   ├── listados/             # Script listings retained as report resources
│   ├── capturas/             # Screenshot folders organised by exercise
│   ├── figuras/              # Placeholder for additional figures
│   └── vectoriales/          # UCM logo, optional cover artwork and provenance
└── build/                    # Locally generated PDF and auxiliary files
```

### Report sources and supporting material

[`config/`](config/) contains the author, module and course metadata (`datos.tex`), package dependencies (`paquetes.tex`), typography and layout (`estilo.tex`), diagram styling (`esquemas.tex`) and reusable commands (`comandos.tex`).

[`secciones/`](secciones/) contains the cover, module summary, introduction, exercise development and references. Each exercise includes its analysis, implementation and validation, with script source code and recorded output.

[`recursos/`](recursos/) holds the material used to explain and document the work. The TikZ diagrams illustrate key derivation, encryption and authentication, verification and decryption, and AES-GCM. Saved output records execution results; diagrams describe the proposed design and are not execution evidence.

### Exercise 1 scripts

The environment preparation script is [`scripts/prepare-inputs.sh`](scripts/prepare-inputs.sh); key generation and other question-specific scripts remain in [`scripts/pregunta-1/`](scripts/pregunta-1/). All questions share `scripts/crypto-workspace/`, including a copy of the assignment in `originals/`:

| Script | Purpose |
| --- | --- |
| `scripts/prepare-inputs.sh` | Prepare the shared directories and copy the assignment PDF, preserving existing resources. |
| `pregunta-1/gen-keys.sh` | Generate the master key and ten salts, then validate them. |
| `pregunta-1/check-inputs.sh` | Check the master key, salt sizes and salt uniqueness without modifying them. |
| `derive-keys.sh` | Use the validated inputs and derive the encryption and authentication key pair for each file. |
| `gen-files.sh` | Generate ten random originals with different lengths. |
| `encrypt-files.sh` | Encrypt the ten originals with AES-128-CBC and authenticate their headers and ciphertext with HMAC-SHA-256. |
| `decrypt-files.sh` | Reconstruct the keys from the master and stored parameters, verify HMAC and recover the originals. |

Run these scripts from their own directory, with OpenSSL available in `PATH`. From `1-cripto/`, check an existing workspace with:

```sh
cd scripts/pregunta-1
sh check-inputs.sh
```

For a new workspace, run `sh prepare-inputs.sh` from `scripts/`, then `sh gen-keys.sh` and `sh derive-keys.sh` from `scripts/pregunta-1/`. The generator requires typing `DELETE` before replacing an existing workspace, which removes its current keys and files. The derivation script refuses to overwrite an existing derived-key directory.

See the [step-by-step script guide](scripts/pregunta-1/README.md) for workspace handling, prerequisites and validation details.

## Building the report

Use a TeX Live or MiKTeX installation with pdfLaTeX and the packages listed in [`config/paquetes.tex`](config/paquetes.tex). From `1-cripto/`, run:

```sh
latexmk main.tex
```

Alternatively:

```sh
make pdf
```

The generated report is **`build/main.pdf`**. This build does not automatically replace the separate `main.pdf` stored at the directory root. Build output and LaTeX auxiliary files are excluded by `.gitignore`.

Without `latexmk`, create the output directory and run pdfLaTeX twice to update the table of contents and cross-references:

```sh
mkdir -p build
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
```

For Overleaf, upload the sources and resources, select `main.tex` as the main document and use pdfLaTeX. No shell escape is required.

To remove auxiliary build files while keeping the compiled PDF:

```sh
make clean
```

## Report layout and attribution

The report layout is adapted from the author’s [undergraduate thesis repository](https://github.com/nowelito28/TFG), with an A4 book-style layout, a UCM cover and vector diagrams. It is a personal adaptation, not an official UCM template. Logo provenance and design references are documented in [`recursos/vectoriales/PROCEDENCIA.md`](recursos/vectoriales/PROCEDENCIA.md).
