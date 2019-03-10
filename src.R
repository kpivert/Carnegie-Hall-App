# Shiny functions

gg_circlepack <- function(dat, label, title) {
  packing <- circleProgressiveLayout(dat$n, sizetype = "area")
  dat %<>% bind_cols(packing)
  layout <- circleLayoutVertices(packing, npoints = 50)
  
  ggplot(dat, aes(x, y)) +
    geom_polygon(data = layout, aes(fill = as.factor(id))) +
    geom_text(data = dat, aes_(size = ~n, label = as.name(label))) +
    scale_size_continuous(range = c(3,5)) +
    theme_void() +
    theme(legend.position = 'none') +
    coord_equal() +
    labs(title = title)
}
