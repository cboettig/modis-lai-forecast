suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

url <- "/vsicurl/https://minio.carlboettiger.info/public-biodiversity/fire22_1.gdb"
st_layers(url)
fire <- st_read(url, "firep22_1")
fire |> filter(GIS_ACRES == max(GIS_ACRES))
august_complex <- fire |> filter(FIRE_NAME == "AUGUST COMPLEX") 

box <- august_complex |> st_transform(crs=4326) |> st_bbox()
