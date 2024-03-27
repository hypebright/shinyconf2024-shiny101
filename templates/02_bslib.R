library(shiny)
library(bslib)

custom_theme <- bs_theme(
  version = 5,
  bg = "#F9F9F9",
  fg = "#003f5c",
  primary = "#bc5090",
  secondary = "#58508d",
  warning = "#ffa600",
  danger = "#ff6361",
  info = "#0091d5",
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
                 label = "Click me",
                 width = "100px"),
    textOutput(outputId = "text")
  )
)

server <- function(input, output, session) {
  output$text <- renderText({
    input$number^2
  }) |> bindEvent(input$button)
}

shinyApp(ui, server)
