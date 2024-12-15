# Make coolorrr package logo

library(hexSticker)
library(UCSCXenaTools)
library(tidyverse)
library(coolorrr)
library(here)
library(ggimage)

p <-
  lm(mpg ~ hp + wt + cyl, mtcars) |>
  broom::tidy() |>
  mutate(
    lo = estimate - 10 * std.error,
    hi = estimate + 10 * std.error
  ) |>
  ggplot() +
  aes(estimate, term) +
  geom_pointrange(
    aes(xmin = lo, xmax = hi),
    color = "steelblue",
    alpha = .7
  ) +
  geom_image(
    data = . %>%
    summarize(
      estimate = mean(c(max(hi), min(lo))),
      term = 3
    ),
    aes(image = "inst/groucho.png"),
    size = .75
  ) +
  labs(
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    legend.position = "none"
  )

sticker(
  p,
  package = "ggregtab",
  p_size = 30,
  s_x = 1,
  s_y=1,
  s_width=1.5,
  s_height = 1.45,
  p_x = 1,
  p_y = 1,
  p_color = "steelblue",
  h_fill = "white",
  h_color = "steelblue",
  url = "https://github.com/milesdwilliams15/regtab",
  filename = here("inst", "logo.png")
)
