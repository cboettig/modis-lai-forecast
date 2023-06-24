#' Build spatial climatology forecast 
#'
#' @param cuberast object of class cube; raster cube to generate forecasts on
#' @param date date as character format yyyy-mm-dd; date to generate forecast
#' @param dir character; directory to store geotiff files. If the specified directory does not exist, it is created
#' @return character; directory that geotiff files are written to.
#' @examples 
#' # Bounding box ------------------------------------------------------------
#' # pull box, mask
#' fire_box <- fire_bbox(fire = "august_complex", pad_box = TRUE)
#' # Ingest data ------------------------------------------------------------
#' raster_cube <- ingest_planetary_data(start_date = "2002-01-01", 
#'                                      end_date = "2023-07-01", 
#'                                      box = fire_box$bbox)
#' # Generate targets dir/files ------------------------------------------------------------
#' # Forecast ----------------------------------------------------------------
#' ensemble_forecast_dir <- spat_climatology(cuberast = raster_cube,
#'                                           date = '2023-06-22',
#'                                           dir = 'climatology')
#' @export
#' 


spat_climatology <- function(cuberast, date, dir = 'climatology'){
  ## FUNCTION: spat_climatology
  ## PURPOSE: spat_climatology takes a raster cube, date, and directory
  ## and generates a climatological forecast for the specified inputs.
  ## This is an ensemble forecasting method, and saves the ensemble as
  ## geotiff files in the specified
  ## INPUTS: 
  ## cuberast - object of class cube
  ## date - object of class character or date
  ## date should be input in the following format:
  ## for June 22nd, 2023, use "2023-06-23"
  ## dir - character vector, directory to store geotiff files.
  ## if the specified directory does not exist, it is created
  ## OUTPUTS: N/A
  
  ## get dimension values from raster cube
  d <- gdalcubes::dimension_values(cuberast)
  
  ## use lubridate to extract month value for 
  ## raster cube dimension values
  months_t <- month(d$t)
  
  ## use lubridate to extract month value for
  ## given forecast date of interest
  month_of_date = month(date)
  
  ## subset raster cube date values for month
  ## of interest
  subset <- d$t[months_t == month_of_date]
  
  ## create directory
  dir.create(dir, FALSE)
  
  ## write geotif file
  cuberast %>% gdalcubes::select_time(subset) %>% write_tif(dir = dir)
  
  return(dir)
}
