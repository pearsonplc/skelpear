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
  path <- file.path("config", "packages.dcf")

  if (!file.exists(path)) {
    return(cli::cat_line(
      sprintf(
        "Warning: There is no `%s` file in your project. Please use `snapshot_pkg` function to save your package environment.",
        path
      ),
      col = "orange"
    ))
  }

  # load snapshot envir
  snapshot_df <- read.dcf(path) %>%
    as.data.frame(stringsAsFactors = F)

  # detect local envir
  local_df <- scour_script()

  # compare both envirs
  is_equal <- dplyr::all_equal(snapshot_df, local_df)

  if (isTRUE(is_equal)) {
    invisible(NULL)
  }

  else {
    check_version(local_df, snapshot_df) %>%
      purrr::map2(., names(.), show_message) %>%
      cli::cat_line()
  }
}

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

modify_col_name <- function(data, type) {
  dplyr::rename_at(data,
                   dplyr::vars(-package),
                   dplyr::funs(paste0(., type)))
}

show_message <- function(data, what) {
  skel_message(
    data,
    what = what,
    title = skel_title(what),
    symbol = skel_symbol(what),
    fun = skel_color(what)
  )
}

skel_message <- function(data, title, subtitle, symbol, what, fun) {
  if (nrow(data) == 0)
    invisible(NULL)

  header <- cli::rule(left = crayon::bold(title),
                      right = what)

  content <- format_message(data, what, fun)

  symbol <- do.call(fun, list(symbol))

  bullets <- paste0(symbol, " ", content,
                    collapse = "\n")

  paste0(header, "\n", bullets)

}

format_message <- function(data, what, fun) {
  args <- data %>% {
    switch(
      what,
      install = paste0(.$package, " ", .$version_sp),
      reinstall = paste0(.$package, " ", .$version_sp, " (local: ", .$version_lc, ")"),
      save = paste0(.$package, " ", .$version_lc)
    )
  }

  do.call(fun, list(args)) %>% format()
}

skel_title <- function(what) {
  switch(what,
         "install" = "Package/s to install",
         "reinstall" = "Package to reinstall",
         "save" = "Package to save")
}

skel_symbol <- function(what) {
  switch(
    what,
    "install" = cli::symbol$cross,
    "reinstall" = cli::symbol$cross,
    "save" = cli::symbol$star
  )
}

skel_color <-  function(what) {
  switch(
    what,
    "install" = crayon::red,
    "reinstall" = crayon::red,
    "save" = crayon::yellow
  )
}
