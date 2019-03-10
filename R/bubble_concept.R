# Bubble chart scratch

library(feather)
library(magrittr)
library(tidyverse)

dat <- read_feather("data/name_instrument.feather")%>%
  count(inst, sort = T) %>% 
  filter(n > 2)

library(packcircles)

packing <- circleProgressiveLayout(dat$n, sizetype = "area")

dat %<>% bind_cols(packing)

layout <- circleLayoutVertices(packing, npoints = 50)

p <- ggplot(dat, aes(x, y)) +
  geom_polygon(data = layout, aes(fill = as.factor(id))) +
  geom_text(data = dat, aes(size = n, label = inst)) +
  scale_size_continuous(range = c(3,5)) +
  theme_void() +
  theme(legend.position = 'none') +
  coord_equal() +
  labs(title = "Instrument")

p

library(plotly)

ggplotly(p, 
         tooltip = c("label", "size"))
