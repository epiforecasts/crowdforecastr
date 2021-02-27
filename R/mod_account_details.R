#' account_details UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_account_details_ui <- function(id, selection_vars, observations){
  ns <- NS(id)
  
  tagList(
    uiOutput(ns("account_details")), 
    h3("Select which targets to forecast"),
    lapply(selection_vars, 
           FUN = function(var) {
             possible_selections <- list_selections(selection_vars, observations)
             selection_options <- possible_selections[[var]]
             mod_account_details_selection_ui(id = ns(paste0("selection_", var)),
                                              selection_options = selection_options, 
                                              label = paste("Options for", var))
           })
  )
}
    

#' account_details Server Functions
#'
#' @noRd 
mod_account_details_server <- function(id, user_management, possible_selections){
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
  
  lapply(names(possible_selections), 
         FUN = function(var) {
           mod_account_details_selection_server(id = paste0("selection_", var), 
                                                possible_selections)
         })
  
  
}
    


#' UI for selection of targets
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_account_details_selection_ui <- function(id, selection_options, label){
  ns <- NS(id)
  tagList(
    checkboxGroupInput(inputId = ns("make_selection"), 
                       label = label,
                       choices = selection_options, 
                       selected = selection_options, 
                       inline = TRUE)
  )
  
}


#' account_details Server Functions
#'
#' @noRd 
mod_account_details_selection_server <- function(id, possible_selections){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    selection_vars <- names(possible_selections)
    
    # # first do it hard-coded for location names
    # if ("location" %in% selection_vars) {
    #   
    # }
    
  
  })
}
