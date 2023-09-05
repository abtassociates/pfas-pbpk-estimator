# PFAS PBPK Model
# This is as close as possible to the typescript code. comments note r analog functions
# Random Functions

#' Random Normal Function
#'
#' @param mu mean value of normal distribution
#' @param sd standard deviation of normal distribution
#'
#' @return random value in normal distribution
#'
#' @examples
#' 
#' set.seed(1)
#' rNormal(10,2) # 8.483559
#' rNormal(10,2) # 12.93526
#' 
rNormal <- function(mu, sd){ #analog stats::rnorm
  
  r <- 1
  while(r>=1.0){
    v1 <- 2*runif(1)-1
    v2 <- 2*runif(1)-1
    r <-  v1 * v1 + v2 * v2
  }
    
  if( runif(1) >= 0.5 ) {
      v3 <-  v2
      }else{
        v3 <- v1
    }
  
  dev <- v3 * sqrt(( - 2 * log(r)) / r);
  return (mu + dev * sd)
}

#' Random LogNormal Function
#'
#' @param GM geometric mean of lognormal distribution
#' @param GSD geometric standard deviation of lognormal distribution
#'
#' @return random value in lognormal distribution
#'
#' @examples
#' 
#' set.seed(1)
#' rLogNormal(10,2) # 5.912251
#' rLogNormal(10,2) # 27.65671
#' 
rLogNormal <- function(GM , GSD){ # analog stats::rlnorm? 
  
  return (exp(rNormal(log(GM),log(GSD))))
}

#' Random Function
#'
#' @param dtype type of distribution, either "normal" or "lognormal"
#' @param parm1 mean for normal distribution and geometric mean for lognormal distribution
#' @param parm2 standard deviation for normal distribution and geometric standard deviation for lognormal distribution
#'
#' @return a random value within the distribution dtype 
#' @examples
#' 
#' set.seed(1)
#' rrandom(dtype = "LogNormal", 10,2) # 5.912251
#' rrandom(dtype = "Normal", 10,2) # 12.93526
#'  
rrandom <- function(dtype = "Normal" , parm1, parm2){
  if (dtype %in% c("Normal", "normal")){ 
    return( rNormal(parm1, parm2))
  }else if (dtype %in% c("LogNormal", "lognormal")){
    return( rLogNormal(parm1, parm2))}
}
