### This code creates a file that compilates all the data of the
### INEGI census (2000, 2005, 2010, 2015, 2020) in one single file.

#install.packages("readxl")
#install.packages("dplyr")
#install.packages("writexl")
library(readxl)
library(dplyr)
library(writexl)
library(tidyr)
library(tibble)
library(stringr)
library(readr)

###
### Compiling the 2015 data (because it's all over the place)
###

carpeta <- "/Users/etiennericardez/Downloads/UBC Masters thesis/Raw data/Population/2015"  # Cambia esto a la ruta de tu carpeta
archivos <- list.files(path = carpeta, pattern = "*.xls", full.names = TRUE)

# Crear una lista para almacenar los dataframes filtrados
lista_datos <- lapply(archivos, function(archivo) {
  # Leer la hoja "03" del archivo a partir de la fila 7
  datos <- read_excel(archivo, sheet = "03", skip = 6)
  
  # Filtrar los datos según las condiciones dadas
  datos_filtrados <- datos %>%
    filter(Estimador == "Valor", Sexo == "Total")
  
  return(datos_filtrados)
})

# Combinar todos los dataframes en uno solo
datos_combined <- bind_rows(lista_datos)

# Combinar las columnas "Municipio" y "Delegación"
datos_combined <- datos_combined %>%
  mutate(Municipio = coalesce(Municipio, Delegación))

# Filtrar los datos combinados para excluir los valores de "Municipio" que son "Total"
datos_combined <- datos_combined %>%
  filter(Municipio != "Total")

datos_combined <- datos_combined %>%
  mutate(year = 2015)

data_2015 <- datos_combined %>%
  select(year, `Entidad federativa`, Municipio, `Población total`)

data_2015 <- data_2015 %>%
  mutate(mun_ID = paste0(substr(`Entidad federativa`, 1, 2), substr(Municipio, 1, 3)),
         mun_ID = sub("^0", "", mun_ID))

data_2015 <- data_2015 %>% 
  rename(Total = "Población total")

###
### Cleaning data from 2020
###

data_2020 <- read_excel("Raw data/Population/PSM2020_tabla_indicadores_entidad.xlsx",
                              , sheet = 2)

data_2020 <- data_2020[-c(1:3), ]

data_2020 <- data_2020 %>%
  mutate(year = 2020)

data_2020 <- data_2020 %>%
  select(year, `Entidad federativa`, Municipio, `Población total`)

###
### Cleaning data from 2000
###

data2000 <- read_excel("Raw data/Population/INEGI_exporta_7_6_2024_14_6_3 - 2000 - 9jun2024.xlsx",
                       skip = 4)

data2000 <- data2000[-c(4:6), ]

data_2000_t <- t(data2000)

data_2000_df <- as.data.frame(data_2000_t)
colnames(data_2000_df) <- data_2000_t[1, ]
data_2000_df <- data_2000_df[-1, ]

data_2000_df <- data_2000_df %>%
  mutate(across(c(Total, Hombres, Mujeres), as.numeric))

data_vertical <- data_2000_df %>%
  rownames_to_column("Municipio") %>%
  pivot_longer(cols = c(Total, Hombres, Mujeres), names_to = "Categoria", values_to = "Poblacion") %>%
  pivot_wider(names_from = Categoria, values_from = Poblacion) %>%
  select(Municipio, Total, Hombres, Mujeres)

###
### Giving the 2000 data the codes needed
###

data_2020 <- data_2020 %>%
  mutate(municipality_name = sub("^[0-9]{3} ", "", Municipio),
         mun_ID = paste0(substr(`Entidad federativa`, 1, 2), substr(Municipio, 1, 3)),
         Código = sub("^0", "", mun_ID))

data_codes <- data_2020 %>%
  select(Entidad = `Entidad federativa`, Municipio, Código, municipality_name)

data_vertical <- data_vertical %>%
  mutate(Municipio = gsub("\\.\\.\\..*", "", Municipio))

estados <- unique(data_codes$Entidad)
estados <- gsub("^\\d+\\s+", "", estados)

# Crear una columna vacía para los estados en data_vertical
data_vertical <- data_vertical %>%
  mutate(Estado = NA,
         ID = row_number())

estados_ids <- data.frame(
  Estado = c("Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Coahuila de Zaragoza", 
             "Colima", "Chiapas", "Chihuahua", "Distrito Federal", "Durango", "Guanajuato", "Guerrero", 
             "Hidalgo", "Jalisco", "México", "Michoacán de Ocampo", "Morelos", "Nayarit", "Nuevo León", 
             "Oaxaca", "Puebla", "Querétaro de Arteaga", "Quintana Roo", "San Luis Potosí", "Sinaloa", 
             "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz de Ignacio de la Llave", 
             "Yucatán", "Zacatecas"),
  ID = c(2, 14, 20, 26, 38, 77, 88, 207, 275, 292, 332, 379, 456, 541, 666, 789, 903, 937, 958, 1010, 
         1581, 1799, 1818, 1827, 1886, 1905, 1978, 1996, 2040, 2101, 2312, 2419)
)

# Asignar los estados a los municipios en data_vertical
for (i in seq_len(nrow(estados_ids))) {
  estado_actual <- estados_ids$Estado[i]
  id_actual <- estados_ids$ID[i]
  if (i < nrow(estados_ids)) {
    id_siguiente <- estados_ids$ID[i + 1] - 1
  } else {
    id_siguiente <- nrow(data_vertical)
  }
  data_vertical$Estado[id_actual:id_siguiente] <- estado_actual
}

# Filtrar y renombrar las columnas de data_codes según los nombres correctos
data_codes_filtered <- data_codes %>%
  select(Entidad = `Entidad`, Municipio = `municipality_name`, Codigo = `Código`)

