# Recursos vectoriales e identidad de portada

## Marca UCM

`ucm-marca-secundaria.eps` es el original vectorial de la marca secundaria policroma con logotipo negro, obtenido del paquete público de la Universidad Complutense de Madrid:

- Página oficial: https://www.ucm.es/descarga-la-marca-ucm
- Paquete: https://www.ucm.es/data/cont/docs/3-2016-07-19-3-2015-06-30-Marca%20UCM%20Alternativa%20logo%20negro.zip
- Archivo del paquete: `Marca UCM Alternativa logo negro/Marca UCM Alternativa logo negro.eps`.
- Consulta y descarga: 14 de noviembre de 2026.

`ucm-marca-secundaria.pdf` se ha convertido desde ese EPS mediante `epstopdf`, conservando los trazados vectoriales y las proporciones. El PDF está incluido para que compilar la memoria no requiera Ghostscript ni conversión de imágenes.

La marca identifica la universidad de la memoria académica. El diseño es una adaptación personal y no se presenta como plantilla oficial. No se reutiliza la marca URJC del TFG de referencia.

## Referencia de maquetación

El diseño se inspira en el TFG del autor: https://github.com/nowelito28/TFG. Se han consultado la memoria española y los archivos `estilo.tex`, `memoria.tex` y `portada/portada.tex` de `docs/spanish/plantilla-latex-tfg-spanish/`.

Se adaptan la portada centrada, el formato de libro, la tipografía clásica, los márgenes, el interlineado y el tratamiento de los capítulos. No se incorpora el contenido técnico del TFG ni se confunde esta práctica con un trabajo de fin de grado.

`motivo-portada.tex` conserva el dibujo TikZ de la primera versión como recurso opcional; el diseño actual no lo incluye.
