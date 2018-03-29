#' @title TopicFundeR - get_project_details
#'
#' @description Search the GEPRIS-Database for a project-ID and extract the information.
#'
#' @param x A numerical project-ID.
#'
#' @param reqtime An integer number specifying the number of seconds to wait between requests.
#'     Default is set to 0.
#'
#'
#' @return Returns a dataframe with all available information.
#'
#' @examples
#'
#' get_project_details(project_id, reqtime = 5)
#'
#'
#' @export



get_project_details <- function(project_id, reqtime = 0) {
    Sys.sleep(reqtime)
    link <- paste0("http://gepris.dfg.de/gepris/projekt/", project_id)
    text <- vector()

    page <- httr::GET(link)
    if(page$status_code < 300){
        page <- xml2::read_html(page)

        text <- rvest::html_nodes(page, "#projekttext")
        text <- rvest::html_text(text, trim = TRUE)

        titel <- rvest::html_nodes(page, "h3")
        titel <- rvest::html_text(titel, trim = TRUE)

        categories <- rvest::html_nodes(page, ".name")
        categories <- rvest::html_text(categories, trim = TRUE)

        values <-  rvest::html_nodes(page, ".value")
        values <- rvest::html_text(values, trim = TRUE)

        values_links <- rvest::html_nodes(page, ".value .intern")
        values_links0 <- rvest::html_attr(values_links, "href")

        ids <- stringr::str_extract(values_links0, "\\/gepris\\/person\\/\\d+")
        ids <- ids[!is.na(ids)]
        ids <- as.numeric(stringr::str_extract(ids, "\\d+"))
        values_links <- rvest::html_text(values_links, trim = T)
        v <- paste(values_links, collapse = "|")

        fun1 <- function(x){
            position <- which(x == categories)
            categ <- categories[position]
            val <- values[position]
            v1 <- stringr::str_extract_all(val, v)
            val <- ifelse(v1 == "character(0)", val, v1)
            d <- cbind(val)
            colnames(d) <- categ
            d

        }

        a <- lapply(categories, fun1)
        x <- as.data.frame(do.call(cbind, a))
        x$text <- text
        x$titel <- titel
        x$involved_persons <- list(ids)
        x$project_id <- project_id
        x$Projektkennung <- gsub("[^\\d]", "", x$Projektkennung, perl = TRUE)
        f <- which(colnames(x) == "Förderung")
        if(length(f) > 0){
            colnames(x)[3] <- "Foerderung"
            x$Foerderung1 <- gsub("Förderung", "",x$Foerderung)
            x$Foerderung1 <- gsub("seit", "", x$Foerderung1)
            x$Foerderung1 <- gsub("in", "", x$Foerderung1)
            x$Foerderung1 <- gsub("von", "", x$Foerderung1)
            x$Foerderung1 <- gsub("bis", ":", x$Foerderung1)
            x$Foerderung1 <- gsub("\\s", "", x$Foerderung1)
            x$Foerderung_start <- stringr::str_extract(x$Foerderung1, "^\\d{4}")
            x$Foerderung_ende <- stringr::str_extract(x$Foerderung1, "(?<=:)\\d{4}")
            x$Foerderung1 <- NULL
            x

        }

        colnames(x) <- gsub("[^\\w-\\\\\\s]", "", colnames(x), perl = TRUE)
        x

    }


}
