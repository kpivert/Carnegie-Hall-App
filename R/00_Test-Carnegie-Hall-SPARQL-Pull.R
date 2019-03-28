
# Proof of Concept SPARQL Data Pull ---------------------------------------


# 00 Load Packages --------------------------------------------------------

require(RCurl)
require(jsonlite)
require(feather)
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
PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <http://schema.org/>

  select ?name ?birthPlace ?birthDate ?label where {
    ?performer foaf:name ?name ;
    dbpedia-owl:birthPlace ?birthPlace ;
    schema:birthDate ?birthDate ;
    gndo:playedInstrument ?instrument .
    ?instrument rdfs:label ?label .
  }

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

# 03 Role-Performer Query ----------------------------------------------
PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <http://schema.org/>

  select ?name ?birthPlace ?birthDate ?label ?role where {
    ?performer foaf:name ?name ;
    dbpedia-owl:birthPlace ?birthPlace ;
    schema:birthDate ?birthDate ;
    gndo:professionOrOccupation ?prof ;
    gndo:playedInstrument ?instrument .
    ?instrument rdfs:label ?label .
    ?prof rdfs:label ?role
  }

roles <- 
  getURL("http://data.carnegiehall.org/sparql/select?query=PREFIX%20dbpedia-owl%3A%20%3Chttp%3A%2F%2Fdbpedia.org%2Fontology%2F%3E%0APREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20gndo%3A%20%3Chttp%3A%2F%2Fd-nb.info%2Fstandards%2Felementset%2Fgnd%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%0Aselect%20%3Fname%20%3FbirthPlace%20%3FbirthDate%20%3Flabel%20%3Frole%20where%20%7B%0A%20%20%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20dbpedia-owl%3AbirthPlace%20%3FbirthPlace%20%3B%0A%20%20%20%20%20%20schema%3AbirthDate%20%3FbirthDate%20%3B%0A%20%20%20%20%20%20gndo%3AprofessionOrOccupation%20%3Fprof%20%3B%0A%20%20%20%20%20%20gndo%3AplayedInstrument%20%3Finstrument%20.%0A%20%20%20%20%3Finstrument%20rdfs%3Alabel%20%3Flabel%20.%0A%20%20%20%20%3Fprof%20rdfs%3Alabel%20%3Frole%0A%20%20%7D&out=json&key=") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value"))

dim(roles)
head(roles)


# 04 Instruments grouped by name -----------------------------------------------

PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

select ?name (group_concat(?inst; separator="|") AS ?inst) where {
  ?performer foaf:name ?name ;
  gndo:playedInstrument ?instrument .
  ?instrument rdfs:label ?inst .
}
GROUP BY ?name

inst <-
  getURL("http://data.carnegiehall.org/sparql/select?query=PREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20gndo%3A%20%3Chttp%3A%2F%2Fd-nb.info%2Fstandards%2Felementset%2Fgnd%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%0Aselect%20%3Fname%20(group_concat(%3Finst%3B%20separator%3D%22%7C%22)%20AS%20%3Finst)%20where%20%7B%0A%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20gndo%3AplayedInstrument%20%3Finstrument%20.%0A%20%20%3Finstrument%20rdfs%3Alabel%20%3Finst%20.%0A%7D%0AGROUP%20BY%20%3Fname&out=json&key=") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value"))

inst %>% 
  rename_all(~ gsub("\\.value", "", .)) %>%
  separate_rows(inst, sep = "\\|") %>%
  write_feather("data/name_instrument.feather")

## 2019-03-27 Carnegie Hall Data Pull: Convert CSV to Feather

inst <- read_csv(
  here::here("data", "name_instrument_ch.csv")
)

write_feather(
  inst,
  here::here("data", "name_instrument.feather")
)

# 05 Roles grouped by name -----------------------------------------------

PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX gndo: <http://d-nb.info/standards/elementset/gnd#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

select ?name (group_concat(?role; separator="|") AS ?role) where {
  ?performer foaf:name ?name ;
    gndo:professionOrOccupation ?prof .
  ?prof rdfs:label ?role .
}
GROUP BY ?name

role <- 
  getURL("http://data.carnegiehall.org/sparql/select?query=PREFIX%20foaf%3A%20%3Chttp%3A%2F%2Fxmlns.com%2Ffoaf%2F0.1%2F%3E%0APREFIX%20gndo%3A%20%3Chttp%3A%2F%2Fd-nb.info%2Fstandards%2Felementset%2Fgnd%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0A%0Aselect%20%3Fname%20(group_concat(%3Frole%3B%20separator%3D%22%7C%22)%20AS%20%3Frole)%20where%20%7B%0A%20%20%3Fperformer%20foaf%3Aname%20%3Fname%20%3B%0A%20%20%20%20gndo%3AprofessionOrOccupation%20%3Fprof%20.%0A%20%20%3Fprof%20rdfs%3Alabel%20%3Frole%20.%0A%7D%0AGROUP%20BY%20%3Fname&out=json&key=") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble() %>% 
  select(results) %>% 
  unnest() %>%
  select(matches("value"))


role %>% 
  rename_all(~ gsub("\\.value", "", .)) %>%
  separate_rows(role, sep = "\\|") %>%
  write_feather("data/name_role.feather")


## 2019-03-27 Carnegie Hall Data Pull: Convert CSV to Feather

role <- read_csv(
  here::here("data", "name_role_ch.csv")
)

write_feather(
  role,
  here::here("data", "name_role.feather")
)
