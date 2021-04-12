library(magrittr)
library(crowdforecastr)
library(shinyjs)

deaths_inc <- data.table::fread("../covid-german-forecasts/data-raw/daily-incidence-deaths.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "deaths")

cases_inc <- data.table::fread("../covid-german-forecasts/data-raw/daily-incidence-cases.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "cases")

observations <- dplyr::bind_rows(deaths_inc,
                                 cases_inc)  %>%
  dplyr::filter(location_name %in% c("Germany", "Poland")) %>%
  # this has to be treated with care depending on when you update the data
  dplyr::rename(target_type = type, 
                target_end_date = date) %>%
  dplyr::arrange(location, target_type, target_end_date)

obs_filt <- observations


run_app(data = obs_filt, 
        google_account_mail = "epiforecasts@gmail.com", 
        selection_vars = c("location_name", "target_type"),
        path_service_account_json = "../covid-german-forecasts/crowd-forecast/.secrets/crowd-forecast-app-c98ca2164f6c-service-account-token.json",
        forecast_sheet_id = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",#"1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI",
        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
        submission_date = "2020-01-11")



