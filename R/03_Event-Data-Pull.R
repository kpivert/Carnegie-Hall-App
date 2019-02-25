
# Performer Event Data Pull Attempt ---------------------------------------


# 00 Load Packages --------------------------------------------------------


library(tidyverse)
require(here)
require(RCurl)




# 01 Sample SPARQL Query --------------------------------------------------


# PREFIX chnames: <http://data.carnegiehall.org/names/>
#   PREFIX dcterms: <http://purl.org/dc/terms/>
#   PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
# PREFIX foaf: <http://xmlns.com/foaf/0.1/>
#   PREFIX mo: <http://purl.org/ontology/mo/>
#   PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# SELECT ?event ?eventTitle ?performerName 
# WHERE {
#   {
#     ?event mo:conductor ?performerID ;
#     dcterms:date ?date ;
#     rdfs:label ?eventTitle .
#     ?performerID foaf:name ?performerName .
#   }
#   UNION
#   {
#     ?event event:product ?workPerformance ;
#     dcterms:date ?date ;
#     rdfs:label ?eventTitle .
#     ?workPerformance mo:performer ?performerID .
#     ?performerID foaf:name ?performerName .
#   }
#   filter(year(?date) = 1960)
# }

url <- "http://data.carnegiehall.org/sparql/select?query=PREFIX%20chnames%3A%20%3Chttp%3A%2F%2Fdata.carnegiehall.org%2Fnames%2F%3E%0APREFIX%20dcterms%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2F%3E%0APREFIX%20event%3A%20%3Chttp%3A%2F%2Fpurl.org%2FNET%2Fc4dm%2Fevent.owl%23%3E%0APREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20mo%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fontology%2Fmo%2F%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0ASELECT%20%3Fevent%20%3FeventTitle%20%3FperformerName%20%0AWHERE%20%7B%0A%7B%0A%20%20%20%20%20%20%20%20%3Fevent%20mo%3Aconductor%20%3FperformerID%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dcterms%3Adate%20%3Fdate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20rdfs%3Alabel%20%3FeventTitle%20.%0A%20%20%20%20%20%20%20%20%3FperformerID%20foaf%3Aname%20%3FperformerName%20.%0A%20%20%20%20%7D%0AUNION%0A%7B%0A%20%20%20%20%20%20%20%20%3Fevent%20event%3Aproduct%20%3FworkPerformance%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dcterms%3Adate%20%3Fdate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20rdfs%3Alabel%20%3FeventTitle%20.%0A%20%20%20%20%20%20%20%20%3FworkPerformance%20mo%3Aperformer%20%3FperformerID%20.%0A%20%20%20%20%20%20%20%20%3FperformerID%20foaf%3Aname%20%3FperformerName%20.%0A%20%20%20%20%7D%0A%20%20%20%20filter(year(%3Fdate)%20%3D%201960)%0A%7D&out=json&key="
   
df <- getURL(url = url) %>% 
  jsonlite::fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest()

df



#' ---
#' title: Useful SPARQL queries
#' description: Each top-level section builds a new table. Data will likely need to be pulled for specific Qs
#' author: nathancday@@gimal.com


# Map ----------------------------------------------------------

# * SPARQL --------------------------------------------------------------

# query is most frequent with birth details

# PREFIX dbp: <http://dbpedia.org/ontology/>
# PREFIX event: <http://purl.org/NET/c4dm/event.owl#>
# PREFIX foaf: <http://xmlns.com/foaf/0.1/>
# PREFIX mo: <http://purl.org/ontology/mo/>
# PREFIX schema: <http://schema.org/>
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
  select(birthPlace = V1, city = V2, lat = V5, lon = V5)

dat %<>%
  mutate(birthPlace = gsub(".*org/(\\d+)/", "\\1", birthPlace) %>%
           as.numeric()) %>%
  inner_join(geonames) 

dat %>%
  count(city, sort = T)

# * Export ----------------------------------------------------------------

# RDS for taday, maybe feather later
saveRDS(dat, "data/birth_locations.RDS")
