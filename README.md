Introducing `{ggregtab}`
<img src='inst/logo.png' align='right' height='130' />
================

Yet another R package for making regression tables… Why?!

The `{ggregtab}` package is a hyper-specific solution to a
hyper-specific problem I have. As an academic researcher, I love the
look of the pdf manuscripts I can make using Quarto and RMarkdown.
Unfortunately, most of the journals that I submit my work to want Word
Documents. This wreaks havoc with regression tables. They’re never
formatted the way I like, and often I have to contend with tables being
split between two pages because of their placement in my Quarto or
RMarkdown file. This is a never ending source of frustration. To add
insult to injury, I couldn’t find a solution other than editing my .docx
files after the fact. That’s not ideal for replication.

I then had a realization. I don’t have this problem with the plots I
make for my manuscripts, and the reason is that they’re rendered as
images. No matter their placement in my Quarto or RMarkdown files, plots
are never split between pages. So what if I had a method for quickly
making a plot that just happens to look like a table?

Hence, I give you `{ggregtab}`. It produces plots that look like
regression tables. Specifically, it produces ggplots that look like
regression tables, making them both easy to produce and easy to
customize using the vast ecosystem of tools and packages centered around
`{ggplot2}`.

To install the package just write:

``` r
install.packages("devtools")
devtools::install_github("milesdwilliams15/ggregtab")
```

## Main Functions

The main functions in the package are:

- `ggregtab()`
- `tidy_coeftest()`

`ggregtab()` produces a ggplot that looks like a regression table once
given a tidy coefficient test object.

Importantly, this object must contain eight unique columns. In addition
to the usual that are produced for model objects using `broom::tidy()`,
other columns required are `conf.low`, `conf.high`, `model`, and `N`.
The first two are needed if you want to show confidence intervals
instead of standard errors in your tables. The latter are needed for
model labeling and for showing sample sizes.

`tidy_coeftest()` is a helper function that makes it easy to get your
model objects into the correct shape. You don’t have to use this
function, however, as long as the coefficient test object you give to
`ggregtab()` contains the required columns.

## An Example

Here’s some code that produces a regression table using data from the
`mtcars` dataset. If I didn’t know any better, I wouldn’t know that this
was a plot rather than a decently formatted regression table.

``` r
## open the package
library(ggregtab)

## fit a regression model
fit <- lm(mpg ~ hp + wt + cyl, mtcars)

## prep it for visualization
tidy_fit <- tidy_coeftest(fit)

## plot the regression table
ggregtab(tidy_fit)
```

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

For those curious few who care, here’s what the `tidy_fit` object looks
like that `ggregtab()` expects to see:

``` r
tidy_fit
```

    ## # A tibble: 4 × 9
    ##   term      estimate std.error statistic  p.value conf.low conf.high model     N
    ##   <chr>        <dbl>     <dbl>     <dbl>    <dbl>    <dbl>     <dbl> <chr> <int>
    ## 1 (Interce…  38.8       1.79       21.7  4.80e-19  35.2     42.3     Mode…    32
    ## 2 hp         -0.0180    0.0119     -1.52 1.40e- 1  -0.0413   0.00524 Mode…    32
    ## 3 wt         -3.17      0.741      -4.28 1.99e- 4  -4.62    -1.72    Mode…    32
    ## 4 cyl        -0.942     0.551      -1.71 9.85e- 2  -2.02     0.138   Mode…    32

## Advanced Options

There are many ways to customize your regression tables. I’ve included
some examples below.

### Updating Labels and Text

Since the output of `ggregtab()` is a `ggplot()` object, you can use all
the `{ggplot2}` extras you want to customize it. For example you can use
`+ labs()` to give your table a title and subtitle. You can also use
`scale_y_discrete()` to update the labels for the model terms.

