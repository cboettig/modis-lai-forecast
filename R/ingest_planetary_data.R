
ingest_planetary_data <- function(collection = "modis-15A2H-061",
                                  start_date,
                                  end_date,
                                  box){
  
  # TODO check format of dates and box
  
  matches <-
    stac("https://planetarycomputer.microsoft.com/api/stac/v1") |>
    stac_search(collections = "modis-15A2H-061",
                datetime = "2018-01-01/2023-07-01",
                bbox = c(box)) |>
    get_request() |>
    items_fetch() |>
    items_sign(sign_fn = sign_planetary_computer())
  
}