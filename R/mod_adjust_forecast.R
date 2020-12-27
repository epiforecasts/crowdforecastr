#' adjust_forecast UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_adjust_forecast_ui <- function(id, num_horizons = 4){
  ns <- NS(id)
  tagList(
    
    
    fluidRow(column(8,
                    selectInput(inputId = ns("select_baseline"),
                                label = "Choose baseline forecast",
                                choices = c("zero baseline", "constant baseline",
                                            "log-linear baseline"), 
                                selected = "constant baseline")),
             column(4,
                    actionButton(inputId = ns("apply_baseline"),
                                 label = "Apply",
                                 style = 'margin-top: 25px'))
             ),

    selectInput(inputId = ns("distribution"),
                label = "Select distribution",
                choices = c("log-normal",
                            "normal",
                            "cubic-normal",
                            "fifth-power-normal",
                            "seventh-power-normal"),
                selected = "log-normal"),
    
    lapply(1:num_horizons,
           FUN = function(i) {
             mod_adjust_forecast_enter_values_ui(id = ns(paste0("prediction_", i)),
                                                 horizon = i)
           }),
    br(),

    fluidRow(column(8,
                    actionButton(inputId = ns("update"),
                                 label = HTML("<b>Update</b>"))),
             column(4,
                    actionButton(inputId = ns("submit"),
                                 label = "Submit")))
  )
}




mod_adjust_forecast_enter_values_ui <- function(id, horizon){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(4, 
             numericInput(inputId = ns("median"),
                          label = paste0("Median ", horizon),
                          value = NA)), 
      column(4, 
             numericInput(inputId = ns("width"),
                          label = paste0("Width ", horizon),
                          value = NA)), 
      column(4, 
             actionButton(inputId = ns("copy"),
                          label = "Copy above",
                          style = 'margin-top: 25px')
      )
             
    )
  )
}
    


#' adjust_forecast Server Functions
#'
#' @noRd 
mod_adjust_forecast_server <- function(id, num_horizons, observations, forecast, 
                                       forecast_quantiles,
                                       view_options, selection_vars, baseline){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    lapply(1:num_horizons,
           FUN = function(i) {
             mod_adjust_forecast_enter_values_server(id = paste0("prediction_", i),
                                                     horizon = i,
                                                     forecast = forecast)
           })

    observeEvent(input$select_baseline, {
      baseline <- input$select_baseline
    })

    observeEvent(input$apply_baseline, {
      
      filtered_observations <-     filtered <- filter_data_util(data = observations, 
                                                                view_options, 
                                                                selection_vars)
      
      baseline <- baseline_forecast(baseline = input$select_baseline, 
                                    filtered_observations = filtered_observations, 
                                    num_horizons = num_horizons)
      
      forecast$median_latent <- baseline$median
      forecast$width_latent <- baseline$width
      
      # if (input$select_baseline == "zero baseline") {
      #   zero_baseline(observations, num_horizons)
      # }
      # if (input$select_baseline == "constant baseline") {
      #   forecast$median_latent <- constant_baseline(observations, num_horizons,
      #                                               view_options, selection_vars)
      # }
      
      forecast$median <- forecast$median_latent
      forecast$width <- forecast$width_latent
      
      # update_values(id_prefix = "prediction_", forecast = forecast,
      #               num_horizons = num_horizons, session = session)
    }, ignoreNULL = FALSE)


    observeEvent(input$update, {
      
      # turn latent values into values that are actually stored
      # this should also automatically update any numeric inputs
      forecast$median <- forecast$median_latent
      forecast$width <- forecast$width_latent
      
      # update_values(id_prefix = "prediction_", forecast = forecast,
      #               num_horizons = num_horizons, session = session)
    }, ignoreNULL = FALSE)
    
    # whenever either median or width changes (if points are dragged or 
    # something is updated) --> upadte the stored forecasting in accordance
    # to the selected forecast distribution
    # not quite sure whether this logic should happen somewhere else?
    observeEvent(c(forecast$median, forecast$width), {
      
      # THIS IS BUSINESS LOGIC THAT SHOULD HAPPEN SOMEWHERE OUTSIDE
      
      for (horizon in 1:num_horizons) {
        if (input$distribution == "log-normal") {
          forecast[[paste0("forecasts_horizon_", horizon)]] <- exp(qnorm(forecast_quantiles,
                                                                   mean = log(forecast$median[horizon]),
                                                                   sd = as.numeric(forecast$width[horizon])))
        } else if (input$distribution == "normal") {
          forecast[[paste0("forecasts_horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[horizon]),
                                                                sd = as.numeric(forecast$width[horizon])))
          
        } else if (input$distribution == "cubic-normal") {
          forecast[[paste0("forecasts_horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[horizon]) ^ (1 / 3),
                                                                sd = as.numeric(forecast$width[horizon]))) ^ 3
        } else if (input$distribution == "fifth-power-normal") {
          forecast[[paste0("forecasts_horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[horizon]) ^ (1 / 5),
                                                                sd = as.numeric(forecast$width[horizon]))) ^ 5
        } else if (input$distribution == "seventh-power-normal") {
          forecast[[paste0("forecasts_horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[horizon]) ^ (1 / 7),
                                                                sd = as.numeric(forecast$width[horizon]))) ^ 7
        }
      }
    })
    
    
  })
}
    


#' adjust_forecast Server Functions
#' @importFrom shinyjs hideElement
#' @noRd 
mod_adjust_forecast_enter_values_server <- function(id, horizon, forecast){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    if (horizon == 1) {
      print("horizon is 1")
      shinyjs::hideElement(id = "copy", asis = FALSE)
    }
    
    # observe any changes in the median (if a point is dragged) and 
    # update the numeric inputs accordingly
    observeEvent(forecast$median, {
      updateNumericInput(session = session, inputId = "median",
                         value = forecast$median[horizon])
    })

    observeEvent(input$median, {
      forecast$median_latent[horizon] <- input$median
    })

    observeEvent(input$width, {
      forecast$width_latent[horizon] <- input$width
    })
  })
}
