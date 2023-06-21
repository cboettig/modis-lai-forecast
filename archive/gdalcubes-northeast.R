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


## not fast but valid
RW <- function(v) {
  v[1] + rnorm(1,0,1)
}
y <- raster_cube(cube, v) |> apply_pixel(names="predicted", FUN=RW)

y |> write_tif("rw_forecast")



raster_cube(cube,v) |> 
  animate(zlim=c(0,70), col = viridisLite::mako, fps=2, save_as = "northeast.gif")



library(stars)
fs <- fs::dir_ls("forecast/")
times <- seq(as.Date("2018-01-01"), as.Date("2022-12-01"), by=16)
times <- as.POSIXct(times)
x = read_stars(fs, proxy=TRUE,along = "time")
x = st_set_dimensions(x, 3, values = dates,  names = "time")

#small <- x |> stars::st_downsample(4)
#st_get_dimension_values(x, "time")

y = aggregate(x, by = lubridate::month, FUN=mean) 
plot(y)

library(tmap)
tm_shape(y) + tm_raster(palette= viridisLite::mako(100), n=100) + tm_facets("time")


plot(Q, zlim=c(0,70), col = viridisLite::mako)
# plot average over time
Q |> reduce_time(c("mean(Lai_500m)")) |>
  plot(zlim=c(0,50), col = viridisLite::mako)

Q 