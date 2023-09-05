
#' Run serum sensitivity
#' 
#' @param sensivary data frame of monte carlo inputs
#' @param plist parameter list for sensitivity
#' @param sourceData  list of source data sheets from the source file
#' @param pfas chemical, defaults to PFOA
#' 
#' @return
#'
#' @examples
#' pfoa <-   mc_create_M(plist = param_list_PFOA_ucmr5, sourceData = sourceData,
#'                       pfas = "PFOA")
#' 
#' results_pfoa <-serum_sensitiv_runs(sensivary= pfoa , 
#'                                    plist = param_list_PFOA_ucmr5,
#'                                    sourceData = sourceData , 
#'                                    pfas = "PFOA" )
#' 
serum_sensitiv_runs <- function(sensivary , plist = param_list_PFOA_ucmr5, sourceData = sourceData , pfas = "PFOA" ) {
  tic()
  serum_calcs <- pmap(sensivary, 
                      main_func, 
                      parameter_list =  plist, 
                      source_data =  sourceData, full = FALSE) 
  
  ### Clean up output for ggtornado
  serum_calcs <- serum_calcs %>% 
    bind_rows()  %>%
    mutate(pred_serum_ug_L = 1000 * Serum_a # convert from mg/L to ug/l
          
    ) %>%
    select( DWI, out_BW = BW, pred_serum_ug_L) 
  
  serum_calcs <- sensivary %>% select (iter , BW,  HL,  V_d , starts_with("Bkgd"), perc_tap ,  concs, 
                                       MatXfer, MatRemove, PlacXfer, MilkClearance  )  %>% 
    mutate(conc_t1 = as.numeric(map(concs, pluck( 1 ))) , 
           conc_t2 = as.numeric(map(concs, pluck(2))),
           perc_tap1 = as.numeric(map(perc_tap, pluck( 1))),
           date_t1 =plist$water_concs_dates[1], 
           date_t2 =plist$water_concs_dates[2]) %>% 
    select(-concs, - perc_tap) %>%
    bind_cols(serum_calcs)
  toc()
  serum_calcs
}

