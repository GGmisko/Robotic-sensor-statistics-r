# ==========================================================
# PROYECTO DE ESTADÍSTICA DESCRIPTIVA EN R
# Dataset: Human Activity Recognition Using Smartphones
# Tema: Análisis de datos sensoriales tipo robótico
# ==========================================================

# 1. Instalar paquetes si no los tienes
# install.packages("tidyverse")

# 2. Cargar librerías
library(tidyverse)

# 3. Definir ruta principal
ruta <- dirname(archivo_features[1])

# 4. Leer nombres de variables
features <- read.table(file.path(ruta, "features.txt"))

# 5. Leer etiquetas de actividades
activity_labels <- read.table(file.path(ruta, "activity_labels.txt"))

# 6. Cargar datos de entrenamiento
X_train <- read.table(file.path(ruta, "train", "X_train.txt"))
y_train <- read.table(file.path(ruta, "train", "y_train.txt"))
subject_train <- read.table(file.path(ruta, "train", "subject_train.txt"))

# 7. Cargar datos de prueba
X_test <- read.table(file.path(ruta, "test", "X_test.txt"))
y_test <- read.table(file.path(ruta, "test", "y_test.txt"))
subject_test <- read.table(file.path(ruta, "test", "subject_test.txt"))

# 8. Asignar nombres correctos a las columnas
colnames(X_train) <- features$V2
colnames(X_test) <- features$V2

# 9. Unir datos de entrenamiento y prueba
X_total <- rbind(X_train, X_test)
y_total <- rbind(y_train, y_test)
subject_total <- rbind(subject_train, subject_test)

# 10. Renombrar columnas auxiliares
colnames(y_total) <- "ActivityCode"
colnames(subject_total) <- "Subject"

# 11. Reemplazar códigos de actividad por nombres
y_total$Activity <- factor(
  y_total$ActivityCode,
  levels = activity_labels$V1,
  labels = activity_labels$V2
)

# 12. Unir todo en una sola base de datos
datos <- cbind(
  Subject = subject_total$Subject,
  Activity = y_total$Activity,
  X_total
)

# 13. Verificar estructura
dim(datos)
head(datos)
summary(datos$Activity)

# ==========================================================
# SELECCIÓN DE VARIABLES IMPORTANTES
# ==========================================================

datos_seleccionados <- datos %>%
  select(
    Subject,
    Activity,
    `tBodyAcc-mean()-X`,
    `tBodyAcc-mean()-Y`,
    `tBodyAcc-mean()-Z`,
    `tBodyAcc-std()-X`,
    `tBodyAcc-std()-Y`,
    `tBodyAcc-std()-Z`,
    `tBodyGyro-mean()-X`,
    `tBodyGyro-mean()-Y`,
    `tBodyGyro-mean()-Z`
  )

# Cambiar nombres para que sean más fáciles de usar
datos_seleccionados <- datos_seleccionados %>%
  rename(
    Acc_Media_X = `tBodyAcc-mean()-X`,
    Acc_Media_Y = `tBodyAcc-mean()-Y`,
    Acc_Media_Z = `tBodyAcc-mean()-Z`,
    Acc_Desv_X = `tBodyAcc-std()-X`,
    Acc_Desv_Y = `tBodyAcc-std()-Y`,
    Acc_Desv_Z = `tBodyAcc-std()-Z`,
    Gyro_Media_X = `tBodyGyro-mean()-X`,
    Gyro_Media_Y = `tBodyGyro-mean()-Y`,
    Gyro_Media_Z = `tBodyGyro-mean()-Z`
  )

head(datos_seleccionados)

# ==========================================================
# TABLAS DESCRIPTIVAS
# ==========================================================

# Tabla de frecuencia de actividades
tabla_actividades <- datos_seleccionados %>%
  count(Activity)

tabla_actividades

# Resumen general de variables numéricas
resumen_general <- datos_seleccionados %>%
  select(-Subject, -Activity) %>%
  summary()

resumen_general

# Medidas estadísticas por actividad
resumen_por_actividad <- datos_seleccionados %>%
  group_by(Activity) %>%
  summarise(
    Media_Acc_X = mean(Acc_Media_X),
    Mediana_Acc_X = median(Acc_Media_X),
    Desv_Acc_X = sd(Acc_Media_X),
    Min_Acc_X = min(Acc_Media_X),
    Max_Acc_X = max(Acc_Media_X)
  )

resumen_por_actividad

# ==========================================================
# GRÁFICOS
# ==========================================================

# Gráfico 1: cantidad de registros por actividad
ggplot(datos_seleccionados, aes(x = Activity)) +
  geom_bar() +
  labs(
    title = "Cantidad de registros por actividad",
    x = "Actividad",
    y = "Frecuencia"
  ) +
  theme_minimal()

# Gráfico 2: histograma de aceleración media en X
ggplot(datos_seleccionados, aes(x = Acc_Media_X)) +
  geom_histogram(bins = 30) +
  labs(
    title = "Distribución de la aceleración media en el eje X",
    x = "Aceleración media en X",
    y = "Frecuencia"
  ) +
  theme_minimal()

# Gráfico 3: boxplot de aceleración media en X por actividad
ggplot(datos_seleccionados, aes(x = Activity, y = Acc_Media_X)) +
  geom_boxplot() +
  labs(
    title = "Aceleración media en X por actividad",
    x = "Actividad",
    y = "Aceleración media en X"
  ) +
  theme_minimal()

# Gráfico 4: boxplot de aceleración media en Z por actividad
ggplot(datos_seleccionados, aes(x = Activity, y = Acc_Media_Z)) +
  geom_boxplot() +
  labs(
    title = "Aceleración media en Z por actividad",
    x = "Actividad",
    y = "Aceleración media en Z"
  ) +
  theme_minimal()

# Gráfico 5: relación entre aceleración X y aceleración Y
ggplot(datos_seleccionados, aes(x = Acc_Media_X, y = Acc_Media_Y, color = Activity)) +
  geom_point(alpha = 0.5) +
  labs(
    title = "Relación entre aceleración media en X y Y",
    x = "Aceleración media en X",
    y = "Aceleración media en Y"
  ) +
  theme_minimal()

# Gráfico 6: relación entre aceleración y giroscopio
ggplot(datos_seleccionados, aes(x = Acc_Media_X, y = Gyro_Media_X, color = Activity)) +
  geom_point(alpha = 0.5) +
  labs(
    title = "Relación entre aceleración y velocidad angular en el eje X",
    x = "Aceleración media en X",
    y = "Velocidad angular media en X"
  ) +
  theme_minimal()

# ==========================================================
# MATRIZ DE CORRELACIÓN
# ==========================================================

correlaciones <- datos_seleccionados %>%
  select(Acc_Media_X, Acc_Media_Y, Acc_Media_Z,
         Gyro_Media_X, Gyro_Media_Y, Gyro_Media_Z) %>%
  cor()

correlaciones

# ==========================================================
# EXPORTAR TABLAS
# ==========================================================

write.csv(datos_seleccionados, "datos_seleccionados_robotica.csv", row.names = FALSE)
write.csv(tabla_actividades, "tabla_actividades.csv", row.names = FALSE)
write.csv(resumen_por_actividad, "resumen_por_actividad.csv", row.names = FALSE)

# Primeras 20 filas para anexo
primeras_20_filas <- head(datos_seleccionados, 20)
write.csv(primeras_20_filas, "primeras_20_filas.csv", row.names = FALSE)