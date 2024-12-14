#' Prep models for visualization
#' 
#' `tidy_coeftest()` takes a model object and converts 
#' it into a tidy table of coefficients and their associated
#' standard errors, test statistics, etc. in a format that is
#' acceptable for use with `ggregtab()`.
#' 
#' @param x A model object that is compatible with `lmtest::coeftest()`.
#' @param vcov. A variance-covariance matrix for coefficient standard errors. If `NULL` (default) classical standard errors are produced. Will accept any variance-covariance matrix produced by alternative methods, for example via functions from the `{sandwhich}` package for robust and clustered standard errors.
#' @param model An optional model label. Must be a character string. If `NULL` (default), the label `"Model 1"` is applied.
#' @returns A tidy coefficient test tibble with eight columns: `term`, `estimate`, `std.error`, `statistic`, `p.value`, `conf.low`, `conf.high`, `model`, and `N`.
#' @export
tidy_coeftest <- function(x, vcov. = NULL, model = NULL) {
  lmtest::coeftest(
    x,
    vcov. = vcov.
  ) |>
    broom::tidy() |>
    dplyr::mutate(
      conf.low = estimate - 1.96 * std.error,
      conf.high = estimate + 1.96 * std.error,
      model = ifelse(is.null(model), "Model 1", model),
      N = model.frame(x) |> nrow()
    )
}