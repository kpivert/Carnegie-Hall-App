
# * Add Transformations to Clean Datasets ---------------------------------

# * Load Packages ---------------------------------------------------------

library(feather)
library(rnaturalearth)
library(tidyverse)

# * Load Original Datasets ------------------------------------------------

dat <- read_feather(
  "data/geolocated_performers_dt.feather"
)

# Instrumental Performers Dataset
instruments <- read_feather("data/name_instrument.feather")

# Performer Roles Dataset
roles <- read_feather("data/name_role.feather")

# Country Simple Features
world <- ne_countries(scale = "medium", returnclass = "sf")

dat <- dat %>% 
  mutate(birth_year = as.numeric(gsub("-.*", "", birthDate))) %>% 
  mutate(
    `Online Resource` = case_when(
      str_detect(`Online Resource`, "\\'c\\(") == TRUE ~  
        str_c(
          "<a href = '",
          str_extract(
            `Online Resource`,
            "(?<=c\\()(.*?)(?=,)"
          ) %>% 
            str_sub(2, -2), 
          "' ",
          str_extract(
            `Online Resource`,
            "target.+"
          )
        ),
      str_detect(`Online Resource`, "^https://id.loc.gov") == TRUE ~ 
        str_c(
          "<a href ='",
          `Online Resource`,
          "' target='_blank'>Library of Congress</a>" 
        ),
      name == "Dave Samuels" ~ "http://dbpedia.org/resource/Dave_Samuels",
      name == "Shirley Verrett" ~ "http://dbpedia.org/resource/Shirley_Verrett",
      TRUE ~ `Online Resource`
    )
  ) %>% 
  mutate(
    `Online Resource` = case_when(
      str_detect(`Online Resource`, "dbpedia.org/") == TRUE ~
        str_c(
          "<a href ='",
          `Online Resource`,
          "' target='_blank'>DBPedia</a>" 
        ),
      TRUE ~ `Online Resource`
    )
  )

# Join Datasets for App Use
dat <- left_join(
  dat, 
  instruments
) %>% 
  mutate(
    inst = str_to_title(inst),
    role = str_to_title(role)
  )

# * Add Variables for DeckGL Vizes and Tooltip ----------------------------

# Edit Names
dat <- dat %>% 
  mutate(
    from_lon = lon,
    from_lat = lat, 
    from_name = birthPlaceName,
    to_lon = ch_lon,
    to_lat = ch_lat
  ) 

# Add Distances, Tooltip, and Continental Color Scheme  
dat <- dat %>%   
  mutate(
    distance_miles = geosphere::distGeo(
      dat %>% 
        select(starts_with("from_l")) %>% 
        as.matrix(),
      dat %>% 
        select(starts_with("to_l")) %>% 
        as.matrix()
    ) / 1609.344
  ) %>% 
  mutate(
    to_name = "Carnegie Hall",
    tooltip = str_c(
      name, 
      ": Born in ", 
      from_name,
      ", ",
      round(distance_miles),
      " miles from Carnegie Hall"
    ),
    ch_color = "#F7002B",
    from_color = case_when(
      `continent code` == "AF" ~ "#8F9DCB",
      `continent code` == "AS" ~ "#DBA8AF",
      `continent code` == "EU" ~ "#f9f6f7",
      `continent code` == "NA" ~ "#1DA3CA",
      `continent code` == "OC" ~ "#BF346B",
      `continent code` == "SA" ~ "#767969"
    ),
    cont_lon = case_when(
      `continent code` == "AF" ~ 18.77,
      `continent code` == "AS" ~ 100.16,
      `continent code` == "EU" ~ 11.61,
      `continent code` == "NA" ~ -101,
      `continent code` == "OC" ~ 133.7,
      `continent code` == "SA" ~ -59.4
    ),
    cont_lat = case_when(
      `continent code` == "AF" ~ 10.86,
      `continent code` == "AS" ~ 39.39,
      `continent code` == "EU" ~ 48.8,
      `continent code` == "NA" ~ 41.86,
      `continent code` == "OC" ~ -20.9,
      `continent code` == "SA" ~ -14
    )
  )

# Counts for Choropleth  
choro_dat <- dat %>% 
  count(ISO_Country) %>%
  mutate(n = n * 1000) %>% 
  right_join(world, ., by = c("iso_a2" = "ISO_Country")) %>% 
  mutate(
    tooltip = str_c(
      formal_en, 
      "\u2013",
      n / 1000,
      " Performers"
    )
  )  

# * Save Datasets ---------------------------------------------------------

write_rds(x = dat, path = "data/geolocated_performers.RDS")

write_rds(x = instruments, path = "data/name_instrument.RDS")

write_rds(x = roles, path = "data/name_role.RDS")

write_rds(x = world, path = "data/world_sf.RDS")

write_rds(x = choro_dat, path = "data/choro_dat.RDS")
