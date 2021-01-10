#' user_management_create_user UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_user_management_create_user_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(column(12, h3("Your Name"))),
    fluidRow(column(12, textInput(ns("name"), label = NULL))),
    fluidRow(column(12, "Please enter your name. (If you really do not wish to be identified, you can also enter an imaginary name or leave it blank.)")),
    # br(),
    fluidRow(column(12, h3("User Name and Performance Board"))),
    fluidRow(column(6, textInput(ns("username"), label = "Your username")), 
             column(6, radioButtons(inputId = ns("appearboard"), label = "Appear on Performance Board?", 
                                           choices = c("yes", "anonymous"), selected = "anonymous", inline = TRUE))), 
    fluidRow(column(12, "Please provide a username needed to log in. If you select the appropriate option, this username will also appear on our performance board. If you select 'anonymous', an anonymous alias will appear instead")),
    # br(), 
    fluidRow(column(12, h3("Password"))),
    fluidRow(column(6, passwordInput(ns("password"), "Choose a password")), 
             column(6, passwordInput(ns("password2"), "Repeat password"))),
    # br(),
    fluidRow(column(12, h3("Email"))),
    fluidRow(column(12, "Please submit your email, if you like. If you provide your email, we will send you weekly reminders to conduct the survey and may contact you in case of questions.")), 
    fluidRow(column(12, textInput(ns("email"), label = "Email"))),
    fluidRow(column(12, h3("Domain Expertise"))),
    fluidRow(column(4, 
                    checkboxInput(inputId = ns("expert"), 
                                  label = "Do you have domain expertise?")), 
             column(4, textInput(inputId = ns("affiliation"), label = "Affiliation")),
             column(4, textInput(inputId = ns("affiliationsite"), "Institution website"))),
    fluidRow(column(12, "If you work in infectious disease modelling or have professional experience in any related field, please tick the appropriate box and state the website of the institution you are or were associated with")),
    br(),
    fluidRow(column(3, actionButton(inputId = ns("createnew"), 
                                    label = HTML("<b>Create New User</b>"))), 
             column(3, actionButton(inputId = ns("backtologin"), 
                                    label = "Back to login")))
 
  )
}
    
#' user_management_create_user Server Functions
#'
#' @noRd 
mod_user_management_create_user_server <- function(id, user_management, 
                                                   user_data, 
                                                   user_data_sheet_id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    observeEvent(input$createnew,
                 {
                   if ((input$username != "") && (input$password != "")) {
                     existing_users <- unique(user_data$username)
                     
                     if (input$username %in% existing_users) {
                       showNotification("Username already taken", type = "error")
                     } else if (input$password != input$password2) {
                       showNotification("Passwords don't match", type = "error")
                     } else {
                       showNotification("New user created", type = "message")
                       removeModal()
                       
                       generate_random_id <- function() {
                         existing_ids <- unique(user_data$forecast_id)
                         id <- round(runif(1) * 1000000)
                         while (id %in% existing_ids) {
                           id <- round(runif(1) * 1000000)
                         }
                         return(id)
                       }
                       
                       create_leaderboard_name <- function() {
                         if (input$appearboard == "yes") {
                           board_name <- input$username
                         } else {
                           existing_names <- unique(user_data$board_name)
                           
                           used_animals <- gsub(".*_","", existing_names)
                           free_animals <- setdiff(crowdforecastr::animals, used_animals)
                           
                           if (length(free_animals) > 0) {
                             n <- length(free_animals)
                             index <- sample(x = 1:n, size = 1)
                             board_name = paste0("anonymous_", free_animals[index])
                           } else {
                             # make this more flexible in the future
                             animal_list <- paste0(animal_list, "_2")
                             free_animals <- setdiff(animal_list, used_animals)
                             n <- length(free_animals)
                             index <- sample(x = 1:n, size = 1)
                             board_name = paste0("anonymous_", free_animals[index])
                           }
                         }
                         return(board_name) 
                       }
                       
                       current_user_data <- data.frame(forecaster = input$name, 
                                                       username = input$username,
                                                       password = sodium::password_store(input$password),
                                                       email = input$email,
                                                       expert = input$expert,
                                                       appearboard = input$appearboard,
                                                       affiliation = stringr::str_to_lower(input$affiliation),
                                                       website = stringr::str_to_lower(input$affiliationsite),
                                                       forecaster_id = generate_random_id(), 
                                                       board_name = create_leaderboard_name())
                       
                       googlesheets4::sheet_append(data = current_user_data, 
                                                   ss = user_data_sheet_id)
                       
                       user_management$current_user_data <- current_user_data
                       
                     }
                   } else {
                     showNotification("Username or password missing", type = "error")
                   }
                 })
    
    observeEvent(input$backtologin, {
      user_management$open_login <- TRUE
      user_management$open_create_user_form <- FALSE
    })
    
  })
}
    
## To be copied in the UI
# mod_user_management_create_user_ui("user_management_create_user_ui_1")
    
## To be copied in the server
# mod_user_management_create_user_server("user_management_create_user_ui_1")
