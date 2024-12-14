# `{ggregtab}`

It's yet another R package for making regression tables. Why?!

The `{ggregtab}` package is a hyper-specific solution to a hyper-specific problem I've been having. As an academic researcher, I love the look of pdfs that I can make of paper manuscripts using Quarto and RMarkdown. Unfortunately, most of the journals that I submit my work to want Word Documents. This is havoc for regression tables. The placement of these is never formatted the way I like, and often I have to contend with tables being split between two pages because of their placement in my Quarto or RMarkdown file. This is frustrating to no end, and I couldn't find a solution other than editing my files after the fact.

I then had a realization. I don't have this problem with my figures because they are rendered as images. That means they aren't split between pages. So what if I had a method for quickly making a figure that just happens to look like a table?

Hence, I give you `{ggregtab}`. It produces ggplots that look like regression tables.

To install the package just write:

```
install.packages("devtools")
devtools::install_github("milesdwilliams15/ggregtab")
```

## Main Functions

The main functions in the package are:

- `ggregtab()`
- `tidy_coeftest()`

`ggregtab()` produces a ggplot that looks like a regression table once given a tidy coefficient test object.

Importantly, this object must contain eight unique columns. In addition to the usual that are produced for model objects using `broom::tidy()`, additional columns required are `conf.low`, `conf.high`, `model`, and `N`. The first two are required if you want to show confidence intervals instead of standard errors in your "tables." The latter are required for model labeling and for showing sample sizes.

`tidy_coeftest()` is a helper function that makes it easy to get your model objects into the correct shape. You don't have to use this function, however, as long as the coefficient test object you give to `ggregtab()` contains the requisite columns.

## An Example

Here's some code that produces a regression table using data from the `mtcars` dataset.

```
## open the package
library(ggregtab)

## fit a regression model
fit <- lm(mpg ~ hp + wt + cyl, mtcars)

## prep it for visualization
tidy_fit <- tidy_coeftest(fit)

## plot the regression table
ggregtab(tidy_fit)
```

## Advanced Options

