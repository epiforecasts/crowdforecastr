# download all existing forecasts to check how many forecasts there 
# already exist for each location

get_existing_forecasts <- function(
  regular_sheet = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",
  rt_sheet = "1g4OBCcDGHn_li01R8xbZ4PFNKQmV-SHSXFlv2Qv79Ks"
) {
  all_sub_reg <- googlesheets4::read_sheet(
    ss = regular_sheet, 
    sheet = "predictions"
  ) %>%
    dplyr::select(c(forecaster_id, forecast_date, 
                    forecast_time, location_name)) %>%
    dplyr::filter(forecast_date == max(forecast_date))
  
  all_sub_rt <- googlesheets4::read_sheet(
    ss = rt_sheet, 
    sheet = "predictions"
  ) %>%
    dplyr::select(c(forecaster_id, forecast_date, 
                    forecast_time, region)) %>%
    dplyr::rename(location_name = region) %>%
    dplyr::filter(forecast_date == max(forecast_date))
  
  
  all_sub <- rbind(all_sub_reg, all_sub_rt) 
  
  if (nrow(all_sub) == 0) {
    all_sub <- tibble::tibble(location = "none", 
                              "number of forecasts" = "no submissions yet")
  } else {
    all_sub <- all_sub %>%
      dplyr::group_by(forecaster_id, location_name) %>%
      dplyr::filter(forecast_time == max(forecast_time)) %>%
      unique() %>%
      dplyr::arrange(location_name) %>%
      dplyr::group_by(location_name) %>%
      dplyr::mutate(n_forecaster = dplyr::n()) %>%
      dplyr::select(location_name, n_forecaster) %>%
      unique() %>%
      dplyr::ungroup() %>%
      dplyr::mutate(index = 1:dplyr::n()) %>%
      dplyr::relocate(index) %>%
      dplyr::rename(location = location_name, 
                    "number of forecasts" = n_forecaster)
  }
  return(all_sub)
}



