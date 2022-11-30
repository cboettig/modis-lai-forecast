# needs dev rstac to avoid signing issue
#remotes::install_github("OldLipe/rstac@b-0.9.1")
box <- c(-75, 40, -70, 44)
library(rstac)
matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = "2022-01-01/2022-11-08",
              bbox = box) |>
  get_request() |>
  items_fetch() |>
  items_sign(sign_fn = sign_planetary_computer())

# Confirm we can read a single image as expected

library(gdalcubes)
cube <- gdalcubes::stac_image_collection(matches$features,
                                         asset_names = "Lai_500m",
                                         duration = "start")
v <- cube_view(srs = "EPSG:4326",
               extent = list(t0 = "2022-08-01", t1 = "2022-08-31",
                             left = box[1], right = box[3],
                             top = box[4], bottom = box[2]),
               nx = 1000, ny = 1000, dt= "P8D",
               aggregation = "median", resampling = "average"
               )

Q <- raster_cube(cube,v) |>
  apply_pixel("log(Lai_500m)", "LAI") |>
  reduce_time(c("mean(LAI)"))
plot(Q, zlim=c(0,3), col = viridisLite::mako)





# Time for some gdalcubes
cube <- gdalcubes::stac_image_collection(matches$features, asset_names = "Lai_500m")


ext <- gdalcubes::extent(cube, srs = "OGC:CRS84")  ## native is "Sinusoidal"
ext[c("left", "right", "bottom", "top")] <- as.list(box[c(1, 3, 2,4)])
v <- cube_view(srs = "OGC:CRS84",
               extent = ext,
               nx = 240, ny = 240, dt= "P28D",
               aggregation = "median", resampling = "near"
)


Q <- raster_cube(cube,v)
plot(Q, zlim=c(0,25))

# cut <- setNames(box, c("xmin", "ymin", "xmax", "ymax")) |>
# st_bbox(box, crs=4326L) |> st_as_sfc() |> st_transform(st_crs(remote))
# remote |> st_crop(cut) |> plot()


library(stars)
url1 <- matches$features[[2]]$assets$Lai_500m$href
remote <- stars::read_stars(paste0("/vsicurl/", url1))
plot(remote)
