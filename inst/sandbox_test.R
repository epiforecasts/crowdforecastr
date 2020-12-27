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

run_app(data = obs_filt)


