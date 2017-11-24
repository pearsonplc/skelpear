#' Create a new ENR project.
#'
#' This function will create all of the scaffolding for a new ENR project.
#' It will set up all of the relevant directories and their initial
#' contents.
#'
#' @export
#' @param project_name A character vector containing the name for this new
#'   project. Must be a valid directory name for your file system.
#' @param path A path where you want to store your new project.
#'
#' @examples
#'
#' \dontrun{project_create('new_enr_project', path = "/"}
#'

project_create <- function(project_name = 'enr_project', path){

  whole_path <- file.path(path, project_name)

  if (is_dir(whole_path)) {
    create_enr_project_existing(project_name, whole_path)
  } else
    create_enr_project_new(project_name, whole_path)

}

create_enr_project_existing <- function(project_name, path) {

  template_path <- system.file('project_skeleton/', package = 'skelpear')
  template_files <- list_files_and_dirs(path = template_path)

  project_path <- file.path(path)

  file.copy(file.path(template_path, template_files),
            project_path,
            recursive = TRUE, overwrite = FALSE)

  create_rproj(project_name, path)

  # packrat::init(project = normalizePath(path, winslash = "/", mustWork = TRUE))

  message(paste0("New directory ", path, " has been created."))
}

create_enr_project_new <- function(project_name, path) {

  dir.create(path)
  tryCatch(
    create_enr_project_existing(project_name = project_name, path = path),
    error = function(e) {
      unlink(path, recursive = TRUE)
      stop(e)
    }
  )
}

create_rproj <- function(project_name, path) {
  path <- file.path(path, paste0(project_name, ".Rproj"))
  template_path <- system.file("templates/template.Rproj",
                               package = "devtools")

  invisible(file.copy(template_path, path))

}

list_files_and_dirs <- function(path) {
  files <- list.files(path = path, all.files = TRUE, include.dirs = TRUE)
  files <- grep("^[.][.]?$", files, value = TRUE, invert = TRUE)
  files
}

is_dir <- function(project_name) {
  file.exists(project_name) && file.info(project_name)$isdir
}

