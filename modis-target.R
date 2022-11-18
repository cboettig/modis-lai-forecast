library(tidyverse)
library(lubridate)
library(rstac)
library(httr)
library(stars)
library(spData)
library(tmap)
#tmap_options(max.raster=c(plot=1e6, view=1e6))

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

# example fn, use logs
remap <- function(x, epsilon=1e-1) {
  log(x[1] + epsilon)
}

plot_png <- function(X, date) {
  m <- X |>
    st_apply(1:2, remap) |>
    # st_transform(crs="+proj=longlat")  |> slow!!
    tm_shape() +
    tm_raster(n = 100,
              palette = viridisLite::mako(100),
              legend.show = FALSE)
  tmap_save(m, paste0("lai-", date, ".png"), width=1920, height=1080)
}

get_mosaic <- function(end) {
  start <- end - 8

  matches <-
    stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
    stac_search(collections = "modis-15A2H-061",
                datetime = paste(start, end, sep="/"),
                bbox = c(box),
                limit = 100) |>
    post_request() |>
    items_sign(sign_fn = sign_planetary_computer())

  ## Some tiles have been visited multiple times, get most recent for each US-intesecting tile
  v <- purrr::map_int(matches$features, list("properties", "modis:vertical-tile"))
  h <- purrr::map_int(matches$features, list("properties", "modis:horizontal-tile"))
  date <- purrr::map_chr(matches$features, list("properties", "created"))
  urls <- map_chr(matches$features, list("assets", "Lai_500m", "href"))
  usa <- tibble(v,h, date, urls) |> group_by(v,h) |> slice_max(date)

  ## Grab the US tiles
  rast <- vector("list", nrow(usa))
  for(i in 1:nrow(usa)) {
    rast[[i]] <- stars::read_stars(mysign(usa$urls[i]))
    Sys.sleep(10) # avoid rate limiting
  }
  mosaic <- do.call(st_mosaic, compact(rast))



  tif <- paste0("mosaic-", end, ".tif")
  message(paste("writing", tif))
  stars::write_stars(mosaic, tif)

  plot_png(mosaic, end)


}

# test one date
# get_mosaic(Sys.Date())

#as.Date(strptime(week(today()), format="%W"))
#today <- today()
today <- as.Date("2020-12-16")

bench::bench_time({
#dates <- seq(today-years(4),today, by = 'week')
dates <- seq(as.Date("2020-08-07"),as.Date("2022-01-01"), by = 'week')

walk(dates, get_mosaic)
})


pngs <- fs::dir_ls(glob="*.png")
gifski::gifski(pngs, "modis.gif", width = 800, height = 300, loop = FALSE, delay = 0.01)


