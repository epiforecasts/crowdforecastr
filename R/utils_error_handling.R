try_and_wait <- function(expr, 
                         type = "warning", 
                         message, 
                         time_to_wait = 25) {
  out <- attempt::attempt(expr)
  
  message <- paste(message, 
                   "This sometimes fails when too many requests are sent at the same time - sorry! We'll keep retrying every 25 seconds - usually this shouldn't take too long. Thanks for putting your time and effort into participating, we very much appreciate it!")
  
  while (attempt::is_try_error(out)){
    shinyalert::shinyalert(type = type, 
                           text = message, 
                           closeOnClickOutside = TRUE)
    Sys.sleep(time_to_wait)
    out <- attempt::attempt(expr)
    shinyalert::closeAlert()
  } 
  return(out)
}