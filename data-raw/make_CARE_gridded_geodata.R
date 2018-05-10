as_gridded <- function (x, layer, ...) {
  spobj <- as_spatial(x, ...)
  gridded(spobj) <- TRUE
  return(spobj)
}

as_raster <- function (x, layer, ...) {
  grd <- as_gridded(x, ...)
  raster::raster(grd, layer = layer)
}

pmean <- function (x, y) (x + y) / 2

make_CARE_1km_cancer_risk <- function (xlsx_file) {

  # Read in the "raw" coords from an Excel file
  # Average `XMIN` and `XMAX` (and same for Y) to get cell centers
  cancer_1x1_data <-
    here::here(xlsx_file) %>%
    read_excel() %>%
    mutate(cell_UTM_E = pmean(XMIN, XMAX)) %>%
    mutate(cell_UTM_N = pmean(YMIN, YMAX)) %>%
    select(-XMIN, -XMAX, -YMIN, -YMAX)

  # define Lambert Comformal Conic(LCC) coorinate system according to CMAQ modeling domain BAAQMD_1km_PM
  proj4string <- "+proj=lcc +a=6370000.0 +b=6370000.0 +lat_1=30 +lat_2=60 +lat_0=37 +lon_0=-120.5 +units=m"
  lcccrs <- CRS(proj4string)

  # See `as_raster()`, defined above
  cancer_raster <-
    cancer_1x1_data %>%
    as_raster(layer = "CANCER_RIS",
              coord_vars = c("cell_UTM_E", "cell_UTM_N"),
              crs = lcccrs)

  return(cancer_raster)

}
