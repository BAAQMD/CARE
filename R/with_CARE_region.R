#' with_CARE_region
#'
#' @param input_data data frame or tibble with column \code{fac_id}
#'
#' @export
with_CARE_region <- function (
  input_data,
  by = "fac_id",
  using = filter(CARE_region_geodata, CARE_designation == "impact")
) {

  .Defunct("Try performing a spatial join with `CARE_region_geodata`, which is now an sf object.")

  stopifnot(by %in% names(input_data))

  facility_coordinates <-
    distinct(select_(input_data, by)) %>%
    with_facility_coordinates(by = by)

  datum <- EPSG_4326

  geolocated_facilities <-
    facility_coordinates %>%
    filter(is.finite(fac_lng), is.finite(fac_lat)) %>%
    as_spatial(coord_vars = c("fac_lng", "fac_lat"), crs = datum)

  CARE_regions <-
    reproject(using, datum)

  CARE_overlay <-
    geolocated_facilities %>%
    sp::over(CARE_regions)

  CARE_lookup <- data_frame(
    fac_id = geolocated_facilities[[by]],
    CARE_region = as.character(CARE_overlay[["CARE_name"]]))

  CARE_lookup %>%
    rename_(.dots = set_names("fac_id", by)) %>%
    left_join(input_data, ., by = by)

}
