# modis-lai-forecast

This repo holds code for a spatially explicit forecasting challenge pipeline to benchmark spatial models using MODIS leaf index data. In this example we focus on locations of wildfire burns and recovery.

## Workflow overview
![efi-spatial (3)](https://github.com/eco4cast/modis-lai-forecast/assets/16726030/8e9b7eb5-62ca-4a7f-9df1-a5c09bd569b2)


## Site selection
- California August complex fire
- Colorodo East Troublesome

## Functions
- `fire_bbox()` reads in a fire boundary shapefile and determines a bounding box for grabbing MODIS data with a padding option. 
- `ingest_planetary_data()` downloads data from Microsoft planetary comuputer and returns a `gdalcube` data cube proxy object. 
- `create_target_file()` subsets the data cube and serializes target geotiff to disk.  
- `spat_climatology()` creates climatology predictions and serializes prediction geotiff to disk. 
- `scoring_spat_ensemble()` assigns crps and logs scores and serializes scored geotiff to disk.  

## Next steps
- Ingest additional fire sites. Potential locations
    - NEON GRSM: https://www.neonscience.org/
    - NEON SOAP: https://www.neonscience.org/field-sites/soap 
    - Arizona rapid burn/recovery
    - Eastern canada fires
- Automation logic
- 
