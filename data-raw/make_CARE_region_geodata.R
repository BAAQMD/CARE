make_CARE_region_geodata <- function (CARE_impact_spdf, CARE_exceedance_spdf) {

  impact_geodata <-
    st_as_sf(CARE_impact_spdf) %>%
    mutate(CARE_designation = "impact")

  exceedance_geodata <-
    st_as_sf(CARE_exceedance_spdf) %>%
    mutate(CARE_designation = "exceedance")

  st_transform(
    rbind(impact_geodata, exceedance_geodata),
    NAD83_UTM10)

}

make_CARE_impact_spdf <- function (kmz_file) {

  kmz_spobj <-
    read_kmz(kmz_file)

  str_sanitize <- function (x) {
    str_trim(str_replace_all(x, "\\s+", " "))
  }

  CARE_impact_data <-
    kmz_spobj@data %>%
    transmute(CARE_name = str_sanitize(Name),
              CARE_designation = "impact")

  CARE_impact_spdf <-
    SpatialPolygonsDataFrame(
      geometry(kmz_spobj),
      CARE_impact_data,
      match.ID = FALSE)

  # mapview::mapview(CARE_impact_spdf, zcol = "CARE_name")

  return(CARE_impact_spdf)

}

make_CARE_exceedance_spdf <- function (kmz_file, CARE_impact_regions) {

  require(purrr)
  require(geotools)

  packed_geoms <-
    read_kmz(kmz_file) %>%
    polygons()

  kmz_proj4 <-
    proj4string(packed_geoms)

  geom_list <-
    packed_geoms %>%
    .@polygons %>%
    first() %>%
    .@Polygons

  geom_ids <-
    1:length(geom_list)

  unpacked_geoms <-
    geom_list %>%
    set_names(geom_ids) %>%
    map2(geom_ids, ~ Polygons(list(.x), ID = .y)) %>%
    SpatialPolygons(proj4string = CRS(kmz_proj4))

  inferred_data <-
    unpacked_geoms %>%
    over(CARE_impact_regions)

  # FIXME: HACK: HARDCODED
  inferred_data[2, "CARE_name"] <- "Tri-Valley"
  inferred_data[7, "CARE_name"] <- "San Rafael"
  inferred_data[9, "CARE_name"] <- "Bethel Island"

  inferred_data[, "CARE_designation"] <- "exceedance"

  CARE_exceedance_spdf <-
    SpatialPolygonsDataFrame(
      unpacked_geoms,
      inferred_data)

  return(CARE_exceedance_spdf)

}

