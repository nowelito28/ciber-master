# Máster en Ciberseguridad: Defensiva y Ofensiva

Este repositorio recoge las prácticas que realizo durante el **Máster en Ciberseguridad: Defensiva y Ofensiva de la Universidad Complutense de Madrid (UCM)**, en el curso **2026-2027**.

El máster aborda la seguridad de los sistemas y de la información desde dos perspectivas complementarias: la defensiva, orientada a proteger los entornos y detectar amenazas, y la ofensiva, centrada en identificar y analizar vulnerabilidades. Las prácticas permiten aplicar los conceptos estudiados mediante herramientas, scripts y ejercicios técnicos, documentando los procedimientos y sus resultados.

## Prácticas

### [1-cripto — Criptografía aplicada y Esteganografía](1-cripto/)

El módulo estudia cómo proteger la confidencialidad, la integridad y la autenticidad de la información mediante cifrado simétrico y asimétrico, funciones hash, derivación de claves y firmas digitales. También introduce la esteganografía: técnicas para ocultar información en un soporte o canal y métodos para detectar esa ocultación.

La práctica plantea un caso de asesoramiento a la empresa ficticia **Crypto S.A.**, utilizando **OpenSSL** y scripts para resolver tres ejercicios:

1. **Derivación de claves y cifrado de ficheros:** obtener diez claves a partir de una clave maestra de 128 bits y utilizarlas para cifrar y descifrar diez ficheros, cada uno con una clave diferente.
2. **Cifrado autenticado con AES-GCM:** proteger un fichero mediante un esquema que combine cifrado y autenticación.
3. **Firma digital con curva elíptica:** generar un par de claves, firmar un documento y verificar su firma.

La carpeta contiene el [enunciado](1-cripto/tarea.pdf), la memoria en LaTeX y su PDF, los scripts y los recursos de apoyo, como diagramas y salidas de ejecución. El [README de la práctica](1-cripto/README.md) detalla su estructura y las instrucciones de uso y compilación.

**Estado:** en desarrollo. Por ahora se han implementado la preparación y la derivación de claves de la primera pregunta; el resto de la implementación y su validación siguen pendientes.
