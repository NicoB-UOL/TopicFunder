#' @title TopicFundeR
#'
#' @description Takes a project ID or ID of a person and extracts the involved scientists. Wraps
#'     around wrap_it.
#'
#' @param x A numeric ID.
#'
#' @param reqtime A integer number specifying the seconds to wait between requests.
#'     Default is set to 0.
#'
#' @return Returns a dataframe consisting of informations about all joined in scientists and conditionally project-texts.
#'
#' @examples
#'  df <- steps2(person_id, reqtime = 2, texts = TRUE, projects = FALSE)
#'  df <- steps2(project_id, reqtime = 2, texts = TRUE, projects = TRUE)
#'
#' @export

steps2 <- function(project_id, reqtime = 0, texts = FALSE, projects = FALSE){

    id <- as.numeric(project_id)

    if(projects == TRUE){
        Sys.sleep(reqtime)
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
    }  else {
        ids <- id
    }
    df <- wrap_it(unique(ids), reqtime = reqtime)
    df <- dplyr::distinct(df, id, project_id, .keep_all = T)

    if(texts == TRUE) {
        get_text <- function(project_id, reqtime = 0) {
            link <- paste0("http://gepris.dfg.de/gepris/projekt/", project_id)
            text <- vector()

            page <- httr::GET(link)
            if(page$status_code < 300){
                page <- xml2::read_html(page)
                text <- rvest::html_nodes(page, "#projekttext")
                text <- rvest::html_text(text, trim = TRUE)

            } else {
                text <- append(text, "no results")
            }

        }
        texts <- sapply(df$project_id, get_text, reqtime = reqtime)
        df$texts <- unname(texts)
        df
    } else {
        df
    }
}


