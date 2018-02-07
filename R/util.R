
extract_session_info <- function() {

  sinfo <- sessioninfo::session_info()
  attach_pkg <- sinfo$packages %>%
    as.data.frame() %>%
    dplyr::select(package, loadedversion, attached, source) %>%
    dplyr::mutate_all(as.character)

  return(attach_pkg)
}

only_attached <- function(data, col) {

  col_name <- dplyr::enquo(col)
  dplyr::filter(data, (!!col_name) == "TRUE")
}
