library(shiny)
library(bslib)
library(shinyWidgets)
library(lubridate)
library(dplyr)
library(echarts4r)

custom_theme <- bs_theme(
  version = 5,
  bootswatch = "quartz", # united
  base_font = font_google("PT Sans")
)

e_common(
  font_family = "PT Sans",
  theme = NULL
)

soccer_scorers <- readRDS("../data/soccer_scorers.rds")
soccer_matches <- readRDS("../data/soccer_matches.rds")
soccer_rank <- readRDS("../data/country_rank.rds")

available_countries <- sort(unique(soccer_matches$home_team))

available_countries <- setNames(available_countries,
                                sort(unique(paste(soccer_matches$home_team, soccer_matches$country_flag_home))))

ui <- page_navbar(
  theme = custom_theme,
  title = "She Scores ⚽️: Women's International Soccer Matches",
  nav_panel(
    title = "Overview",
    fluidRow(
      column(4,
             value_box(
               title = "Top scoring country",
               value = paste(
                 head(soccer_rank$country, 1),
                 head(soccer_rank$country_flag, 1)
               )
             )),
      column(4,
             value_box(
               title = "Top scorer",
               value = paste(
                 head(soccer_scorers$scorer, 1),
                 head(soccer_scorers$country_flag, 1)
               )
             )),
      column(4,
             value_box(
               title = "Total countries",
               value = length(unique(soccer_matches$home_team))
             ))
    ),
    card(
      min_height = "600px",
      echarts4rOutput("overview")
    )
  ),
  nav_menu(title = "Countries",
           nav_panel(
             title = "Set-up",
             pickerInput(
               inputId = "country",
               label = "Select a country",
               multiple = TRUE,
               choices = available_countries,
               selected = NULL,
               options = pickerOptions(
                 actionsBox = TRUE,
                 liveSearch = TRUE,
                 liveSearchPlaceholder = "Search for a country",
                 selectedTextFormat = "count > 1",
                 countSelectedText = "{0} countries selected"
               )
             ),
             actionButton(
               inputId = "pages",
               label = "Generate pages",
               icon = icon("plus-circle"),
               width = "250px"
             )
           )
  )
)

server <- function(input, output, session) {

  output$overview <- renderEcharts4r({
    # get the number of matches over time
    soccer_matches |>
      mutate(date = as.Date(date)) |>
      group_by(date = lubridate::floor_date(date, "year")) |>
      summarise(matches = n()) |>
      e_charts(date) |>
      e_line(matches,
             lineStyle = list(
               width = 3,
               color = "#0f0437"
             )) |>
      e_title("Soccer matches over time",
              left = "40%", # somehow textAlign does not work
              textStyle = list(
                color = "white",
                fontSize = 26
              )) |>
      e_tooltip() |>
      e_legend(show = FALSE) |>
      e_x_axis(
        axisLabel = list(
          color = "white"
        )
      ) |>
      e_y_axis(
        axisLabel = list(
          color = "white"
        )
      )
  })

}

shinyApp(ui, server)
