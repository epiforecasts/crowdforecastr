# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

pkgload::load_all(export_all = FALSE,helpers = FALSE,attach_testthat = FALSE)
options( "golem.app.prod" = TRUE)

obs_filt <- read.csv("external_ressources/observations.csv")

print(obs_filt)

crowdforecastr::run_app(data = obs_filt, 
        google_account_mail = "epiforecasts@gmail.com", 
        forecast_sheet_id = "1xdJDgZdlN7mYHJ0D0QbTcpiV9h1Dmga4jVoAg5DhaKI",
        user_data_sheet_id = "1GJ5BNcN1UfAlZSkYwgr1-AxgsVA2wtwQ9bRwZ64ZXRQ", 
        path_past_forecasts = "external_ressources/processed-forecast-data/")


