
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


m_country <- filter(m, !is.na(region)) %>% 
  filter(region != "Antarctica") %>% 
  group_by_at(vars(region:iso_country)) %>% 
  summarise(geometry = st_union(geometry))

saveRDS(m_country, "data/country_sf.RDS")

ggplot(m_country, aes(fill = region)) +
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
  
