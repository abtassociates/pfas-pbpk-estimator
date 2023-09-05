#' Make Random Stream
#'
#' @param parm1 mean for normal distribution and geometric mean for lognormal distribution
#' @param parm2 standard deviation for normal distribution and geometric standard deviation for lognormal distribution
#' @param dtype type of distribution, either "normal" or "lognormal"
#' @param n number of random values to produce
#' @param RunType technique for number generation; either "icdf" or "random"
#'
#' @return a vector of values in distribution dtype, length n
#'
#' @examples
#' 
#' set.seed(2)
#' MakeRndStream(10, 2, "Normal", 3, RunType = "icdf") # 11.934726 10.000000  8.065274
#' MakeRndStream(10, 2, "LogNormal", 3, RunType = "icdf") # 19.55264 10.00000  5.11440
#' MakeRndStream(10, 2, "Normal", 3, RunType = "random") # 9.848793 13.824529 11.112840
#' MakeRndStream(10, 2, "LogNormal", 3, RunType = "random") # 5.829325 2.222572 7.735995
#' 
make_rnd_stream <- function(parm1, parm2, dtype = "Normal", n = 1000, RunType = "icdf"){
  # Could be more efficiently replaced by rnorm (~dtype = normal, runtype = random); 
  # rlnorm(~dtype = lognormal, runtype = random); no shuffle array needed
  vmin <- -9e9
  vmax <- 9e9
  
  R <- c() 
  pct <- 1/n
  pctd2 <- pct/2
  
  i <- 1
  while(i<=n){
    if(RunType %in% c("random", "Random", 0)){
      v <- rrandom(dtype,parm1,parm2)
      R <- c(R, v)
    } else if (RunType %in% c( "icdf", 1)){
      v <- icdf(dtype = dtype, i*pct - pctd2, parm1, parm2)
      R <- c(R, v)
    }
    
    i <- i + 1
  }
  
  R[which(R<vmin)] <- vmin
  R[which(R>vmax)] <- vmax
  R <- shuffle_array(R)
  
  return(R)
}
