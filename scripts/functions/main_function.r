
# Main Function


### Master Function
#The master function constructs a dataframe for a single iteration of MC variables, populates it and performs the serum calculations. It returns only the last row of the dataframe.

#The following table defines the columns of the result dataframe:

# Column | Description | Formula
#-------|------------|---------------------------------------------
# Time | Exact model age (years)| Days/days_per_year
# Years| Years old| floor(Days/days_per_year)
# Months | Months old | floor(Days/days_per_month)
# Days | Days old| seq(1,total_steps,timestep), where total_steps = ceiling((ed-sd)/timestep)
# Date | Calendar date| seq(sd,ed,timestep)
# DWC | Drinking Water Concentration| MC varied concs looked up with water_concs_dates and set to 0 before 1960
# DWI | Drinking Water Intake| Mean DWI (looked up from source file) * MC varied DWI adjustment factor (DWIaf)
# BW | Body Weight | MC varied BW and the creation_date are used to select the individual's weight percentile at the current age. BW over time is looked up by age from that percentile
# Daily_Dose_DW | Daily Dose from Drinking Water| MC varied perc_tap looked up by date * (DWC/1000)*(DWI/1000)/BW. Set to 0 during breastfeeding and drinking store bought formula
# Vd | Volume of distribution, for each time t | Age_adjust * MC varied V_d. Age_adjust is an adjustment factor for the volume of distribution in children, otherwise it is 1
# Bkgd_serum | Background Serum | MC Varied BkgdF, BkgdM, BkgdFk, or BkgdMk when Days = 1, and a Time Step Adjustment (TSA) for Days > 1 to account for decay.
# Daily_Dose_BM | Daily Dose of Breast Milk. Only used for breastfeeding infants during breastfeeding |  (BMC)*(BMI/1000)/BW_i, where BMC is Breast Milk Concentration, calculated using mother's steady state serum concentration and MC varied MatXfer; BMI is Mean Breast Milk Intake for the infant, looked up from the source file; and BW_i is the Median Body Weight of infants looked up from the source file which differs by gender.
# Serum_b | Serum concentration before elimination | Bkgd_serum + TSA + timestep * (Daily_Dose_DW/Vd), for t = 1. For all t > 1, Serum_a[@t-1] + TSA + timestep * (Daily_Dose_DW/Vd). For infants this is initialized with the steady state value for mother's serum at the time of birth, using MC varied PlacXfer. The Serum_b calculation for infants includes an additional Daily_Dose_BM component. For adults, it is initialized with the background serum.
# Serum_a | Serum concentration after elimination | Serum_b * DecayPerStep. While women are breastfeeding, we substitute CRBFPerStep for DecayPerStep to add additional decay for breast milk clearance. These are calculated with MC varied Halflife, MC varied MilkClearnance and MC varied MatRemove
# id | Unique row identifier | 1:n

