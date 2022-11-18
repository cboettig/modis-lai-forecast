library(tidyverse)
library(lubridate)
library(rstac)
library(httr)
library(stars)
library(spData)
library(tmap)
## Create a climatology forecast using monthly averages
box <- st_bbox(us_states)


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



## too many items, must subset datetime range better
matches <-
  stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
  stac_search(collections = "modis-15A2H-061",
              datetime = "2018-01-01/2022-11-15",
              bbox = c(box),
              limit=10) |>
  get_request()

length(matches$features)

## Some tiles have been visited multiple times, get most recent for each US-intesecting tile
v <- purrr::map_int(matches$features, list("properties", "modis:vertical-tile"))
h <- purrr::map_int(matches$features, list("properties", "modis:horizontal-tile"))
date <- purrr::map_chr(matches$features, list("properties", "created"))
urls <- map_chr(matches$features, list("assets", "Lai_500m", "href"))
usa_all <- tibble(v,h, date, urls) |> mutate(year=year(date), month=month(date), week = week(date))


usa <- usa_all |> group_by(v,h, year, week) |> slice_max(date)

month_groups <- usa |>
  group_by(v, h, month) |>
  dplyr::group_map( \(x, ...) x$urls)


## Example: average 1 month-group across one tile:

set <- month_groups[[1]]


## Grab the tiles
urls <- map(set,
            function(x) {
              out <- mysign(x)
              Sys.sleep(10)
              out
              }
            )

# ~ 1 min per group
X <- read_stars(urls, along = "time")
bench::bench_time({
  X |>
    st_apply(1:2, mean) |>
    write_stars("forecast/test.tif")
})



