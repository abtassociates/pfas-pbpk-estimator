# shuffle an array for random stream generation
# This is as close as possible to the typescript code. comments note r analog functions
#' Shuffle Array
#'
#' @param V a vector to shuffle
#'
#' @return vector v in a random order
#'
#' @examples shuffleArray(1:5)
#' 
shuffle_array <- function(V){
  ### The icdf function returns values in ascending order, so for a randomized stream, they must be shuffled; r output does this automatically
  currentIndex = length(V)
  while (currentIndex != 0) {
    randomIndex <- ceiling(runif(1) * currentIndex) 
    # since runif() < 1; randomIndex always smaller than current index
    
    temporaryValue <- V[currentIndex]
    
    V[currentIndex] <- V[randomIndex]
    V[randomIndex] <- temporaryValue
    
    currentIndex <- currentIndex - 1
  }
  return(V)
}