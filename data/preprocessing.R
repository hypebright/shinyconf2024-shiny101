library(dplyr)
library(countrycode)

# Read the csv files
results <- read.csv("data/results.csv")
goalscorers <- read.csv("data/goalscorers.csv")

# Merge the two dataframes on date, home_team, away_team
# Remove any games with no known outcome
data_scorers <- results |>
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

data_scorers <-
  data_scorers |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("home_team" = "country.name.en")) |>
  mutate(country_flag_home = get_flag(iso2c)) |>
  select(-iso2c) |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("away_team" = "country.name.en")) |>
  mutate(country_flag_away = get_flag(iso2c)) |>
  select(-iso2c) |>
  group_by(scorer, team) |>
  summarise(goals = sum(ifelse(team == home_team, home_score, away_score)),
            penalties = sum(penalty),
            country_flag = first(ifelse(team == home_team, country_flag_home, country_flag_away))) |>
  arrange(desc(goals))


data_matches <- results |>
  filter(!is.na(home_score) | !is.na(away_score)) |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("home_team" = "country.name.en")) |>
  mutate(country_flag_home = get_flag(iso2c)) |>
  select(-iso2c) |>
  left_join(select(countrycode::codelist, c(country.name.en, iso2c)),
            by = c("away_team" = "country.name.en")) |>
  mutate(country_flag_away = get_flag(iso2c)) |>
  select(-iso2c)

# construct country rank
# Get the number of matches played by each country
# Get the number of goals scored by each country
# Both when the country when was in the home_team and away_team
country_rank <- data_matches |>
  group_by(home_team) |>
  summarise(
    country = first(home_team),
    matches = n(),
    goals = sum(home_score),
    country_flag = first(country_flag_home)
  ) |>
  bind_rows(
    data_matches |>
      group_by(away_team) |>
      summarise(
        country = first(away_team),
        matches = n(),
        goals = sum(away_score),
        country_flag = first(country_flag_away)
      )
  ) |>
  group_by(country) |>
  summarise(
    matches = sum(matches),
    goals = sum(goals),
    country_flag = first(country_flag)
  ) |>
  arrange(desc(goals))

saveRDS(data_scorers, "data/soccer_scorers.rds")
saveRDS(data_matches, "data/soccer_matches.rds")
saveRDS(country_rank, "data/country_rank.rds")
