na_bootstrap_fun <- function(x){
  ## check if all x values are NA. stop if so 
  if (all(is.na(x))) stop('All values NA, cannot perform bootstrap')
  ## check if all x values are non-missing. return x if so
  if (all(!is.na(x))) return(x)
  ## if some values are missing, perform bootstrap resampling
  x[is.na(x)] <- sample(x[!is.na(x)], size = length(x[is.na(x)]))
  return(x)
}
