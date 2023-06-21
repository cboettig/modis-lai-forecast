# needs some dev versions of packages for now
# remotes::install_github("OldLipe/rstac@b-0.9.1")
# remotes::install_github("appelmar/gdalcubes_R")
library(rstac)
library(gdalcubes)
library(spData)
library(stars)
gdalcubes_options(parallel = 24)
box <- c(-75, 40, -70, 44)


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
               nx = 2400, ny = 1000, dt= "P8D",
               aggregation = "median", resampling = "near"
)



Q <- raster_cube(cube,v)

# plot average over time
Q |> reduce_time(c("mean(Lai_500m)")) |>
  plot(zlim=c(0,50), col = viridisLite::mako)

Q |>
  animate(col = viridisLite::mako, zlim=c(0,60),
          key.pos = 1, save_as = "anim.gif", fps = 4)




stars <- Q |> st_as_stars()

plot(stars, zlim=c(0,3.4), col = viridisLite::mako, na.rm = TRUE)



ext <- gdalcubes::extent(cube, srs = "OGC:CRS84")  ## native is "Sinusoidal"
ext[c("left", "right", "bottom", "top")] <- as.list(box[c(1, 3, 2,4)])
v <- cube_view(srs = "OGC:CRS84",
               extent = ext,
               nx = 1000, ny = 1000, dt= "P8D",
               aggregation = "median", resampling = "average"
)