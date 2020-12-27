
update_values <- function(id_prefix = "prediction_", forecast, 
                          num_horizons, session) {
  
  # turn latent values into values that are actually stored
  forecast$median <- forecast$median_latent
  forecast$width <- forecast$width_latent
  
  lapply(1:num_horizons,
         FUN = function(i) {
           # update numeric inputs. this could be necessary if we update the baseline
           updateNumericInput(inputId = paste0(id_prefix, i, "-median"),
                              session = session,
                              value = forecast$median[i])
           
           updateNumericInput(inputId = paste0(id_prefix, i, "-width"),
                              session = session,
                              value = forecast$width[i])
         })
}

# for (i in steps) {
#   
#   # rv[[paste0("forecasts_week_", i)]] <<- qlnorm(quantile_grid, 
#   #                                               meanlog = log(rv$median[i]), 
#   #                                               sdlog = as.numeric(rv$width[i]))
#   
#   if (input$distribution == "log-normal") {
#     rv[[paste0("forecasts_week_", i)]] <<- exp(qnorm(quantile_grid, 
#                                                      mean = log(rv$median[i]),
#                                                      sd = as.numeric(rv$width[i])))
#   } else if (input$distribution == "normal") {
#     rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
#                                                   mean = (rv$median[i]),
#                                                   sd = as.numeric(rv$width[i])))
#     
#   } else if (input$distribution == "cubic-normal") {
#     rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
#                                                   mean = (rv$median[i]) ^ (1 / 3),
#                                                   sd = as.numeric(rv$width[i]))) ^ 3
#   } else if (input$distribution == "fifth-power-normal") {
#     rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
#                                                   mean = (rv$median[i]) ^ (1 / 5),
#                                                   sd = as.numeric(rv$width[i]))) ^ 5
#   } else if (input$distribution == "seventh-power-normal") {
#     rv[[paste0("forecasts_week_", i)]] <<- (qnorm(quantile_grid, 
#                                                   mean = (rv$median[i]) ^ (1 / 7),
#                                                   sd = as.numeric(rv$width[i]))) ^ 7
#   } 