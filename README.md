# modis-lai-forecast

This repo holds code for a spatially explicit forecasting challenge pipeline to benchmark spatial models using MODIS leaf index data. Code included in the repo will download MODIS data for polygon regions around 5 defined sites that have experienced some disturbance: 

- NEON sites
    - NEON GRSM: https://www.neonscience.org/
    - NEON SOAP: https://www.neonscience.org/field-sites/soap 
- Arizona rapid burn/recovery
- Eastern canada fires
- California fires

The data would be downloaded using ingest_planetary_data() function to grab data for the polygon of interest and defined data range. A climatology forecast method will be used to create as a benchmark model that will be evaluated against target MODIS data.

