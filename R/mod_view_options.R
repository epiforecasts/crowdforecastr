#' view_options UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param selection_vars character vector with categories that can be selected. 
#' For example, this could included `location` if there are different locations or
#' `target_type` if there are multiple targets. 
#' @param observations the data.frame with observed values
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_view_options_ui <- function(id, selection_vars, observations){
  ns <- NS(id)
  tagList(
    

    fluidRow(column(6, 
                    # create a selection field for every value specified in selection_vars
                    # by the user. 
                    lapply(selection_vars, 
                           FUN = function(var) {
                             mod_view_options_selection_field_ui(id = ns(paste0("select_", var)),
                                                                 observations = observations,
                                                                 selection_var = var)
                           })
                    ), 
             column(6,
                    # input to select the number of past observations to plot
                    numericInput(inputId = ns("weeks_to_show"), 
                                 label = "No. of weeks to show",
                                 min = 1,
                                 value = 12))
             ),
    
    fluidRow(column(12, 
                    p("To choose the targets you want to forecast, go to the 'Account Details' tab on the left"))
             ),
    
    # fluidRow(
    #   actionButton(inputId = "select_forecast_targets",
    #                label = "Choose forecast targets")),
    # br(),
    
    shinyWidgets::prettyRadioButtons(inputId = ns("plot_scale"),
                                     inline = TRUE,
                                     label = "Plot scale",
                                     choices = c("linear", "log")),

    shinyWidgets::prettyCheckboxGroup(inputId = ns("desired_intervals"),
                                      label = "Prediction intervals to show",
                                      choices = c("20%", "50%", "90%", "95%", "98%"),
                                      inline = TRUE,
                                      fill = TRUE,
                                      selected = c("50%", "90%"))
  )
}




    
#' view_options Server Functions
#' 
#' @param id Internal parameter for {shiny}
#' @param view_options `reactiveValues()` list that holds all the options 
#' for visualising the data. This must include `weeks_to_show`, `plot_scale`. 
#' There can be additional element that must be named according to the 
#' elements in `selection_vars`
#' @param selection_vars character vector with categories that can be selected. 
#' For example, this could included `location` if there are different locations or
#' `target_type` if there are multiple targets. 
#' @param observations the data.frame with observed values
#'
#' @noRd 
mod_view_options_server <- function(id, view_options, forecast,
                                    selection_vars, observations, 
                                    user_management, 
                                    parent_session){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    
    # add a server function for every selection sub-module
    lapply(selection_vars, 
           FUN = function(var) {
             mod_view_options_selection_field_server(id = paste0("select_", var),
                                                     selection_var = var, 
                                                     forecast = forecast,
                                                     view_options = view_options, 
                                                     user_management = user_management)
           })
    
    
    # update the list of reactive values when selections are changed
    observeEvent(input$weeks_to_show, {
      view_options[["weeks_to_show"]] <- input$weeks_to_show
    })
    
    observeEvent(input$select_forecast_targets, {
      updateTabItems(session = parent_session, 
                     inputId = "tabs", 
                     selected = "account")
    })
    
    observeEvent(input$plot_scale, {
      view_options[["plot_scale"]] <- input$plot_scale
    })
    
    observeEvent(input$desired_intervals, {
      view_options[["desired_intervals"]] <- input$desired_intervals
    })
  })
}



#' view_options_selection_field UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param selection_vars character vector with categories that can be selected. 
#' For example, this could included `location` if there are different locations or
#' `target_type` if there are multiple targets. 
#' @param observations the data.frame with observed values
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 

mod_view_options_selection_field_ui <- function(id, selection_var, observations){
  ns <- NS(id)
  
  tagList(
    # create a selection input and 
    # determine available choices from the observations 
    selectInput(inputId = ns("selection"), 
                label = paste("Select", selection_var), 
                choices = unique(observations[[selection_var]])),
  )
}



#' view_options_selection_field Server Functions
#' 
#' @param id Internal parameter for {shiny}
#' @param selection_var character, one element of `selection_vars`
#' @param view_options `reactiveValues()` list that holds all the options 
#' for visualising the data. This must include `weeks_to_show`, `plot_scale`. 
#' There can be additional element that must be named according to the 
#' elements in `selection_vars`
#'
#' @noRd 
mod_view_options_selection_field_server <- function(id, 
                                                    selection_var, 
                                                    view_options, forecast, 
                                                    user_management){
  moduleServer( id, function(input, output, session){
    ns <- NS(id)
    
    # update view options and also duplicate the data into forecast
    observeEvent(input$selection, {
      view_options[[selection_var]] <- input$selection
      
      forecast[[selection_var]] <- input$selection
      # also update the selected combination string that is a unique identifier
      # of the currently displayed selection by collecting all selections in a 
      # vector and collapsing to a string. This is used as a label for the 
      # y-axis of the main plot
      forecast$selection_list[[selection_var]] <- input$selection
      forecast$selected_combination <- paste(forecast$selection_list, 
                                             collapse = " - ")
    })
    
    # also update the selection whenever the view_options change. This change can 
    # be externally introduced when something is submitted and the next 
    # forecast is selected
    observeEvent(forecast[[selection_var]], {
      print("updating input selection as forecast[[selection_var]] changed")
      updateSelectInput(session = session, inputId = "selection",
                        selected = forecast[[selection_var]])
    })
    
    # update the available choices according to what the user has chosen. 
    # This happens after login when user data is fetched from the server or 
    # when the user changes their choices in the user account tab (which also)
    # changes the current user data
    observeEvent(user_management$current_user_data, {
      
      user_selection <- get_selections(
        user_management$current_user_data
    )
      
      # if target for currently selected for forecasting is not in the 
      # targets that the user chose to forecast, select the first target 
      # the user chose to forecast instead
      if (!(forecast[[selection_var]] %in% user_selection[[selection_var]])) {
        print("update input after change in user selection")
        forecast[[selection_var]] <- user_selection[[selection_var]][1]
      }
      
      updateSelectInput(session = session, inputId = "selection",
                        selected = forecast[[selection_var]],
                        choices = user_selection[[selection_var]])
    })
    
  })
}
