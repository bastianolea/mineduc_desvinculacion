# Tasas de incidencia de desvinculación
# https://datosabiertos.mineduc.cl/desvinculacion/

library(rvest)
library(dplyr)
library(stringr)

# obtener datos desde el sitio web
sitio <- session("https://datosabiertos.mineduc.cl/desvinculacion/") |> 
  read_html()

elementos <- sitio |> 
  html_elements(".card") |> 
  html_elements("a")

texto <- elementos |> html_text2()
enlace <- elementos |> html_attr("href")

tabla_enlaces <- tibble(texto,
                        enlace)

# extraer enlace correcto
archivo <- tabla_enlaces |> 
  filter(str_detect(texto, "Tasa"),
         str_detect(texto, "2023")) |> 
  filter(str_detect(enlace, "xls")) |> 
  pull(enlace)


# definir ruta donde guardar el archivo
dir.create("datos")
dir.create("datos/datos_originales")

ruta <- paste0("datos/datos_originales/", str_extract(archivo, "OFICIAL.*xlsx"))

# descargar
download.file(archivo, ruta)
