library(tidyverse)
library(lubridate)
library(rstac)
library(httr)
library(stars)
library(spData)
library(tmap)
## Create a climatology forecast using monthly averages
box <- st_bbox(us_states)

sites <- readr::read_csv(paste0("https://github.com/eco4cast/neon4cast-noaa-download/",
       "raw/master/noaa_download_site_list.csv"))

z <- sites |> filter(site_id == "HARV")
y <- z$latitude
x <- z$longitude
buffer <- 0.1
coords <- c(x - buffer, y- buffer, x+buffer, y+ buffer)

matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = "2022-09-01/2022-10-01",
              bbox = coords,
              limit=10) |>
  get_request()


# Ick work around rstac bug
mysign <- function(href) {
  x <- parse_url(href)
  y <- glue::glue("{scheme}://{hostname}/{path}", scheme = x$scheme, hostname = x$hostname, path = x$path)
  resp <- GET(paste0("https://planetarycomputer.microsoft.com/api/sas/v1/sign?href=", y))
  stop_for_status(resp)
  url <- httr::content(resp)
  out <- paste0("/vsicurl/",url$href)
  return(out)
}
date <- matches$features[[1]]$properties$created

url <- mysign(matches$features[[1]]$assets$Lai_500m$href)
x <- read_stars(url, proxy=TRUE)

x |>
  # st_transform(crs="+proj=longlat")  |> # optionally reproject
  tm_shape() +
  tm_raster(n = 100,
            palette = viridisLite::mako(100),
            legend.show = FALSE) +
  tm_shape(sites_sf) + tm_markers(col = "darkred") +
  tm_text("site_id", size = 0.5, col = "white") +
  tm_credits(paste("MODIS LAI on", as.Date(date)))



