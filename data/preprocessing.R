library(dplyr)
library(countrycode)

# Read the csv files
results <- read.csv("data/results.csv")
goalscorers <- read.csv("data/goalscorers.csv")

# Merge the two dataframes on date, home_team, away_team
# Remove any games with no known outcome
data <- results |>
  left_join(goalscorers,
            by = c("date", "home_team", "away_team")) |>
  filter(!is.na(home_score) | !is.na(away_score))

# function to get the unicode for the country flag
get_flag <- function(country_codes) {
  sapply(country_codes, function(country_code) {
    # question mark emoji
    if (is.null(country_code) || is.na(country_code)) {
      return(intToUtf8(10067))
    } else {
      intToUtf8(127397 + strtoi(charToRaw(toupper(country_code)), 16L))
    }
  }) |>
    as.vector()
}

data <-
  data |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("home_team" = "country.name.en")) |>
  mutate(country_flag_home = get_flag(iso2c)) |>
  select(-iso2c) |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("away_team" = "country.name.en")) |>
  mutate(country_flag_away = get_flag(iso2c)) |>
  select(-iso2c)

saveRDS(data, "data/.rds")
