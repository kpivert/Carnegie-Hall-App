
# Build map by continent --------------------------------------------
library(cleangeo)
library(sf)
library(lwgeom)
library(dplyr)
library(ggplot2)

m <- rworldmap::getMap()
m <- cleangeo::clgeo_Clean(m)

m <- st_as_sf(m) %>%
  st_make_valid() %>%
  rename_all(tolower) %>%
  select(region, name, iso_country = iso_a2)


m_cont <- filter(m, !is.na(region)) %>% 
  group_by(region) %>%
  summarise(geometry = st_union(geometry)) %>%
  filter(region != "Antarctica")

saveRDS(m_cont, "data/continent_sf.RDS")

ggplot(m_cont, aes(fill = region)) +
  geom_sf() +
  scale_fill_brewer(palette = "Dark2") +
  coord_sf(datum = NULL) +
  theme_void()

# Interactive ----------------------------------------------------------


pal <- colorFactor("Dark2", m_cont$region)

leaflet(m_cont,
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
  
