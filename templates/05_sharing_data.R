library(shiny)
library(bslib)
library(DT)

custom_theme <- bs_theme(
  version = 5,
  bootswatch = "quartz",
  base_font = font_google("PT Sans")
)

# module 1 -------------------------------------------------------
numberAnalysisModUI <- function(id) {
  ns <- NS(id)
  dataTableOutput(outputId = ns("table"))
}

numberAnalysisServer <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    # display table of squares and highlight the number
    output$table <- renderDataTable({
      req(r$number > 0)
      squares <- 1:(r$number + 5)
      squares <- data.frame(number = squares, square = squares^2)
      datatable(squares, rownames = FALSE, selection = "none") |>
        formatStyle(columns = "number",
                    target = "row",
                    border = styleEqual(r$number, "3px"))
    }) |> bindEvent(r$button)
  })
}

# module 2 -------------------------------------------------------
numberModUI <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(inputId = ns("number"),
                 label = "Enter a number",
                 value = 0),
    actionButton(inputId = ns("button"),
                 label = "Calculate"),
    textOutput(outputId = ns("text")),
    numberAnalysisModUI(ns("analysis"))
  )
}

numberModServer <- function(id, r) {
  moduleServer(id, function(input, output, session) {

    output$text <- renderText({
      input$number^2
    }) |> bindEvent(input$button)

    observe({
      r$number <- input$number
      r$button <- input$button
    })

    numberAnalysisServer("analysis", r = r)

  })
}

# app ------------------------------------------------------------
ui <- page_navbar(
  theme = custom_theme,
  title = "Modular App Blueprint",
  nav_panel(
    title = "Numbers",
    numberModUI("numbers")
  )
)

server <- function(input, output, session) {

  r <- reactiveValues(number = NULL)

  numberModServer("numbers", r = r)
}

shinyApp(ui, server)
