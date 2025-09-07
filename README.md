
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgicon

<!-- badges: start -->

<!-- badges: end -->

This is a local alternative to \[pkgdown::build_favicons()\].

It is also expected to work on more cases and avoid strange issues where
some logo elements were dropped from the online converter used by
pkgdown.

## Installation

You can install the development version of pkgicon from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Bisaloo/pkgicon")
```

## Example

To generate your package favicons, please the source logo (ideally saved
as an `.svg`) under one of the locations recognized by pkgdown and
r-universe:

- `./logo.svg` (`.` is the root of your R package, where the
  `DESCRIPTION` file is located)
- `./man/figures/logo.svg`
- `./logo.png`
- `./man.figures/logo.png`

And then run:

``` r
pkgicon::build_pkgdown_favicons(
  pkg = "." # change this to the path of the root of your pkg
)
```
