library(shiny)
library(bslib)

custom_theme <- bs_theme(
  version = 5,
  bootswatch = "quartz",
  base_font = font_google("PT Sans")
)

ui <- page_navbar(
  theme = custom_theme,
  title = "Modular App Blueprint",
  nav_panel(
    title = "Numbers",
    numericInput(inputId = "number",
                 label = "Enter a number",
                 value = 0),
    actionButton(inputId = "button",
                 label = "Calculate"),
    textOutput(outputId = "text")
  )
)

server <- function(input, output, session) {
  output$text <- renderText({
    input$number^2
  }) |> bindEvent(input$button)
}

shinyApp(ui, server)
