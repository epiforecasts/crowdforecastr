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
mod_view_options_server <- function(id, view_options, 
                                    selection_vars, observations){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    
    # add a server function for every selection sub-module
    lapply(selection_vars, 
           FUN = function(var) {
             mod_view_options_selection_field_server(id = paste0("select_", var),
                                                     selection_var = var, 
                                                     view_options = view_options)
           })
    
    # update the list of reactive values when selections are changed
    observeEvent(input$weeks_to_show, {
      view_options[["weeks_to_show"]] <- input$weeks_to_show
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
mod_view_options_selection_field_server <- function(id, selection_var, view_options){
  moduleServer( id, function(input, output, session){
    ns <- NS(id)
    
    # update the view_options reactive list whenever an input changes
    observeEvent(input$selection, {
      view_options[[selection_var]] <- input$selection
    })
  })
}
