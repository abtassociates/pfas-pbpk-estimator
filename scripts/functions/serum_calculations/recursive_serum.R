#' Recursive Serum Calculation
#'
#' @param data Entire dataframe for referencing background serum, breastfeeding, and daily doses 
#' @param timestep Number of days between calculations
#' @param iter iteration, used in recursive indexing, represented by a row
#' @param decay value for DecayPerStep
#' @param decay_bf value for CRBFPerStep (additional decay for breast milk clearance)
#' @param curage  Current age, calculated using parameters sd and creation_date
#' @param PlacXfer MC varied Placental Transfer Rate
#' @param bf TRUE/FALSE - was the individual breastfed?
#
#' @return values for serum before and after decay for row in data corresponding to iter
#'
#' @examples
#' 
#' BF <- ifelse(fed_most == "breast milk" & curage < 6, TRUE, FALSE)
#' if(nrow(data) <= 650){
#'   serums <- recursive_serum(data = data, timestep = timestep,  iter = nrow(data), 
#'                             decay = DecayPerStep, decay_bf = CRBFPerStep,
#'                             curage = curage, PlacXfer = PlacXfer, bf = BF)
#'   
#' }else{
#'   serums <- recursive_large(data = data, timestep = timestep,  iter = nrow(data), 
#'                             decay = DecayPerStep, decay_bf = CRBFPerStep,
#'                             curage = curage, PlacXfer = PlacXfer,bf = BF)
#' }
#' 
recursive_serum <- function(data, timestep, iter, decay = DecayPerStep, decay_bf = CRBFPerStep, 
                            curage, PlacXfer, bf){
  # helper functions for the steps of adding daily dose and decay
  b2a <- function(Serum_b, Decay){return(Serum_b*Decay)}
  a2b <- function(Serum_a, timestep, DD, BG){return(Serum_a +BG+ timestep*(DD))}
  
  # pull out columns we will need from data
  BF <- data$Breastfeeding # needed for choosing Decay or CRBF
  DD <- data$DD # the daily dose of PFAS in water or milk divided by VD
  BG <- data$Bkgd_serum # Background serum in row 1, times step adjustment otherwise
  # The time step adjustment simply adds back Background serum that was eliminated
  # This is to keep the Background serum as a minimum value
  
  if(iter == 1){  # starting values
    # calculate starting serum
    if(curage < 6){ # use mother's serum at birth and placental transfer for children (current age < 6)
      serum_1 <- data$mother_serum[1] * PlacXfer
      if(!bf){ # if not breastfed, add a dose
        serum_1 <- a2b(Serum_a = serum_1, BG = BG[2], # BG[2] is the TSA
                       timestep = timestep, DD = DD[1])
      }
    }else{
      serum_1 <- a2b(Serum_a = BG[1], BG = BG[2], # BG[1] is background serum and BG[2] is the TSA
                      timestep = timestep, DD = DD[1])
      
    }
    # The column breastfeeding indicates dates that the user was a breastfeeding mother
    # this is always 0 for infants
    # normal decay because infant
    serum_ai <- b2a(Serum_b = serum_1, Decay =  decay)
    
    return(list("Serum_a" = serum_ai,
                "Serum_b" = NA))
    
    }else{ # rows 2+ 
      
      # get serum for iter-1 row
      serum_ai_minus <- recursive_serum(decay = decay, decay_bf =  decay_bf,  
                                        curage = curage, PlacXfer = PlacXfer,
                                        timestep =  timestep,
                                        data = data, iter = iter-1, bf = bf)
        
      # do recursive calculation
      serum_bi <- a2b(Serum_a = serum_ai_minus[["Serum_a"]][length(serum_ai_minus[["Serum_a"]])],
                       timestep = timestep, DD = DD[iter], BG = BG[iter]) # BG[iter] is the TSA
      
      # choose decay val by breastfeeding column row: iter
      serum_ai <- b2a(Serum_b = serum_bi, Decay = ifelse(BF[iter] == 1, decay_bf, decay))
      
      return(list("Serum_a" = c( unlist(serum_ai_minus[["Serum_a"]]), serum_ai),
                  "Serum_b" = c( unlist(serum_ai_minus[["Serum_b"]]), serum_bi)))
  }    
}

#' R on some systems can't handle a certain amount of recursion. 
#' This version takes a deep recursion and starts adding on to it.
#'
#' @param data Entire dataframe for referencing background serum, breastfeeding, and daily doses 
#' @param timestep Number of days between calculations
#' @param iter iteration, used in recursive indexing
#' @param decay value for DecayPerStep
#' @param decay_bf value for CRBFPerStep (additional decay for breast milk clearance)
#' @param curage  Current age, calculated using parameters sd and creation_date
#' @param PlacXfer MC varied Placental Transfer Rate
#' @param bf TRUE/FALSE - was the individual breastfed?

recursive_large <- function(data, timestep, iter, decay = DecayPerStep, decay_bf = CRBFPerStep, 
                          curage, PlacXfer, bf = FALSE){
  
  # c stack error kicks in around row 700, so lets start at 650
  if(iter <= 650){return("use smaller recursive function")}
  
  # choose decay val by breastfeeding column row: iter-1 
  serums <- recursive_serum(decay = decay, decay_bf =  decay_bf,  
                            curage = curage, PlacXfer = PlacXfer,
                            timestep =  timestep, data = data, iter = 650,
                            bf = bf)
  # pull out columns we will need from data
  BF <- data$Breastfeeding # needed for choosing Decay or CRBF
  DD <- data$DD # the daily dose of PFAS in water or milk divided by VD
  BG <- data$Bkgd_serum # Background serum in row 1, times step adjustment otherwise
  # The time step adjustment simply adds back Background serum that was eliminated
  # This is to keep the Background serum as a minimum value
  
  # helper functions for the steps of adding daily dose and decay
  b2a <- function(Serum_b, Decay){return(Serum_b*Decay)}
  a2b <- function(Serum_a, timestep, DD, BG){return(Serum_a +BG+ timestep*(DD))}
  
  # next step 651
  serum_bi <- a2b(Serum_a = serums[["Serum_a"]][length(serums[["Serum_a"]])], # 650 serum_a
                  timestep = timestep, DD = DD[651], BG = BG[651])
  
  # choose decay val by breastfeeding column row: iter
  serum_ai <- b2a(Serum_b = serum_bi, Decay = ifelse(BF[651] == 1, decay_bf, decay))
  serums$Serum_a <- c(unlist(serums$Serum_a), serum_ai)
  serums$Serum_b <- c(unlist(serums$Serum_b), serum_bi)
  
  i <- 652
  while(i <= iter){ #652:iter
    serum_bi <- a2b(Serum_a = serum_ai,
                    timestep = timestep, DD = DD[i], BG = BG[i])
    # choose decay val by breastfeeding column row: iter
    serum_ai <- b2a(Serum_b = serum_bi, Decay = ifelse(BF[i] == 1, decay_bf, decay))
    
    serums$Serum_a <- c(unlist(serums$Serum_a), serum_ai)
    serums$Serum_b <- c(unlist(serums$Serum_b), serum_bi)
    
    i <- i+1
  }
  return(serums)
}
