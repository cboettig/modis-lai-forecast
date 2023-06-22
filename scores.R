## scores

source('./R/ingest_planetary_data.R')

target <- ingest_planetary_data(start_date = '2023-05-01', end_date = '2023-05-30',
                                box = c("xmin" = -123, "ymin" = 39, "xmax" = -122, "ymax" = 40))

#target %>% gdalcubes::animate(zlim=c(0,42))

target_rast <- rast('targets/cube_14d9733031be32023-05-01.tif')

fc <- rast(dir_ls('climatology/'))

y <- as.vector(values(target_rast))
#y[y > 42] <- NA

dat <- values(fc)

#dat[dat > 42] <- NA

crps_ensemble <- crps_sample(y = y, dat = dat)
logs_ensemble <- logs_sample(y = y, dat = dat)

crps_ensemble[y > 42] <- NA
logs_ensemble[y > 42] <- NA

crps_scores <- target_rast
values(crps_scores) <- matrix(crps_ensemble, ncol = 1)

## set range argument
plot(fc, range = c(0, 42))
