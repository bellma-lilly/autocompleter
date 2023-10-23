.global <- new.env()

initResourcePaths <- function() {
  if (is.null(.global$loaded)) {
    shiny::addResourcePath(
      prefix = 'autocompleter',
      directoryPath = system.file('www', package='autocompleter'))
    .global$loaded <- TRUE
  }
  shiny::HTML("")
}

