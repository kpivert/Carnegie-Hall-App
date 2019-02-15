
# Proof of Concept SPARQL Data Pull ---------------------------------------


# 00 Load Packages --------------------------------------------------------

require(RCurl)
require(jsonlite)
require(tidyverse)


# 01 Use Sample Query HTML  -----------------------------------------------

# Sample from JSON-LD page from data.carnegiehall.org Query
# Will need to create a protocol to translate & 
# paste together queries into HTML string

q <- "http://data.carnegiehall.org/sparql/select?query=%23Find%20works%0APREFIX%20mo%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fontology%2Fmo%2F%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0Aselect%20%3Fwork%20%3Ftitle%20where%20%7B%0A%20%20%20%20%3Fwork%20a%20mo%3AMusicalWork%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20rdfs%3Alabel%20%3Ftitle%20.%0A%7D%0Alimit%2050&out=json&key="

ch_test <- RCurl::getURL(q)

ch_test_df <- ch_test %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest()

ch_test_df


# 02 Instrument-Performer Query ----------------------------------------------

# # Raw SPARQL
# PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
# PREFIX foaf: <http://xmlns.com/foaf/0.1/>
# PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX schema: <http://schema.org/>
#   
#   select ?name ?birthPlace ?birthDate ?label where {
#     ?performer foaf:name ?name ;
#     dbpedia-owl:birthPlace ?birthPlace ;
#     schema:birthDate ?birthDate ;
#     gndo:playedInstrument ?instrument .
#     ?instrument rdfs:label ?label .
#   }

instrument <- 
  getURL("http://data.carnegiehall.org/sparql/select?query=%23Find%20alto%20saxophonists%20born%20in%20November%0A%0A%23%20templated%20%5E%5E%5E%5E%0A%20PREFIX%20dbpedia-owl%3A%20%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0A%20PREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0A%20PREFIX%20gndo%3A%20%3Chttp%3A%2F%2Fd-nb.info%2Fstandards%2Felementset%2Fgnd%23%3E%0A%20PREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%20PREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%20%0A%20select%20%3Fname%20%3FbirthPlace%20%3FbirthDate%20%3Flabel%20where%20%7B%0A%20%20%20%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dbpedia-owl%3AbirthPlace%20%3FbirthPlace%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20schema%3AbirthDate%20%3FbirthDate%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20gndo%3AplayedInstrument%20%3Finstrument%20.%0A%20%20%20%20%20%3Finstrument%20rdfs%3Alabel%20%3Flabel%20.%0A%20%7D&out=json&key=") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value"))

dim(instrument)
head(instrument)

saveRDS(instrument, "data/intrument_performer.RDS")
