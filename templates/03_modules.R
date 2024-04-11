library(shiny)
library(bslib)

custom_theme <- bs_theme(
  version = 5,
  # for themes see: https://bootswatch.com
  preset = "quartz",
  base_font = font_google("PT Sans"),
  bg = NULL,
  fg = NULL,
  primary = NULL,
  secondary = NULL,
  success = NULL,
  info = NULL,
  warning = NULL,
  danger = NULL,
  code_font = NULL,
  heading_font = NULL,
  font_scale = NULL
)

numberModUI <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(inputId = ns("number"),
                 label = "Enter a number",
                 value = 0),
    actionButton(inputId = ns("button"),
                 label = "Calculate"),
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

ui <- page_navbar(
  theme = custom_theme,
  title = "Modular App Blueprint",
  nav_panel(
    title = "Numbers",
    numberModUI("numbers")
  )
)

server <- function(input, output, session) {
  numberModServer("numbers")
}

shinyApp(ui, server)
