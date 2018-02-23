<!-- README.md is generated from README.Rmd. Please edit that file -->
Overview
--------

`skelpear` package belongs to the `pearsonverse` - set of packages which facilitates the data science process in R. The main goal of this package is to support teams via __building an identical project environment__ and __maintaining a reproducibility__. It depends mainly on `ProjectTemplate` package.

## Installation

First install `pearsonverse` [package](https://github.com/pearsonplc/pearsonverse). It will install all `*pear` packages.

``` r
devtools::install_github("pearsonplc/pearsonverse")
```

However, if you want to install just `skelpear` package:

``` r
devtools::install_github("pearsonplc/skelpear")
```

## Main functions

1. `project_create()`     
2. `snapshot_pkg()` & `compare_snapshot()`    
3. `docker_snapshot()`     

## Goals

### 1. Building project environment

#### 1.1 _project_create()_


A function which builds the project skeleton. It will automatically open a new sesion. It contains several pre-defined directories and files. More info in _Project structure_ section. For example,

`project_create(name = "example_project", path = ".")`

The function automatically initialises `git` environment. Then, to push your project into __bitbucket__, two things have to be done:

1. Create a repo on bitbucket.
2. Use `git remote add origin <remote_URL>` to link your local project with repo on bitbucket. E.g. `git remote add origin https://lint_to_your_repo.git`.

After that, you're ready to push your commit/s.

### 2. Maintaining reproducibility

#### 2.1 _snapshot_pkg() & compare_snapshot()_

A pair of functions which allows to save and compare set of packages used during the project. It's especially useful when more team members are involved in code development.

The `snapshot_pkg()` function saves the package environment in `config/packages.dcf` file. It looks thorugh all R scripts and `config/global.dcf` within a project to find an execution of `library`, `require` or `::`. Once you push it to the bitbucket repository, anybody can pull it and compare to the local package envrionment via `compare_snapshot` function.

Both functions return a message only when snapshot process fails. Below the local environment is identical with the snapshot.

![](https://raw.githubusercontent.com/pearsonplc/skelpear/new_compare_snapshot/inst/img/snapshot_no_message.png)

__How to read `compare_snapshot` summary__

![](https://raw.githubusercontent.com/pearsonplc/skelpear/new_compare_snapshot/inst/img/compare_snapshot.png)

The summary consists of three sections:

- Packages to install
- Packages to reinstall
- Packages to save

__Packages to install__ section lists packages which are not installed locally but are critical to the project.

__Packages to reinstall__ section lists packages which have different version in local environment than in `config/pacakges.dcf`. In following example, `dplyr v0.7.4` was detected in your local environment, but one of your colleagues uses `dplyr v0.7.2`. You should decide together which `dplyr` version you want to use.

__Packages to save__ section lists packages which were detected in your local environment but have not been included in `config/packages.dcf` yet. You can include them by executing `snapshot_pkg()` function. But __be careful__, first you have to solve all conflicts on the first two sections.

#### 2.2 _docker_snapshot()_

A function which creates chunk of code with package installation for Dockerfile. It stores those commands in memory. Just paste it (Cmd + V) in Dockerfile.

## Project structure

Once you use `project_name()` function, you will get a new project directory with several pre-defined empty directories and files. Below you can find short description of each component:

->__cache/__ - a directory with cached data objects.     
->__config/__ - a directory with one file `global.dcf`. It is responsible for all things which happen while opening the `.Rproj` file.        
->__data/__ - a directory with data files (`.csv`, `.RData` etc.).   
->__graphs/__ - a directory with created graphs during the project.    
->__misc/__ - a directory with the rest of relevant files.    
->__munge/__ - a directory with R scripts with all pre-processing R scripts which are executed while opening the `.Rproj` file.   
->__reports/__ - a directory with presentations and shiny app.   
->__sql/__ - a directory with sql queries.     
->__src/__ - a directory with R scripts related to data analysis.    
->__.Rprofile__    
->__project.Rproj__    

