library(shiny)

ui <- fluidPage(
  numericInput(inputId = "number",
               label = "Enter a number",
               value = 0),

  actionButton(inputId = "button",
               label = "Calculate"),

  textOutput(outputId = "text")
)

server <- function(input, output, session) {
  output$text <- renderText({
    input$number^2
  }) |> bindEvent(input$button)
}

shinyApp(ui, server)
