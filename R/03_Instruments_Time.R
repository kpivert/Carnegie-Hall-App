# Explore Instument data over time

library(tidyverse)

dat <- readRDS("data/instrument_years.RDS")

dat %>%
  group_by(label) %>%
  summarise(tot = sum(instCount)) %>%
  arrange(desc(tot)) %>%
  filter(tot > 100) %>%
  mutate(label = fct_inorder(label)) -> more_than100

dat %>%
  filter(label %in% more_than100$label) %>%
  mutate(label = factor(label, levels(more_than100$label))) %>% 
  ggplot(aes(birthYear, instCount, color = label)) +
  geom_line() +
  ggsci::scale_color_d3("category20")

range(dat$birthYear)
filter(dat, birthYear > 2010)

dat %>%
  filter(label %in% more_than100$label,
         between(birthYear, 1850, 2005)) %>%
  mutate(label = factor(label, levels(more_than100$label))) %>% 
  ggplot(aes(birthYear, instCount, color = label)) +
  geom_line() +
  ggsci::scale_color_d3("category20")

sankey_dat <- dat %>%
  filter(label %in% more_than100$label,
         between(birthYear, 1850, 1990))

sankey_dat$birthYear %>% hist()

sankey_dat %>% 
  count(label, wt = instCount) %>%
  ggplot(aes(label, n)) +
  geom_col()

library(bubbles)
library(ggsci)

inst_dat <- dat %>% 
  count(label, wt = instCount) %>%
  filter(n > 100)

bubbles(value = inst_dat$n, label = inst_dat$label,
          color = gsub("FF$", "", pal_d3("category20")(17)))

year_dat <- dat %>% 
  count(birthYear, wt = instCount) %>%
  arrange(desc(n)) %>%
  filter(n > 10)

library(viridis)


bubbles(value = year_dat$n, label = year_dat$birthYear)
