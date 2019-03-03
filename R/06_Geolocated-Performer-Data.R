
# Script to Geolocate Birthplaces for Performers --------------------------


# * Load Packages  --------------------------------------------------------

require(feather)
require(RCurl)
require(tidyverse)


# * Pull Performer Data from SPARQL ---------------------------------------

## SPARQL Query

# PREFIX dbp: <http://dbpedia.org/ontology/>
#   PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
# PREFIX foaf: <http://xmlns.com/foaf/0.1/>
#   PREFIX mo: <http://purl.org/ontology/mo/>
#   PREFIX schema: <http://schema.org/>
#   
#   SELECT DISTINCT ?performer ?name ?birthDate ?birthPlace
# WHERE {
#   ?performer foaf:name ?name ;
#   schema:birthDate ?birthDate ;
#   dbp:birthPlace ?birthPlace .
#   ?workPerf event:product ?work ;
#   mo:performer ?performer .
# }

sparql_url <- "http://data.carnegiehall.org/sparql/select?query=PREFIX%20dbp%3A%20%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0APREFIX%20event%3A%20%3Chttp%3A%2F%2Fpurl.org%2FNET%2Fc4dm%2Fevent.owl%23%3E%0APREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20mo%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fontology%2Fmo%2F%3E%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%0ASELECT%20DISTINCT%20%3Fperformer%20%3Fname%20%3FbirthDate%20%3FbirthPlace%0AWHERE%20%7B%0A%20%20%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20schema%3AbirthDate%20%3FbirthDate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dbp%3AbirthPlace%20%3FbirthPlace%20.%0A%20%20%20%20%3FworkPerf%20event%3Aproduct%20%3Fwork%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20mo%3Aperformer%20%3Fperformer%20.%0A%7D&out=json&key="

ch_dat <- RCurl::getURL(sparql_url) %>% 
  jsonlite::fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value")) %>%
  rename_all(~ gsub("\\..*", "", .))


# * Pull GEO Data from Geonames -------------------------------------------

## See http://download.geonames.org/export/dump/

## Cities with >=500 Population

geonames <- read_delim(
  here::here("data", "cities500.txt"),
  delim = "\t",
  col_names = FALSE) %>% 
  mutate(Continent = str_extract(X18, '^[^/]+')) %>% 
  select(
    birthPlace = X1, 
    birthPlaceName = X2, ## To account for birthplaces that are countries
    lat = X5, 
    lon = X6, 
    Continent, 
    ISO_Country = X9
    )

## Country Data for Performers with Country-only Birthplace

countries <- read_delim(
  here::here("data", "allCountries.txt"),
  delim = "\t",
  col_names = FALSE) %>% 
  mutate(Continent = str_extract(X18, '^[^/]+')) %>% 
  select(
    birthPlace = X1, 
    birthPlaceName = X2, ## To account for birthplaces that are countries
    lat = X5, 
    lon = X6, 
    Continent, 
    ISO_Country = X9
    )

# * Join Performer and GEO Data -------------------------------------------

## 4979 Records of 8026 Distinct Performers

ch_dat_by_city <- ch_dat  %>% 
  mutate(birthPlace = gsub(".*org/(\\d+)/", "\\1", birthPlace) %>%
           as.numeric()
         ) %>%
  inner_join(geonames) 

## 2775 Records of 8026 Distinct Performers

ch_dat_by_country <- ch_dat %>% 
  anti_join(., ch_dat_by_city, by = "performer") %>% 
  mutate(birthPlace = gsub(".*org/(\\d+)/", "\\1", birthPlace) %>%
           as.numeric()
         ) %>%
  inner_join(countries) 

## 7754 Geolocated Performers 

dat <- rbind(ch_dat_by_city, ch_dat_by_country)

## 267 Records of Edge Cases to Added Later 

oddballs <- anti_join(ch_dat, dat, by = "performer")  
anti_join(ch_dat, dat, by = "performer")  

## Note that dat + oddballs = 8021 (not 8026 of pulled dataset of performers)


# * Save Feather File of Geolocated Performers  ---------------------------

write_feather(dat, path = here::here("data", "geolocated_performers.feather"))
