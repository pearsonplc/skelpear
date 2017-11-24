#' Compare your session info with packages stored in `config/packages.dcf`
#'
#' A function which allows you to compare your set of packages with those stored in `config/packages.dcf` file.
#'
#' @export
#' @param only_attached if TRUE, it will only compare attached packages.
#'
#' @examples
#' \dontrun{
#'  compare_snapshot_pkg()
#'  }

compare_snapshot_pkg <- function(only_attached = T) {

  snapshot_df <- read.dcf("config/packages.dcf") %>%
    as.data.frame(stringsAsFactors = F)

  local_df <- extract_session_info()

  if (only_attached) {
    snapshot_df <- only_attached(snapshot_df, attached)
    local_df <- only_attached(local_df, attached)
  }

  is_equal <- all_equal(snapshot_df, local_df)

  if (isTRUE(is_equal)) {
    return(invisible())
  }

  else {

    snapshot_pkg_selected <- modify_col_name(snapshot_df, "_snapshot")
    local_pkg_selected <- modify_col_name(local_df, "_local")

    joined_pkg <- check_version(local_pkg_selected, snapshot_pkg_selected)

    if (only_attached) { joined_pkg <- only_attached(joined_pkg, attached_snapshot) }

    # return(joined_pkg)

    cli::cat_line("The following packages were loaded in different versions comparing to the snapshot:", col = "orange")
    cli::cat_line()
    cli::cat_bullet(format(joined_pkg$package), " (local: ",
                    joined_pkg$loadedversion_local, " -> snapshot: ",
                    joined_pkg$loadedversion_snapshot, ")",
                    col = "orange", bullet_col = "orange")

    invisible()
  }

}

modify_col_name <- function(data,  type) {

  dplyr::rename_at(data,
                   dplyr::vars(loadedversion, attached),
                   dplyr::funs(paste0(., type)))
}

check_version <- function(local_data, snapshot_data) {
  local_data %>%
    dplyr::full_join(snapshot_data, by = "package") %>%
    dplyr::mutate(check_version = dplyr::case_when(
      loadedversion_local == loadedversion_snapshot ~ TRUE,
      TRUE ~ FALSE)) %>%
    dplyr::filter(check_version == FALSE)
}

only_attached <- function(data, col) {

  col_name <- dplyr::enquo(col)
  dplyr::filter(data, (!!col_name) == "TRUE")
}

