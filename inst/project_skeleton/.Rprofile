
library(stats)
library(utils)

local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com"
  options(repos = r)
})

inst <- "ProjectTemplate" %in% installed.packages()

if (!inst) install.packages("ProjectTemplate", repos = "https://cran.rstudio.com/")

.First <- function(){
  ProjectTemplate::load.project()
  compare_snapshot()
}
