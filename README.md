# CARE

This package (`CARE`) wraps up some datasets specific to the [BAAQMD CARE program](http://www.baaqmd.gov/plans-and-climate/community-air-risk-evaluation-care-program).

For example, if you wanted to get the polygons that correspond to CARE "impact" or "exceedance" regions, there is an `sf` (geodata) object called `CARE_region_geodata` in this package. (See `vignette("mapping_CARE_regions", package = "CARE")`.)

This is mostly a data-only package. The plan is to import more datasets, such as ZIP code data that were used to create the CARE regions, and possibly raster datasets as well.
