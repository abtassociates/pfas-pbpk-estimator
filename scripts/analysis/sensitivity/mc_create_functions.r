#' create monte carlo inputs for an adult male
#'
#' @param plist parameter list for sensitivity
#' @param sourceData  list of source data sheets from the source file
#' @param pfas chemical - default set to PFOA
#' @param BW_range range of values to use as the low, mid and high estimate for body weight (kg)
#' @param DWIaf_range range of values to use as the low, mid and high estimate for the drinking water intake adjustment factor (unitless)
#' @param HL_range range of values to use as the low, mid and high estimate for half life (years)
#' @param V_d_range range of values to use as the low, mid and high estimate for volume of distribution (1/L)
#' @param Bkgd_range range of values to use as the low, mid and high estimate for background serum (ug/L)
#' @param Sex gender of the individual - default set to male
#' @param concs_range range of values to use as the low, mid and high estimate for drinking water concentration (ug/L)
#' @param perc_tap_range range of values to use as the low, mid and high estimate for percent of drinking water intake from tap water (unitless)
#'
#' @return a data frame with all the different model input combinations as rows
#' 
#' @examples
#'  pfoa <-   mc_create_M(plist = param_list_PFOA_ucmr5, sourceData = sourceData)
#'                        
#'  pfos <- mc_create_M( plist = param_list_PFOS_ucmr5, 
#'                       sourceData = sourceData , pfas = "PFOS", 
#'                       HL_range =  c(2.2, 3.36, 10.6) , 
#'                       V_d_range =  c(0.23, 0.32, 0.47),
#'                       Bkgd_range = c(2.4, 5.362624307, 11.97 ))
#'                       
mc_create_M <- function(plist = param_list_PFOA_ucmr5, sourceData = sourceData , pfas = "PFOA", 
                        BW_range = c(64.9, 86.62, 125), DWIaf_range = c(0.7, 1, 1.3),
                        HL_range =  c(2.1, 3.14, 10.2) , V_d_range =  c(0.17, 0.434, 0.59),
                        Bkgd_range = c(0.6, 1.607060362 , 4 ) ,  Sex = "Male",
                        concs_range = list(data.frame(t1 = .1, t2 = .002), 
                                           data.frame(t1 = .1, t2 = .005),  
                                           data.frame(t1 =.1, t2=.01)),
                        perc_tap_range = list(data.frame(perc_tap = 0.5),
                                              data.frame(perc_tap = 0.9),
                                              data.frame(perc_tap = 1))){
  
  MC_vars  <- monte_carlo_vars( param_list = plist, sourceData = sourceData ) 
  
  mcvars_pfas <- MC_vars %>% bind_rows (MC_vars, MC_vars) 
  
  sensivary_perc_tap <- mcvars_pfas %>% mutate(iter = c(1:3), perc_tap = perc_tap_range)
  sensivary_DWC <- mcvars_pfas %>% mutate(iter = c(1:3), concs = concs_range)
  sensivary_DWIaf <- mcvars_pfas %>% mutate(iter = c(1:3), DWIaf = DWIaf_range)
  sensivary_BW <- mcvars_pfas %>% mutate(iter = c(1:3), BW = BW_range)
  sensivary_HL  <-  mcvars_pfas %>%   mutate( iter = c(1:3), HL =  HL_range ) 
  sensivary_V_d  <- mcvars_pfas %>% mutate( iter = c(1:3), V_d =  V_d_range )
  
  if(Sex == "Male"){
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdM = Bkgd_range, BkgdMk = Bkgd_range,  )
  }else{
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdFk = Bkgd_range, BkgdF = Bkgd_range)
  }
  
  sensivary <- bind_rows(sensivary_DWIaf,sensivary_BW, sensivary_HL , sensivary_V_d , 
                         sensivary_bkg, sensivary_perc_tap, sensivary_DWC ) }

