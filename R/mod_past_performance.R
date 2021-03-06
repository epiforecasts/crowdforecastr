#' past_performance UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_past_performance_ui <- function(id){
  ns <- NS(id)
  tagList(
    h4("Past Performance will be coming shortly!"),
    p("For now, have a look at the performance board, epiforecasts.io/covid.german.forecasts"),
    plotOutput(ns("past_forecasts_plot"))
  )
}
    
#' past_performance Server Functions
#'
#' @noRd 
mod_past_performance_server <- function(id, user_management){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    observeEvent(user_management$past_forecasts, {
      
      if (!is.null(user_management$past_forecasts)) {
        
        
        output$past_forecasts_plot <- renderPlot({
          
          # user_forecasts <- user_management$past_forecasts %>%
          #   dplyr::filter(model == user_management$current_user_data$board_name)
          # 
          # plot <- scoringutils::plot_predictions(user_management$past_forecasts, 
          #                                        x = "target_end_date") 
          # 
          # plot
        })
        
      }
      
    })
 
  })
}
    
## To be copied in the UI
# mod_past_performance_ui("past_performance_ui_1")
    
## To be copied in the server
# mod_past_performance_server("past_performance_ui_1")
