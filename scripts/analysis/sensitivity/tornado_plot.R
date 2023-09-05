
#' Create a "tornado" plot using ggplot2 https://rdrr.io/github/jhelvy/jhelvyr/src/R/ggtornado.R
#'
#' This function creates a "tornado" plot using the ggplot2 package. These
#' are primarily used to display results of a sensitivity analysis.
#' @param data A data frame containing the results of a sensitivity analysis.
#' @param baseline The baseline val for the sensitivity analysis.
#' @param var The data column identifying the variable name being varied.
#' @param level The data column identifying the sensitivity case level  (usually 'high' or 'low', relative to the baseline).
#' @param val The data column identifying the val of the variable being varied.
#' @param result The data column identifying the result when the variable 'var' is set at the val of 'val'.
#' @param h_just the horizontal shift of labels, defaults to NA. Setting to 0 shifts labels slightly to the right
#' @param var_order The variable order provided as a list, defaults to NA to sort by size of impact 
#' @param Bkgd, The background serum concentration 
#' @param line_label Whether to label the NHANES Background serum line, defaults to TRUE
#' @param together A list of variables to paste high and low labels into one, defaults to NA. This is used when impacts are small to avoid over plotting labels
#' 
#' @importFrom ggplot2 ggplot aes geom_col geom_text scale_x_continuous
#' labs theme theme_bw
#' @importFrom rlang .data
#' 
#' @examples
#'
#' # Create an example data frame of a sensitivity analysis - columns:
#' # 'var'    <- The name of the variable being varied.
#' # 'level'  <- 'high' or 'low' (relative to the baseline).
#' # 'val'  <- The val of the variable being varied.
#' # 'result' <- The result of the output val at the varied variable val.
#' data <- data.frame(
#'     var    = c('price', 'price', 'fuelEconomy', 'fuelEconomy',
#'                'accelTime', 'accelTime'),
#'     level  = rep(c('high', 'low'), 3),
#'     val  = c(10, 20, 25, 15, 10, 6),
#'     result = c(0.95, 0.15, 0.90, 0.60, 0.85, 0.75)
#' )
#'
#' # Make a tornado plot of the sensitivity analysis results:
#' library(ggplot2)
#'
#' ggtornado(
#'     data = data,
#'     baseline = 0.8, # Baseline result
#'     var    = 'var',
#'     level  = 'level',
#'     val  = 'val',
#'     result = 'result'
#' )
#'
ggtornado <- function(
  data,
  baseline,
  var,
  level,
  value,
  result,
  h_just = NA, var_order = NA,
  Bkgd, line_label = T, together = NA
) {
  
  # Create a new data frame for plotting
  dat <- data[,c(var, level, value, result)]
  
  colnames(dat) <- c('var', 'level', 'val', 'result')
  
  
  dat$var <- recode(dat$var,
                   "HL" = "T[1/2] (years)", "DWI" = "DWI (μg/L)", 'perc_tap1' = "Percent Tap (%)",
                   "V_d" = "V[d] (L/kg)", "BW" = "BW (kg)", "Bkgd" = "C[bgd] (μg/L)",
                   "PlacXfer" = "PTF", "MatXfer" = "LTF", "MilkClearance" = "Milk Clearance",
                   "conc_t2" = "DWC (μg/L)")
  
  my_labs <- c("T[1/2] (years)" = expression(T[1/2]~(years)), 
               "DWI (μg/L)" = "DWI (μg/L)", "Percent Tap (%)" = "Percent Tap (%)",
               "V[d] (L/kg)" = expression(V[d]~(L/kg)),
               "BW (kg)" = "BW (kg)","C[bgd] (μg/L)" = expression(C[bgd]~(μg/L)),
               "PTF" = "PTF", "LTF" = "LTF", "Milk Clearance" = "Milk Clearance",
               "DWC (μg/L)" =  "DWC (μg/L)")
  

  # "Center" the result around the baseline result (so baseline is at 0)
  dat$result <- dat$result - baseline
  
  # Add hjust based on the level
  if(is.na(h_just)){
    dat <- dat %>% mutate(hjust = if_else(result >= 0 , 0, 1))
    
  }else{
    dat <- dat %>% mutate(hjust = if_else(result >= 0 , 0, h_just))
    
  }
  
  # Compute the range in change from low to high levels for sorting
  dat$resultRange <- stats::ave(abs(dat$result), dat$var, FUN = sum)
  
  dat <- dat %>% mutate(val = ifelse(var == "Percent Tap (%)", as.numeric(val)*100, val),
                        val = as.character( signif(as.numeric(val), digits = 3))) %>%
    mutate(val = formatC(val, format = "f", big.mark = ","))
  
  for(i in unique(dat$var)){
    dat_i  <- dat %>% filter(var == i)
    
    if(all(dat_i$result < 0.01) | i %in% together){  # when labels are too close due to small effect, this pastes them together in one label
      dat_i <- dat_i %>% arrange(result)
      lab <- paste0(unique(signif(as.numeric(as.character(dat_i$val)), digits = 3)), collapse = "  ")
      if(!"val_2" %in% colnames(dat)){ dat <- dat %>% mutate(val_2 = NA)}
      dat <- dat %>% 
        mutate(val = ifelse(var == i & level == "low",NA, as.character(val))) %>%
        mutate(val = ifelse(var == i & level == "high",NA, as.character(val)),
               # create new val_2 for label
               val_2 = ifelse(var == i & level == "low", lab,val_2),
               hjust = ifelse(var == i, hjust + 0.5, hjust))
    }
  }
  
  # Compute labels for the x-axis
  lb        <- floor(13*min(dat$result))/10 
  ub        <- ceiling(11*max(dat$result))/10
  
  # If background value is lower than lower bound, reset it
  if(lb > (Bkgd-baseline)){ lb = floor(11*(Bkgd - baseline))/10}
  
  breaks    <- seq(lb, ub, (ub - lb) / 5)
  breakLabs <- round(breaks + baseline, 2)
  
  if((lb+baseline) < 0){breakLabs[1] <- 0} # if that made it negative, set JUST LABEL to zero
  
  
  # arrange by descending result range (largest first)
  dat <- dat %>% mutate(Bgd = Bkgd - baseline) 
  
  if(!is.na(var_order[1])){ # if order provided, order using a factor
    
    dat$var <- factor(dat$var, levels =  rev(var_order))
    dat <- dat %>% arrange(var) 
    bottom_cat = rev(var_order)[1]
  }else{
    dat <- dat %>% arrange(desc(resultRange))
    dat$var <- with(dat, reorder(var, order(resultRange))) # set levels of var to that order
    bottom_cat = dat$var[nrow(dat)] %>% as.character()# get bottom category
  }
  
  # Make the tornado diagram
  plot <- ggplot(dat,
                 aes(
                   x = .data$result,
                   y = .data$var,
                   fill = level)
  ) + geom_vline( aes(xintercept =Bgd)) + scale_y_discrete(labels = my_labs, limits = levels(dat$var))
  
  if(line_label){
    plot <- plot + annotate("text", x = dat$Bgd[1], label="NHANES Mean Background Serum", 
                            y = bottom_cat, angle=90, vjust = -1.2, hjust = -0.05, 
                            size = 12 / ggplot2::.pt)
  }
    
    plot <- plot +
    scale_fill_manual(values = c("low" = "#98CAE1","high"  ="#FEDA8B")) +
    geom_col(width = 0.6) +
    # Add labels on bars
    scale_x_continuous(
      limits = c(lb, ub),
      breaks = breaks,
      labels = breakLabs) +
    geom_text(aes(label = .data$val,  
                  hjust = .data$hjust), vjust = 0.5) +
    labs(x = 'Serum μg/L', y = 'Parameter') +
    theme_bw() + 
    theme(legend.position = 'none') + # Remove legend
    theme(axis.text = element_text(size=12)) +
    theme(axis.title = element_text(size=14))
    
  if("val_2" %in% colnames(dat)){
    plot <- plot + geom_text(aes(label = .data$val_2))
  }
  
  return(plot)
}
