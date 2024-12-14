#' Create a regression table as an image
#' 
#' `ggregtab()` uses `{ggplot2}` under the hood to create a 
#' regression table for one or more models as an image.
#' 
#' @param coef_tbl A coefficient test tibble produced with `tidy_coeftest()` or by some other means. To work, the tibble must contain the following columns: `term`, `estimate`, `std.error`, `statistic`, `p.value`, `conf.low`, `conf.high`, `model`, and `N`.
#' @param show Can be one of `"se"` (default), `"stat"`, or `"ci"`. This controls whether coefficient standard errors, test statistics, or confidence intervals are shown.
#' @param single Logical. If `TRUE`, then the coefficient with its standard error, statistic, or confidence intervals are shown in a single line. If `FALSE` (default), then the relevant statistic is shown below the coefficent.
#' @param digits An integer indicating the number of significant digits to show. Set to `3` by default.
#' @param ratio Controls the height to width ratio of the table. Set to `1/5` by default.
#' @param base_family Controls the font family of the plot. Set to `"sans"` by default.
#' @returns A `{ggplot2}` object.
#' @examples 
#' # Fit some regression models
#' fit1 <- lm(mpg ~ hp + wt, mtcars)
#' fit2 <- lm(mpg ~ hp + wt + cyl, mtcars)
#' 
#' # Prep for visualization
#' tidy_fit1 <- tidy_coeftest(fit1, model = "Model 1")
#' tidy_fit2 <- tidy_coeftest(fit2, model = "Model 2")
#' tidy_fits <- dplyr::bind_rows(tidy_fit1, tidy_fit2)
#' 
#' # Plot the regression table
#' ggregtab(tidy_fits) +
#'   labs(
#'     title = "A Regression Table",
#'     subtitle = "It shows OLS estimates" 
#'   )
ggregtab <- function(coef_tbl, 
                     show = "se",
                     single = F,
                     digits = 3, 
                     ratio = 1/5,
                     base_family = "sans") {
  coef_tbl |>
    dplyr::mutate(
      label = dplyr::case_when(
        show == "se" ~ paste0(
          round(estimate, digits),
          gtools::stars.pval(p.value),
          "\n(", round(std.error, digits), ")"
        ),
        show == "stat" ~ paste0(
          round(estimate, digits),
          gtools::stars.pval(p.value),
          "\n(", round(statistic, digits), ")"
        ),
        show == "ci" ~ paste0(
          round(estimate, digits),
          gtools::stars.pval(p.value),
          "\n(", round(conf.low, digits), ", ",
          round(conf.high, digits), ")"
        )
      )
    ) -> coef_tbl
  if(single) {
    coef_tbl |>
      dplyr::mutate(
        label = str_replace_all(label, "\n", " ")
      ) -> coef_tbl
  }
  ggplot(coef_tbl) +
    aes(
      x = as.numeric(as.factor(model)),
      y = reorder(term, length(term):1),
      label = label
    ) +
    geom_tile(
      alpha = 0
    ) +
    geom_text(
      family = base_family
    ) +
    scale_x_continuous(
      position = "top",
      breaks = 1:length(unique(coef_tbl$model)),
      labels = unique(coef_tbl$model),
      sec.axis = sec_axis(
        transform = ~.,
        breaks = 1:length(unique(coef_tbl$model)),
        labels = coef_tbl |>
          dplyr::select(model, N) |>
          dplyr::distinct() |>
          dplyr::pull(N) |>
          scales::comma() %>%
          paste0("N = ", .)
      )
    ) +
    labs(
      x = NULL,
      y = NULL,
      caption = "Note: .p < 0.1; *p < 0.05; **p < 0.01; ***p < 0.001"
    ) +
    theme_minimal(
      base_family = base_family
    ) +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(hjust = 0),
      plot.caption.position = "plot",
      plot.title.position = "plot",
      axis.text = element_text(color = "black")
    ) +
    annotate(
      geom = "segment",
      y = -Inf,
      yend = -Inf,
      x = -Inf,
      xend = Inf,
      size = 1,
      color = "black"
    ) +
    annotate(
      geom = "segment",
      y = Inf,
      yend = Inf,
      x = -Inf,
      xend = Inf,
      size = 1,
      color = "black"
    ) +
    coord_fixed(
      ratio = ratio
    )
}