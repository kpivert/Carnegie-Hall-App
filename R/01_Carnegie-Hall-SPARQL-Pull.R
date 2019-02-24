#' ---
#' title: Useful SPARQL queries
#' description: Each top-level section builds a new table. Data will likely need to be pulled for specific Qs
#' author: nathancday@@gimal.com

library(tidyverse)

# Map ----------------------------------------------------------

# * SPARQL --------------------------------------------------------------

# query is most frequent with birth details

PREFIX dbp: <http://dbpedia.org/ontology/>
PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX mo: <http://purl.org/ontology/mo/>
PREFIX schema: <http://schema.org/>
# 
# SELECT DISTINCT ?performer ?name ?birthDate ?birthPlace
# WHERE {
#     ?performer foaf:name ?name ;
#                schema:birthDate ?birthDate ;
#                dbp:birthPlace ?birthPlace .
#     ?workPerf event:product ?work ;
#               mo:performer ?performer .
# }

dat <- RCurl::getURL("http://data.carnegiehall.org/sparql/select?query=PREFIX%20dbp%3A%20%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0APREFIX%20event%3A%20%3Chttp%3A%2F%2Fpurl.org%2FNET%2Fc4dm%2Fevent.owl%23%3E%0APREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20mo%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fontology%2Fmo%2F%3E%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%0ASELECT%20DISTINCT%20%3Fperformer%20%3Fname%20%3FbirthDate%20%3FbirthPlace%0AWHERE%20%7B%0A%20%20%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20schema%3AbirthDate%20%3FbirthDate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dbp%3AbirthPlace%20%3FbirthPlace%20.%0A%20%20%20%20%3FworkPerf%20event%3Aproduct%20%3Fwork%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20mo%3Aperformer%20%3Fperformer%20.%0A%7D&out=json&key=") %>% 
  jsonlite::fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value")) %>%
  rename_all(~ gsub("\\..*", "", .))

# * GeoNames ---------------------------------------------------------------

# Join in GeoNames data (webscraping didn't work)

# Found a file dump with city codes
# Picked the file with the bigest number
# http://download.geonames.org/export/dump/

geonames <- read.csv("data/cities15000.csv", header = F) %>%
  select(birthPlace = V1, city = V2, lat = V5, lon = V6)

dat <- dat %>% 
  mutate(birthPlace = gsub(".*org/(\\d+)/", "\\1", birthPlace) %>%
           as.numeric()) %>%
  inner_join(geonames) 

dat %>%
  count(city, sort = T)

# * Export ----------------------------------------------------------------

# RDS for taday, maybe feather later
saveRDS(dat, "data/birth_locations.RDS")

# Sankey ------------------------------------------------------------------

# Count events by year
# PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX dcterms: <http://purl.org/dc/terms/>
#   SELECT ?year (COUNT (?event) AS ?numEvents) WHERE {
#     ?event a event:Event ;
#     rdfs:label ?label ;
#     dcterms:date ?date
#     BIND (str(YEAR(?date)) AS ?year)
# 
#   }
# GROUP BY ?year
# ORDER BY ?year

# Count intruments by performer birth year
# PREFIX chinstruments: <http://data.carnegiehall.org/instruments/>
#   PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
#   PREFIX foaf: <http://xmlns.com/foaf/0.1/>
#   PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX schema: <http://schema.org/>
#   
#   select ?birthYear ?label (COUNT(?label) AS ?instCount) where {
#     ?performer foaf:name ?name ;
#     dbpedia-owl:birthPlace ?birthPlace ;
#     schema:birthDate ?birthDate ;
#     gndo:playedInstrument ?instrument ;
#     BIND (str(YEAR(?birthDate)) AS ?birthYear) .
#     ?instrument rdfs:label ?label .
#   }
# GROUP BY ?birthYear ?label
# ORDER BY DESC(?instCount)

url <- "http://data.carnegiehall.org/sparql/select?query=PREFIX%20chinstruments%3A%20%3Chttp%3A%2F%2Fdata.carnegiehall.org%2Finstruments%2F%3E%0A%20PREFIX%20dbpedia-owl%3A%20%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0A%20PREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0A%20PREFIX%20gndo%3A%20%3Chttp%3A%2F%2Fd-nb.info%2Fstandards%2Felementset%2Fgnd%23%3E%0A%20PREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%20PREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%20%0A%20select%20%3FbirthYear%20%3Flabel%20(COUNT(%3Flabel)%20AS%20%3FinstCount)%20where%20%7B%0A%20%20%20%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dbpedia-owl%3AbirthPlace%20%3FbirthPlace%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20schema%3AbirthDate%20%3FbirthDate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20gndo%3AplayedInstrument%20%3Finstrument%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20BIND%20(str(YEAR(%3FbirthDate))%20AS%20%3FbirthYear)%20.%0A%20%20%20%20%20%3Finstrument%20rdfs%3Alabel%20%3Flabel%20.%0A%20%7D%0AGROUP%20BY%20%3FbirthYear%20%3Flabel%0AORDER%20BY%20DESC(%3FinstCount)&out=json&key="

dat <- RCurl::getURL(url) %>%
  jsonlite::fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value")) %>%
  rename_all(~ gsub("\\..*", "", .))

dat <- dat %>%
  mutate_at(vars(birthYear, instCount), as.numeric) %>%
  filter(!is.na(birthYear))


# * Export ----------------------------------------------------------------

saveRDS(dat, "data/instrument_years.RDS")
