library(tidyverse)
library(rstac)
library(httr)
library(stars)
library(spData)
box <- st_bbox(us_states)

mysign <- function(href) {
  x <- parse_url(href)
  y <- glue::glue("{scheme}://{hostname}/{path}", scheme = x$scheme, hostname = x$hostname, path = x$path)
  resp <- GET(paste0("https://planetarycomputer.microsoft.com/api/sas/v1/sign?href=", y))
  stop_for_status(resp)
  url <- httr::content(resp)
  out <- paste0("/vsicurl/",url$href)
  return(out)
}

end <- Sys.Date()
start <- end - 8

matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = paste(start, end, sep="/"),
              bbox = c(box),
              limit = 100) |>
  post_request() |>
  items_sign(sign_fn = sign_planetary_computer())

urls <- map_chr(matches$features, list("assets", "Lai_500m", "href"))

x <- stars::read_stars(mysign(urls[[17]]) )


library(tmap)
tmap_options(max.raster=c(plot=1e6, view=1e6))

tm_shape(x) + tm_raster(palette = viridisLite::mako(200) )


library(MODISTools)

# download data
subset <- mt_subset(product = "MOD15A2H",
                    lat = 40,
                    lon = -110,
                    band = "Lai_500m",
                    start = "2004-01-01",
                    end = "2004-02-01",
                    km_lr = 1,
                    km_ab = 1,
                    site_name = "testsite",
                    internal = FALSE,
                    progress = FALSE,
                    out_dir = ".")
subset
