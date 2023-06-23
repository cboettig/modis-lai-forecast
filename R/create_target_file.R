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
