#' @title PackageMA - steps
#'
#' @description Takes a project ID and extracts the involved scientists.
#'
#' @param x A numeric project-ID.
#'
#' @param reqtime A integer number specifying the number of seconds to wait between requests.
#'     Default is set to 0.
#'
#' @param index If set to TRUE, a continuous index keeps track of the ID's that were already scraped.
#'
#' @return Returns a dataframe consisting of informations about all joined in scientists.
#'
#' @examples
#'  df <- steps(project_id, reqtime = 2, index = TRUE)
#'
#'
#' @export

steps <- function(project_id, reqtime = 0, index = TRUE){
    Sys.sleep(reqtime)
    id <- as.numeric(project_id)
    link <- paste0("http://gepris.dfg.de/gepris/projekt/", id)
    ids <- vector()

    page <- httr::GET(link)
    if(page$status_code < 300){
        page <- xml2::read_html(page)
        nodes <- rvest::html_nodes(page, "a")
        links <- rvest::html_attr(nodes, "href")
        ids <- stringr::str_extract(links, "\\/gepris\\/person\\/\\d+")
        ids <- ids[!is.na(ids)]
        ids <- as.numeric(stringr::str_extract(ids, "\\d+"))

    } else {
        ids <- append(ids, "0")
    }

    df <- lapply(ids, find_info, reqtime = reqtime,  index = index)
    df <- do.call(rbind, df)
    rownames(df) <- 1:nrow(df)

    df <- dplyr::distinct(df, id, project_id, .keep_all = T)
    df <- df[complete.cases(df),]


}
