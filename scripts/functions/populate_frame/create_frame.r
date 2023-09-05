#' Create Data frame
#' stage the output data frame, name the columns, populate dates/ages
#' 
#' @param sd starting day (birthday)
#' @param ed end day of simulation
#' @param timestep number of days between calculations
#'
#' @return a dataframe with columns for date and age variables
#' 
#' @example
#' 
#' df <- create_frame("1985-1-1", "2021-1-1", timestep = 30)
#' 
create_frame <- function(sd, ed, timestep = 30){

  require(dplyr)
  days_per_year <- 365
  days_per_month <- days_per_year/12
   
  if(is.character(sd)){sd = as.Date(sd)} 
  if(is.character(ed)){sd = as.Date(ed)} 
  
  data <- data.frame("id" = 1:(ceiling((ed-sd)/timestep) +1))
  data <- data %>% 
    mutate("Days" = seq(1,(nrow(data))*timestep, timestep),
           "Months" = floor(Days/days_per_month),
           "Years" = floor(Days/days_per_year),
           "Time" = Days/days_per_year,
           "Date" = seq(as.Date(sd),
                       as.Date(as.numeric(as.Date(sd))+(nrow(data)-1)*timestep, 
                               origin = "1970-1-1"), timestep))
  
  return( data )
}
