#' Compare your session info with packages stored in `config/packages.dcf`
#'
#' A function which allows you to compare your set of packages with those stored in `config/packages.dcf` file.
#' It is so-called `silent function`` i.e. when a function executes successfully, no message shows up.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  compare_snapshot()
#'  }

compare_snapshot <- function() {

  only_attached <- TRUE
  snapshot_path <- "config/packages.dcf"

  if(!file.exists(snapshot_path)) {
    return(cli::cat_line("Warning: There is no `packages.dcf` file in your project. Please use `snapshot_pkg` function to save your package environment.", col = "orange"))
  }

  snapshot_df <- read.dcf(snapshot_path) %>%
    as.data.frame(stringsAsFactors = F)

  local_df <- extract_session_info()

  if (only_attached) {
    snapshot_df <- only_attached(snapshot_df, attached)
    local_df <- only_attached(local_df, attached)
  }

  is_equal <- dplyr::all_equal(snapshot_df, local_df)

  if (isTRUE(is_equal)) {
    invisible(NULL)
  }

  else {
    snapshot_pkg_selected <- modify_col_name(snapshot_df, "_snapshot")
    local_pkg_selected <- modify_col_name(local_df, "_local")

    joined_pkg <- check_version(local_pkg_selected, snapshot_pkg_selected)

    cli::cat_line(snapshot_message(joined_pkg))
    cli::cat_line(snapshot_message(joined_pkg, crucial = FALSE))
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

snapshot_message <- function(data, crucial = TRUE) {

  if (crucial) data <- only_attached(data, attached_snapshot)
  else data <- only_attached(data, attached_local) %>% dplyr::filter(is.na(attached_snapshot))

  if (nrow(data) == 0) return("")

  header <- cli::rule(
    left = crayon::bold(ifelse(crucial, "Crucial packages to attach", "Potential packages to save")
    ),
    right = ifelse(crucial, "attach/install", "save")
  )

  funs <- list_pkgs(data, crucial)

  sign <- ifelse(crucial, crayon::red(cli::symbol$cross), crayon::yellow(cli::symbol$star))

  bullets <- paste0(
    sign, " ", funs,
    collapse = "\n"
  )

  paste0(header, "\n", bullets)
}

list_pkgs <- function(data, crucial = TRUE) {
  if (crucial) {
    format(paste0(
      crayon::red(data$package), " ", crayon::red(data$loadedversion_snapshot),
      " (", ifelse(is.na(data$loadedversion_local), "nonattached)", paste0("local version: ", data$loadedversion_local, ")"))
    ))
  }
  else {
    format(
      paste0(
        crayon::yellow(data$package), " ", crayon::yellow(data$loadedversion_local))
    )
  }
}

