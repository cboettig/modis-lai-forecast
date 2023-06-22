suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Bounding box ------------------------------------------------------------
# TODO add function and documentation for how this was selected

# Ingest data ------------------------------------------------------------
cuberast_ex1 <- ingest_planetary_data(start_date = "2002-01-01", 
                                      end_date = "2023-07-01", 
                                      box = c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))

# Generate targets dir/files ------------------------------------------------------------
# TODO function to create target file

# Forecast ----------------------------------------------------------------
spat_climatology(cuberast = cuberast_ex1,
                 date = '2023-06-22') 

# Score ----------------------------------------------------------------
# TODO add mask here (0/1)
scoring_spat_ensemble(fc_dir = 'climatology',
                      target_dir = 'targets',
                      scores_dir = 'scores')

# Upload to AWS -----------------------------------------------------------
# prediction ensembles
# target file
# scored
