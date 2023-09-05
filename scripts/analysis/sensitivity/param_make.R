# Set preferred parameters as follows
#' Title
#'
#' @param chemical PFAS chemical - "PFOA", "PFOS", "PFHxS", or 'PFNA', defaults to "PFOA"
#' @param water_concs list of concentrations in tap water (ug/L), defaults to c(.1,0.002)
#' @param water_concs_dates list of start dates of water concentrations in the format "YYYY-MM-DD" and must be the same length as 'water_concs', defaults to c("1960-1-1", "2020-1-1")
#' @param perc_tap list of fractional drinking water intakes from tap water, defaults to c(0.9) = 90% intake from tap water
#' @param perc_tap_dates list of start dates of percentage of drinking water intake from tap in the format "YYYY-MM-DD" and must be the same length as 'perc_tap'. This input is initialized in 1900-01-01 which is the default.
#' @param mom_pct_tap  individual's mother's percent drinking water intake from tap water at birth, defaults to 1 = 100% intake from tap water
#' @param gender sex of the individual - "Male" or "Female", defaults to "Male"
#' @param BW current body weight (kg) of simulated individual, defaults to 81.6; used to select body weight percentile at current age (calculated with creation_date which we assume is ed)
#' @param fed_most What was the individual fed most as an infant? - "breast milk", "tap water" (for formula made with tap water), or "other formula" (for store bought formula), defaults to "tap water"
#' @param fed_mo How many months were they breast-fed or formula-fed?, defaults to NA - ignored if fed_most = "tap water", maximum 6 if fed_most = "breast milk", defaults to 6 for fed_most = "breast milk" and 12 if fed_most = "other formula"
#' @param numChild  number of children breastfed, defaults to 0
#' @param child_gender list of sexes for each child breastfed, defaults to c(NA); must be length 'numChild'
#' @param child_bday list of birth dates in the format "YYYY-MM-DD", defaults to c(NA); must be length 'numChild'
#' @param child_bf_mo  list of how many months each child was breastfed, defaults to c(NA); must be lenght 'numChild'
#' @param niter number of Monte Carlo iterations for simulation, defaults to 1 (since sensitivities won't be varied). Recommendation: set to 10 for initial testing, and to 1000 for full simulation. Values over 1000 not recommended to avoid intensive computing.  
#' @param timestep Length of time step (days between calculations). 30 day time step is recommended for ease of simulation. Shorter time steps are slower to run. 
#' @param sd start date of simulation i.e. the individuals birth date in the format "YYYY-MM-DD", defaults to as.Date("1980-01-1")
#' @param ed end date of simulation, defaults to as.Date("2022-01-01") - the sensitivity uses this end date as the result 'creation_date' to correctly calculate current age
#'
#' @return a list of parameters
#'
#' @examples
#' 
#' param_list_pfoa <- param_make(chemical = "PFOA", 
#'                              water_concs = c(.1, 0.005), # concentrations in tap water (ug/L)
#'                              water_concs_dates = c("1960-1-1", "2020-1-1"), 
#'                              perc_tap = c(.9), 
#'                              gender = "Male", 
#'                              BW = 86.62, niter = 1, timestep = 30, 
#'                              sd = as.Date("1982-01-1"), # start date of simulation, 
#'                              ed = as.Date("2022-01-01"))
#'                              
param_make <- function (chemical = "PFOA", 
                        water_concs = c(.1,0.002),
                        water_concs_dates = c("1960-1-1", "2020-1-1"), 
                        perc_tap = c(.9), 
                        perc_tap_dates = c("1900-1-1"), 
                        mom_pct_tap = 1, 
                        gender = "Male",  
                        BW = 81.6,
                        
                        fed_most = "tap water", 
                        fed_mo = NA, # for how many months? (ignored when fed_most = "tap water")
                        # default 6 months for breastfeeding (breast milk intake max)
                        # default 12 months for other formula (no max)?
                        
                        # For simulated individual who has born children, with option to model clearance through breastfeeding: (ignored if gender = Male or numChild = 0)
                        numChild = 0,
                        child_gender = c(NA), 
                        child_bday = c(NA), 
                        child_bf_mo = c(NA), 
                        
                        niter = 1, 
                        timestep = 30, 
                        sd = as.Date("1982-01-1"),
                        ed = as.Date("2022-01-01"))  
{ param_list_full <- list(chemical = chemical,
                              water_concs = water_concs, 
                              water_concs_dates = water_concs_dates, 
                              perc_tap =perc_tap, 
                              
                              perc_tap_dates = perc_tap_dates, 
                              
                              mom_pct_tap = mom_pct_tap,
                              gender = gender,
                              BW = BW,
                              
                              fed_most = fed_most, 
                             
                              fed_mo = fed_mo,
                              numChild = numChild,
                              child_gender = child_gender, 
                              child_bday = child_bday, 
                              child_bf_mo = child_bf_mo, 
                              creation_date = ed, 
                              niter = niter, 
                              timestep = timestep, 
                              sd =sd,
                              ed = ed) }
