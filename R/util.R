
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

  packinfo <- utils::installed.packages(fields = c("Package", "Version"))

  must_pkgs <- pkgs %in% packinfo

  # Condition when some package are not installed
  if (!all(must_pkgs))
    to_install <- dplyr::data_frame(package = pkgs[must_pkgs == FALSE])

  pkgs <- pkgs[must_pkgs == TRUE]

  pkgs_df <- packinfo[pkgs, c("Package", "Version")] %>%
    dplyr::as_data_frame() %>%
    dplyr::rename_all(tolower)

  if (exists("to_install"))
    pkgs_df <- dplyr::bind_rows(pkgs_df, to_install)

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

show_message <- function(data, what) {
  skel_message(
    data,
    what = what,
    title = skel_title(what),
    symbol = skel_symbol(what),
    fun = skel_color(what)
  )
}

skel_message <- function(data, what, title = NULL, symbol = NULL, fun = crayon::white) {
  if (nrow(data) == 0)
    invisible(NULL)

  header <- ifelse(is.null(title), "", cli::rule(left = crayon::bold(title),
                      right = what))

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
      snapshot = .$package,
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

show_uninst_pkgs <- function(data, intro, what) {
    pkgs <- skel_message(data, what)
    intro <- crayon::red(intro)
    message(intro, pkgs)
}
