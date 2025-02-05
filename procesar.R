# convertir los datos desde Excel a un formato de tabla tidy

library(readxl)

# obtener ruta del archivo
ruta_archivo <- list.files("datos/datos_originales", full.names = T) |> 
  str_subset("xls") |> 
  str_subset("~", negate = T)

# cargar archivo excel
datos <- read_excel(ruta_archivo, sheet = "Tasas a nivel de Comuna")
# en una misma hoja vienen tres tablas (!)

# la hoja viene demasiado mal; en el código comentado se intentó extraer normalmente,
# pero hubo que recurrir a otras formas de limpieza de datos

# datos2 <- datos |> 
#   janitor::clean_names() |> 
#   rename(comuna = 1)
# 
# # identificar textos titulares de cada tabla
# titulos_tablas_genero <- datos2 |> 
#   rename(tablas = 1) |> 
#   select(tablas) |> 
#   filter(str_detect(tablas, "Tabla")) |> 
#   mutate(genero = str_extract(tablas, "mujer|hombre"))
# 
# titulo_tabla_mujeres <- titulos_tablas_genero |> 
#   filter(genero == "mujer") |> 
#   pull(tablas)
# 
# titulo_tabla_hombres <- titulos_tablas_genero |> 
#   filter(genero == "hombre") |> 
#   pull(tablas)
# 
# # usando los titulares de las tablas, identificar en qué fila empieza cada tabla
# datos3 <- datos2 |> 
#   mutate(id = row_number(),
#          # fila donde aparece cada titular
#          pos_mujeres = match(titulo_tabla_mujeres, comuna),
#          pos_hombres = match(titulo_tabla_hombres, comuna)) |> 
#   relocate(starts_with("id_"), starts_with("pos_"), .before = comuna)
# 
# # usando la posición de los titulares, separar la hoja en dos tablas
# datos_mujeres <- datos3 |> 
#   filter(id >= pos_mujeres,
#          id < pos_hombres)
# 
# datos_hombres <- datos3 |> 
#   filter(id >= pos_hombres)
# 
# datos_mujeres
# datos_hombres
# 
# datos_mujeres


# des-pivotar ----
# como las tablas vienen altamente formateadas, es necesario extraerlas usando un 
# método distinto a una simple limpieza

library(tidyxl)
library(unpivotr)

# leer archivo excel como celdas
celdas <- xlsx_cells(ruta_archivo, sheets = "Tasas a nivel de Comuna") |> 
  select(row, col, data_type, numeric, character, date)

# extraer las celdaas que contienen títulos de tablas
titulos <- celdas |> 
  filter(str_detect(character, "Tabla")) |> 
  select(row, col) |> 
  inner_join(celdas, by = c("row", "col"))

# separar hoja por tablas en base al título de cada una
tablas <- partition(celdas, titulos)


# des-pivotar tabla de total
tabla_total <- tablas$cells[[1]] |> 
  behead("up", "título") |> 
  behead("up-left", "año") |> 
  behead("up-left", "sistema") |> 
  behead("up", "variable") |> 
  behead("left", "comuna") |> 
  select(año, sistema, variable, comuna,
         cifra = numeric) |> 
  mutate(sexo = "Total")


# des-pivotar tabla de hombres
tabla_mujeres <- tablas$cells[[2]] |> 
  behead("up", "título") |> 
  behead("up-left", "año") |> 
  behead("up-left", "sistema") |> 
  behead("up", "variable") |> 
  behead("left", "comuna") |> 
  select(año, sistema, variable, comuna,
         cifra = numeric) |> 
  mutate(sexo = "Mujeres")

# probar
tabla_mujeres |> 
  filter(comuna == "ARICA", año == 2023)

# des-pivotar tabla de hombres
tabla_hombres <- tablas$cells[[3]] |> 
  behead("up", "título") |> 
  behead("up-left", "año") |> 
  behead("up-left", "sistema") |> 
  behead("up", "variable") |> 
  behead("left", "comuna") |> 
  select(año, sistema, variable, comuna,
         cifra = numeric) |> 
  mutate(sexo = "Hombres")

# probar
tabla_hombres |> 
  filter(comuna == "ARICA", año == 2023)

# unir datos
desvinculados <- bind_rows(tabla_total, tabla_mujeres, tabla_hombres)

# guardar ----
readr::write_csv2(desvinculados, "datos/mineduc_desvinculacion.csv")
writexl::write_xlsx(desvinculados, "datos/mineduc_desvinculacion.xlsx")
