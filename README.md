<!-- README.md is generated from README.Rmd. Please edit that file -->
Overview
--------

`skelpear` package belongs to the `pearsonverse` - set of packages which facilitates the data science process in R. The mail goal of this package is to support teams via building an identical project environment and maintaining a reproducibility. It depends mainly on `ProjectTemplate` package.

Installation
------------

First install `pearsonverse` [package](https://github.com/pearsonplc/pearsonverse). It will install all `*pear` packages.

``` r
devtools::install_github("pearsonplc/pearsonverse")
```

However, if you want install just `skelpear` package:

``` r
devtools::install_github("pearsonplc/skelpear")
```

Goals
------------

__Building project environment__

`project_create(project_name, path = ".")` - a function which builds the project skeleton. It contains several pre-defined directories and files. More info about the role of each components in Pearson Efficacy Analytics Handbook.

__Maintaining reproducibility__

`snapshot_pkg()` & `compare_snapshot()` - pair of functions which allows to save and compare set of packages used during the project. It's especially useful when more team members are involved in producing code.
