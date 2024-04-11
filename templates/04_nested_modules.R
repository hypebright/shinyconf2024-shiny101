library(shiny)
library(bslib)
library(DT)

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

# module 1 -------------------------------------------------------
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

numberModServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$text <- renderText({
      input$number^2
    }) |> bindEvent(input$button)

    numberAnalysisServer("analysis")

  })
}

# module 2 -------------------------------------------------------
numberAnalysisModUI <- function(id) {
  ns <- NS(id)
  dataTableOutput(outputId = ns("table"))
}

numberAnalysisServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # display table of squares and highlight the number
    output$table <- renderDataTable({
      squares <- 1:10
      squares <- data.frame(number = squares, square = squares^2)
      datatable(squares, rownames = FALSE)
    })
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
  numberModServer("numbers")
}

shinyApp(ui, server)
