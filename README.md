
<!-- README.md is generated from README.Rmd. Please edit that file -->
resampleR
=========

**resamplerR** is like M.Kuhn\`s **rsample**, but all resamples are realised as plain data.table objects. This package aims to be as easy to extend as possible.

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

cv_base(as.data.table(iris), "Species")
#>      split_1 split_2 split_3 split_4 split_5
#>   1:       0       0       0       0       1
#>   2:       0       0       1       0       0
#>   3:       0       0       1       0       0
#>   4:       0       0       0       1       0
#>   5:       1       0       0       0       0
#>  ---                                        
#> 146:       1       0       0       0       0
#> 147:       0       0       1       0       0
#> 148:       1       0       0       0       0
#> 149:       1       0       0       0       0
#> 150:       0       0       0       1       0

dt <- data.table(
    user = rep(1:100, each = 5),
    date = as.POSIXct(rep(seq(1.8*10e8, 1.8*10e8 + 388800, by = 86400), 100),
                      origin = "1960-01-01"),
    target = rnorm(5e2)
)

cv_split_group_kfold(dt, "target", "user")
#>      split_1 split_2 split_3 split_4 split_5
#>   1:       0       0       1       0       0
#>   2:       0       0       1       0       0
#>   3:       0       0       1       0       0
#>   4:       0       0       1       0       0
#>   5:       0       0       1       0       0
#>  ---                                        
#> 496:       0       1       0       0       0
#> 497:       0       1       0       0       0
#> 498:       0       1       0       0       0
#> 499:       0       1       0       0       0
#> 500:       0       1       0       0       0

cv_split_temporal(dt, "target", "user", "date")
#>      split_1 split_2 split_3 split_4 split_5
#>   1:       0       0       0       0       0
#>   2:       0       0       0       0       0
#>   3:       0       0       0       0       0
#>   4:       0       0       0       0       0
#>   5:       0       1       1       1       0
#>  ---                                        
#> 496:       0       0       0       0       0
#> 497:       0       0       0       0       0
#> 498:       0       0       0       0       0
#> 499:       0       0       0       0       0
#> 500:       1       0       1       0       0

repeated_kfold(expr = quote(cv_base(as.data.table(iris), "Species")))
#>      rep_1_fold_1 rep_1_fold_2 rep_1_fold_3 rep_1_fold_4 rep_1_fold_5
#>   1:            1            0            0            0            0
#>   2:            0            0            1            0            0
#>   3:            0            0            0            0            1
#>   4:            0            1            0            0            0
#>   5:            1            0            0            0            0
#>  ---                                                                 
#> 146:            0            0            0            0            1
#> 147:            0            0            0            0            1
#> 148:            1            0            0            0            0
#> 149:            0            0            0            0            1
#> 150:            1            0            0            0            0
#>      rep_2_fold_1 rep_2_fold_2 rep_2_fold_3 rep_2_fold_4 rep_2_fold_5
#>   1:            1            0            0            0            0
#>   2:            0            0            0            1            0
#>   3:            0            0            0            1            0
#>   4:            0            0            0            0            1
#>   5:            1            0            0            0            0
#>  ---                                                                 
#> 146:            0            0            0            1            0
#> 147:            0            1            0            0            0
#> 148:            0            0            0            0            1
#> 149:            0            0            1            0            0
#> 150:            0            0            1            0            0
```
