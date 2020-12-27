#' forecast_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import plotly
#' @import rlang
#' 

mod_forecast_plot_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("forecast_plot"), height = "850px")
  )
}
    
#' forecast_plot Server Functions
#' @param observations a data.frame with the observed data to plot and on 
#' which to base the forecasts
#' @param view_options a list with numerous elements that define how the data
#' should be plotted. \code{view_options} should contain the following elements: 
#' \code{weeks_to_show} (numeric with the number of past weeks to show),
#' \code{plot_scale} (character with either 'log' or 'linear'), \code{
#' desired_intervals} (character vector with the prediction intervals to plot)
#' @importFrom purrr map2
#' @import plotly
#' @noRd 
mod_forecast_plot_server <- function(id, observations, 
                                     forecast, 
                                     num_horizons,
                                     view_options, 
                                     selection_vars, 
                                     forecast_quantiles){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    
    output$forecast_plot <- plotly::renderPlotly({

      # filter data according to selection
      obs_filtered <- observations %>%
        filter_data_util(view_options = view_options, selection_vars = selection_vars)

      # create circles for the prediction that can then be dragged around
      circles_pred <- map2(.x = forecast$x, .y  = forecast$median,
                           ~list(type = "circle",
                                 # anchor circles at (mpg, wt)
                                 xanchor = .x,
                                 yanchor = .y,
                                 # give each circle a 2 pixel diameter
                                 x0 = -4, x1 = 4,
                                 y0 = -4, y1 = 4,
                                 xsizemode = "pixel",
                                 ysizemode = "pixel",
                                 # other visual properties
                                 fillcolor = "orange",
                                 line = list(color = "transparent")))

      # make basic plot
      plot <- plot_ly() %>%
        add_trace(x = obs_filtered$target_end_date,
                  y = obs_filtered$value, type = "scatter",
                  name = 'observed data',mode = 'lines+markers') %>%
        add_trace(x = forecast$x,
                  y = forecast$median, type = "scatter",
                  name = 'forecast',mode = 'lines') %>%
        layout(xaxis = list(range = c(min(obs_filtered$target_end_date),
                                      max(forecast$x) + 5))) %>%
        # layout(yaxis = list(hoverformat = '0f', rangemode = "tozero")) %>%
        layout(shapes = c(circles_pred)) %>%
        layout(legend = list(orientation = 'h')) %>%
        # config(edits = list(shapePosition = TRUE))
        config(editable = TRUE)

      # add ribbons for the selected prediction intervals
      for (interval in view_options$desired_intervals) {
        
        int <- sub(pattern = "%", replacement = "", x = interval) %>%
          as.numeric()

        lower_quantile <- round((100 - int) / (2 * 100), 3)
        upper_quantile <- 1 - lower_quantile
        
        print(lower_quantile)
        
        lower_bound <- rep(NA, num_horizons)
        upper_bound <- rep(NA, num_horizons)
        
        # calculate upper and lower bound for a given prediction interval
        for (horizon in 1:num_horizons) {
          print(round(forecast_quantiles, 3) == lower_quantile)
          
          lower_bound[horizon] <- forecast[[paste0("forecasts_horizon_", horizon)]][round(forecast_quantiles, 3) == lower_quantile]
          upper_bound[horizon] <- forecast[[paste0("forecasts_horizon_", horizon)]][round(forecast_quantiles, 3) == upper_quantile]
        }
        
        print(lower_bound)
        print(upper_bound)
        
        color <- "'rgba(255, 127, 14," #orange
        # color <- "'rgba(26,150,65," # green
        
        plot <- plot %>%
          add_ribbons(x = forecast$x, ymin = lower_bound, ymax = upper_bound,
                      name = paste0(interval, "% prediction interval"),
                      line = list(color = "transparent"),
                      fillcolor = paste0(color, (1 - int/100 + 0.1), ")'"))

      }
      
      
      # turn plot into log scale if log is selected by user
      if(view_options$plot_scale == "log") {
        plot <- layout(plot, yaxis = list(type = "log"))
      }
      
      

      plot
    })
    
    # update x/y reactive values in response to changes in shape anchors
    observeEvent(event_data("plotly_relayout"),
                 {
                   ed <- event_data("plotly_relayout", priority = "input")
                   shape_anchors <- ed[grepl("^shapes.*anchor$", names(ed))]
                   if (length(shape_anchors) != 2) return()
                   row_index <- unique(readr::parse_number(names(shape_anchors)) + 1)
                   y_coord <- as.numeric(shape_anchors[2])
                   
                   forecast$median[row_index] <- round(y_coord)
                 })
    
    
  })
}
