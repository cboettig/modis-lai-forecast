library(rstac)
s = stac("https://earth-search.aws.element84.com/v0")

items <- s %>%
  stac_search(collections = "sentinel-s2-l2a-cogs",
              bbox = c(6.1,46.2,6.2,46.3), # Geneva
              datetime = "2020-01-01/2020-12-31",
              limit = 500) %>%
  post_request()

library(gdalcubes)


assets = c("B02","B03","B04", "SCL")
col = stac_image_collection(items$features,
                            asset_names = assets,
                            property_filter = function(x) {x[["eo:cloud_cover"]] < 20})

v = cube_view(srs = "EPSG:3857",  extent = list(t0 = "2020-01-01", t1 = "2020-12-31",
                                                left = 674052, right = 693136,  top = 5821142, bottom = 5807088),
              dx = 20, dy = 20, dt = "P1D", aggregation = "median", resampling = "average")

S2.mask = image_mask("SCL", values=c(3,8,9)) # clouds and cloud shadows
gdalcubes_options(parallel = 12)
raster_cube(col, v, mask = S2.mask) %>%
  select_bands(c("B02","B03","B04")) %>%
  reduce_time(c("median(B02)", "median(B03)", "median(B04)")) %>%
  plot(rgb = 3:1, zlim=c(0,1800)) %>% system.time()
