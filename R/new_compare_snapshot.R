compare_chunk <- function(file, fun, attached = TRUE) {

  path <- file.path("config", file)

  if(!file.exists(path)) {
    return(
      cli::cat_line(
        sprintf("Warning: There is no `%s` file in your project. Please use `snapshot_pkg` function to save your package environment.", path),
        col = "orange")
    )
  }

  snapshot_df <- read.dcf(path) %>%
    as.data.frame(stringsAsFactors = F)

  args <- switch(as.character(attached),
                 "TRUE" = list(),
                 "FALSE" = snapshot_df$package)

  local_df <- do.call(fun, args) %>%
    as.data.frame()

  if (attached) {
    snapshot_df <- only_attached(snapshot_df, attached)
    local_df <- only_attached(local_df, attached)
  }

  is_equal <- dplyr::all_equal(snapshot_df, local_df)

  if (isTRUE(is_equal)) {
    invisible(NULL)
  }

  else {

    joined_pkg <- check_version(local_df, snapshot_df)

    joined_pkg
  }
}
