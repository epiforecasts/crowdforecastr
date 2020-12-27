#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @import shinydashboardPlus
#' @noRd

app_ui <- function(request) {
  
  tagList(
    
    golem_add_external_resources(),
    
    dashboardPage(
      dashboardHeader(title = "crowdforecastr test"),
      # dashboardHeader(title = "crowdforecastr test", 
      #                 tags$li(shinyWidgets::prettySwitch(inputId = "tooltips", 
      #                                                    label = "Tooltips",
      #                                                    value = TRUE), 
      #                         class = 'dropdown')
      #                 ),
      dashboardSidebar(
        sidebarMenu(
          menuItem("Make Forecast", tabName = "makeforecast", icon = icon("chart-line")),
          menuItem("View Performance", tabName = "performance", icon = icon("chart-bar")),
          menuItem("Account Details", tabName = "account", icon = icon("user"))
        )
      ),
      dashboardBody(
        # Leave this function for adding external resources
        golem_add_external_resources(),
        # List the first level UI elements here 
        fluidPage(
          # h1("Make a Forecast"),
          
          
          # mod_plotly_test_ui("test"),
          
          shiny::fluidRow(
            column(width = 9,
                   shinydashboard::box(title = "Forecast visualisation",
                                       mod_forecast_plot_ui(id = "forecast_plot"),
                                       width = NULL)
                   ),
            column(width = 3,
                   shinydashboard::box(title = "View Options",
                                       mod_view_options_ui("view_options",
                                                           selection_vars = golem::get_golem_options("selection_vars"),
                                                           observations = golem::get_golem_options("data")),
                                       width = NULL),
                   shinydashboard::box(title = "Adjust Forecast",
                                       # "box content",
                                       
                                       mod_adjust_forecast_ui("adjust_forecast",
                                                              num_horizons = golem::get_golem_options("horizons")),
                                       width = NULL)

                   )
            ),
          shiny::fluidRow(
            shinydashboard::box(title = "Additional Information", 
                                mod_display_external_info_ui("cfr"),
                                width = 12)
          )
          
          
          
        )
      )
    )
  )
  
  
  
  
  
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'crowdforecastr'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

