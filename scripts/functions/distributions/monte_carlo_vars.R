
#' Create Monte Carlo Inputs from Source File
#'
#' @param param_list user entered parameter list
#' @param sourceData list of dataframes from the source file
#'
#' @return dataframe of Monte Carlo varied model inputs with number of rows corresponding to niter in param_list
#
#' @examples
#' MC_vars <- monte_carlo_vars( param_list = param_list, sourceData = sourceData )
#' @seealso [simulate_PBPK.Rmd] for preparation of param_list and sourceData
#' 
monte_carlo_vars <- function(param_list, sourceData){
  require(dplyr)
  require(purrr)
  
  lookup_tab <- sourceData[["MonteCarlo"]]
  lookup_tab <- lookup_tab[lookup_tab$Chemical %in% 
                             c(NA,"NA", param_list$chemical),]
  
  lookup_tab <- lookup_tab %>% mutate(Mean = as.numeric(lookup_tab$Mean),
                                      Sd = as.numeric(lookup_tab$Sd),
                                      sd_multiplier =as.numeric(lookup_tab$sd_multiplier)) %>% suppressWarnings()
  # ignore the warning about NA introduced by coercion
  
  # create MC inputs matrix
  print("Creating Monte Carlo variables dataframe")
  
  MC_vars <- data.frame("iter" = 1:param_list$niter, 
                        "DWIaf" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "DWIaf")],
                                                n = param_list$niter, 
                                                parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "DWIaf")],
                                                parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "DWIaf")]),
                        "BW" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "BW")],
                                             n = param_list$niter, 
                                             parm1 = param_list$BW, 
                                             parm2 = lookup_tab$sd_multiplier[which(lookup_tab$Variable == "BW")] * param_list$BW),
                        "HL" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "HL")],
                                             n = param_list$niter, 
                                             parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "HL")],
                                             parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "HL")]),
                        "V_d" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "V_d")],
                                              n = param_list$niter, 
                                              parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "V_d")],
                                              parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "V_d")]),
                        "MatXfer" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "MatXfer")],
                                                  n = param_list$niter, 
                                                  parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "MatXfer")],
                                                  parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "MatXfer")]), 
                        "MatRemove" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "MatRemove")],
                                                    n = param_list$niter, 
                                                    parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "MatRemove")],
                                                    parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "MatRemove")]), 
                        "MilkClearance" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "MilkClear")],
                                                        n = param_list$niter, 
                                                        parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "MilkClear")],
                                                        parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "MilkClear")]), 
                        "PlacXfer" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "PlacXfer")],
                                                   n = param_list$niter, 
                                                   parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "PlacXfer")],
                                                   parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "PlacXfer")]),
                        "BkgdF" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "BkgdF")],
                                                n = param_list$niter, 
                                                parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "BkgdF")],
                                                parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "BkgdF")]),
                        "BkgdM" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "BkgdM")],
                                                n = param_list$niter, 
                                                parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "BkgdM")],
                                                parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "BkgdM")]),
                        "BkgdFk" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "BkgdFk")],
                                                 n = param_list$niter, 
                                                 parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "BkgdFk")],
                                                 parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "BkgdFk")]),
                        "BkgdMk" = make_rnd_stream(dtype = lookup_tab$Distribution[which(lookup_tab$Variable == "BkgdMk")],
                                                 n = param_list$niter, 
                                                 parm1 = lookup_tab$Mean[which(lookup_tab$Variable == "BkgdMk")],
                                                 parm2 = lookup_tab$Sd[which(lookup_tab$Variable == "BkgdMk")]))
  
  water_concs_to_nest <- data.frame(parm1 = as.numeric(param_list$water_concs), 
                                    parm2 = exp(lookup_tab$sd_multiplier[which(lookup_tab$Variable == "concs")] * 
                                                  log( as.numeric(param_list$water_concs))),
                                    dtype = rep(lookup_tab$Distribution[which(lookup_tab$Variable == "concs")],
                                                length(param_list$water_concs)), 
                                    n = rep(param_list$niter, length(param_list$water_concs)), 
                                    stringsAsFactors = FALSE)
  water_concs_to_nest <- water_concs_to_nest %>% 
    mutate("parm2" = min(water_concs_to_nest$parm2)) # try using minimum of those sd...
  
  water_concs_to_nest<- pmap(water_concs_to_nest,make_rnd_stream) %>% as.data.frame()
  colnames(water_concs_to_nest) <- paste0("t", 1:ncol(water_concs_to_nest))
  water_concs_to_nest <- water_concs_to_nest %>% mutate("iter" = 1:param_list$niter)  
  
  perc_tap_to_nest <- data.frame(parm1 = as.numeric(param_list$perc_tap),
                                 parm2 = lookup_tab$sd_multiplier[which(lookup_tab$Variable == "perc_tap")] *
                                   as.numeric(param_list$perc_tap),
                                 dtype = rep(lookup_tab$Distribution[which(lookup_tab$Variable == "perc_tap")],
                                             length(param_list$perc_tap)), 
                                 n = rep(param_list$niter, length(param_list$perc_tap)), stringsAsFactors = FALSE) 
  
  perc_tap_to_nest<- pmap(perc_tap_to_nest,make_rnd_stream) %>% as.data.frame()
  colnames(perc_tap_to_nest) <- paste0("t", 1:ncol(perc_tap_to_nest))
  perc_tap_to_nest <- as.data.frame(perc_tap_to_nest) %>% mutate("iter" = 1:param_list$niter)  
  
  MC_vars <- MC_vars %>% nest_join(as.data.frame(perc_tap_to_nest), by = "iter", name = "perc_tap") %>% 
    nest_join(as.data.frame(water_concs_to_nest), by = "iter", name = "concs") 
  
  return(MC_vars)
}
