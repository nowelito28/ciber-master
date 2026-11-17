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

## Current progress

This assignment is **in progress**; the repository does not yet contain a complete solution to all three exercises.

- **Exercise 1:** workspace preparation, input checks and key derivation are implemented. The derivation uses PBKDF2-HMAC-SHA-256 with 600,000 iterations and a separate 16-byte salt for each file. Each 48-byte result is split into a 16-byte encryption key and a 32-byte authentication key. The report describes the planned AES-128-CBC and HMAC-SHA-256 Encrypt-then-MAC scheme; file encryption, authentication and recovery remain to be implemented.
- **Exercise 2:** the report includes an analysis and a diagram of AES-GCM. Implementation and validation are pending.
- **Exercise 3:** the problem statement and report sections are prepared. Analysis, implementation and verification are pending.

Execution output for the initial stages of exercise 1 is stored in `recursos/salidas/pregunta-1/`. Screenshot folders and script folders for the remaining exercises are placeholders.

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
│   ├── ejercicios/           # Analysis and procedures for the three exercises
│   └── anexos/               # Optional appendix material
├── scripts/
│   ├── pregunta-1/           # Preparation and key derivation scripts and guide
│   │   └── crypto-workspace/ # Master key, salts and derived exercise keys
│   ├── pregunta-2/           # Placeholder for the AES-GCM implementation
│   └── pregunta-3/           # Placeholder for the signature implementation
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

[`secciones/`](secciones/) contains the cover, module summary, introduction, exercise development, conclusions and references. The first exercise is further divided into preparation and derivation procedures and full program listings. Pending work is marked with `\pendiente{...}` in the LaTeX sources.

[`recursos/`](recursos/) holds the material used to explain and document the work. The TikZ diagrams illustrate key derivation, encryption and authentication, verification and decryption, and AES-GCM. Saved output records execution results; diagrams describe the proposed design and are not execution evidence.

### Exercise 1 scripts

The runnable scripts are in [`scripts/pregunta-1/`](scripts/pregunta-1/):

| Script | Purpose |
| --- | --- |
| `gen-keys.sh` | Create a workspace with a 128-bit master key and ten random salts, then validate the inputs. |
| `prepare-inputs.sh` | Check the existing master key and salts, including their sizes and duplicate salts, without modifying them. |
| `derive-keys.sh` | Validate the inputs and derive the encryption and authentication key pair for each file. |

Run these scripts from their own directory, with OpenSSL available in `PATH`. From `1-cripto/`, check an existing workspace with:

```sh
cd scripts/pregunta-1
sh prepare-inputs.sh
```

For a new workspace, run `sh gen-keys.sh`, followed by `sh derive-keys.sh`. The generator requires typing `DELETE` before replacing an existing workspace, which removes its current keys and files. The derivation script refuses to overwrite an existing derived-key directory.

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
