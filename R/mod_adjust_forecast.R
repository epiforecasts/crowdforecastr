#' adjust_forecast UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#' @importFrom shinyjs useShinyjs
#' @importFrom shiny NS tagList 
mod_adjust_forecast_ui <- function(id, num_horizons = 4){
  ns <- NS(id)
  
  tagList(
    shinyjs::useShinyjs(),  
    
    fluidRow(column(8,
                    selectInput(inputId = ns("select_baseline"),
                                label = "Choose baseline forecast",
                                choices = c("zero baseline", "constant baseline"),
                                           # "log-linear baseline"), 
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
                selected = golem::get_golem_options("default_distribution")),
    
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
                                 label = HTML("<b>Submit</b>"))))
  )
}




mod_adjust_forecast_enter_values_ui <- function(id, horizon){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(4, 
             numericInput(inputId = ns("median"),
                          min = 0,
                          label = paste0("Median ", horizon),
                          step = 50,
                          value = NA)), 
      column(4, 
             numericInput(inputId = ns("width"),
                          min = 0,
                          label = paste0("Width ", horizon),
                          step = 0.01,
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
                                       forecast_quantiles, user_management,
                                       view_options, selection_vars, baseline, 
                                       submitted){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    lapply(1:num_horizons,
           FUN = function(i) {
             mod_adjust_forecast_enter_values_server(id = paste0("prediction_", i),
                                                     horizon = i,
                                                     forecast = forecast)
           })

    observeEvent(input$distribution, {
      forecast$distribution <- input$distribution
    })

    observeEvent(input$apply_baseline, {
      selection_id <- forecast$selected_combination
      filtered_observations <- filter_data_util(data = observations, 
                                                view_options, 
                                                selection_vars)
      
      baseline <- baseline_forecast(baseline = input$select_baseline, 
                                    filtered_observations = filtered_observations, 
                                    num_horizons = num_horizons)
      
      forecast$median_latent[[selection_id]] <- baseline$median
      forecast$width_latent[[selection_id]] <- baseline$width
      forecast$median[[selection_id]] <- forecast$median_latent[[selection_id]]
      forecast$width[[selection_id]] <- forecast$width_latent[[selection_id]]
      # this works
    }, ignoreNULL = FALSE)


    observeEvent(input$update, {
      selection_id <- forecast$selected_combination
      # turn latent values into values that are actually stored
      # this should also trigger an automatic update of any numeric inputs
      forecast$distribution <- input$distribution
      forecast$median[[selection_id]] <- forecast$median_latent[[selection_id]]
      forecast$width[[selection_id]] <- forecast$width_latent[[selection_id]]
      # this works
    }, ignoreNULL = FALSE)
    
    # whenever either median or width changes (if points are dragged or 
    # something is updated) --> upadte the stored forecasting in accordance
    # to the selected forecast distribution
    # not quite sure whether this logic should happen somewhere else?
    observeEvent(c(forecast$median, forecast$width, input$distribution, forecast$selected_combination), {
      selection_id <- forecast$selected_combination
      # THIS IS BUSINESS LOGIC THAT SHOULD HAPPEN SOMEWHERE OUTSIDE
      for (horizon in 1:num_horizons) {
        
        if (input$distribution == "log-normal") {
          forecast[[selection_id]][[paste0("horizon_", horizon)]] <- exp(qnorm(forecast_quantiles,
                                                                   mean = log(forecast$median[[selection_id]][horizon]),
                                                                   sd = as.numeric(forecast$width[[selection_id]][horizon])))
        } else if (input$distribution == "normal") {
          forecast[[selection_id]][[paste0("horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[[selection_id]][horizon]),
                                                                sd = as.numeric(forecast$width[[selection_id]][horizon])))
          
        } else if (input$distribution == "cubic-normal") {
          forecast[[selection_id]][[paste0("horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[[selection_id]][horizon]) ^ (1 / 3),
                                                                sd = as.numeric(forecast$width[[selection_id]][horizon]))) ^ 3
        } else if (input$distribution == "fifth-power-normal") {
          forecast[[selection_id]][[paste0("horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[[selection_id]][horizon]) ^ (1 / 5),
                                                                sd = as.numeric(forecast$width[[selection_id]][horizon]))) ^ 5
        } else if (input$distribution == "seventh-power-normal") {
          forecast[[selection_id]][[paste0("horizon_", horizon)]] <- (qnorm(forecast_quantiles,
                                                                mean = (forecast$median[[selection_id]][horizon]) ^ (1 / 7),
                                                                sd = as.numeric(forecast$width[[selection_id]][horizon]))) ^ 7
        }
        # this works
      }
    })
    
    
    observeEvent(c(input$submit),
                 {
                   selection_id <- forecast$selected_combination
                   # error handling
                   # expand this at some point to handle both conditions
                   if (!is.na(forecast$median[[selection_id]]) && 
                       all(forecast$median[[selection_id]] == forecast$median_latent[[selection_id]]) && 
                       all(forecast$width[[selection_id]] == forecast$width_latent[[selection_id]])) {
                     mismatch <- FALSE
                   } else {
                     mismatch <- TRUE
                   }
                   
                   if (mismatch) {
                     showNotification("Your forecasts don't match your inputs yet. Please press 'update' for all changes to take effect and submit again.", type = "error")
                   } else if (golem::get_golem_options("force_increasing_uncertainty") && any(diff(forecast$width[[selection_id]]) <= 0)) {
                     showNotification("Your uncertainty should be increasing over time. Please increase the width parameter for later forecast dates.", type = "error")
                     }
                   else {
                     # collect data in submission sheet
                     current_user_data <- user_management$current_user_data
                     submissions <- data.frame(forecaster_id = current_user_data$forecaster_id, 
                                               forecast_date = Sys.Date(),
                                               forecast_time = Sys.time(),
                                               expert = current_user_data$expert,
                                               leader_board = current_user_data$appearboard,
                                               name_board = current_user_data$board_name,
                                               distribution = forecast$distribution,
                                               median = forecast$median[[selection_id]],
                                               width = forecast$width[[selection_id]],
                                               horizon = 1:golem::get_golem_options("horizons"),
                                               target_end_date = forecast$x,
                                               submission_date = as.Date(golem::get_golem_options("submission_date")))
                     
                     # add information about selection variables to submission sheet
                     for (selection_var in selection_vars) {
                       submissions[[selection_var]] <- forecast[[selection_var]]
                     }

                     # append data to google sheet
                     try_and_wait(
                       googlesheets4::sheet_append(data = submissions,
                                                   ss = golem::get_golem_options("forecast_sheet_id")), 
                       message = "We are trying to connect to the submission data base."
                     )
                     
                     # store submission in submitted list
                     submitted$submitted_combinations <- 
                       c(submitted$submitted_combinations, forecast$selected_combination)
                  
                     # move to the next forecast
                     # go through the selection variables in a backwards order
                     n <- length(selection_vars)
                     reverse_selection <- selection_vars[n:1]
                     
                     # get the list of items the user has selected to forecast
                     user_selections <- get_selections(current_user_data)
                     
                     for (selection_var in reverse_selection) {

                       available_choices <- unique(user_selections[[selection_var]])
                       num_choices <- length(available_choices)
                       index_current_selection <- which(forecast[[selection_var]] == available_choices)
                       
                       # increment choice if we are not at the maximums
                       if (index_current_selection < num_choices) {
                         # change variable stored in forecasts. This will lead to an update in the view_options_module
                         forecast[[selection_var]] <- available_choices[index_current_selection + 1]
                         shinyalert::shinyalert(type = "success", 
                                                text = "Thank you for your submissions. Here is the next data set. Press 'apply' to apply the baseline forecast", 
                                                closeOnClickOutside = TRUE, 
                                                timer = 2500)
                         break
                       } else if (index_current_selection == num_choices) {
                         # if the last choice was selected, change back to the first choice
                         forecast[[selection_var]] <- available_choices[1]
                         
                       }
                       # if we arrived at the the last iteration
                       if (selection_var == selection_vars[1]) {
                         shinyalert::shinyalert(type = "success", 
                                                title = "All submissions completed",
                                                text = "Thank you for your submissions. If you completed all previous locations, you are done now!", 
                                                closeOnClickOutside = TRUE)
                       }
                     }
                   }
                 },
                 priority = 99,
                 ignoreInit = TRUE)

  })
}
    


#' adjust_forecast Server Functions
#' @importFrom shinyjs toggleElement
#' @noRd 
mod_adjust_forecast_enter_values_server <- function(id, horizon, forecast){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    if (horizon == 1) {
      shinyjs::hideElement(id = "copy", asis = FALSE)
    }
    
    
    # observe any changes in the median 
    # (if baseline changes or if a point is dragged) and 
    # update the numeric inputs accordingly
    observeEvent(c(forecast$median, forecast$selected_combination), {
      selection_id <- forecast$selected_combination
      updateNumericInput(session = session, inputId = "median",
                         value = forecast$median[[selection_id]][horizon])
    })
    # observe any changes in the median (if baseline is changed on startup) and
    # update the numeric inputs accordingly
    observeEvent(c(forecast$width, forecast$selected_combination), {
      selection_id <- forecast$selected_combination
      updateNumericInput(session = session, inputId = "width",
                         value = round(forecast$width[[selection_id]][horizon], 3))
    })
    
    observeEvent(input$copy, {
      selection_id <- forecast$selected_combination
      updateNumericInput(session = session, inputId = "median",
                         value = forecast$median_latent[[selection_id]][horizon - 1])
      updateNumericInput(session = session, inputId = "width",
                         value = forecast$width_latent[[selection_id]][horizon - 1])
    })

    observeEvent(input$median, {
      selection_id <- forecast$selected_combination
      forecast$median_latent[[selection_id]][horizon] <- input$median
    })

    observeEvent(input$width, {
      selection_id <- forecast$selected_combination
      forecast$width_latent[[selection_id]][horizon] <- input$width
    })
  })
}
