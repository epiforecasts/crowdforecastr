#' plotly_test UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#'
#' @noRd 
#' @import plotly
#' @importFrom shiny NS tagList 
mod_plotly_test_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("p")),
    verbatimTextOutput(ns("event"))
  )
}

#' plotly_test Server Functions
#'
#' @noRd 
mod_plotly_test_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$p <- renderPlotly({
      plot_ly() %>%
        layout(
          xaxis = list(range = c(-10, 10)),
          yaxis = list(range = c(-10, 10)),
          shapes = list(
            type = "circle", 
            fillcolor = "gray",
            line = list(color = "gray"),
            x0 = -1, x1 = 1,
            y0 = -1, y1 = 1,
            xsizemode = "pixel", 
            ysizemode = "pixel",
            xanchor = 0, yanchor = 0
          )
        ) %>%
        config(editable = TRUE)
      
    })
    
    output$event <- renderPrint({
      event_data("plotly_relayout")
    })
    
  })
}

