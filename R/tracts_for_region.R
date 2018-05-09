#' @export
tracts_for_region <- function (region_geodata, data_vars = c("GEOID", "TRACTCE", "ALAND"), clip_coast = TRUE) {

  require(TIGER2015)

  region_geom <-
    gUnionCascaded(region_geodata)

  region_CRS <-
    CRS(proj4string(region_geodata))

  SFBA_tracts <-
    TIGER2015_SFBA_tracts %>%
    reproject(region_CRS) %>%
    .[, data_vars]

  filtered_tracts <-
    SFBA_tracts %>%
    filter_spatial(region_geom)

  filtered_tracts <-
    spChFIDs(filtered_tracts, filtered_tracts[["GEOID"]])

  if (isTRUE(clip_coast)) {

    tract_geodata <-
      filtered_tracts %>%
      gClip(SFBA_OSM_coast)

  } else {

    tract_geodata <-
      filtered_tracts

  }

  return(tract_geodata)

}

