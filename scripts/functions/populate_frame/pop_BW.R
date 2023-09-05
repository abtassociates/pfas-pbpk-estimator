#' Populate Body Weight
#' populate BW with BW percentile chosen by using BW & creation date to calculate current ages
#' source loads tabs BW_F & BW_M 
#'
#' @param data Data frame created in [create_frame()] and modified by other functions
#' @param source a list of data frames loaded from the source file
#' @param gender User's gender; passed from parameter_list
#' @param sd the user's birthday, the start date of the simulation; passed from parameter_list
#' @param creationDate the creation date of the simulation, for matching results from previous days; defaults to today
#' @param BW Monte Carlo varied body weight in kg
#'
#' @return data with new column BW
#' 
pop_BW <- function(data = data.frame(), source = list(), 
                        gender, sd, creationDate = Sys.Date(), BW){
  
  require(dplyr)
  days_per_year <- 365.2425
  days_per_month <- days_per_year/12
  
  if(gender == "Male"){
    body_weight <- source[["BW_M"]]
  }else if(gender == "Female"){
    body_weight <- source[["BW_F"]]
  }
  
  # for bodyweight, split into infant (months) and adults (years)
  body_weight_infant <- body_weight[as.numeric(body_weight$age) < 1, ]
  body_weight_adult <- body_weight[as.numeric(body_weight$age) >= 1 | 
                               as.numeric(body_weight$age) == 0, ] # leave zero row for row indexing
  
  # calculate weight percentile
  curage <- as.Date(creationDate, origin = "1970-1-1") - as.Date(sd, 
                                                                 origin = "1970-1-1")
  r <- which(body_weight_adult$age == floor(as.numeric(curage)/days_per_year)) 
  # get row for current age of user when entering body weight
  # first col is age, causes issues when age == BW
  if(length(which((as.numeric(body_weight_adult[r,2:ncol(body_weight_adult)]) - as.numeric(BW)) > 0)) == 0){
    # if all values are < 0, set at 100 percentile
    BWperc <- ncol(body_weight_adult) 
  }else{
    BWperc <- min(which((as.numeric(body_weight_adult[r,2:ncol(body_weight_adult)]) - as.numeric(BW)) > 0)) + 1
    # add + 1 to correct for missing age col
  }
  
  if(floor(as.numeric(curage)/days_per_year) == 0){ # IF INFANT, use infant df instead
    
    r <- which.min(abs((body_weight_infant$age - as.numeric(curage)/days_per_year ) ))
    # first col is age, causes issues when age == BW
    if(length(which((as.numeric(body_weight_infant[r,2:ncol(body_weight_infant)]) - as.numeric(BW)) > 0)) == 0){
      # if all values are < 0, set at 100 percentile
      BWperc <- ncol(body_weight_infant) 
    }else{
      BWperc <- min(which((as.numeric(body_weight_infant[r,2:ncol(body_weight_infant)]) - as.numeric(BW)) > 0)) + 1
      # add + 1 to correct for missing age col
    }
  }
 
  if(as.numeric(BW)==0){ # TS model assumes p50 for children and provides BW = 0
    BWperc <- which(colnames(body_weight_adult) == "p50")
    # this will be the same regardless of adult/infant df
  }
  
  BW_list <- t(body_weight_adult[,BWperc]) # get list of BW from percentile column
  BW_list_inf <- t(body_weight_infant[,BWperc]) # for baby get same percentile column from infant frame
  
  # populate body weight
  data <- data %>% mutate("BW" = ifelse(Years >= 1,as.numeric(BW_list[Years +1 ]),
                                        as.numeric(BW_list_inf[Months+1])))
  return(data)
}
