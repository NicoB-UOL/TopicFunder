#' @title PackageMA - meta_fun
#'
#' @description Search the GEPRIS-Database for a name and extract the information.
#'     meta_fun is performing all the other functions at once without interim steps.
#'
#' @param x A character name.
#'
#' @param reqtime An integer number specifying the number of seconds to wait between requests.
#'     Default is set to 0.
#'
#'
#' @return Returns a dataframe with all available information.
#'
#' @examples
#'
#' df <- meta_fun("J*rgen Gerhards", reqtime = 5)
#'
#'
#' @export


meta_fun <- function(x, reqtime = 0){
    if(is.character(x)){
        id <- sapply(x, fasteR, id_only =T, reqtime = reqtime)
    } else if(is.numeric(x)){
        id <- x
    }
    info <- lapply(id, find_info, index = FALSE, reqtime = reqtime)
    info <- do.call(rbind, info)
    df <- lapply(info$project_id, steps, reqtime = reqtime )
    df <- do.call(rbind, df)
    df2 <- lapply(df$project_id, get_project_details, reqtime = reqtime)

    df2 <- plyr::rbind.fill(df2)

    df5 <- dplyr::full_join(df, df2)
    df6 <- dplyr::distinct(df5, project_id, id, .keep_all = TRUE)
}
