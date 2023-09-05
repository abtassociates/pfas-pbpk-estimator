#' Quantile List
#' This function column binds the serum concentration results for each iteration. 
#' It then calculates the mean, 5th percentile and 95th percentile for every time step.
#'
#' @param results list of result dataframes for each iteration
#' @param parameters parameter list, used to count number of iterations
#'
#' @return data frame of 5th percentile (lbound), 9th percentile (ubound), and mean serum concentrations at every time step (Date)
#' 
quantile_list <-  function(results, parameters){
  
  res_df <- NULL
  
  for (i in 1:parameters$niter){
    cols <- colnames(res_df)
    res_df <- cbind(res_df, results[[i]]$Serum_a) 
    colnames(res_df) <- c(cols, paste0("iter",i))
  }
  
  if(nrow(res_df) > 1){
    res_sum <- rowQuantiles(res_df , probs = c(0.05, 0.95)) %>% as.data.frame()
  }else{
    res_sum <- quantile(res_df, probs = c(0.05,0.95)) %>% t() %>% as.data.frame()
  }
  
  res_sum$Mean <- rowMeans(res_df, na.rm = TRUE) # Row Means functions were buggy
  res_sum$Date <- results[[1]]$Date %>% as.Date(origin = "1970-1-1")
  colnames(res_sum) <- c("lbound", "ubound", "Mean", "Date")
  
  res_df <- as.data.frame(res_df %>% t())
  colnames(res_df) <- results[[1]]$Date
  
  return(res_df)
}