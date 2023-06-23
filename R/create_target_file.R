#' Create target geotiff
#'
#' @param cuberast object of class cube; raster cube to generate target file on
#' @param dir character; directory that target geotiff is stored
#' @param date character; date to create target geotiff for
#' @param mask sf object; optional, mask polygon to use
#' @return character; directory that geotiff target file is written to.
#' @examples 
#' # Bounding box ------------------------------------------------------------
#' # pull box, mask
#' fire_box <- fire_bbox(fire = "august_complex", pad_box = TRUE)
#' # Ingest data ------------------------------------------------------------
#' raster_cube <- ingest_planetary_data(start_date = "2002-01-01", 
#'                                      end_date = "2023-07-01", 
#'                                      box = fire_box$bbox)
#' # Generate targets dir/files ------------------------------------------------------------
#' target_forecast_dir <- create_target_file(cuberast = raster_cube, 
#'                                           date = '2023-06-22',
#'                                           dir = 'targets',
#'                                           mask = fire_box$maskLayer)

create_target_file <- function(cuberast, date, dir, mask = NULL){
  ## write geotif file
  dir.create(dir, FALSE)
  #if statement to mask data in burn area
  if(!is.null(mask)){
    #Data masked
    cuberast %>% gdalcubes::select_time(date) %>% gdalcubes::filter_geom(geom = mask, srs = "EPSG:4326") %>% write_tif(dir = dir)
    
  }
  else{
    #data not masked
  cuberast %>% gdalcubes::select_time(date) %>% write_tif(dir = dir)
  } #end if statement to mask data to burn area
  return(dir)
}
