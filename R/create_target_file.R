create_target_file <- function(cuberast, date, dir){
  ## write geotif file
  dir.create(dir, FALSE)
  cuberast %>% gdalcubes::select_time(date) %>% write_tif(dir = dir)
  return(dir)
}
