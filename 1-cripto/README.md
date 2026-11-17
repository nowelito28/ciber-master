# Memoria de la práctica de criptografía

Proyecto LaTeX del **Máster en Ciberseguridad**, módulo **Criptografía aplicada y Esteganografía**, Universidad Complutense de Madrid.

El formato actual está adaptado de la memoria del TFG del autor: [repositorio de referencia](https://github.com/nowelito28/TFG). Mantiene su composición académica y la adapta a esta práctica y a la identidad de la UCM.

La práctica está en desarrollo. La pregunta 1 incluye el análisis y el procedimiento de preparación y derivación, con fragmentos y listados completos enlazados directamente a los scripts y explicados mediante sus líneas. Se han incorporado las salidas iniciales facilitadas por el autor en `recursos/salidas/pregunta-1/entorno.txt`; las salidas de preparación y derivación y las capturas están pendientes. El cifrado, la autenticación y la recuperación se desarrollarán después de comprobar las claves. Cada pregunta conserva su enunciado original, transcrito de la página 3 de `tarea.pdf`. Las capturas se integrarán en el procedimiento o la verificación correspondiente. Las siglas técnicas se desarrollan entre paréntesis en su primera explicación, sin modificar el texto original de los enunciados.

La pregunta 1 utiliza **PBKDF2-HMAC-SHA-256**, desarrollado en el tema 1.4 (pp. 12-14) y presentado en la diapositiva 26. Se utiliza una sal aleatoria de 16 bytes por fichero y una derivación de 48 bytes, con 600 000 iteraciones. Se asignan los primeros 16 bytes a AES-128-CBC y los 32 restantes a HMAC-SHA-256, con Encrypt-then-MAC. El análisis presenta el fundamento técnico del procedimiento. La clave inicial es binaria y aleatoria, de 128 bits.

## Initial workspace script

Run the question 1 scripts from the project **`scripts/pregunta-1/` directory**. All paths
are relative to that directory; workspace data stays in
`crypto-workspace/`. Commands and messages are in English.

For a new workspace, starting in the LaTeX project directory:

```sh
cd scripts/pregunta-1
sh gen-keys.sh
```

The workspace layout relative to `scripts/pregunta-1/` is:

```text
crypto-workspace/
├── secrets/master_key.bin   # 16 bytes: 128-bit master key
├── metadata/salts/
│   ├── file-01.bin          # 16-byte public salt for file 01
│   ├── ...
│   └── file-10.bin          # 16-byte public salt for file 10
├── originals/
├── encrypted/
└── decrypted/
```

The script requires OpenSSL in `PATH`, restricts access to generated files, prints file sizes without displaying secret contents, and calls the input checker after generation. Replacing an existing workspace requires typing `DELETE`. It prepares the inputs only; key derivation and encryption are later steps.

`gen-keys.sh` creates and validates a workspace. If it already exists, or a failed
attempt left one behind, the script requires `DELETE` before removing it and
starting again. Any other response or end of input cancels without deletion.
`prepare-inputs.sh` checks the existing master key and ten 16-byte salts without
modifying any file. `derive-keys.sh` derives the ten key pairs after validation.
See [the step-by-step guide](scripts/pregunta-1/README.md). All scripts run from
`scripts/pregunta-1/` and use `crypto-workspace/`. The report includes this phase
through `secciones/ejercicios/pregunta-1/preparacion-y-derivacion.tex`.

## Compilación

Se necesita una instalación de TeX Live o MiKTeX con pdfLaTeX y los paquetes indicados en `config/paquetes.tex`. Se ha comprobado la compilación con TeX Live 2025.

Desde este directorio:

```sh
latexmk main.tex
```

El resultado se genera en **`build/main.pdf`**. `latexmk` repite las pasadas necesarias para actualizar el índice y los enlaces. También puede utilizarse:

```sh
make pdf
```

Si no se dispone de `latexmk`, crear el directorio `build` y ejecutar dos veces:

```sh
mkdir -p build
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
```

No se necesita `shell-escape`, bibliografía externa, Python ni descarga de imágenes para compilar. Para Overleaf, subir las fuentes y los recursos, seleccionar `main.tex` como documento principal y pdfLaTeX como compilador. La ubicación del PDF la gestiona Overleaf.

## Organización

```text
1-cripto/
├── tarea.pdf                    # Enunciado original
├── main.tex                     # Punto de entrada y orden de las secciones
├── .latexmkrc                   # Compilación y salida en build/
├── Makefile                     # Atajos de compilación y limpieza
├── README.md
├── config/
│   ├── datos.tex                # Autor, profesor, fecha, curso y estado
│   ├── paquetes.tex             # Dependencias LaTeX
│   ├── estilo.tex               # Tipografía, colores, cabeceras y bloques
│   ├── esquemas.tex             # Estilo común de diagramas vectoriales
│   └── comandos.tex             # Marcadores y utilidades para figuras
├── secciones/
│   ├── 00-portada.tex
│   ├── 01-resumen-modulo.tex
│   ├── 02-introduccion.tex
│   ├── 03-desarrollo.tex
│   ├── 04-conclusiones.tex
│   ├── 05-referencias.tex
│   ├── ejercicios/
│   │   ├── 01-claves-y-ficheros.tex
│   │   ├── 02-cifrado-autenticado.tex
│   │   └── 03-firma-curva-eliptica.tex
│   └── anexos/
│       └── entorno.tex          # Opcional; todavía no se incluye
├── recursos/
│   ├── esquemas/                # Diagramas TikZ de derivación, cifrado y verificación
│   ├── vectoriales/
│   │   ├── ucm-marca-secundaria.pdf # Logotipo UCM vectorial listo para LaTeX
│   │   ├── ucm-marca-secundaria.eps # Original oficial
│   │   ├── PROCEDENCIA.md      # Fuentes de diseño e identidad
│   │   └── motivo-portada.tex  # Recurso TikZ opcional; no se usa en portada
│   ├── figuras/                # Diagramas y figuras futuras
│   └── capturas/
│       ├── pregunta-1/
│       ├── pregunta-2/
│       └── pregunta-3/
├── scripts/
│   ├── pregunta-1/
│   ├── pregunta-2/
│   └── pregunta-3/
└── build/                      # PDF y auxiliares generados
```

## Cómo completar la memoria

1. Revisar `config/datos.tex` cuando sea necesario actualizar los datos de portada. La denominación del máster, el curso y la fecha de entrega ya han sido personalizados por el autor.
2. Trabajar cada pregunta en su archivo de `secciones/ejercicios/`.
3. Guardar las capturas reales y scripts en los directorios de la pregunta correspondiente.
4. Sustituir los marcadores `\pendiente{...}` por el desarrollo y los resultados verificados.
5. Completar las conclusiones y las fuentes efectivamente utilizadas.
6. El indicador `\MemoriaInicialtrue` queda disponible en la configuración. La portada e introducción actuales han sido personalizadas por el autor y no muestran un aviso automático; los marcadores `\pendiente{...}` se sustituyen manualmente al completar el trabajo.

## Figuras y comandos

Los tres esquemas explicativos de la primera pregunta están en `recursos/esquemas/`. Se dibujan en TikZ al compilar, mantienen resolución vectorial y tienen referencias cruzadas y atribución en sus pies de figura. El archivo `recursos/esquemas/README.md` documenta sus fuentes y símbolos. Representan el diseño propuesto; no sustituyen a las capturas reales de la práctica.

Cada esquema se incluye después del párrafo que presenta su proceso, con posición `[H]`, para que LaTeX no lo adelante ni lo agrupe con otros diagramas. Las utilidades `\captura` y `\diagrama` siguen la misma regla: deben invocarse justo después de explicar y nombrar la figura. Si no cabe en el espacio disponible, la figura pasa a la página siguiente manteniendo el orden.

Para una captura real:

```tex
\captura{recursos/capturas/pregunta-1/resultado.png}
        {Descripción concreta de lo que demuestra la captura.}
        {fig:resultado-p1}
```

Para un diagrama vectorial, exportarlo como PDF y usar:

```tex
\diagrama{recursos/figuras/esquema.pdf}
         {Descripción del esquema.}
         {fig:esquema}
```

Para mostrar un script cuando exista:

```tex
\lstinputlisting[caption={Descripción del script.},label={lst:script-p1}]
                {scripts/pregunta-1/nombre-del-script.sh}
```

Se admiten gráficos PDF y dibujos TikZ sin rasterizar. PNG es apropiado para capturas de terminal o pantalla. El logotipo UCM de portada es vectorial y se incluye en PDF. Su original EPS y su procedencia oficial también se conservan. El motivo TikZ de la primera versión queda disponible como recurso opcional.

## Criterio visual y adaptación del TFG

- Clase `book`, A4, una cara, aperturas sin páginas en blanco forzadas.
- Letra Latin Modern de 12 puntos, próxima a la tipografía de la memoria de referencia.
- Interlineado 1,35 y sangría de primera línea.
- Márgenes del cuerpo: 35 mm a la izquierda, 20 mm a la derecha, 30 mm arriba y 20 mm abajo.
- Portada centrada y simétrica, con marca vectorial oficial UCM, máster, módulo, título, autor y profesor. El profesor no se presenta como tutor de TFG.
- Capítulos con etiqueta y título a la izquierda entre una regla fina superior y otra gruesa inferior.
- Índice general con capítulos y secciones; los apartados internos conservan numeración y marcadores PDF. Se evita un índice inicial demasiado extenso para una práctica breve.
- Preliminares con números romanos y cuerpo con números arábigos. Aperturas de capítulo con número al pie; páginas interiores con cabecera de capítulo.
- Enlaces activos discretos, sin recuadros coloreados, para conservar una presentación formal al imprimir.

La portada adapta la composición del TFG con los datos de esta memoria. La procedencia de la marca y las fuentes del diseño se documentan en `recursos/vectoriales/PROCEDENCIA.md`. Es una adaptación personal; no se afirma que sea una plantilla oficial de la UCM. El enunciado original no se modifica.

La estructura mantiene resumen del módulo, introducción, desarrollo con los tres enunciados, conclusiones y referencias. El anexo de entorno está preparado, pero permanece desactivado hasta disponer de información real. Las preguntas siguen pendientes de resolución.

## Limpieza

```sh
make clean
```

Elimina auxiliares mediante `latexmk -c` y conserva el PDF. El enunciado original no se modifica durante la compilación.
