suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Bounding box ------------------------------------------------------------
# TODO add function and documentation for how this was selected

# Ingest data ------------------------------------------------------------
raster_cube <- ingest_planetary_data(start_date = "2002-01-01", 
                                     end_date = "2023-07-01", 
                                     box = c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))

# Generate targets dir/files ------------------------------------------------------------
# TODO function to create target file
# take the cube
# gdal split for a given day (argument)
# incorporate mask
# return targets directory

# Forecast ----------------------------------------------------------------
ensemble_forecast_dir <- spat_climatology(cuberast = raster_cube,
                                      date = '2023-06-22') 

# Score ----------------------------------------------------------------
scored_forecast_dir <- scoring_spat_ensemble(fc_dir = ensemble_forecast_dir,
                                        target_dir = 'targets', # chnage to output of create_target
                                        scores_dir = 'scores')

# Upload to AWS -----------------------------------------------------------
# TODO
# prediction ensembles
# target file
# scored


# TODO automation logic (setting dates)
