# this script will 
# a) ingest data
# b) run simple model
# c) publish results

suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)


# Data ingest -------------------------------------------------------------
# selecting 5 example locations

url <- "/vsicurl/https://minio.carlboettiger.info/public-biodiversity/fire22_1.gdb"
st_layers(url)
fire <- st_read(url, "firep22_1")
fire |> filter(GIS_ACRES == max(GIS_ACRES))
august_complex <- fire |> filter(FIRE_NAME == "AUGUST COMPLEX") 

box <- august_complex |> st_transform(crs=4326) |> st_bbox()

## Example 1: 

cuberast_ex1 <- ingest_planetary_data(collection = "modis-15A2H-061", asset_name = "Lai_500m", start_date = "2002-01-01", end_date = "2023-07-01", box = c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))

## set forecast date. note that date
## should be input in format yyyy-mm-dd
forecast_date <- '2023-06-22'

## generate climatology forecast using spat_climatology function
spat_climatology(cuberast = cuberast_ex1,
                 date = forecast_date)
