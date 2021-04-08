#' Rt-sim-plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_Rt_sim_plot_ui <- function(id){
  ns <- NS(id)
  tagList(
    add_busy_spinner(spin = "fading-circle", position = "bottom-left",
                     margins = c(100, 100), 
                     height = "100px", width = "100px",
                     color = "#A8A8A8"),
    actionButton(ns("simulate"), label = "Simulate"),
    plotlyOutput(ns("rt_forecast_plot"), height = "400px")
  )
}
    
#' Rt-sim-plot Server Functions
#'
#' @noRd 
mod_Rt_sim_plot_server <- function(id, 
                                   observations, 
                                   forecast){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    sim <- reactiveValues(
      forecast = NULL, 
      truth_data = NULL
    )
    
    output$rt_forecast_plot <- plotly::renderPlotly({
      
      observeEvent(input$simulate, {
        sim_data <- simulate_cases_from_rt(forecast)
        
        print("success")
        sim$forecast <- forecasthubutils::make_weekly(
          sim_data$forecast,
          value_cols = c("lower_90", "lower_50", "median", "upper_50", "upper_90"),
          group_by = NULL
        )
        
        sim$truth_data <- forecasthubutils::make_weekly(sim_data$observations,
                                                        value_cols = "confirm",
                                                        group_by = NULL)
      }, ignoreInit = TRUE)
      
      print(sim$forecast)
      
      if (is.null(sim$forecast)) {
        plot <- plot_ly(type = "scatter")
      } else {
        
        color <- "'rgba(31, 119, 180," # default blue color
        
        plot <- plot_ly() %>%
          add_trace(x = sim$truth_data$target_end_date,
                    y = sim$truth_data$confirm, type = "scatter",
                    name = 'observed data',mode = 'lines+markers',
                    marker = list(size = 2)) %>%
          add_trace(x = sim$forecast$target_end_date,
                    y = sim$forecast$median, type = "scatter",
                    name = 'forecast', mode = 'lines', color = I("dark green")) %>%
          layout(xaxis = list(range = c(min(sim$truth_data$target_end_date),
                                        max(sim$forecast$target_end_date) + 5),
                              title = "Date")) %>%
          layout(yaxis = list(hoverformat = '.2f', rangemode = "tozero")) %>%
          layout(legend = list(orientation = 'h'))
        
        # add ribbons
        plot <- plot %>%
          add_ribbons(x = sim$forecast$target_end_date, 
                      ymin = sim$forecast$lower_90, ymax = sim$forecast$upper_90,
                      name = "90% uncertainty interval",
                      line = list(color = "transparent"),
                      fillcolor = paste0(color, 0.1, ")'")) %>%
          add_ribbons(x = sim$forecast$target_end_date, 
                      ymin = sim$forecast$lower_50, ymax = sim$forecast$upper_50,
                      name = "50% uncertainty interval",
                      line = list(color = "transparent"),
                      fillcolor = paste0(color, 0.1, ")'"))
      }

      plot
    })
    

    
    # output$rt_forecast_plot <- renderPlot({
    #   
    #   if (is.null(sim$forecast)) {
    #     ggplot()
    #   } else {
    #     plot <- ggplot(data = sim$forecast,
    #                    aes(y = median, x = target_end_date)) +
    #       geom_ribbon(aes(ymin = lower_90, ymax = upper_90), alpha = 0.4,
    #                   fill = "lightskyblue1") +
    #       geom_ribbon(aes(ymin = lower_50, ymax = upper_50), alpha = 0.8,
    #                   fill = "lightskyblue1") +
    #       geom_line(color = "steelblue3") +
    #       geom_line(data = sim$truth_data,
    #                 aes(y = confirm, x = target_end_date),
    #                 color = "black") +
    #       theme_minimal()
    #     
    #     plot
    #   }
    # })
 
  })
}
    
## To be copied in the UI
# mod_Rt-sim-plot_ui("Rt-sim-plot_ui_1")
    
## To be copied in the server
# mod_Rt-sim-plot_server("Rt-sim-plot_ui_1")