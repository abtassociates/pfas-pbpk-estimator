#' Look up age adjustment factor
#'
#' @param age_adjust data frame of age adjustment factors
#' @param d age in days
#'
#' @return age adjustment factor for an individual d days old
#'
age_adjust <- function(age_adjust, d){
  # d in this function is days old
  # age_adjust is the AgeAjust tab of the source file. 
  r <- which(age_adjust$`_Metric`=="age_adjust") # factor value
  t1 <- which(age_adjust$`_Metric`=="Age_start") # start age in days
  t2 <- which(age_adjust$`_Metric`=="Age_end") # end age in days
  
  d <- as.numeric(d) 
  
  aa <- age_adjust[r,max(which(age_adjust[t1,] <= d))] %>% as.numeric()
  
  if(d > age_adjust[t2, ncol(age_adjust)]){ aa <- 1 }
  
  return(aa)
}