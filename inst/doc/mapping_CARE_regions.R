## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)

## ----message = FALSE-----------------------------------------------------
library(CARE)

## ----CARE_region_geodata, echo = TRUE, message = FALSE-------------------
show(CARE_region_geodata) # full menu = `data(package = "CARE")`

## ----mapview-CARE_region_geodata-----------------------------------------
mapview(CARE_region_geodata, zcol = "CARE_designation")

## ----impact_regions------------------------------------------------------
impact_regions <- filter(CARE_region_geodata, CARE_designation == "impact")
mapview(impact_regions, zcol = "CARE_name")

## ----exceedance_regions, echo = TRUE-------------------------------------
exceedance_regions <- filter(CARE_region_geodata, CARE_designation == "exceedance")
mapview(exceedance_regions, zcol = "CARE_name")

## ----CARE_Pbg_regions----------------------------------------------------
Pbg_area_names <- c("Pittsburg", "Bethel Island")
CARE_Pbg_regions <- filter(CARE_region_geodata, CARE_name %in% Pbg_area_names)
mapview(CARE_Pbg_regions, zcol = "CARE_name")

## ----Pbg_boundary--------------------------------------------------------
Pbg_boundary <- st_union(CARE_Pbg_regions)
mapview(Pbg_boundary)

