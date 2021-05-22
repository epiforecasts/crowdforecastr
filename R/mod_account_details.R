#' account_details UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#' @importFrom googlesheets4 range_write
#' @importFrom shiny NS tagList 
mod_account_details_ui <- function(id){
  ns <- NS(id)
  
  selection_vars <- golem::get_golem_options("selection_vars")
  tagList(
    uiOutput(ns("id")), 
    br(),
    textInput(inputId = ns("name"), label = "Name"),
    textInput(inputId = ns("username"), label = "Username (used to log in)"),
    textInput(inputId = ns("board_name"), label = "Name on leaderboard"),
    textInput(inputId = ns("email"), label = "Email"),
    shinyWidgets::prettyRadioButtons(inputId = ns("expert"),
                                     inline = TRUE,
                                     label = "Do you have domain expertise?",
                                     choices = c("yes", "no")),
    textInput(inputId = ns("affiliation"), label = "Affiliation / Institution"),
    textInput(inputId = ns("website"), label = "Affiliation website"),
    
    
    h3("Select which targets to forecast"),
    lapply(selection_vars, 
           FUN = function(selection_var) {
             possible_selections <- list_selections()
             selection_options <- possible_selections[[selection_var]]
             mod_account_details_selection_ui(
               id = ns(paste0("selection_", selection_var)),
               selection_var = selection_var
             )
           }), 
    br(), 
    actionButton(inputId = ns("update_preferences"), 
                 label = HTML("<b>Update User Data and Preferences</b>"))
  )
}
    

#' account_details Server Functions
#'
#' @noRd 
mod_account_details_server <- function(id, user_management){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # after startup, all the user data gets read in. At this point, the 
    # input fields are updated according to what was read from the server
    observeEvent(user_management$current_user_data, {
    if (!is.null(user_management$current_user_data)) {
        
        current_user_data <- user_management$current_user_data
        
        # show ID (cannot be changed)
        output$id <- renderUI({
          HTML(paste0("<b>ID</b>: ", current_user_data$forecaster_id))
        })
        
        # update all fields with the read in user_data
        updateTextInput(inputId = "name", value = current_user_data$name)
        updateTextInput(inputId = "username", value = current_user_data$username)
        updateTextInput(inputId = "board_name", value = current_user_data$board_name)
        updateTextInput(inputId = "email", value = current_user_data$email)
        updateTextInput(inputId = "affiliation", value = current_user_data$affiliation)
        updateTextInput(inputId = "website", value = current_user_data$website)
        shinyWidgets::updatePrettyRadioButtons(
          session = session,
          inputId = "expert", selected = ifelse(current_user_data$expert, "yes", "no")
        )
      }
    })
    
    selection_vars <- golem::get_golem_options("selection_vars")
    
    lapply(selection_vars, 
           FUN = function(var) {
             mod_account_details_selection_server(id = paste0("selection_", var),
                                                  selection_var = var,
                                                  user_management = user_management)
           })

    # update preferences, store in user data, write to server, update selection    
    observeEvent(input$update_preferences, {
      
      # for all selection variables, update the selection in the user data
      lapply(selection_vars, 
             FUN = function(var) {
               user_selection <- user_management$selection_choice[[var]]
               user_selection <- paste(user_selection, collapse = ", ")
               colname <- paste0("selection_", var)
               user_management$current_user_data[[colname]] <- user_selection
             })
      
      # update user data with all other inputs
      user_management$current_user_data$name <- input$name
      user_management$current_user_data$username <- input$username
      user_management$current_user_data$board_name <- input$board_name
      user_management$current_user_data$email <- input$email
      user_management$current_user_data$affiliation <- input$affiliation
      user_management$current_user_data$website <- input$website
      user_management$current_user_data$expert <- ifelse(input$expert == "yes", TRUE, FALSE)
      
      # construct range to write to by getting the line and 
      # add + 1 as the header is the first line in the sheet
      forecaster_id <- user_management$current_user_data$forecaster_id
      # read user data from sheet - this is necessary because a new user 
      # might want to change their data again and in the meantime the 
      # user data could have grown if other users had registered
      user_data <- try_and_wait(
        read_sheet(ss = golem::get_golem_options("user_data_sheet_id"), 
                   sheet = "ids")
      )
      line_number <- which(user_data$forecaster_id == forecaster_id) + 1
      
      # write to sheet
      try_and_wait(
        range_write(ss = golem::get_golem_options("user_data_sheet_id"), 
                    data = user_management$current_user_data, 
                    sheet = "ids", 
                    range = paste0("A", line_number), 
                    col_names = FALSE)
      )
      
      # show an alert that the update was successful
      shinyalert::shinyalert(type = "success", 
                             title = "",
                             text = "User data successfully updated!", 
                             closeOnClickOutside = TRUE, 
                             timer = 2500)
      
    })
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
mod_account_details_selection_ui <- function(id, selection_var){
  ns <- NS(id)
  
  possible_selections <- list_selections()
  selection_options <- possible_selections[[selection_var]]
  
  tagList(
    fluidRow(column(12, 
                    checkboxGroupInput(inputId = ns("make_selection"), 
                                       label = paste("Options for", selection_var),
                                       choices = selection_options, 
                                       # selected = selection_options, 
                                       inline = TRUE)
                    )), 
    fluidRow(column(2, actionButton(ns("select_all"), label = "Select all")),
             column(2, actionButton(ns("deselect_all"), label = "Select none")))
  )
  
}


#' account_details Server Functions
#'
#' @noRd 
mod_account_details_selection_server <- function(id, selection_var, 
                                                 user_management){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # whenever a selection is changed, store it such that it can be accessed
    # from within the mod_account_details_server() function and the 
    # actionButton there. 
    observeEvent(input$make_selection, {
      user_management$selection_choice[[selection_var]] <- input$make_selection
    })
    
    observeEvent(input$select_all, {
      updateCheckboxGroupInput(session = session, 
                               inputId = paste0("make_selection"), 
                               choices = list_selections()[[selection_var]],
                               selected = list_selections()[[selection_var]], 
                               inline = TRUE)
    })
    
    observeEvent(input$deselect_all, {
      updateCheckboxGroupInput(inputId = paste0("make_selection"), 
                               choices = list_selections()[[selection_var]],
                               selected = NULL, 
                               inline = TRUE)
    })
    
    # update the selected choices according to what the user has selected. 
    # This happens after login when user data is fetched from the server
    observeEvent(user_management$current_user_data, {
      user_selection <- get_selections(user_management$current_user_data)
      updateCheckboxGroupInput(
        inputId = "make_selection",
        selected = user_selection[[selection_var]])
    })
  })
}
