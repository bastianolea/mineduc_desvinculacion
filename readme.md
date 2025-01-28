## Tasas de incidencia de desvinculación

[Tasas de incidencia de desvinculación](https://datosabiertos.mineduc.cl/desvinculacion/) de niños, niñas y jóvenes que cursan básica y media en establecimientos públicos y privados, para una serie de años. Los datos han sido desglosadas según región, provincia, comuna, género y nivel.

En el script `obtener.R` se descargan los datos en formato Excel usando web scraping, para no depender de un enlace estático.

Con el script `procesar.R` se extraen los datos de las tablas presentes en la hoja "Tasas a nivel de Comuna". En esta hoja vienen tres tablas de datos distintos, y cada tabla tiene múltiples filas de encabezados que agurpan columnas de cifras. El script convierte este caos en una tabla de datos en formato _tidy_ gracias al paquete [{unpivotr}](https://nacnudus.github.io/unpivotr/index.html).

### Fuente:
- [Datos abiertos Mineduc](https://datosabiertos.mineduc.cl/desvinculacion/)
