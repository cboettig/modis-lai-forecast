##############################################################################################
#' @title Fire bounding box

#' @author David Durden


#' @description Function definition. Read in fire boundary shapefile and determine
#' and a bounding box for grabbing MODIS data with a padding option.

#' @param dir directory where shapefiles are located 
#' @param fire name of fire incident, needs to be specified to read in shapefile (Defaults to "august_complex")
#' @param crs coordinate reference system (Defaults to "EPSG:4326")
#' @param pad_box logical to determine if padding should be applied to bounding box (defaults to FALSE)
#' @param pad_degree decimal degree of latitude and longitude to pad the bounding box (defaults to 0.1) 

#' @return list containing shapefile data and bbox

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords natural constants

#' @examples Currently none

#' @seealso Currently none

#' @export
#' 
# changelog and author contributions
#   Stefan Metzger (2023-06-23)
#     original creation 
##############################################################################################
fire_bbox <- function(
    dir = "./shp", 
    fire = c("august_complex","east_troublesome")[1],
    crs = "EPSG:4326",
    pad_box = FALSE,
    pad_degree = 0.1){
  #Input directory
  dirInp <- paste0(dir,"/",fire)
  
  #Initialize list
  out <- list()
  
  ## read shape file
  out$shp <- sf::read_sf(dsn = dirInp, "mask")

  #generate bounding box
  out$bbox <- out$shp |> sf::st_transform(crs=crs) |> sf::st_bbox()

  #pad bounding box
  if(pad_box == TRUE){
    out$bbox[1] <- out$bbox$xmin - pad_degree #Padding in degrees
    out$bbox[2] <- out$bbox$ymin - pad_degree
    out$bbox[3] <- out$bbox$xmax + pad_degree
    out$bbox[4] <- out$bbox$ymax + pad_degree
  }
  
  #Return output list with shp and bbox
  return(out)
}


