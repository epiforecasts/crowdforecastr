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
mod_user_management_server <- function(id, 
                                       user_management, 
                                       user_data, 
                                       user_data_sheet_id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # open login screen when appropriate
    observeEvent(user_management$open_login, {
      if (user_management$open_login) {
        removeModal()
        showModal(modalDialog(
          tagList(
            mod_user_management_login_ui(ns("login"))
          ),
          footer = NULL, 
          size = "l"))
      } 
    }, ignoreNULL = FALSE)
    mod_user_management_login_server("login", user_management, user_data)
    
    # open screen with consent needed to create new user if appropriate
    observeEvent(user_management$open_new_user_consent, {
      if (user_management$open_new_user_consent) {
        removeModal()
        showModal(modalDialog(
          tagList(
            mod_user_management_new_user_consent_ui(ns("create_new_user_consent")),
          ), 
          footer = NULL, 
          size = "l"))
      }
    })
    mod_user_management_new_user_consent_server("create_new_user_consent", 
                                                user_management)
    
    # open form to create new user when appropriate
    observeEvent(user_management$open_create_user_form, 
                 {
                   if (user_management$open_create_user_form) {
                     removeModal()
                     showModal(modalDialog(
                       size = "l",
                       title = "Create New User", 
                       mod_user_management_create_user_ui(ns("create_user_form")),
                       footer = NULL
                     ))
                   }
                 })
    mod_user_management_create_user_server("create_user_form", 
                                           user_management, user_data, 
                                           user_data_sheet_id)
  })
}
    
## To be copied in the UI
# mod_user_management_ui("user_management_ui_1")
    
## To be copied in the server
# mod_user_management_server("user_management_ui_1")
