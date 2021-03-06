#' user_management_new_user UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_user_management_new_user_consent_ui <- function(id){
  ns <- NS(id)
  instructions <- '<h3> Welcome! </h3> 
                        Please read these instructions and terms carefully. If you agree, please click "I understand and consent" to proceed. If you do not consent, you cannot use this app.
                        <br>
                        <h4> What this app does </h4>
                        This app is designed to collect forecasts from experts and non-experts. Predictions are made for weekly incident case numbers and deaths from Covid-19 in Germany and Poland. To facilitate this process we will create a user account for you, consisting of a username, a password and additional optional information you provide. 

                        <br>
                        <h4> Creating a user account </h4>
                        In order to reliably attribute forecasts to forecasters we need you to create a user account. To that end you must submit a username and password. 
                        While we would appreciate if you identified yourself (especially if you have professional experience in the field), you can also create a completely anonymous account. 
                        In the same manner, providing an email address is optional, but much appreciated. If you submit your email address we will send you a weekly reminder to make a forecast and may contact you in case of questions. 
                        In addition we ask whether you have any professional experience in the field to compare performance of experts vs. non-experts. If you have professional experience, please state your affiliation and a web link to your institution. 
                        Lastly you can opt in to have your username appear on our performance board. Alternatively, you can appear with an anonymous alias or not at all. 
                        <br>
                        <h4> Making Forecasts </h4>
                        
                        You are asked to provide a predictive distirbution for every week. You can choose a distribution and adjust the median and width of the forecast. 
                        <br>
                        Tooltips will guide you through the interface, but you can also turn them off. If you cannot see the entire user interface you may want to zoom out in your browser.
                        <br>
                        You can either drag the points to adjust forecasts or use the numeric input fields. If you want to reset the forecasts, press reset. 
                        For reference, you can look at a plot with incident cases in the chosen location. 
                        In order for your changes to take effect, please press "update". This will update the plots and the input fields. If you like, you can propagate your predictions to future dates (i.e. the values for a given horizon will be copied to future dates) by pressing "propagate". 
                        <br>
                        Once you submit a forecast, the next input will be selected until you have made forecasts for all targets. You can submit multiple times if you want and we will only count the latest submission. 
                        
                        <h4> Performance Board </h4>
                        If you like you can have your username appear on our Performance Board. The current performance board is at 
                        <a href="https://epiforecasts.shinyapps.io/performance-board/" title="epiforecasts.shinyapps.io/performance-board/"> </a> and shows different performance metrics and diagnostic plots. Alternatively, you can either have your forecasts not appear or appear with an anonymous alias. 
                        <br>
                        <h3> Data Policy</h3> 
                        
                        <h4> Responsible for the data policy </h4>
                   Nikos Bosse<br>
                   London School of Hygiene and Tropical Medicine<br>
                   Keppel Street<br>
                   WC1E 7HT London<br>
                   nikos.bosse@lshtm.ac.uk
                   <br>
                   <h4> What data we collect </h4>
                   With your consent we collect
                    <ul>
                    <li>Your name</li>
                    <li>Your email address</li>
                    <li>Your username and password</li>
                    <li>The forecasts you submit through this app</li>
                    </ul>
                    <h4> What we do with your data</h4>
                    Your username and password will be used to create a user account that you need to access this app. Your username will appear on the performance board if you opt in. 
                    <br>
                    Your name and your email address will be used to identify you and to contact you in case of questions and to send you a weekly reminder
                    <br>
                    Your forecasts will be used for research on forecasting as well as on Covid-19. Use cases will include, but are not limited to:
                    <ul>
                    <li>Sharing pseudonymised (forecasts will be attributed to forecasters using a random forecaster_id) and/or aggregate forecasts with other research institutions, especially the German Forecast Hub. These research institutions use your forecasters to make accurate predictions about the future trajectory of the COVID-19 pandemic. </li>
                    <li>Sharing pseudonymised forecasts with the public through repositories on github.com
Sharing pseudonymised forecasts instead of completely anonymous or aggregate data is necessary to a) ensure that results can be reproduced and b) allow researchers to analyse aspects that need attribution of forecasts to (pseudonymous) individuals. Examples of these include: How forecasters learn over time, how much of variation can be explained by innate ability, how we can improve ensemble models by weighting forecasts according to experience etc. 
</li>
                    <li>Using pseudonymised versions of the forecasts for scientific publications about forecasting and/or Covid-19. </li>
                    <li>Sharing pseudonymised forecasts with the public</li>
                    </ul>
                    Under no circumstances will we share your personal data (your name and your email address) with anyone. 
                    
                    <h4>How we respect your privacy</h4>
                    You yourself can decide what data you entrust us with. Once a user account is created, your identity will be pseudonymised and a random forecaster ID will be created that links all your forecasts to you. Your name and prive data will never be used or shared in public. The only exception may be the performance board: if you opt in, your username will appear on the performance board. 
                    All the forecasts as well as the corresponding forecaster IDs will however be stored on github and will be publicly accessible. While this is highly unlikely, it is not impossible that someone may find a way to link your forecaster ID to your identity,  especially if you allow your username to appear on the public performance board. 
                    
                    <h4>How do we store your data</h4>
                    Once you click submit, your data will be sent to a Google Sheet stored in a Google Drive folder. One sheet will hold your personal information (name, username, encrypted password, email address, affiliation, preference to appear on the performance board and random forecaster ID). Information in this sheet is used to manage your account and allow you to log in and make forecasts. 
                    A second sheet will hold your random forecaster ID as well as your forecasts, whether or not you are an expert and the name with which you appear on the performance board (either your username or a pseudonym like "Anyonymous Alpaca"). 
                    <br>
Every Tuesday, the forecast sheet will be cleared and forecasts will be deleted from Google Drive (information that links your personal information to the forecaster ID remains). Forecasts will be uploaded to Github, containing no private information you did not allow to share. In addition, the performance board will be updated using the name you provided in the app.
                    <h4> How long do we store your data? </h4>
We will store the data as long as is necessary to conduct research on forecasting and Covid-19. We will store your personal information (name and email) as long as may be necessary to contact you with questions and updates. We expect to delete all personal information no later than the end of 2022.
<br>
Pseudonymised versions of your forecasts may be stored indefinitely, e.g. as part of a publication.
<br>
You can, at any point, request deletion of your personal data. To that end, please send an email at nikos.bosse@lshtm.ac.uk.'
    
    
  tagList(
    HTML(instructions),
    br(),
    br(),
    
    fluidRow(column(3, actionButton(inputId = ns("consent"), 
                                    label = "I understand and consent")), 
             column(3, actionButton(inputId = ns("backtologin"), 
                                    label = "Back to login"))),
    footer = NULL,
 
  )
}
    
#' user_management_new_user Server Functions
#'
#' @noRd 
mod_user_management_new_user_consent_server <- function(id, user_management){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    observeEvent(input$consent, {
      user_management$consent_given <- TRUE
      user_management$open_create_user_form <- TRUE
      user_management$open_new_user_consent <- FALSE
    })
    observeEvent(input$backtologin, {
      user_management$open_login <- TRUE
      user_management$open_new_user_consent <- FALSE
    })
 
  })
}
    
## To be copied in the UI
# mod_user_management_new_user_ui("user_management_new_user_ui_1")
    
## To be copied in the server
# mod_user_management_new_user_server("user_management_new_user_ui_1")
