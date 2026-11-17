# Esquemas de la primera pregunta

Figuras originales en TikZ, incluidas en la memoria como gráficos vectoriales. No son capturas ni evidencias de ejecución. Sus elementos se pueden editar directamente en los archivos `.tex`; el estilo común está en `config/esquemas.tex`.

Los tres esquemas comparten una leyenda de bordes por función: granate para datos secretos, verde para datos públicos, azul para operaciones criptográficas y ocre para operaciones de formato. La clasificación se configura mediante los estilos `funcionsecreta`, `funcionpublica`, `funcioncripto` y `funcionformato`. El rechazo del tercer esquema utiliza un borde gris neutro como salida de control. Los rótulos describen cada bloque también sin depender del color.

| Archivo | Proceso | Fundamento |
|---|---|---|
| `01-derivacion-claves.tex` | Clave maestra, sal por fichero y PBKDF2; partición de una salida de 48 bytes | Tema 1.4, pp. 12-14; diapositiva 26 del tema 1.4; RFC 8018, sección 5.2 |
| `02-cifrado-autenticacion.tex` | Relleno, AES-CBC y HMAC sobre cabecera y criptograma | Tema 1.2, pp. 15, 21 y 24; tema 1.4, pp. 18–19 |
| `03-verificacion-descifrado.tex` | Verificación de la etiqueta, rechazo o descifrado y retirada del relleno | Tema 1.4, pp. 18–19; tema 1.2, p. 21 |

La primera figura muestra una derivación PBKDF2-HMAC-SHA-256 por fichero, con la misma clave maestra binaria de 16 bytes y una sal aleatoria de 16 bytes (128 bits) distinta por fichero. El número de iteraciones es 600 000. Los 48 bytes de salida se dividen sin solapamiento: bytes 1-16 para AES-128 y bytes 17-48 para HMAC-SHA-256. La numeración del dibujo empieza en 1; en código, los segmentos equivalentes son `[0:16]` y `[16:48]`. Hay diez claves de cifrado y diez claves auxiliares de autenticación; todas dependen de la misma clave maestra. La partición es una decisión del diseño propuesto, no una captura literal del temario.

En el segundo esquema, `H_i` representa una cabecera pública y `D_i` una codificación inequívoca de esa cabecera y del criptograma. La cabecera incluye la sal por fichero, el número de iteraciones, la versión del formato, el identificador, los algoritmos y el vector de inicialización necesarios para reconstruir las claves e interpretar el contenido. La longitud de salida y su partición quedan fijadas por la versión del formato. El vector `V_i` es el mismo que utiliza el cifrado CBC. La etiqueta autentica todos esos datos.

El tercer esquema sigue la misma jerarquía de símbolos, nombres y detalles en inglés. Las flechas de datos muestran tamaños en bytes y bits, y las de control indican decisiones. La etiqueta recibida `T_i` y la recalculada `T'_i` se comparan en tiempo constante; solo después de una coincidencia se descifra y se comprueba el relleno. Se representan el rechazo por etiqueta incorrecta y el rechazo por relleno inválido. El texto recuperado se entrega únicamente tras validar el relleno. Un error de formato también debe detener la recuperación.

El segundo esquema utiliza el mismo estilo del primero: rótulos en inglés, símbolo o sigla principal en negrita, nombre debajo y detalles entre paréntesis. Las flechas expresan las longitudes en bytes y bits. Las variables `n_i`, `m_i`, `h_i` y `d_i` representan los tamaños en bytes del original, del texto con relleno (y del criptograma), de la cabecera serializada y de su codificación conjunta con el criptograma, respectivamente. El relleno PKCS#7 produce `m_i = 16 * (floor(n_i / 16) + 1)`, incluso si el original ya mide un múltiplo de 16 bytes. La etiqueta HMAC ocupa 32 bytes. Estos símbolos describen tamaños variables; no son resultados de ejecución.

Los pies de figura citan las referencias incluidas en la memoria. Los enunciados originales y los apartados pendientes de procedimiento y verificación se conservan.
