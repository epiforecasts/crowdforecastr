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
    uiOutput(ns("account_details"))
  )
}
    
#' account_details Server Functions
#'
#' @noRd 
mod_account_details_server <- function(id, user_management){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    observeEvent(user_management$current_user_data, {
    if (!is.null(user_management$current_user_data)) {
        
        current_user_data <- user_management$current_user_data
        
        output$account_details <- renderUI({
          str1 <- paste0("<b>Name</b>: ", current_user_data$name)
          str11 <- paste0("<b>ID</b>: ", current_user_data$forecaster_id)
          str2 <- paste0("<b>Email</b>: ", current_user_data$email)
          str3 <- paste0("<b>Expert</b>: ", current_user_data$expert)
          str4 <- paste0("<b>Appear on Performance Board</b>: ", current_user_data$appearboard)
          str41 <- paste0("<b>Name Performance Board</b>: ", current_user_data$board_name)
          str5 <- paste0("<b>Affiliation</b>: ", current_user_data$affiliation, ". ", current_user_data$website)
          HTML(paste(str1, str11, str2, str3, str41, str5, sep = '<br/>'))
        })
      }
    })
  })
}
    
## To be copied in the UI
# mod_account_details_ui("account_details_ui_1")
    
## To be copied in the server
# mod_account_details_server("account_details_ui_1")
