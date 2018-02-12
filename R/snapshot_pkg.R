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
  used_pkgs <- scour_script()

  not_install <- any(is.na(used_pkgs$version))

  # Condition when some package are not installed
  if (not_install) {
    return(
      cli::cat_line(
        "Warning: There is at least one package which is not installed in local environment. Please install it and then `snapshot_pkg()` again.",
        col = "orange"
      )
    )
  }

  if (!dir.exists("config")) {
    dir.create("config")
  }

  write.dcf(used_pkgs, file = file.path("config", "packages.dcf"))
}
