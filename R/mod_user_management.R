#' user_management UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_user_management_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' user_management Server Functions
#'
#' @noRd 
mod_user_management_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_user_management_ui("user_management_ui_1")
    
## To be copied in the server
# mod_user_management_server("user_management_ui_1")
