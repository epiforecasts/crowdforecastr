#' display_external_info UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_display_external_info_ui <- function(id){
  ns <- NS(id)
  tagList(
 
    htmlOutput(outputId = ns("external_data")),
    
    p("This data is provided by Our World in Data. Data sources may differ and information must be treated carefully. Usually, dates are moved by a day when compared to our sources")
    
  )
}
    
#' display_external_info Server Functions
#'
#' @noRd 
mod_display_external_info_server <- function(id, src){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$external_data <- renderUI({
      pos <- tags$iframe(src=src, height=600, width = "100%")
      print(pos)
      pos
    })
    
 
  })
}
    
## To be copied in the UI
# mod_display_external_info_ui("display_external_info_ui_1")
    
## To be copied in the server
# mod_display_external_info_server("display_external_info_ui_1")