``` r
ggregtab(tidy_fit) +
  labs(
    title = "A Regression Table",
    subtitle = "With OLS estimates"
  ) +
  scale_y_discrete(
    labels = c(
      "Cylinders",
      "Weight",
      "Horse Power",
      "(Intercept)"
    )
  )
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

You can also update the model summary stats shown below the coefficient
summaries. By default just the sample size is shown. I excluded other
summary stats like R-squared or negative log-likelihood because in most
cases I’m not concerned about these metrics of model performance
(R-squared is overrated anyway for drawing conclusions about model fit
within sample, and I find log-likelihood generally uninformative).

But you might feel otherwise. So here’s how you can update the model
summary stats to show whatever you want.

First, create a customized label by calculating the stats you care
about. Second, give this new label to `scale_x_continuous()`. Under the
hood a continuous x scale is used for any and all model IDs. This was a
round-about solution for making the plot show an upper and lower axis
label simultaneously—one for the model stats and the other for the model
caption.

``` r
## get adjusted r-squared and N
smry_fit <- summary(fit)
rsqrd <- smry_fit$adj.r.squared
nobs <- nrow(model.frame(fit))

## paste together as a new label for the bottom x-axis
smry_stats <- paste0(
  "N = ", nobs, "\n",
  "Adj. R2 = ", round(rsqrd, 2)
)

## update the plot
ggregtab(tidy_fit) +
  labs(
    title = "A Regression Table",
    subtitle = "With OLS estimates"
  ) +
  scale_y_discrete(
    labels = c(
      "Cylinders",
      "Weight",
      "Horse Power",
      "(Intercept)"
    )
  ) +
  scale_x_continuous(
    breaks = 1,
    labels = smry_stats
  )
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

One last thing I’ll show you is how to update the font of your tables.
Here’s an example using “serif”. I haven’t tested it, but I assume you
could use something like `{showtext}` to use a wider variety of fonts
than what are available by default with `{ggplot2}` as well.

``` r
ggregtab(tidy_fit, base_family = "serif") +
  labs(
    title = "A Regression Table",
    subtitle = "With OLS estimates"
  ) +
  scale_y_discrete(
    labels = c(
      "Cylinders",
      "Weight",
      "Horse Power",
      "(Intercept)"
    )
  ) +
  scale_x_continuous(
    breaks = 1,
    labels = smry_stats
  )
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

### Multiple Models

You can show multiple regression models at once. When doing this, just
make sure that the tidy coefficient test object you give `ggregtab()`
has unique model IDs for each model you want to show. You can control
this using the `model` option in `tidy_coeftest()`.

Also, when you start adding more models, you may want to play around
with the `ratio` option in `ggregtab()`. By default this is set to
`1/5`, but you’ll probably need to adjust this as you add more columns
to your table. This `ratio` option is given to `coord_fixed()` under the
hood, which is a convenient method for keeping consistent dimensions for
data visualizations.

Here’s an example with three regression models:

``` r
fit1 <- lm(mpg ~ hp, mtcars)
fit2 <- lm(mpg ~ wt, mtcars)
fit3 <- lm(mpg ~ hp + wt, mtcars)

dplyr::bind_rows(
  tidy_coeftest(fit1, model = "Model 1"),
  tidy_coeftest(fit2, model = "Model 2"),
  tidy_coeftest(fit3, model = "Model 3")
) |>
  ggregtab(ratio = 1/2) +
  labs(
    title = "Many Regression Models",
    subtitle = "Still OLS Estimates"
  ) 
```

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

### Using Robust or Clustered Standard Errors

Under the hood, `tidy_coeftest()` uses `lmtest::coeftest()` before it
passes things over to `broom::tidy()`. This means you can supply your
own variance-covariance matrix for coefficient tests. `tidy_coeftest()`
lets you pass such a matrix to `coeftest()` using the same `vcov.`
syntax. Just specify `vcov. = ...` and provide your alternative
variance-covariance matrix. This is useful if you want to show robust or
clustered standard errors.

You might do this using functions from the `{sandwich}` package, like
so:

``` r
tidy_coeftest(
  fit,
  vcov. = sandwich::vcovHC(fit, type = "HC1")
) |>
  ggregtab() +
  labs(
    title = "A Regression Table",
    subtitle = "With HC1 Standard Errors"
  ) +
  scale_y_discrete(
    labels = c(
      "Cylinders",
      "Weight",
      "Horse Power",
      "(Intercept)"
    )
  )
```

![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

### You Can Do Even More

I’ve just barely scratched the surface of what you can do. Since
`ggplot()` itself is so infinitely customizable, so are the tables you
can make with `ggregtab()`.

You can also use any model object or class that is compatible with
`lmtest::coeftest()`. I haven’t checked, but that covers most model
types that most researchers use most of the time.

Now go have fun disguising ggplots as regression tables!
