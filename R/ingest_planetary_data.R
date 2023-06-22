#' Download data from Microsoft planetary comuputer 
#'
#' @param collection Name of planetary collection
#' @param asset_name Name of asset name
#' @param start_date Start date for data in format yyyy-mm-dd
#' @param end_date End date for data in format yyyy-mm-dd
#' @param box Vector of values (xmin, ymin, xmax, ymax)
#' @return An image_collection_cube pointer
#' @examples 
#' ingest_planetary_data(collection = "modis-15A2H-061", asset_name = "Lai_500m", start_date = "2022-01-01", end_date = "2023-07-01", box =  c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))
# roxygen

ingest_planetary_data <- function(collection = "modis-15A2H-061",
                                  asset_name = "Lai_500m",
                                  start_date = "2022-01-01",
                                  end_date = "2023-07-01",
                                  box){
  
  # defaults for dx dy and time
  # srs
  # user needs to ensure box is same as source
  
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
  return(d)
}