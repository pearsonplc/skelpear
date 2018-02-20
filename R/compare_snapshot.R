#' Compare your session info with packages stored in `config/packages.dcf`
#'
#' A function which allows you to compare your set of packages with those stored in `config/packages.dcf` file.
#' It is so-called `silent function`` i.e. when a function executes successfully, no message shows up.
#'
#' @export
#' @examples
#' \dontrun{
#'  compare_snapshot()
#'  }

compare_snapshot <- function() {
  sp_path <- file.path("config", "packages.dcf")

  if (!file.exists(sp_path)) {
    stop(no_file_message(sp_path), call. = F)
  }

  # load snapshot envir
  snapshot_df <- read.dcf(sp_path) %>%
    dplyr::as_data_frame()

  # detect local envir
  local_df <- scour_script()

  # compare both envirs
  is_equal <- dplyr::all_equal(snapshot_df, local_df)

  if (!isTRUE(is_equal)) {
    check_version(local_df, snapshot_df) %>%
      purrr::map2(., names(.), show_message) %>%
      cli::cat_line()
  }

  invisible(NULL)
}

utils::globalVariables(".")
utils::globalVariables("check_v")

check_version <- function(local_data, snapshot_data) {
  # modify tables before merging
  snapshot_pkg <- modify_col_name(snapshot_data, "_sp")
  local_pkg <- modify_col_name(local_data, "_lc")

  # filter out correct packages
  int_data <- local_pkg %>%
    dplyr::full_join(snapshot_pkg, by = "package") %>%
    dplyr::mutate(check_v = dplyr::case_when(version_lc == version_sp ~ TRUE,
                                             TRUE ~ FALSE)) %>%
    dplyr::filter(check_v == FALSE)

  # divide message into separated data.frame
  divide_message(int_data)

}

utils::globalVariables("info")
utils::globalVariables(".")

# divide message into separated data.frame
divide_message <- function(data) {
  data %>%
    dplyr::mutate(info = dplyr::case_when(
      is.na(version_lc) ~ "install",
      is.na(version_sp) ~ "save",
      TRUE ~ "reinstall"
    )) %>%
    dplyr::group_by(info) %>%
    split(., .$info)
}

utils::globalVariables("package")

modify_col_name <- function(data, type) {
  dplyr::rename_at(data,
                   dplyr::vars(-package),
                   dplyr::funs(paste0(., type)))
}
