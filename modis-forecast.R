# remotes::install_github("OldLipe/rstac@b-0.9.1")
# remotes::install_github("appelmar/gdalcubes_R")
# remotes::install_github("r-spatial/stars")
library(rstac)
library(gdalcubes)
library(stars)
gdalcubes_options(parallel = 24)
box <- c(-75, 40, -70, 44)

matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = "2018-01-01/2022-12-01",
              bbox = c(box)) |>
  get_request() |>
  items_fetch() |>
  items_sign(sign_fn = sign_planetary_computer())

cube <- gdalcubes::stac_image_collection(matches$features,
                                         asset_names = "Lai_500m",
                                         duration = "start")
v <- cube_view(srs = "EPSG:4326",
               extent = list(t0 = "2018-11-01", t1 = "2022-12-01",
                             left = box[1], right = box[3],
                             top = box[4], bottom = box[2]),
               nx = 1000, ny = 1000, dt= "P16D",
               aggregation = "mean", resampling = "near"
)


## A climatology forecast -- monthly averages via temporal stars::aggregate
raster_cube(cube, v) |> write_tif("target")

## do monthly averages with stars, since we can't do with gdalcubes (yet?)
library(stars)
fs <- fs::dir_ls("target/")
dates <- as.POSIXct(stringr::str_extract(fs, "\\d{4}-\\d{2}-\\d{2}"))
x = read_stars(fs, proxy=TRUE,along = "time") |> stars::st_downsample(6)
x = st_set_dimensions(x, 3, values = dates,  names = "time")
y = aggregate(x, by = \(x) lubridate::month(x, label=TRUE), FUN=mean)
# y |> write_stars("forecast.tif")
plot(y, col = viridisLite::mako(100),  breaks="kmeans")


raster_cube(cube, v) |> filter_time()



# https://lpdaac.usgs.gov/documents/926/MOD15_User_Guide_V61.pdf
# 255 NA
# 254 land cover assigned as perennial salt or inland fresh water
# 253 land cover assigned as barren, sparse vegetation (rock, tundra, desert)
# 252 land cover assigned as perennial snow, ice
# 251 land cover assigned as “permanent” wetlands/inundated marshlands
# 250 land cover assigned as urban/built−up
# 249 land cover assigned as “unclassified” or not able to determine

## We can view this 'target' data in animation
raster_cube(cube,v) |> 
  animate(zlim=c(0,70), col = viridisLite::mako, fps=2, save_as = "northeast.gif")

## We can use custom functions to define forecasts
RW <- function(v) {
  v[1] + rnorm(1,0,1)
}
# y <- raster_cube(cube, v) |> apply_pixel(names="predicted", FUN=RW)


## example chunk-apply  
#f <- function() {
#  x <- read_chunk_as_array()
#  out <- reduce_time(x, function(x) {
#    cor(x[1,], x[2,], use="na.or.complete", method = "kendall")
#  }) 
#  write_chunk_from_array(out)
#}
#L8.cor = chunk_apply(L8.cube, f)

### Regression-based forecast?
#raster_cube(L8.col, cube_view(view = v.subarea.60m, dx=200), mask = L8.clear_mask) |>
#  select_bands(c("B04","B05")) |>
#  apply_pixel("(B05-B04)/(B05+B04)", names = "NDVI") |>
#  reduce_time(names=c("ndvi_trend"), FUN=function(x) {
#    z = data.frame(t=1:ncol(x), ndvi=x["NDVI",])
#    result = NA
#    if (sum(!is.na(z$ndvi)) > 3) {
#      result = coef(lm(ndvi ~ t, z, na.action = na.exclude))[2]
#    }
#    return(result) 
#  }) |>
#  plot(key.pos=1, col=viridis::viridis)

