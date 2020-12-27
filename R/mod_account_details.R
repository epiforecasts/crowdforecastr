#' account_details UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_account_details_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' account_details Server Functions
#'
#' @noRd 
mod_account_details_server <- function(id, user_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    # output$account_details <- renderUI({
    #   str1 <- paste0("<b>Name</b>: ", user_data$name)
    #   str11 <- paste0("<b>ID</b>: ", identification()$forecaster_id)
    #   str2 <- paste0("<b>Email</b>: ", identification()$email)
    #   str3 <- paste0("<b>Expert</b>: ", identification()$expert)
    #   str4 <- paste0("<b>Appear on Performance Board</b>: ", identification()$appearboard)
    #   str41 <- paste0("<b>Name Performance Board</b>: ", identification()$board_name)
    #   str5 <- paste0("<b>Affiliation</b>: ", identification()$affiliation, ". ", identification()$website)
    #   HTML(paste(str1, str11, str2, str3, str41, str5, sep = '<br/>'))
    # })
  })
}
    
## To be copied in the UI
# mod_account_details_ui("account_details_ui_1")
    
## To be copied in the server
# mod_account_details_server("account_details_ui_1")
