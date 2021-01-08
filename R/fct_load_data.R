load_past_forecasts <- function(root_dir) {
  file_paths_forecast <- paste0(root_dir, list.files(root_dir))
  
  prediction_data <- purrr::map_dfr(file_paths_forecast, readr::read_csv) %>%
    dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
    dplyr::rename(prediction = value) %>%
    dplyr::mutate(forecast_date = submission_date) %>%
    dplyr::rename(model = board_name) %>%
    dplyr::filter(type == "quantile") %>%
    dplyr::select(location, location_name, forecast_date, quantile, prediction, model, target_end_date, horizon, target, target_type)
}


