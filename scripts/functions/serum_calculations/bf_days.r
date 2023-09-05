#' Breast feeding days 
#' select which days mother is Breast feeding
#' 
#' @param data Entire dataframe to populate
#' @param gender gender of the user
#' @param child_bday children's birthdays
#' @param child_bf_mo length of breastfeeding for each child
#'
#' @return dataframe with populated Breastfeeding column
#'
#' @examples
#' 
#' # populates Breastfeeding column for 6 months after 2o18-1-1 and 4 months after 2019-1-1
#' data <- bf_days(data = data,  
#'                 gender = c("Female", "Male), 
#'                 child_bday = c("2018-1-1", "2019-1-1"), 
#'                 child_bf_mo = c(6, 4))
#'                 
bf_days <- function(data, gender, child_bday, child_bf_mo){
  
  days_per_year <- 365.2425
  days_per_month <- days_per_year/12
  
  bf_child <- which(!is.na(child_bf_mo))
  
  if(length(bf_child) > length(child_bday)){
    child_bday <- c(unique(child_bday), 
                    rep(child_bday[1], length(bf_child) - length(child_bday)) )
  }
  
  BF_dates <- c()
  
  if(gender == "Female" & length(bf_child) > 0){
    for (child in bf_child){
      BF_days <- seq(as.Date(child_bday[child], origin = "1970-1-1"),
                     as.Date(child_bday[child], origin = "1970-1-1") + 
                       (child_bf_mo[child]*days_per_month), 1)
      BF_dates <- c(BF_dates, BF_days)
    }
  }
  
  data <- data %>% mutate("Breastfeeding" = ifelse(Date %in% BF_dates,1,0))
  return(data)
}