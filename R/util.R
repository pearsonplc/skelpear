
extract_session_info <- function() {

  sinfo <- sessioninfo::package_info()
  attach_pkg <- sinfo %>%
    dplyr::select(package, loadedversion, attached, source) %>%
    dplyr::rename(version = loadedversion) %>%
    dplyr::mutate_all(as.character)

  return(attach_pkg)
}

only_attached <- function(data, col) {

  col_name <- dplyr::enquo(col)
  dplyr::filter(data, (!!col_name) == "TRUE")
}

extract_script <- function() {

  dir <- normalizePath(".", winslash = '/')
  pattern <- "[.](?:r)$"

  pkgs <- character()

  R_files <- list.files(dir,
                        pattern = pattern,
                        ignore.case = TRUE,
                        recursive = TRUE
  )

  sapply(R_files, function(file) {
    filePath <- file.path(dir, file)
    pkgs <<- append(pkgs, packrat:::fileDependencies(file.path(dir, file)))

  })

  pkgs <- packrat:::dropSystemPackages(pkgs)

  pkgs <- extract_pkg_info(pkgs)

  return(pkgs)

}

extract_pkg_info <- function(pkgs) {
  packinfo <- installed.packages(fields = c("Package", "Version"))

  pkgs_mat <- packinfo[pkgs, c("Package", "Version")]
  colnames(pkgs_mat) <- tolower(colnames(pkgs_mat))

  return(pkgs_mat)
}
