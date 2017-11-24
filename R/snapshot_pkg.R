#' Create a snapshot of your session info
#'
#' A function which creates a file with your local session info (all packages you use) in config/packages.dcf file.
#' 
#' @export
#' @examples 
#' \dontrun{
#'  snapshot_pkg()
#'  }


snapshot_pkg <- function() {
  
  attach_pkg <- extract_session_info()
  
  if (!dir.exists("config")) { dir.create("config") }
  
  write.dcf(attach_pkg, file = file.path("config", "packages.dcf"))
}

