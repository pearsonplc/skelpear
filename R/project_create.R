#' Create a new ENR project.
#'
#' This function will create all of the scaffolding for a new ENR project.
#' It will set up all of the relevant directories and their initial
#' contents.
#'
#' @export
#' @param name A project name. Must be a valid directory name for your file system.
#' @param path A path where you want to store your new project.
#'
#' @examples
#'
#' \dontrun{project_create(name = "new_enr_project", path = "/"}
#'

project_create <- function(name = 'enr_project', path = "."){

  whole_path <- file.path(path, name)

  if (is_dir(whole_path)) {
    create_enr_project_existing(name, whole_path)
  } else
    create_enr_project_new(name, whole_path)

}

create_enr_project_existing <- function(name, path) {

  template_path <- system.file('project_skeleton/', package = 'skelpear')
  template_files <- list_files_and_dirs(path = template_path)

  project_path <- file.path(path)

  file.copy(file.path(template_path, template_files),
            project_path,
            recursive = TRUE, overwrite = FALSE)

  git2r::init(path)

  create_rproj(name, path)
}

create_enr_project_new <- function(name, path) {

  dir.create(path)
  tryCatch(
    create_enr_project_existing(name = name, path = path),
    error = function(e) {
      unlink(path, recursive = TRUE)
      stop(e)
    }
  )
}

create_rproj <- function(name, path) {
  path <- file.path(path, paste0(name, ".Rproj"))
  template_path <- system.file("templates/template.Rproj",
                               package = "devtools")

  invisible(file.copy(template_path, path))

  rstudioapi::openProject(path)
}

list_files_and_dirs <- function(path) {
  files <- list.files(path = path, all.files = TRUE, include.dirs = TRUE)
  files <- grep("^[.][.]?$", files, value = TRUE, invert = TRUE)
  files
}

is_dir <- function(project_name) {
  file.exists(project_name) && file.info(project_name)$isdir
}