#' PBPK main function
#'
#' @param parameter_list A list of various model settings entered by a user  
#' @param source_data A list of data frames loaded from the source file  
#' @param DWIaf Monte Carlo varied adjustment factor for drinking water intake  
#' @param BW Monte Carlo varied body weight in kg  
#' @param HL Monte Carlo varied PFAS half-life in years  
#' @param V_d Monte Carlo varied volume of distribution in 1/kg  
#' @param MatXfer Monte Carlo varied rate of transfer from a mother's PFAS serum concentration to her breast milk  
#' @param MatRemove Monte Carlo varied rate of elimination from a mother's blood serum through breast feeding  
#' @param MilkClearance Monte Carlo varied rate of elimination of PFAS concentrations in breast milk  
#' @param PlacXfer Monte Carlo varied rate of transfer from a mother's PFAS serum concentration at birth to her infant via the placenta  
#' @param BkgdF Monte Carlo varied background PFAS concentration in blood serum for females 6 years old or older  
#' @param BkgdM Monte Carlo varied background PFAS concentration in blood serum for males 6 years old or older  
#' @param BkgdFk Monte Carlo varied background PFAS concentration in blood serum for females younger than 6 years old  
#' @param BkgdMk Monte Carlo varied background PFAS concentration in blood serum for males younger than 6 years old  
#' @param perc_tap Monte Carlo varied values perc_tap (from the parameter_list) for the percentage of drinking water intake coming from tap water at different points in time perc_tap_dates (from parameter_list)      
#' @param concs Monte Carlo varied values water_concs (from the parameter_list) for the concentration of PFAS in tap water at different points in time water_concs_dates  (from the parameter_list)  
#' @param iter iteration number for printing to console  
#'
#' @return a data frame with each row representing a timestep and the PFAS serum concentrations populated in column 'Serum_a'  
#'
main_func <- function(parameter_list, source_data, DWIaf, BW, HL, V_d, MatXfer, MatRemove, MilkClearance,
                      PlacXfer, BkgdF, BkgdM, BkgdFk, BkgdMk, perc_tap, concs, iter, full = FALSE, dwi_units = "mL/day"){
  
  # max val for perc_tap is 1
  perc_tap[perc_tap >1] <- 1
  
  # stage the output dataframe, name the columns, populate dates/ages
  staged_frame <- create_frame(sd = parameter_list$sd, 
                      ed = parameter_list$ed, 
                      timestep = parameter_list$timestep)
  
  # populate BW with BW percentile chosen by using BW & creation date to calculate current ages
  # then look up in percentiles of NHANES
  # source loads tabs BW_F & BW_M 
  staged_frame <- pop_BW(data = staged_frame, 
                         gender = parameter_list$gender,
                         sd = parameter_list$sd,
                         source = source_data,  BW = BW,
                         creationDate = parameter_list$creation_date)
  
  # populate DWI column & adjust with DWIaf
  # source loads tabs DWI & Breastfeeding 
  staged_frame <- pop_DWI_BMI(data = staged_frame, source = source_data,
                               fed_most = parameter_list$fed_most, fed_mo = parameter_list$fed_mo,
                               AF = DWIaf, dwi_units = dwi_units)
  
  # populate DWC column with MC varied concs and water_concs_dates
  staged_frame <- pop_DWC(data = staged_frame, 
                          water_concs_dates = parameter_list$water_concs_dates,
                          water_concs = concs)
  
  # populate V_d column with age adjustment factor * V_d
  # source loads tabs Age-Adjust 
  staged_frame <- pop_AA_VD(data = staged_frame, source = source_data, Vd = V_d)
  
  # populate Bkgd_serum column depending on gender and current age (calculated with creationDate & sd),
  #     uses HL & timestep to calculate Decay Time Step Adjustment for Bkgd_serum
  staged_frame <- pop_BG(data = staged_frame, gender = parameter_list$gender,
                         BGF = BkgdF, BGM = BkgdM, BGFk = BkgdFk, BGMk = BkgdMk,
                         creation_date = parameter_list$creation_date, sd = parameter_list$sd,
                         timestep = parameter_list$timestep, HL = HL)
  
  result <- serum_calc(data = staged_frame, timestep = parameter_list$timestep,
                       numChild = parameter_list$numChild, 
                       child_bday = parameter_list$child_bday, child_bf_mo = parameter_list$child_bf_mo, 
                       sd = parameter_list$sd, creation_date = parameter_list$creation_date,
                       gender= parameter_list$gender, mom_pct_tap = parameter_list$mom_pct_tap,
                       perc_tap = perc_tap,  perc_tap_dates = parameter_list$perc_tap_dates,
                       MatXfer = MatXfer, PlacXfer = PlacXfer, 
                       MilkClear = MilkClearance, MatRemove = MatRemove, 
                       HL = HL, VD = V_d,  BGF = BkgdF, # for mother's serum calc
                       fed_most = parameter_list$fed_most) 
  
  if(!full){result <- result[nrow(result),]} # filter if full = FALSE (default)
  
  return( result)
}
