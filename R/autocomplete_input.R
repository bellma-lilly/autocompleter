#' @title Creates an autocomplete text input field
#'
#' @description autocomplete_input creates an autocomplete text input field,
#' showing all possible options from a given list under the input while typing.
#' Alternative to very slow select(ize) inputs for (very) large option lists.
#'
#' @param id id of the element
#' @param label label to show for the input, NULL for no label
#' @param options list (or vector) of possible options
#' @param value initial value
#' @param width optional, the width of the input, see
#' \code{\link{validateCssUnit}}
#' @param placeholder optional character specifying the placeholder text
#' @param max_options optional numeric specifying the maximum number of
#' options to show (for performance reasons)
#' @param hide_values optional boolean indicating whether to show values
#' under labels or not
#' @param create optional boolean to enable entering values not in the list
#' @param mode what autocomplete mode to use:
#'  default: autocomplete at word breaks
#'  startswith: autocomplete only at the start of the word
#'  brackets: autocomplete within brackets
#' @return autocomplete_input: shiny input element
#'
#' @export
#' @author richard.kunze
#' @examples ## Only run examples in interactive R sessions
#' if (interactive()) {
#'
#' library(shiny)
#' opts <- sapply(1:100000, function(i) paste0(sample(letters, 9), collapse=""))
#' shinyApp(
#'   ui = fluidPage(
#'     fluidRow(
#'       column(3,
#'         autocomplete_input("auto1", "Unnamed:", opts, create = TRUE),
#'         autocomplete_input("auto2", "Named:", max_options = 500,
#'           structure(opts, names = opts[order(opts)]), mode = "default"),
#'         autocomplete_input("auto3", "Big data:", NULL, max_options = 1000,
#'           placeholder = "Big data taking several seconds to load ..."),
#'         actionButton("calc", "Calculate")
#'       ), column(3,
#'         tags$label("Value:"), verbatimTextOutput("val1", placeholder = TRUE),
#'         tags$label("Value:"), verbatimTextOutput("val2", placeholder = TRUE)
#'        )
#'     )
#'   ),
#'   server = function(input, output, session) {
#'     output$val1 <- renderText(as.character(input$auto1))
#'     output$val2 <- renderText(as.character(input$auto2))
#'     observeEvent(input$calc, {
#'       Sys.sleep(3)
#'       update_autocomplete_input(session, "auto3", placeholder = "Loaded!",
#'         options = rownames(mtcars))
#'     })
#'   }
#' )
#'
#' }
autocomplete_input <- function(
  id, label, options, value = "", width = NULL, placeholder = NULL,
  max_options = 0, hide_values = FALSE, create = FALSE, mode = "default"
) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is needed to convert list of options into json!")
  }
  value <- shiny::restoreInput(id = id, default = value)
  js_opts <- jsonlite::toJSON(as.list(options), auto_unbox = TRUE)
  width <- shiny::validateCssUnit(width)
  if (length(value) == 0L) value <- ""
  shiny::tagList(
    shiny::singleton(shiny::tags$head(
      initResourcePaths(),
      tags$link(rel = "stylesheet", type = "text/css", href = "autocompleter/css/autocomplete.css"),
      tags$script(src="autocompleter/js/autocomplete-binding.js")
    )),
    shiny::div(
      class = "form-group shiny-input-container autocomplete",
      style = if (!is.null(width)) paste0("width: ", width, ";"),
      if (!is.null(label)) shiny::tags$label(label, `for` = id),
      shiny::tags$input(
        id = id, type = "text", class = "form-control", result = value,
        value = value, placeholder = placeholder, "data-options" = js_opts,
        "data-max" = max_options, "data-mode" = mode,
        "data-hide" = logical_js(hide_values), "data-create" = logical_js(create),
        autocomplete = "off"
      )
    )
  )
}

#' @description update_autocomplete_input changes the value or the options of an
#' autocomplete input element on the client side.
#'
#' @param session the shiny session object
#'
#' @return update_autocomplete_input: message to the client
#' @export
#' @rdname autocomplete_input
update_autocomplete_input <- function(
  session, id, label = NULL, options = NULL, max_options = NULL, value = NULL,
  placeholder = NULL, hide_values = NULL, create = NULL, mode = NULL
) {
  message <- not_null(list(
    label = label, options = options, value = value, max = max_options,
    placeholder = placeholder, hide = hide_values, create = create,
    mode = mode
  ))
  session$sendInputMessage(id, message)
}

logical_js <- function(b) {
  tolower(isTRUE(b))
}
not_null <- function(vec) {
  vec[vapply(vec, length, 0L) > 0L]
}
