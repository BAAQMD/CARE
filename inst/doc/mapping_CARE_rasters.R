## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)

## ----message = FALSE-----------------------------------------------------
library(CARE)

## ----clip_and_trim-------------------------------------------------------
# Helper function for the chunk below
clip_and_trim <- function (rst, lower = .Machine$double.eps, upper = Inf) {
  clamped <- raster::clamp(rst, -Inf, upper, useValues = TRUE)
  clipped <- raster::clamp(clamped, lower, Inf, useValues = FALSE)
  raster::trim(clipped)
}

## ----raster_obj----------------------------------------------------------
# Let's only look at cells where the "risk" is between 100 and 500
# Otherwise, we'll have a kludgy map (try it!)
raster_obj <-
  CARE_1km_cancer_risk %>%
  clip_and_trim(lower = 100, upper = 500)

## ----ll_basemap----------------------------------------------------------
# A "basemap" that just shows the (whole) Bay Area, 
# with a nice neutral background (Stamen's "Toner" tileset)
ll_basemap <- 
  leaflet() %>% 
  addProviderTiles("Stamen.TonerLite") %>% 
  setViewBayArea(zoom = 9)

## ----final_map-----------------------------------------------------------
# Finally, add the raster as a layer on top of the basemap.
# Give it a nice perceptually uniform colormap (viridis::plasma)
# Make it mostly translucent with `opcaity = 0.2`
ll_basemap %>% 
  addRasterImage(raster_obj, 
                 colors = viridis::plasma(10), opacity = 0.2)

