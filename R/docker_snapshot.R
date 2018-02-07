#' Create a chunk of code with package installation.
#'
#' A function which creates chunk of code with package installation for Dockerfile. It stores those commands in memory. Just paste it (Cmd + V) to the Dockerfile.
#' It is so-called the `silent function`` i.e. when a function executes successfully, no message shows up. Afterwards, you are ready to paste
#'
#' @export
#' @examples
#' \dontrun{
#'  snapshot_pkg()
#'  }

docker_snapshot <- function() {

  snapshot_path <- "config/packages.dcf"

  if (!file.exists(snapshot_path)) {
    return(cli::cat_line("Warning: There is no `packages.dcf` file in your project. Please use `snapshot_pkg` function to save your package environment.", col = "orange"))

  }

  snapshot_df <- read.dcf(snapshot_path) %>%
    as.data.frame(stringsAsFactors = F) %>%
    only_attached(attached)

  if (any(snapshot_df$source %in% c("Bioconductor", "local"))) {
    return(cli::cat_line("Error: There is at least one attached package from local/Bioconductor source. Please define packages only from CRAN/github source.", col = "red"))
  }

  docker_cmds <- snapshot_df %>%
    dplyr::group_by(package) %>%
    tidyr::nest() %>%
    dplyr::mutate(cmds = purrr::map2_chr(package, data, ~create_docker_cmd(.x, .y))) %>%
    dplyr::pull(cmds)

  clipr::write_clip(docker_cmds)

}

create_docker_cmd <- function(pkg, data) {
  is_cran <- ifelse(grepl("CRAN|cran", data$source), TRUE, FALSE)

  github_source <- gsub(".*\\((.*)\\).*", "\\1", data$source)
  docker_init <- "RUN R -e"

  if (is_cran) {
    sprintf('%s devtools::install_version("%s", version = "%s", repos = "https://cran.rstudio.com/")', docker_init, pkg, data$loadedversion)
  }
  else {
    sprintf('%s devtools::install_github("%s")', docker_init, github_source)
  }
}
