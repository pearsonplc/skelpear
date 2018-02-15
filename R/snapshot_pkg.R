#' Create a snapshot of your session info
#'
#' A function which creates a file with your local session info (all packages you use) in config/packages.dcf file.
#' It is so-called `silent function`` i.e. when a function executes successfully, no message shows up.
#'
#' @export
#' @examples
#' \dontrun{
#'  snapshot_pkg()
#'  }


snapshot_pkg <- function() {

  # detect all packages attached in a project
  used_pkgs <- scour_script()

  # check if any  package is not installed locally
  noninstall_check <- any(is.na(used_pkgs$version))

  if (noninstall_check) {

    data <- dplyr::filter(used_pkgs, is.na(version))
    text <- "Error: Package/s listed below are not installed locally. Intall & `snapshot_pkg()` them again."

    return(show_uninst_pkgs(data, text, "snapshot"))
  }

  if (!dir.exists("config")) {
    dir.create("config")
  }

  write.dcf(used_pkgs, file = file.path("config", "packages.dcf"))
}
