
# autocompleter
Text Input Autocompletion

``` r
library(shiny)
library(autocompleter)
shinyApp(
  ui = fluidPage(
    div("Default mode mmatches at word breaks."),
    autocomplete_input("auto1", "default (dog/cat):", c("dog","cat")),
    div("Startswith matches at the beginning only."),
    autocomplete_input("auto2", "startswith (dog/cat):", c("dog","cat"),mode="startswith"),
    div("brackets matches inside {brackets}"),
    autocomplete_input("auto3", "brackets (dog/cat):", c("dog","cat"),mode="brackets"),
    actionButton("switch","Switch to apple,banana")
  ),
  server = function(input, output, session) {
    observeEvent(input$switch, {
      update_autocomplete_input(session,"auto1", "default (apple/banana):", c("apple","banana"))
      update_autocomplete_input(session,"auto2", "startswith (apple/banana):", c("apple","banana"),mode="startswith")
      update_autocomplete_input(session,"auto3", "brackets (apple/banana):", c("apple","banana"),mode="brackets")
    })
  }
)
```

