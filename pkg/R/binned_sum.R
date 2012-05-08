#' Fast summing in different bins
#' 
#' \code{binned_sum} implements fast summing for given bins by calling c-code.
#' Please note that incorrect use of this function may crash your R-session.
#' the values of \code{bins} must be in between 1:\code{nbins} and \code{bin} may not 
#' contain \code{NA}
#' @useDynLib ffbase
#' @param x \code{numeric} vector with the data to be summed
#' @param bin \code{integer} vector with the bin number for each data point
#' @param nbins \code{integer} maximum bin number 
#' @return \code{numeric} matrix where each row is a bin
#' @export
binned_sum <- function (x, bin, nbins=max(bin)){
   stopifnot(length(x)==length(bin))
   res <- .Call("binned_sum", as.numeric(x), as.integer(bin), as.integer(nbins), PACKAGE = "ffbase")
   dimnames(res) <- list(bin=1:nbins, c("count", "sum"))
   res
}

#' @rdname binned_sum
#' @usage \method{binned_sum}{ff} (x, bin, nbins = max(bin), ...)
#' @param ... passed on to chunk
#' @export
binned_sum.ff <- function(x, bin, nbins=max(bin), ...){
  res <- matrix(0, nrow=nbins, ncol=2, dimnames=list(bin=1:nbins, c("count", "sum")))
  for (i in chunk(x, ...)){
    res <- res + .Call("binned_sum", as.numeric(x[i]), as.integer(bin[i]), as.integer(nbins), PACKAGE = "ffbase")
  }
  res
}

##### quick testing code ######
# x <- as.numeric(1:100000)
# bin <- as.integer(runif(length(x), 1, 101))
# x[1] <- NA
# 
# binned_sum(1:10, 1:10, nbins=10)
# binned_sum(c(1000,NA), 1:2, nbins=2L)
# system.time({
#   replicate(50, {tapply(x, bin, function(i){c(sum=sum(i, na.rm=TRUE), na=sum(is.na(i)))})})
# })
#    
# system.time({
#   replicate(50, {binned_sum(x, bin, nbins=100L)})
# })