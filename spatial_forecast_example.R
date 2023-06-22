suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Data ingest -------------------------------------------------------------
# selecting 5 example locations

## Example 1: 
cuberast_ex1 <- ingest_planetary_data(start_date = "2002-01-01", end_date = "2023-07-01", box = c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))

## set forecast date. note that date
## should be input in format yyyy-mm-dd
forecast_date <- '2023-06-22'

## generate climatology forecast using spat_climatology function
spat_climatology(cuberast = cuberast_ex1,
                 date = forecast_date)

## generate scores
scoring_spat_ensemble(fc_dir = 'climatology',
                      target_dir = 'targets',
                      scores_dir = 'scores')
