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


# Treemap -----------------------------------------------------------------

plotly()

dat %>%
  
  plot_ly(labels = ~inst, values = ~n) %>%
  add_pie(hole = 0.6) %>%
  layout(title = "Donut charts using Plotly",  showlegend = F,
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

plot_ly(data = dat,
  type='treemap',
  labels= ~inst,
  parents="",
  values= ~n,
  color = ~n,
  colors = "Greens",
  textinfo="label") %>% 
  layout(uniformtext=list(minsize=16, mode='hide'))

df2 = read.csv('https://raw.githubusercontent.com/plotly/datasets/718417069ead87650b90472464c7565dc8c2cb1c/coffee-flavors.csv')
df = read.csv('https://raw.githubusercontent.com/plotly/datasets/718417069ead87650b90472464c7565dc8c2cb1c/sunburst-coffee-flavors-complete.csv')

fig <- plot_ly(
  type='treemap',
  ids=df$ids,
  labels=df$labels,
  parents=df$parents)
