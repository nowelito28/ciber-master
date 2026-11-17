# Master's in Cybersecurity: Defensive and Offensive Security

This repository contains the practical assignments I complete during the **Master's in Cybersecurity: Defensive and Offensive Security at the Complutense University of Madrid (UCM)**, in the **2026–2027** academic year.

The programme covers system and information security from two complementary perspectives: defensive security, focused on protecting environments and detecting threats, and offensive security, focused on identifying and analysing vulnerabilities. Practical assignments apply these concepts through tools, scripts and technical exercises, with documented procedures and results.

**Language:** the practical assignments and their reports are written in **Spanish**. This README provides an overview in English; some scripts and technical instructions are also in English.

## Practical assignments

### [1-cripto — Applied Cryptography and Steganography](1-cripto/)

This module explores how to protect the confidentiality, integrity and authenticity of information using symmetric and asymmetric encryption, hash functions, key derivation and digital signatures. It also introduces steganography: techniques for hiding information within a medium or communication channel, and methods for detecting it.

The assignment presents a consulting scenario for the fictional company **Crypto S.A.**, using **OpenSSL** and scripts to address three exercises:

1. **Key derivation and file encryption:** derive ten keys from a 128-bit master key and use them to encrypt and decrypt ten files, each with a different key.
2. **Authenticated encryption with AES-GCM:** protect a file using a scheme that combines encryption and authentication.
3. **Elliptic-curve digital signatures:** generate a key pair, sign a document and verify its signature.

The folder contains the [assignment brief](1-cripto/tarea.pdf), the LaTeX report and its PDF, scripts, and supporting resources such as diagrams and execution output. The [assignment README](1-cripto/README.md) describes the folder structure and provides usage and compilation instructions.

**Status:** work in progress. Preparation and key derivation for the first exercise have been implemented; the remaining implementation and validation are still pending.
