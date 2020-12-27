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
                          value = 10)), 
      column(4, 
             numericInput(inputId = ns("width"),
                          label = paste0("Width ", horizon),
                          value = 10)), 
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
      if (input$select_baseline == "zero baseline") {
        forecast$median_latent <- zero_baseline(observations, num_horizons)
      }
      if (input$select_baseline == "constant baseline") {
        forecast$median_latent <- constant_baseline(observations, num_horizons,
                                                    view_options, selection_vars)
      }
      update_values(id_prefix = "prediction_", forecast = forecast,
                    num_horizons = num_horizons, session = session)
    }, ignoreNULL = FALSE)


    observeEvent(input$update, {
      
      # turn latent values into values that are actually stored
      # this should also automatically update any numeric inputs
      # forecast$median <- forecast$median_latent
      # forecast$width <- forecast$width_latent
      
      update_values(id_prefix = "prediction_", forecast = forecast,
                    num_horizons = num_horizons, session = session)
    }, ignoreNULL = FALSE)
    
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
      shinyjs::hideElement(id = "copy")
    }
    
    observeEvent(forecast$median, {
      updateNumericInput(session = session, inputId = "median",
                         value = forecast$median[horizon])
    })

    observeEvent(input$median, {
      forecast$median_latent[horizon] <- input$median
    })

    observeEvent(input$width, {
      forecast$median_latent[horizon] <- input$width
    })
  })
}
