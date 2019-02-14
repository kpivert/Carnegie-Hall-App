
# Proof of Concept SPARQL Data Pull ---------------------------------------


# 00 Load Packages --------------------------------------------------------

require(tidyverse)
require(jsonlite)
require(RCurl)

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

