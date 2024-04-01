library(shiny)
library(DT)

numberAnalysisModUI <- function(id) {
  ns <- NS(id)
  dataTableOutput(outputId = ns("table"))
}

numberAnalysisServer <- function(id, number) {
  moduleServer(id, function(input, output, session) {
    # display table of squares and highlight the number
    output$table <- renderDataTable({
      req(number() > 0)
      squares <- 1:(number() + 5)
      squares <- data.frame(number = squares, square = squares^2)
      datatable(squares, rownames = FALSE) |>
        formatStyle(columns = "number",
                    target = "row",
                    backgroundColor = styleEqual(number(), "pink"))
    })
  })
}

numberModUI <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(inputId = ns("number"),
                 label = "Enter a number",
                 value = 0),
    actionButton(inputId = ns("button"),
                 label = "Click me"),
    textOutput(outputId = ns("text")),
    numberAnalysisModUI(ns("analysis"))
  )
}

numberModServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$text <- renderText({
      input$number^2
    }) |> bindEvent(input$button)

    number <- reactive(input$number) |>
      bindEvent(input$button)

    numberAnalysisServer("analysis", number)

  })
}

ui <- fluidPage(
  numberModUI("numbers")
)

server <- function(input, output, session) {
  numberModServer("numbers")
}

shinyApp(ui, server)