#' create monte carlo inputs for an adult female
#'
#' @param plist parameter list for sensitivity
#' @param sourceData  list of source data sheets from the source file
#' @param pfas chemical - default set to PFOA
#' @param BW_range range of values to use as the low, mid and high estimate for body weight (kg)
#' @param DWIaf_range range of values to use as the low, mid and high estimate for the drinking water intake adjustment factor (unitless)
#' @param HL_range range of values to use as the low, mid and high estimate for half life (years)
#' @param V_d_range range of values to use as the low, mid and high estimate for volume of distribution (1/L)
#' @param Bkgd_range range of values to use as the low, mid and high estimate for background serum (ug/L)
#' @param Sex gender of the individual - default set to female
#' @param MatRemove_range range of values to use as the low, mid, and hight estimate for Maternal Removal Rate (elimination from blood serum while breastfeeding, unitless)
#' @param concs_range range of values to use as the low, mid and high estimate for drinking water concentration (ug/L)
#' @param perc_tap_range range of values to use as the low, mid and high estimate for percent of drinking water intake from tap water (unitless)
#'
#' @return a data frame with all the different model input combinations as rows
#'
#' @examples
#' 
#' pfoa <- mc_create_F(plist = param_list_PFOA_ucmr5, sourceData = sourceData)
#' 
#' pfos <- mc_create_F( plist = param_list_PFOS_ucmr5, 
#'                      sourceData = sourceData , pfas = "PFOS", 
#'                      HL_range =  c(2.2, 3.36, 10.6) , V_d_range =  c(0.23, 0.32, 0.47),
#'                      Bkgd_range = c(1.32,	3.414556018,	8.78 ),
#'                      MatRemove_range = c(0.22,	0.23,	0.24))
#' 
mc_create_F <- function(plist = param_list_PFOA_ucmr5, sourceData = sourceData , pfas = "PFOA", 
                        BW_range = c(51.3, 71.45, 115.5), DWIaf_range = c(0.7, 1, 1.3),
                        HL_range =  c(2.1, 3.14, 10.2) , V_d_range =  c(0.17, 0.434, 0.59),
                        Bkgd_range = c(0.42, 1.262484175, 3.8 ) ,  Sex = "Female",
                        MatRemove_range = c(.46,.48,.54),
                        perc_tap_range = list(data.frame(perc_tap = 0.5), data.frame(perc_tap =0.9), 
                                              data.frame(perc_tap = 1)),
                        concs_range = list(data.frame(t1 = .1, t2 = .002), data.frame(t1 = .1, t2 = .005),  
                                           data.frame(t1 =.1, t2=.01))){
  
  MC_vars  <- monte_carlo_vars( param_list = plist, sourceData = sourceData ) 
  
  mcvars_pfas <- MC_vars %>% bind_rows (MC_vars, MC_vars) 
  
  sensivary_perc_tap <- mcvars_pfas %>% mutate(iter = c(1:3), perc_tap = perc_tap_range)
  sensivary_DWC <- mcvars_pfas %>% mutate(iter = c(1:3), concs = concs_range)
  sensivary_DWIaf <- mcvars_pfas %>% mutate(iter = c(1:3), DWIaf = DWIaf_range)
  sensivary_BW <- mcvars_pfas %>% mutate(iter = c(1:3), BW = BW_range)
  sensivary_HL  <-  mcvars_pfas %>%   mutate( iter = c(1:3), HL =  HL_range ) 
  sensivary_V_d  <- mcvars_pfas %>% mutate( iter = c(1:3), V_d =  V_d_range )
  
  if(Sex == "Male"){
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdM = Bkgd_range, BkgdMk = Bkgd_range,  )
  }else{
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdFk = Bkgd_range, BkgdF = Bkgd_range)
  }
  
  sensivary_MatRemove <- mcvars_pfas  %>% mutate( iter = c(1:3), MatRemove = MatRemove_range )
  
  
  sensivary <- bind_rows(sensivary_DWIaf,sensivary_DWC,sensivary_BW, sensivary_HL , sensivary_V_d , sensivary_bkg,
                         sensivary_MatRemove, sensivary_perc_tap)
}

