
extract_session_info <- function() {

  sinfo <- sessioninfo::session_info()
  attach_pkg <- sinfo$packages %>%
    as.data.frame() %>%
    dplyr::select(package, loadedversion, attached) %>%
    dplyr::mutate_all(as.character)

  return(attach_pkg)
}
