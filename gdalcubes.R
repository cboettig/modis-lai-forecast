# needs some dev versions of packages for now
# remotes::install_github("OldLipe/rstac@b-0.9.1")
# remotes::install_github("appelmar/gdalcubes_R")
library(rstac)
library(gdalcubes)
library(spData)
library(stars)
gdalcubes_options(parallel = 24)
#mikes_box <- c(-75, 40, -70, 44)
box <- sf::st_bbox(us_states)

matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = "2022-01-01/2022-11-30",
              bbox = c(box)) |>
  get_request() |>
  items_fetch() |>
  items_sign(sign_fn = sign_planetary_computer())

# Confirm we can read a single image as expected

cube <- gdalcubes::stac_image_collection(matches$features,
                                         asset_names = "Lai_500m",
                                         duration = "start")
v <- cube_view(srs = "EPSG:4326",
               extent = list(t0 = "2022-01-01", t1 = "2022-11-30",
                             left = box[1], right = box[3],
                             top = box[4], bottom = box[2]),
               nx = 1000, ny = 1000, dt= "P1M",
               aggregation = "median", resampling = "average"
               )



Q <- raster_cube(cube,v)
plot(Q, zlim=c(0,70), col = viridisLite::mako)
# plot average over time
Q |> reduce_time(c("mean(Lai_500m)")) |>
  plot(zlim=c(0,60), col = viridisLite::mako, downsample=FALSE)

Q |>
  animate(col = viridisLite::mako, zlim=c(0,60),
          key.pos = 1, save_as = "anim.gif", fps = 4)

