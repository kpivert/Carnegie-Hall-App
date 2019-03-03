
# Build map by continent --------------------------------------------

library(sf)
library(lwgeom)
library(dplyr)
library(ggplot2)

m <- rworldmap::getMap()
m <- cleangeo::clgeo_Clean(m)

m <- st_as_sf(m) %>% st_make_valid() %>% rename_all(tolower) %>% select(region)

m <- filter(m, !is.na(region)) %>% 
  group_by(region) %>%
  summarise(geometry = st_union(geometry)) %>%
  filter(region != "Antarctica")

saveRDS(m, "data/continent_sf.RDS")

ggplot(m, aes(fill = region)) +
  geom_sf() +
  scale_fill_brewer(palette = "Dark2") +
  coord_sf(datum = NULL) +
  theme_void()

# Interactive ----------------------------------------------------------

library(leaflet)

pal <- colorFactor("Dark2", m$region)

leaflet(m,
        options = leafletOptions(
          zoomControl = FALSE,
          dragging = FALSE,
          minZoom = 0,
          maxZoom = 0)
        )%>%
  addPolygons(layerId = ~region,
              fillColor = ~pal(region),
              fillOpacity = 1,
              color = "black",
              stroke = F,
              highlight = highlightOptions(
                fillOpacity = .5,
                bringToFront = TRUE))
  
