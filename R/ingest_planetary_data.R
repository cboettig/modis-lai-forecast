
# roxygen

ingest_planetary_data <- function(collection = "modis-15A2H-061",
                                  asset_name = "Lai_500m",
                                  start_date = "2022-01-01",
                                  end_date = "2023-07-01",
                                  box){
  
  # TODO check format of dates and box
  
  matches <-
    stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
    stac_search(collections = collection,
                datetime = paste(start_date, end_date, sep = "/"),
                bbox = c(box)) |>
    get_request() |>
    items_fetch() |>
    items_sign(sign_fn = sign_planetary_computer())
  
  cube <- gdalcubes::stac_image_collection(matches$features,
                                           asset_names = asset_name,
                                           duration = "start")
  
  v <- cube_view(srs = "EPSG:4326", #lat/lon
                 extent = list(t0 = start_date, t1 = end_date,
                               left = box[1], right = box[3],
                               top = box[4], bottom = box[2]),
                 dx = 0.1, dy = 0.1, dt= "P30D",
                 aggregation = "mean", resampling = "near")
  
  # continue with code from disturbace.qmd
  d <- raster_cube(cube, v)
  
}