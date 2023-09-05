#' Populate Drinking Water Concentrations
#' populate DWC column with MC varied concs and water_concs_dates
#'
#' @param data Data frame created in [create_frame()] and modified by other functions
#' @param water_concs_dates Dates of the changes in the PFAS concentration of tap water, passed from parameter_list
#' @param concs Monte Carlo varied values (parameter_list$water_concs) for the concentration of PFAS in tap water at different points in time (parameter_list$water_concs_dates)
#'
#' @return data with new column DWC
#' 
pop_DWC <- function(data, water_concs_dates, water_concs ){
  # lookup drinking water concentration for each date
  water_concs_dates <- water_concs_dates %>% as.Date(origin = "1970-1-1")
  
  data$DWC <- rep(unlist(water_concs)[1], nrow(data)) 
  data <- data %>% rowwise %>%
    mutate(DWC = ifelse(as.Date(as.character(Date), origin = "1970-1-1") <= water_concs_dates[1],
                        DWC,
                        unlist(water_concs)[max(which(water_concs_dates <= as.Date(as.character(Date), 
                                                                            origin = "1970-1-1")))])) 
  # replace with 0 if before 1960
  data <- data %>% mutate(DWC = ifelse(Date < as.numeric(as.Date("1960-1-1")), 0, DWC))
  return(data) 
}