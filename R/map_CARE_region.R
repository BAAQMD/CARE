map_CARE_region <- function (x = NULL, verbose = TRUE) {

  msg <- function (...) if (isTRUE(verbose)) message("[map_CARE_region] ", ...)

  if (is.null(x)) {
    verbose <- TRUE
    CARE_names <- CARE_impact_regions[["CARE_name"]]
    x <- sample(CARE_names, 1)
  }

  msg("mapping ", x)

  region_geodata <-
    CARE_impact_regions %>%
    filter(CARE_name == x)

  tract_geodata <-
    tracts_for_region(region_geodata) %>%
    with_tract_populations()

  map_DB_county_codes <-
    tract_geodata %>%
    pull_fips() %>% .[, "county"] %>% unique() %>%
    decode(SFBA_COUNTY_FIPS_CODES, warn = FALSE) %>%
    encode(DST_COUNTY_NAMES) %>%
    decode(DST_COUNTY_CODES)

  facility_geodata <- local({

    msg("pulling RY2015 facilities")
    DB_facility_emission_data <-
      RY(2014:2016) %>%
      point_source_PONSCO_emissions() %>%
      filter(cnty_abbr %in% map_DB_county_codes) %>%
      filter(pol_abbr == "PM") %>%
      speciate_PM(into = c("PM2.5")) %>%
      tabulate_emissions_by(pol_abbr, fac_id, year, signif = 3)

    closed_facilities <-
      DB_facility_emission_data %>%
      select_distinct(fac_id) %>%
      with_facility_status() %>%
      filter(fac_closed %>% is.finite())

    pmedian <- function (..., na.rm = TRUE) {
      apply(cbind(...), MARGIN = 1, median, na.rm = na.rm)
    }

    msg("matching with coordinates")
    facility_geodata <-
      DB_facility_emission_data %>%
      anti_join(closed_facilities, by = "fac_id") %>%
      with_facility_coordinates() %>%
      as_spatial(coord_vars = c("fac_lng", "fac_lat"), crs = WGS84, na.rm = TRUE) %>%
      filter_spatial(region_geodata, FUN = gContains) %>%
      mutate(PM2.5 = pmedian(RY2014, RY2015, RY2016))

  })

  addCensusTractLayer <- function (map, tract_geodata, ...) {
    addFeatures(map, data = tract_geodata,
                fill = TRUE, fillColor = "gray",
                weight = 1, color = "white", opacity = 1, ...)
  }

  addFacilityLayer <- function (map, facility_geodata, ...) {

    facility_popups <-
      facility_geodata@data %>%
      with_facility_name() %>%
      with_facility_address(type = "location") %>%
      mutate(addr_state = "CA") %>%
      unite("fac_addr", addr_street, addr_city, addr_state, addr_zip, sep = " ") %>%
      with_IRIS_site() %>%
      popupTable(zcol = c("fac_name", "fac_addr", "IRIS_site", "pol_abbr", "ems_unit", "RY2014", "RY2015", "RY2016"))

    addCircleMarkers(map, data = facility_geodata,
               radius = ~ 5 * (0.01 + sqrt(PM2.5)),
               color = "brown", weight = 1,
               popup = facility_popups)
  }

  mapview(region_geodata, layer.name = x, fill = FALSE, stroke = TRUE, color = "black") %>%
    addCensusTractLayer(tract_geodata) %>%
    addFacilityLayer(facility_geodata) %>%
    addMouseCoordinates()

}
