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

  attach_pkg <- extract_session_info()
  # script_pkgs <- extract_script()

  if (!dir.exists("config")) { dir.create("config") }

  write.dcf(attach_pkg, file = file.path("config", "packages.dcf"))
  # write.dcf(script_pkgs, file = file.path("config", "packages_src.dcf"))
}

