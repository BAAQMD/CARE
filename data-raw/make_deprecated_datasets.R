make_CARE_impact_regions <- function (...) {

  err_msg <- "`CARE_impact_regions` is deprecated. Please use `CARE_region_geodata` instead."
  delayedAssign("CARE_impact_regions", warning(err_msg))
  outfile <- here::here("data", "CARE_impact_regions.rda")
  message("Saving promise to ", outfile)
  save(list = c("CARE_impact_regions"),
       eval.promises = FALSE,
       file = outfile)

}

make_CARE_exceedance_regions <- function (...) {

  err_msg <- "`CARE_exceedance_regions` is deprecated. Please use `CARE_region_geodata` instead."
  delayedAssign("CARE_exceedance_regions", warning(err_msg))
  outfile <- here::here("data", "CARE_exceedance_regions.rda")
  message("Saving promise to ", outfile)
  save(list = c("CARE_exceedance_regions"),
       eval.promises = FALSE,
       file = outfile)

}