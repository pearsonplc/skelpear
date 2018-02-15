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

utils::globalVariables("package")
utils::globalVariables("cmds")

docker_snapshot <- function() {
  sp_path <- "config/packages.dcf"

  if (!file.exists(sp_path)) {
    stop(no_file_message(sp_path), call. = F)
  }

  # extract information about package source (either CRAN or github)
  snapshot_df <- extract_source(sp_path)

  # check if any package was installed from local/Biocundor source
  app_source_ckeck <- any(snapshot_df$source %in% c("Bioconductor", "local"))

  if (app_source_ckeck) {

    data <- dplyr::filter(snapshot_df, source %in% c("Bioconductor", "local"))
    text <- "Error: Package/s listed below come from local/Bioconductor source. Define packages only from CRAN/github source."

    return(show_uninst_pkgs(data, text, "install"))
  }

  # create docker commands
  docker_cmds <- snapshot_df %>%
    dplyr::group_by(package) %>%
    tidyr::nest() %>%
    dplyr::mutate(cmds = purrr::map2_chr(package, data, ~ create_docker_cmd(.x, .y))) %>%
    dplyr::pull(cmds)

  # copy docker commands to clipboard
  clipr::write_clip(docker_cmds)

}

create_docker_cmd <- function(pkg, data) {
  is_cran <- ifelse(grepl("CRAN|cran", data$source), TRUE, FALSE)

  github_source <- gsub(".*\\((.*)\\).*", "\\1", data$source)
  docker_init <- "RUN R -e"

  if (is_cran) {
    sprintf(
      "%s \"devtools::install_version('%s', version = '%s', repos = 'https://cran.rstudio.com/')\"",
      docker_init,
      pkg,
      data$version_sp
    )
  }
  else {
    sprintf("%s \"devtools::install_github('%s')\"",
            docker_init,
            github_source)
  }
}

utils::globalVariables("package")
utils::globalVariables("loadedversion")
extract_source <- function(path) {

  loaded_pkgs <- read.dcf(path)[,"package"]


  loaded_pkgs %>%
    sessioninfo::package_info() %>%
    dplyr::filter(package %in% loaded_pkgs) %>%
    dplyr::select(package, loadedversion, source) %>%
    dplyr::rename(version_sp = loadedversion)
}
