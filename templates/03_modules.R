library(shiny)

numberModUI <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(inputId = ns("number"),
                 label = "Enter a number",
                 value = 0),
    actionButton(inputId = ns("button"),
                 label = "Click me"),
    textOutput(outputId = ns("text"))
  )
}

numberModServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$text <- renderText({
      input$number^2
    }) |> bindEvent(input$button)
  })
}

ui <- fluidPage(
  numberModUI("numbers")
)

server <- function(input, output, session) {
  numberModServer("numbers")
}

shinyApp(ui, server)
