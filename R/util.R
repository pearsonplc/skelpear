
no_file_message <- function(path) {
  sprintf(
    "There is no `%s` file in your project. Please use `snapshot_pkg` function to save your package environment.",
    path
  )
}

scour_script <- function() {

  dir <- normalizePath(".", winslash = '/')
  # pattern <- "[.](?:r|rmd)$|global.dcf"
  pattern <- "[.](?:r)$|global.dcf"

  pkgs <- character()

  R_files <- list.files(dir,
                        pattern = pattern,
                        ignore.case = TRUE,
                        recursive = TRUE
  )

  packratDirRegex <- "(?:^|/)packrat"
  R_files <- grep(packratDirRegex, R_files, invert = TRUE, value = TRUE)

  sapply(R_files, function(file) {
    filePath <- file.path(dir, file)
    pkgs <<- append(pkgs, fileDependencies(file.path(dir, file)))

  })

  pkgs <- unique(pkgs) %>% extract_pkg_info()

  return(pkgs)

}

extract_pkg_info <- function(pkgs) {

  packinfo <- installed.packages(fields = c("Package", "Version"))

  must_pkgs <- pkgs %in% packinfo

  # Condition when some package are not installed
  if (!all(must_pkgs)) {
    to_install <- dplyr::data_frame(Package = pkgs[must_pkgs == FALSE])
  }
  else {
    to_install <- dplyr::data_frame()
  }

  pkgs <- pkgs[must_pkgs == TRUE]

  pkgs_df <- packinfo[pkgs, c("Package", "Version")] %>%
    dplyr::as_data_frame() %>%
    dplyr::bind_rows(to_install) %>%
    dplyr::rename_all(tolower)

  return(pkgs_df)
}

fileDependencies <- function(file) {
  file <- normalizePath(file, winslash = "/", mustWork = TRUE)
  fileext <- tolower(gsub(".*\\.", "", file))
  switch(fileext,
         r = packrat:::fileDependencies.R(file),
         rmd = packrat:::fileDependencies.Rmd(file),
         dcf = fileDependencies.dcf(file),
         stop("Unrecognized file type '", file, "'")
  )
}

fileDependencies.dcf <- function(file) {

  if (!file.exists(file)) {
    warning("No file at path '", file, "'.")
    return(character())
  }

  pkgs <- character()
  dcf <- read.dcf(file) %>% dplyr::as_data_frame()
  pkgs <- append(pkgs, strsplit(dcf$libraries, '\\s*,\\s*')[[1]])

  setdiff(unique(pkgs), "")

}
