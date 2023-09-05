#' Populate Background Serum
#' populate Bkgd_serum column depending on gender and current age (calculated with creation_date and sd),
#' uses HL and timestep to calculate Decay Time Step Adjustment for Bkgd_serum
#'
#' @param data Data frame created in [create_frame()] and modified by other functions
#' @param BkgdF Monte Carlo varied background PFAS concentration in blood serum for females 6 years old or older
#' @param BkgdM Monte Carlo varied background PFAS concentration in blood serum for males 6 years old or older
#' @param BkgdFk Monte Carlo varied background PFAS concentration in blood serum for females younger than 6 years old
#' @param BkgdMk Monte Carlo varied background PFAS concentration in blood serum for males younger than 6 years old
#' @param gender User's gender; passed from parameter_list
#' @param sd User's birthday, the start date of the simulation; passed from parameter_list
#' @param creationDate Creation date of the simulation, for matching results from previous days; passed from parameter_list and defaults to today
#' @param timestep Number of days between calculations; passed from parameter_list
#' @param HL Monte Carlo varied PFAS half-life in years
#'
#' @return data with a new column Bkgd_serum
#' 
pop_BG <- function(data, BGF, BGM, BGFk, BGMk, gender,
                   creation_date, sd,  
                   timestep, HL){
  days_per_year <- 365.2425
  # calc current age
  curage <- as.Date(creation_date, origin = "1970-1-1") - 
    as.Date(sd, origin = "1970-1-1")
  
  # choose BG based on gender and curage  
  if(gender == "Female" & curage < 12*days_per_year){BG <-  BGFk *0.8
  }else if(gender == "Female" ){BG <-  BGF *0.8
  }else if(gender == "Male" & curage < 12*days_per_year){BG <-  BGMk *0.8
  }else if(gender == "Male"){BG <-  BGM *0.8
  }else{ stop() }
  
  # create clearance values
  k <- log(2)/(HL *365) # 1/d
  DecayPerStep <- exp(-(k)*timestep)
  
  # set BG and calculate TSA (background the gets eliminated each time step)
  TSA <- as.numeric(BG)/1000 *(1-DecayPerStep) 
  
  data[1, "Bkgd_serum"] <- as.numeric(BG) / 1000 # convert to mg/L from ug/L
  data[2:nrow(data), "Bkgd_serum"] <- TSA 
  return(data)
}