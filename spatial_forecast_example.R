suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Bounding box ------------------------------------------------------------
# pull box, mask
fire_box <- fire_bbox(fire = "august_complex", pad_box = FALSE)

# Ingest data ------------------------------------------------------------
raster_cube <- ingest_planetary_data(start_date = "2002-01-01", 
                                     end_date = "2023-07-01", 
                                     box = fire_box$bbox)

# Generate targets dir/files ------------------------------------------------------------
target_forecast_dir <- create_target_file(cuberast = raster_cube, 
                                          date = '2023-06-22',
                                          dir = 'targets')

# Forecast ----------------------------------------------------------------
ensemble_forecast_dir <- spat_climatology(cuberast = raster_cube,
                                          date = '2023-06-22',
                                          dir = 'climatology') 

# Score ----------------------------------------------------------------
scored_forecast_dir <- scoring_spat_ensemble(fc_dir = ensemble_forecast_dir,
                                             target_dir = target_forecast_dir,
                                             scores_dir = 'scores')

# Upload to AWS -----------------------------------------------------------
# TODO


# Next steps --------------------------------------------------------------
# TODO deliverable: this file, .qmd, flowchart 
# TODO automation logic (setting dates for data download and forecast forward)
