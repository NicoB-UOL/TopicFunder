#' @title TopicFundeR
#'
#' @description Takes a project ID and extracts the involved scientists. Wraps
#'     around wrap_it.
#'
#' @param x A numeric ID.
#'
#' @param reqtime A integer number specifying the seconds to wait between requests.
#'     Default is set to 0.
#'
#' @return Returns a dataframe consisting of informations about all joined in scientists.
#'
#' @examples
#'  df <- steps(id, reqtime = 2)
#'
#'
#' @export

steps <- function(project_id, reqtime = 0){
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


    df <- wrap_it(unique(ids), reqtime = reqtime)
    df <- dplyr::distinct(df, id, project_id, .keep_all = T)
    df <- df[complete.cases(df),]


}
