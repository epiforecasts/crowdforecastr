# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options( "golem.app.prod" = TRUE)

obs_filt <- data.table::fread("external_ressources/observations.csv")  %>%
  dplyr::mutate(target_end_date = as.Date(target_end_date)) %>%
  dplyr::arrange(location, target_type, target_end_date) 

crowdforecastr::run_app(data = obs_filt, 
                        first_forecast_date = "2021-01-23",
                        selection_vars = c("location_name", "target_type"),
                        google_account_mail = "epiforecasts@gmail.com", 
                        forecast_sheet_id = "1nOy3BfHoIKCHD4dfOtJaz4QMxbuhmEvsWzsrSMx_grI",
                        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
                        submission_date = "2021-01-18")