#' create monte carlo inputs for a child
#'
#' @param plist parameter list for sensitivity
#' @param sourceData  list of source data sheets from the source file
#' @param pfas chemical - default set to PFOA
#' @param infant True or False, whether the child is under 6 months old
#' @param BW_range range of values to use as the low, mid and high estimate for body weight (kg)
#' @param DWIaf_range range of values to use as the low, mid and high estimate for the drinking water intake adjustment factor (unitless)
#' @param HL_range range of values to use as the low, mid and high estimate for half life (years)
#' @param V_d_range range of values to use as the low, mid and high estimate for volume of distribution (1/L)
#' @param Bkgd_range range of values to use as the low, mid and high estimate for background serum (ug/L)
#' @param Sex gender of the individual - default set to female
#' @param MatXfer_range range of values to use as the low, mid and high estimate for Maternal Transfer Rate (transfer from blood to breast milk, unitless)
#' @param MilkClear_range range of values to use as the low, mid and high estimate for Milk Clearance Rate (elimination from breast milk, unitless)
#' @param PlacXfer_range  range of values to use as the low, mid and high estimate for Placental Transfer Rate (transfer from mother's blood to infant's blood via the placenta, unitless)
#' @param concs_range range of values to use as the low, mid and high estimate for drinking water concentration (ug/L)
#' @param perc_tap_range range of values to use as the low, mid and high estimate for percent of drinking water intake from tap water (unitless)
#'
#' @return a data frame with all the different model input combinations as rows
#'
#' @examples
#'
#' # for a 6 month old female (infant)
#' pfoa <- mc_create_child( plist = param_list_PFOA_ucmr5, sourceData = sourceData)
#' 
#' pfos <- mc_create_child( plist = param_list_PFOS_ucmr5, 
#'                          sourceData = sourceData , pfas = "PFOS",
#'                          HL_range =  c(2.2, 3.36, 10.6) , 
#'                          V_d_range =  c(0.23, 0.32, 0.47),
#'                          Bkgd_range = c(1.64,3.699068318, 8.34), 
#'                          MatXfer_range = c(.0126,0.013,.022), 
#'                          MilkClear_range = c(0.1, 0.118,.13), 
#'                          PlacXfer_range = c(0.4, 0.42, 0.43))
#'                          
#' # for a 8 year old male (older child)
#' 
#' pfoa <-  mc_create_child(plist = param_list_PFOA_ucmr5, sourceData = sourceData,
#'                         infant = FALSE, Sex = "Male", 
#'                         Bkgd_range = c(0.084, 1.946178197, 4.52),
#'                         BW_range = c(25.44, 39.96, 67.56))   
#'                         
#'  pfos <- mc_create_child( plist = param_list_PFOS_ucmr5, Sex = "Male",
#'                          sourceData = sourceData , pfas = "PFOS", infant = FALSE,
#'                          HL_range =  c(2.2, 3.36, 10.6) ,
#'                          V_d_range =  c(0.23, 0.32, 0.47),
#'                          Bkgd_range = c(1.4,	4.067707504, 11.77),
#'                          BW_range = c(25.44, 39.96, 67.56))                   

mc_create_child <- function(plist = param_list_PFOA_ucmr5, sourceData = sourceData , pfas = "PFOA", infant = TRUE,
                      DWIaf_range = c(0.7, 1, 1.3),
                      HL_range =  c(2.1, 3.14, 10.2) , V_d_range =  c(0.17, 0.434, 0.59),
                      Bkgd_range = c(0.9,1.89681023, 4.01),
                      Sex = "Female", BW_range = c(6.13, 7.45, 8.95),  
                      concs_range = list(data.frame(t1 = .1, t2 = .002), data.frame(t1 = .1, t2 = .005),  
                                         data.frame(t1 =.1, t2=.01)),
                      perc_tap_range = list(data.frame(perc_tap = 0.5), data.frame(perc_tap =0.9), 
                                            data.frame(perc_tap = 1)),
                      MatXfer_range = c(.05,0.052,.066), 
                      MilkClear_range = c(0.45, 0.47,.5), 
                      PlacXfer_range = c(0.84, 0.87, 0.9)) {
  MC_vars  <- monte_carlo_vars( param_list = plist, sourceData = sourceData ) 
  
  mcvars_pfas <- MC_vars %>% bind_rows (MC_vars, MC_vars) 
  
  sensivary_perc_tap <- mcvars_pfas %>% mutate(iter = c(1:3), perc_tap = perc_tap_range)
  sensivary_DWC <- mcvars_pfas %>% mutate(iter = c(1:3), concs = concs_range)
  sensivary_DWIaf <- mcvars_pfas %>% mutate(iter = c(1:3), DWIaf = DWIaf_range)
  sensivary_BW <- mcvars_pfas %>% mutate(iter = c(1:3), BW = BW_range)
  sensivary_HL  <-  mcvars_pfas %>%   mutate( iter = c(1:3), HL =  HL_range ) 
  sensivary_V_d  <- mcvars_pfas %>% mutate( iter = c(1:3), V_d =  V_d_range )
  
  if(Sex == "Male"){
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdM = Bkgd_range, BkgdMk = Bkgd_range,  )
  }else{
    sensivary_bkg  <- mcvars_pfas %>% mutate( iter = c(1:3), BkgdFk = Bkgd_range)  #,BkgdF = Bkgd_range)
  }
  
  if(infant){
    sensivary_MatXfer <- mcvars_pfas  %>% mutate( iter = c(1:3), MatXfer = MatXfer_range )
    sensivary_PlacXfer <- mcvars_pfas  %>% mutate( iter = c(1:3), PlacXfer = PlacXfer_range )
    sensivary_MilkClear <- mcvars_pfas  %>% mutate( iter = c(1:3), MilkClearance = MilkClear_range )
   
    sensivary_bkg <- sensivary_bkg %>% bind_rows(sensivary_MatXfer, sensivary_MilkClear, 
                                                 sensivary_PlacXfer)
  }
    
  # sensivary_MatRemove
  sensivary <- bind_rows( sensivary_DWIaf,sensivary_DWC,sensivary_BW, sensivary_HL , 
                          sensivary_V_d , sensivary_bkg, sensivary_perc_tap ) 
}