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
    shinyjs::useShinyjs(),
    shinyalert::useShinyalert(),
    golem_add_external_resources(),
    
    dashboardPage(
      # think about where to put a tooltip toggle button
      dashboardHeader(title = golem::get_golem_options("app_title")),
      # tags$li(class = "dropdown", style = "padding: 8px;",
      #         shinyauthr::logoutUI("logout")),
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
        
        tabItems(
          tabItem(tabName = "makeforecast",
                  fluidPage(
                    shiny::fluidRow(
                      column(width = 9,
                             shinydashboard::box(title = NULL,
                                                 mod_forecast_plot_ui(id = "forecast_plot"),
                                                 width = NULL)
                      ),
                      column(width = 3,
                             shinydashboard::box(title = "View Options",
                                                 status = "primary", 
                                                 solidHeader = TRUE,
                                                 mod_view_options_ui("view_options",
                                                                     selection_vars = golem::get_golem_options("selection_vars"),
                                                                     observations = golem::get_golem_options("data")),
                                                 width = NULL),
                             shinydashboard::box(title = "Adjust Forecast",
                                                 status = "primary", 
                                                 solidHeader = TRUE,
                                                 # "box content",
                                                 
                                                 mod_adjust_forecast_ui("adjust_forecast",
                                                                        num_horizons = golem::get_golem_options("horizons")),
                                                 width = NULL)
                             
                      )
                    ),
                    
                    shinydashboard::box(title = "Additional Information", 
                                        status = "primary", 
                                        solidHeader = TRUE,
                                        tabsetPanel(type = "tabs", 
                                                    id = "additional_info",
                                                    tabPanel("Overview Information", mod_display_external_info_ui("our_world_in_data_dashboard")),
                                                    tabPanel("Case Fatality Rate", mod_display_external_info_ui("cfr")), 
                                                    tabPanel("Positivity Rate", mod_display_external_info_ui("positivity_rate")), 
                                                    tabPanel("Daily Testing Performed", mod_display_external_info_ui("daily_testing")), 
                                                    tabPanel("Stringency Measures", mod_display_external_info_ui("gov_stringency"))),
                                        width = 12)
                    
                  )
          ),
          
          tabItem(tabName = "performance",
                  h2("Your Past Performnace"), 
                  mod_past_performance_ui("past_performance")
          ),
          
          tabItem(tabName = "account",
                  h2("Account information"), 
                  mod_account_details_ui("account_details")
                  
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

