
<!-- README.md is generated from README.Rmd. Please edit that file -->
resampleR
=========

**resamplerR** is like M.Kuhn\`s **rsample**, but all resamples are realised as plain data.table objects.This package aims to be as easy to extend as possible.

Installation
------------

You can install dev version of **resampleR** from [GitHub](https://github.com) with:

``` r
devtools::install_github("statist-bhfz/resampleR")
```

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
library(resampleR)
#> Loading required package: data.table
dt <- data.table(
    user = rep(1:100, each = 10),
    date = as.POSIXct(rep(seq(1.8*10e8, 1.8*10e8 + 777600, by = 86400), 100),
                      origin = "1960-01-01"),
    target = rnorm(1e3)
)
cv_split_temporal(dt, "target", "user", "date")
#>       split_1 split_2 split_3 split_4 split_5
#>    1:       0       0       0       0       0
#>    2:       0       0       0       0       0
#>    3:       0       0       0       0       0
#>    4:       0       0       0       0       0
#>    5:       0       0       0       0       0
#>   ---                                        
#>  996:       0       0       0       0       0
#>  997:       0       0       0       0       0
#>  998:       0       0       0       0       0
#>  999:       0       0       0       0       0
#> 1000:       0       1       1       1       1
```
