library(magrittr)
library(crowdforecastr)

deaths_inc <- data.table::fread("../covid-german-forecasts/human-forecasts/data/weekly-incident-deaths.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "deaths")

cases_inc <- data.table::fread("../covid-german-forecasts/human-forecasts/data/weekly-incident-cases.csv") %>%
  dplyr::mutate(inc = "incident",
                type = "cases")

observations <- dplyr::bind_rows(deaths_inc,
                                 cases_inc)  %>%
  # this has to be treated with care depending on when you update the data
  dplyr::filter(epiweek <= max(epiweek)) %>%
  dplyr::rename(target_type = type)

obs_filt <- observations

data.table::fwrite(x = obs_filt, file = "external_ressources/observations.csv")
obs_filt <- data.table::fread("external_ressources/observations.csv")

obs_filt <- data.table::fread("external_ressources/observations.csv")  %>%
  dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
  dplyr::arrange(location, target_type, target_end_date) 


run_app(data = obs_filt, 
        google_account_mail = "epiforecasts@gmail.com", 
        forecast_sheet_id = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",#"1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI",
        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
        submission_date = "2020-01-11")



