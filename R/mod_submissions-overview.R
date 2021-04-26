#' submissions-overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_submissions_overview_ui <- function(id){
  ns <- NS(id)
  tagList(
    h3("Here are the total forecasts submitted to the app (not including your current submissions):"),
    tableOutput(outputId = ns("all_submissions_table")),
    br(),
    br(),
    h3("Here are your current submissions:"),
    uiOutput(outputId = ns("submissions"))
  )
}
    
#' submissions-overview Server Functions
#'
#' @noRd 
mod_submissions_overview_server <- function(id, submitted, view_options){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    
    # 
    # output$submissions <- renderPrint({
    #   
    #   if (length(submitted$submitted_combinations) == 0) {
    #     "Nothing submitted yet"
    #   } else {
    #     paste("The following targets have been submitted: <br>", 
    #           paste(submitted$submitted_combinations, 
    #                 collapse = "<br>"))
    #   }
    # })
    
    # observations <- golem::get_golem_options("data")
    # selection_vars <- golem::get_golem_options("selection_vars")
    
    # need to extract the individual selections from the submitted_combination
    # --> write a helper function for that
    
    # filter observations
    #
    # selection_id <- forecast$selected_combination
    
    # make plot
    
    
    # load all submissions
    all_submissions <- get_existing_forecasts()
    
    output$all_submissions_table <- renderTable({
      all_submissions
    })
    
    
    
    # maybe this doesn't have to be wrapped in obesrveEvent
    observeEvent(c(submitted, submitted$submitted_combinations), {
      if (length(submitted$submitted_combinations) == 0) {
        out <- "Nothing submitted yet"
      } else {
        combinations <- paste(submitted$submitted_combinations, 
                              collapse = " <br> ")
        out <-
          paste("The following targets have been submitted: <br>", 
                combinations, collapse = "<br>")
      }
      
      output$submissions <- renderUI({
        HTML(paste0(out))
      })
    })
    
  })
}
    
## To be copied in the UI
# mod_submissions-overview_ui("submissions-overview_ui_1")
    
## To be copied in the server
# mod_submissions-overview_server("submissions-overview_ui_1")
