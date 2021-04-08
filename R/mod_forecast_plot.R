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
  
  plot_height <- ifelse(golem::get_golem_options("app_mode") == "regular", 
                   "850px", 
                   "450px")
  
  tagList(
    plotlyOutput(ns("forecast_plot"), height = plot_height), 
    h4("Drag points around to change the forecast!")
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
      
      selection_id <- forecast$selected_combination
      
      # create circles for the prediction that can then be dragged around
      circles_pred <- map2(.x = forecast$x, .y  = forecast$median[[selection_id]],
                           ~list(type = "circle",
                                 # anchor circles at (mpg, wt)
                                 xanchor = .x,
                                 yanchor = .y,
                                 # give each circle a 2 pixel diameter
                                 x0 = -5, x1 = 5,
                                 y0 = -5, y1 = 5,
                                 xsizemode = "pixel",
                                 ysizemode = "pixel",
                                 # other visual properties
                                 fillcolor = 'rgb(44, 160, 44)',
                                 line = list(color = "transparent")))

      # make basic plot
      plot <- plot_ly() 
      
      if (golem::get_golem_options("app_mode") == "rt") {
        plot <- add_vline(plot, x = golem::get_golem_options("submission_date"), 
                          color = "rgb(169,169,169)", 
                          dash = "dash")
      }
      
      plot <- plot %>%
        add_trace(x = obs_filtered$target_end_date,
                  y = obs_filtered$value, type = "scatter",
                  name = 'observed data',mode = 'lines+markers', 
                  marker = list(size = 2)) %>%
        add_trace(x = forecast$x,
                  y = forecast$median[[selection_id]], type = "scatter",
                  name = 'forecast', mode = 'lines', color = I("dark green")) %>%
        layout(xaxis = list(range = c(min(obs_filtered$target_end_date),
                                      max(forecast$x) + 5), 
                            title = "Date"), 
               yaxis = list(title = selection_id)) %>%
        layout(yaxis = list(hoverformat = '.2f', rangemode = "tozero")) %>%
        layout(shapes = c(circles_pred)) %>%
        layout(title = "Observations and Forecast") %>%
        layout(legend = list(orientation = 'h')) %>%
        # config(edits = list(shapePosition = TRUE))
        config(editable = TRUE)
      
      # add ribbons around the true data if specified. 
      colnames <- colnames(observations)
      if (any(grepl("upper", colnames)) && any(grepl("lower", colnames))) {
        
        for (interval in view_options$desired_intervals) {
          
          int <- sub(pattern = "%", replacement = "", x = interval) %>%
            as.numeric()
          
          # select column name that has the interval as well as "upper" or "lower"
          # in its name
          index_lower <- grepl("lower", colnames) & grepl(int, colnames)
          index_upper <- grepl("upper", colnames) & grepl(int, colnames)
          
          if (any(index_lower) && any(index_upper)) {
            lower_bound <- obs_filtered[[colnames[index_lower]]]
            upper_bound <- obs_filtered[[colnames[index_upper]]]
            
            # color <- "'rgba(255, 127, 14," #orange
            # color <- "'rgba(44, 160, 44," #other green
            # color <- "'rgba(26,150,65," # green
            color <- "'rgba(31, 119, 180," # default blue color
            
            plot <- plot %>%
              add_ribbons(x = obs_filtered$target_end_date, ymin = lower_bound, ymax = upper_bound,
                          name = paste0(interval, " uncertainty interval"),
                          line = list(color = "transparent"),
                          fillcolor = paste0(color, max((1 - int/100 + 0.1)/7, 0.1), ")'"))
          }
        }
      }
      

      # add ribbons around predictions for the selected prediction intervals
      for (interval in view_options$desired_intervals) {
        int <- sub(pattern = "%", replacement = "", x = interval) %>%
          as.numeric()
        
        lower_quantile <- round((100 - int) / (2 * 100), 3)
        upper_quantile <- 1 - lower_quantile
        
        lower_bound <- rep(NA, num_horizons)
        upper_bound <- rep(NA, num_horizons)
        
        # calculate upper and lower bound for a given prediction interval
        for (horizon in 1:num_horizons) {
          lower_bound[horizon] <- forecast[[selection_id]][[paste0("horizon_", horizon)]][round(forecast_quantiles, 3) == lower_quantile]
          upper_bound[horizon] <- forecast[[selection_id]][[paste0("horizon_", horizon)]][round(forecast_quantiles, 3) == upper_quantile]
        }
        
        color <- "'rgba(255, 127, 14," #orange
        color <- "'rgba(44, 160, 44," #other green
        # color <- "'rgba(26,150,65," # green
        
        plot <- plot %>%
          add_ribbons(x = forecast$x, ymin = lower_bound, ymax = upper_bound,
                      name = paste(interval, "prediction interval"),
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
                   
                   selection_id <- forecast$selected_combination
                   
                   forecast$median[[selection_id]][row_index] <- round(y_coord, 2)
                 })
    
    
  })
}
