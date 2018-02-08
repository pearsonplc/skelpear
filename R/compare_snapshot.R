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

    joined_pkg <- check_version(local_df, snapshot_df)

    cli::cat_line(snapshot_message(joined_pkg))
    cli::cat_line(snapshot_message(joined_pkg, crucial = FALSE))
  }
}

check_version <- function(local_data, snapshot_data) {

  snapshot_pkg <- modify_col_name(snapshot_data, "_sp")
  local_pkg <- modify_col_name(local_data, "_lc")

  local_pkg %>%
    dplyr::full_join(snapshot_pkg, by = "package") %>%
    dplyr::mutate(
      check_v = dplyr::case_when(
        version_lc == version_sp ~ TRUE,
        TRUE ~ FALSE
      )) %>%
    dplyr::filter(check_v == FALSE)
}

modify_col_name <- function(data, type) {

  dplyr::rename_at(data,
                   dplyr::vars(-package),
                   dplyr::funs(paste0(., type)))
}

snapshot_message <- function(data, crucial = TRUE) {

  if (crucial) data <- only_attached(data, attached_sp)
  else data <- only_attached(data, attached_lc) %>% dplyr::filter(is.na(attached_sp))

  if (nrow(data) == 0) invisible(NULL)

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
      crayon::red(data$package), " ", crayon::red(data$version_sp),
      " (", ifelse(is.na(data$version_lc), "nonattached)", paste0("local version: ", data$version_lc, ")"))
    ))
  }
  else {
    format(
      paste0(
        crayon::yellow(data$package), " ", crayon::yellow(data$version_lc))
    )
  }
}

