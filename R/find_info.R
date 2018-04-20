#' @title TopicFundeR - find_info
#'
#' @description Extract additional information based on a person's ID.
#'
#' @param x A numeric ID.
#'
#' @param reqtime An integer number specifying the number of seconds to wait between requests.
#'     Default is set to 0.
#'
#' @param index If set to TRUE, a continuous index keeps track of the ID's that were already scraped.
#'
#' @return Returns a dataframe with additional project variables, such as the number of
#'      projects, the name of the projects and their corresponding IDs.
#'
#' @examples  find_info(id)
#' @examples
#' x <- fasteR("Jürgen Gerhards")
#' y <- find_info(x$id)
#' z <- dplyr::left_join(y, x)
#'
#'
#' @export

find_info <- function (x, reqtime = 0, index = TRUE){
    if (index == TRUE & exists("discardable_index")) {
        discardable_index <<- append(discardable_index, x)
    }
    else if (index == TRUE & !exists("discardable_index")) {
        discardable_index <<- vector()
        discardable_index <<- x
    }
    else {
        discardable_index <- NA
    }
    dutemp <- duplicated(discardable_index)
    dutemp <- tail(dutemp, 1)
    if (dutemp == FALSE) {
        Sys.sleep(reqtime)
        id <- as.numeric(x)
        link <- paste0("http://gepris.dfg.de/gepris/person/",
                       id)
        page <- httr::GET(link)
        if (page$status_code < 300) {
            page <- xml2::read_html(page)
            name <- rvest::html_node(page, "h3")
            name <- rvest::html_text(name, trim = TRUE)
            projectlist <- rvest::html_nodes(page, "#projekteNachRolle .intern")
            number_projects <- length(projectlist)
            address <- rvest::html_nodes(page, ".details p:nth-child(1)")
            address <- rvest::html_text(address, trim = T)
            address <- gsub("(\\t|\\n|\\s+)", " ", address)
            affiliation <- NA
            for (i in 1:length(TopicFundeR:::result2)) {
                #pos <- agrep(TopicFundeR:::result2[i], address, fixed = TRUE, max.distance = .05)
                 pos <- grep(TopicFundeR:::result2[i], address)
                 affiliation[pos] <- TopicFundeR:::result2[i]
            }
            if(is.na(affiliation) & length(address)>0){
                message("Unknown affiliation. Please check address")
                affiliation <- "check affiliation"
            }
            project_link <- rvest::html_attr(projectlist, "href")
            projects <- rvest::html_text(projectlist, trim = TRUE)
            project_id <- stringr::str_extract(project_link,
                                               "\\d+")
        }
        else {
            projectlist <- list()
        }
        if (length(projectlist) == 0) {
            warning("not a valide ID")
            data.frame(id = x, name = NA, projects = NA, project_id = NA,
                       number_projects = NA, affiliation = NA, address = NA, stringsAsFactors = F)
        }
        else {
            data.frame(id, name, projects, project_id, number_projects,
                       affiliation, address, stringsAsFactors = F)
        }
    }
    else {
        message("Duplicated ID detected proceeding with next ID.")
        data.frame(id = NA, name = NA, projects = NA, project_id = NA,
                   number_projects = NA, affiliation = NA, address = NA, stringsAsFactors = F)
    }
}
