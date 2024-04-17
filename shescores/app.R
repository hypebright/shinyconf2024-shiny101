# global ------------------------------------------------
library(shiny)
library(bslib)
library(shinyWidgets)
library(lubridate)
library(dplyr)
library(echarts4r)
library(DT)

custom_theme <- bs_theme(
  version = 5,
  # or any other theme that you want
  bootswatch = "quartz",
  base_font = font_google("PT Sans")
)

# set font for echarts
e_common(
  font_family = "PT Sans",
  theme = NULL
)

# read in data
# note that for demo purposes this is in a top-level folder
# normally, you would have this inside the folder that contains app.R
soccer_scorers <- readRDS("../data/soccer_scorers.rds")
soccer_matches <- readRDS("../data/soccer_matches.rds")
soccer_rank <- readRDS("../data/country_rank.rds")

# options for in pickerInput
available_countries <- sort(unique(soccer_matches$home_team))

available_countries <- setNames(available_countries,
                                sort(unique(paste(soccer_matches$home_team, soccer_matches$country_flag_home))))

# country page module ------------------------------------
countryPageUI <- function(id, page_name) {
  ns <- NS(id)
  tagList(
    h2(page_name),
    prettyCheckbox(
      inputId = ns("favourite"),
      label = "This is my favourite",
      value = FALSE,
      status = "warning",
      icon = icon("star"),
      plain = TRUE,
      outline = TRUE
    ),
    card(
      min_height = "700px",
      card_header("General Info"),
      card_body(
        textOutput(ns("general_info")),
        DTOutput(ns("matches_table"))
      )
    )
  )
}

countryPageServer <- function(id, chosen_country, r) {
  moduleServer(id, function(input, output, session) {

    this_soccer_matches <- reactive({
      soccer_matches |>
        filter(home_team == chosen_country | away_team == chosen_country) |>
        arrange(desc(date))
    })

    output$general_info <- renderText({
      sprintf("%s has played %s matches in total. The first match was on %s and the last match was on %s.",
              chosen_country,
              nrow(this_soccer_matches()),
              min(this_soccer_matches()$date),
              max(this_soccer_matches()$date)
      )
    })

    output$matches_table <- renderDT({
      this_soccer_matches() |>
        select(date, home_team, away_team, home_score, away_score, tournament) |>
        datatable()
    })

    observe({

      req(!is.null(input$favourite))

      current_favourites <- isolate(r$favourites)

      if (input$favourite) {
        r$favourites <- c(current_favourites, chosen_country)
      } else {
        r$favourites <- current_favourites[current_favourites != chosen_country]
      }
    })

  })
}

# main app -----------------------------------------------
ui <- page_navbar(
  theme = custom_theme,
  title = "She Scores ⚽️: Women's International Soccer Matches",
  id = "navbar_id",
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
               inputId = "countries",
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
             ),
             textOutput("favourites")
           )
  )
)

server <- function(input, output, session) {

  r <- reactiveValues(active_pages = NULL,
                      favourites = NULL)

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

  observe({

    chosen_countries <- input$countries

    lapply(chosen_countries, function(this_country) {

      if (this_country %in% r$active_pages) {
        # the country already has a page, and is chosen by the user, so don't do anything
        return()
      }

      nav_insert(id = "navbar_id",
                 target = "Set-up",
                 nav = nav_panel(
                   title = this_country,
                   countryPageUI(id = this_country, page_name = this_country)
                 ),
                 position = "after")

      countryPageServer(id = this_country,
                        chosen_country = this_country,
                        r = r)

    })

    if (setdiff(r$active_pages, chosen_countries) |> length() > 0) {

      remove_countries <- setdiff(r$active_pages, chosen_countries)

      for (country in remove_countries) {
        nav_remove(id = "navbar_id",
                   target = country)

      }

    }

    r$active_pages <- chosen_countries

  }) |> bindEvent(input$pages)

  output$favourites <- renderText({
    if (is.null(r$favourites)) {
      "You have not selected any favourites yet."
    } else {
      sprintf("Your favourite countries are: %s",
              paste(r$favourites, collapse = ", "))
    }
  })

}

shinyApp(ui, server)