data_codes_filtered <- data_codes_filtered %>%
  mutate(estate_name = sub("^[0-9]{2} ", "", Entidad))

# Unir los datos usando el nombre del municipio y el estado como claves
data_2000_1 <- data_vertical %>%
  left_join(data_codes_filtered, by = c("Municipio" = "Municipio", "Estado" = "estate_name"))

data_2000_1 <- data_2000_1 %>%
  mutate(year = 2000)

# Crear una columna de índice único
data_2000_1 <- data_2000_1 %>%
  mutate(Index = row_number())

# Identificar los registros duplicados
duplicated_data <- data_2000_1 %>%
  group_by(Municipio, Estado) %>%
  filter(n() > 1) %>%
  ungroup()

# Filtrar registros duplicados conservando las observaciones deseadas
filtered_duplicated_data <- duplicated_data %>%
  group_by(Municipio, Estado) %>%
  filter((str_ends(Codigo, "000") & Total == max(Total)) |
           (!str_ends(Codigo, "000") & Total == min(Total))) %>%
  ungroup()

# Combinar los datos filtrados con los registros no duplicados
data_2000 <- data_2000_1 %>%
  filter(!Index %in% duplicated_data$Index) %>%
  bind_rows(filtered_duplicated_data)

###
### Finishing 2000 and 2020
###

data_2020 <- data_2020 %>%
  select(year, `Entidad federativa`, Municipio, `Población total`, Código)

data_2020 <- data_2020 %>%
  rename(mun_ID = Código,
         Total = `Población total`)

data_2000 <- data_2000 %>%
  select(year, Entidad, Municipio, Total, Codigo)

data_2000 <- data_2000 %>%
  rename(mun_ID = Codigo)

###
### Compiling the 2005 data
###

data_2005 <- read_excel("Raw data/Population/INEGI_exporta_7_6_2024_14_22_50 - 2005 - 10jun2024.xlsx",
                        range = "A5:E2494")

data_2005 <- data_2005 %>%
  rename(mun_ID = 1, Municipio = 2)

data_2005 <- data_2005 %>%
  mutate(mun_ID = str_replace_all(mun_ID, " ", ""))%>%
  mutate(mun_ID = str_remove(mun_ID, "^0")) %>%
  mutate(year = 2005)

data_2005 <- data_2005 %>%
  select(year, mun_ID, Total, Municipio)

###
### Compiling the 2010 data
###

data_2010 <- read_excel("Raw data/Population/INEGI_exporta_30_5_2024_18_47_12 - 2010 - 10jun2024.xlsx",
                        range = "A5:E2494")

data_2010 <- data_2010 %>%
  rename(mun_ID = 1, Municipio = 2)

data_2010 <- data_2010 %>%
  mutate(mun_ID = str_replace_all(mun_ID, " ", ""))%>%
  mutate(mun_ID = str_remove(mun_ID, "^0")) %>%
  mutate(year = 2010)

data_2010 <- data_2010 %>%
  select(year, mun_ID, Total, Municipio)

###
### putting everything together
###

# Concatenar (apendear) los data sets
data_population <- bind_rows(data_2000, data_2005, data_2010, data_2015, data_2020)

data_population <- data_population %>%
  mutate(Estado = coalesce(Entidad, `Entidad federativa`))

data_population <- data_population %>%
  select(year, Estado, Municipio, Total, mun_ID)

###
### Doing the estimates for the years 2003, 2008, 2013 and 2018
###

# Función para hacer la interpolación lineal y agregar el año 2020
interpolate_population <- function(df) {
  years <- c(2000, 2005, 2010, 2015, 2020)
  new_years <- c(2003, 2008, 2013, 2018)
  
  interpolated_data <- df %>%
    group_by(mun_ID) %>%
    summarize(
      Municipio = first(Municipio),
      Estado = first(Estado),
      Total_2000 = sum(if_else(year == 2000, Total, NA_real_), na.rm = TRUE),
      Total_2005 = sum(if_else(year == 2005, Total, NA_real_), na.rm = TRUE),
      Total_2010 = sum(if_else(year == 2010, Total, NA_real_), na.rm = TRUE),
      Total_2015 = sum(if_else(year == 2015, Total, NA_real_), na.rm = TRUE),
      Total_2020 = sum(if_else(year == 2020, Total, NA_real_), na.rm = TRUE)
    ) %>%
    rowwise() %>%
    mutate(
      Total_2003 = approx(years, c(Total_2000, Total_2005, Total_2010, Total_2015, Total_2020), xout = 2003)$y,
      Total_2008 = approx(years, c(Total_2000, Total_2005, Total_2010, Total_2015, Total_2020), xout = 2008)$y,
      Total_2013 = approx(years, c(Total_2000, Total_2005, Total_2010, Total_2015, Total_2020), xout = 2013)$y,
      Total_2018 = approx(years, c(Total_2000, Total_2005, Total_2010, Total_2015, Total_2020), xout = 2018)$y
    ) %>%
    ungroup() %>%
    pivot_longer(
      cols = starts_with("Total_"),
      names_to = "year",
      names_prefix = "Total_",
      values_to = "Total"
    ) %>%
    mutate(year = as.integer(year))
  
  return(interpolated_data)
}

# Aplicar la interpolación
data_interpolated <- interpolate_population(data_population)

# Combinar los datos interpolados con los datos originales para incluir el año 2020
data_final <- data_population %>%
  bind_rows(data_interpolated %>%
              filter(year != 2020) %>%
              select(mun_ID, Municipio, Estado, year, Total))

saveRDS(data_final, file = "Cleaned data/data_population.rds")
