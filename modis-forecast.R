
## Create a climatology forecast using monthly averages

tif <- fs::dir_ls(glob="*.tif")
dates <- as.POSIXct(str_extract(tif, "\\d{4}-\\d{2}-\\d{2}"))
df <- tibble(tif, dates) |> mutate(year=year(dates), month=month(dates))
month_groups <- df |>
  group_by(month) |>
  dplyr::group_map( \(x, ...) x$tif)

fs::dir_create("forecast")
for(i in seq_along(month_groups)) {

  files <- month_groups[[i]]
  dates <- as.POSIXct(str_extract(files, "\\d{4}-\\d{2}-\\d{2}"))
  out <- file.path("forecast/", paste0(month(i), ".tif"))

  X <- read_stars(files, proxy=TRUE, along = "time") |>
    st_set_dimensions(3, values = dates, names = "time")

  ## ICK RAM ineffient doomed to crash
  bench::bench_time({
    X |>
      st_apply(1:2, mean) |>
      st_downsample(48) |>
      write_stars(out)
  })
}





quickmap <- function(x) x |>
  st_apply(1:2, remap) |>
  tm_shape() +
  tm_raster(n = 100,
            palette = viridisLite::mako(100),
            legend.show = FALSE)


