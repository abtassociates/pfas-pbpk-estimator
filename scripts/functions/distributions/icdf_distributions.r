# PFAS PBPK Model
# This is as close as possible to the typescript code. comments note r analog functions

# Inverse Cumulative Distribution Functions

#' Normal Inverse Cumulative Distribution Function
#' @param prob probability to solve for in normal distribution
#' @param mu mean value of normal distribution
#' @param sd standard deviation of normal distribution
#'
#' @return a value within the distribution corresponding to probability prob
#'
#' @examples
#' icdfNormal(.5,7,.5) # 7
#' icdfNormal(0,7,.5) # 4.5
#' icdfNormal(.7,7,.5) # 7.262001
#' 
icdfNormal <- function(prob, mu, sd){ # analog stats::qnorm
  c0  = 2.515517
  c1  = 0.802853
  c2  = 0.010328
  d1  = 1.432788
  d2  = 0.189269
  d3  = 0.001308
  
  r <- 0;
  if(prob==1){ r = mu+5*sd}
  if(prob==0){ r = mu-5*sd}
  if( (prob <= 0) | (prob >= 1)){return(r)}
  
  
  xp <- ifelse(prob > 0.5, 1-prob, prob)
  
  t1 <- sqrt( log( 1 / (xp * xp)))
  t2 <- t1 * t1
  t3 <- t2 * t1
  up <- c0  + c1*t1 + c2*t2
  dn <- 1 + d1*t1 + d2*t2 + d3*t3
  xp <- t1 - (up/dn)
  
  r <- ifelse(prob <= 0.5, mu - xp*sd, mu + xp*sd)
  return(r)
}

#' LogNormal Inverse Cumulative Distribution Function
#' @param prob probability to solve for in lognormal distribution
#' @param GM geometric mean of lognormal distribution
#' @param GSD geometric standard deviation of lognormal distribution
#'
#' @return a value within the distribution corresponding to probability prob
#'
#' @examples
#' icdfLogNormal(.5,7,.5) # 7
#' icdfLogNormal(0,7,.5) # 0
#' icdfLogNormal(.7,7,.5) # 4.868081
#' 
icdfLogNormal <- function(prob, GM, GSD){ # analog stats::qlnorm
  
  if(prob==0){ r <- 0 }
  if(prob==1){ r <- 1e200}
  if(prob<=0 | prob>=1){ return(r)}
  
  u <- log(GM)
  std <- log(GSD)
  n = icdfNormal(prob,0,1)
  r <- ifelse(u + std*n > 1e4 , 1e200, exp(u+std*n))
  
  return(r)
}

#' Inverse Cumulative Distribution Function
#'
#' @param dtype type of distribution, either "normal" or "lognormal"
#' @param y probability to solve for in distribution
#' @param parm1 mean for normal distribution and geometric mean for lognormal distribution
#' @param parm2 standard deviation for normal distribution and geometric standard deviation for lognormal distribution
#'
#' @return a value within the distribution dtype corresponding to probability prob 
#'
#' @examples
#' 
#' icdf("Normal",.7,7,.5) # 7.262001
#' icdf("LogNormal",.7,7,.5) # 4.868081 
#' 
icdf <- function(dtype = "Normal", y , parm1 , parm2){ # wrapper to pick normal/lognormal
  if(dtype %in% c("Normal", "normal")){
    return(icdfNormal(y, parm1, parm2))
  }else if(dtype %in% c("LogNormal", "lognormal", "Lognormal")){
    return(icdfLogNormal(y,parm1,parm2)) }
}
