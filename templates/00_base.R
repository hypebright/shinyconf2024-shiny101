library(shiny)

ui <- fluidPage(
  numericInput(inputId = "number",
               label = "Enter a number",
               value = 0),

  textOutput(outputId = "text")
)

server <- function(input, output, session) {
  output$text <- renderText({
    input$number^2
  })
}

shinyApp(ui, server)
