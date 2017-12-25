#' @title TopicFundeR
#'
#' @description Paste long strings neatly to console in order to fit the limits
#'     of your screen
#' @param x A string or a input coercible to one
#'
#' @param lengthline integer describing the wanted number of characters in each line
#'
#' @return NULL
#'
#' @examples pasteR(long_link)
#'
#' @export


pasteR <- function(x, lengthline = 65){
    if(nchar(as.character(x)) > lengthline){
        x_new <- gsub(paste0('(.{', lengthline, '})'), "\\1 ", x)
        x_new1 <- unlist(strsplit(x_new, " "))
        y <-  cat(paste0(x_new1, collapse = '",\n"'))
    } else {
        cat(x)
    }
}

