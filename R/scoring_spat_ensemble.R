## scores

scoring_spat_ensemble <- function(fc_dir, target_dir, scores_dir){
  ## pull most recent target raster
  target_rast <- rast(last(sort(dir_ls(paste0(target_dir, '/')))))
  
  ## read in forecast as raster
  fc <- rast(dir_ls(paste0(fc_dir, '/')))
  
  ## create vector of observations from target rast
  y <- as.vector(values(target_rast))
  
  mask <- is.na(y)
  y[mask] <- 1
  
  ## create matrix of data to be used during scoring
  dat <- values(fc)
  
  dat_bootstrap <- apply(dat, 2, FUN = na_bootstrap_fun)
  
  ## compute crps and log score from ensemble
  crps_ensemble <- crps_sample(y = y, dat = dat_bootstrap)
  crps_ensemble[mask] <- NA
  logs_ensemble <- logs_sample(y = y, dat = dat_bootstrap)
  logs_ensemble[mask] <- NA
  
  ## convert scores to raster
  crps_scores <- logs_scores <- target_rast
  values(crps_scores) <- matrix(crps_ensemble, ncol = 1)
  values(logs_scores) <- matrix(logs_ensemble, ncol = 1)
  
  ## check for scoring directory
  dir.create(scores_dir, FALSE)
  
  ## write tif files for crps and log scores
  writeRaster(crps_scores, filename = paste0(scores_dir, '/crps_scores.tif'))
  writeRaster(logs_scores, filename = paste0(scores_dir, '/logs_scores.tif'))
  
  return(scores_dir)
}