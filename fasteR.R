#' @title PackageMA - fasteR
#'
#' @description Search the GEPRIS-Database for a name and extract the information.
#'
#' @param x A name put in quotation marks.
#'
#' @param reqtime An integer number specifying the number of seconds to wait between requests.
#'     Default is set to 0.
#'
#' @param id_only If TRUE, returns only a vector containg the ID.
#'
#' @return Returns a dataframe consisting of a ID-Variable, the name-Variable
#'     and the input-Variable.
#'
#' @examples
#' names <- c("J*rgen Gerhards", "Matthias Middell", "Stefan Hornbostel")
#' id <- sapply(names, fasteR, reqtime = 5, id_only = TRUE)
#'
#'
#' @export

fasteR <- function(x, reqtime = 0, id_only = FALSE) {
    Sys.sleep(reqtime)
    searchterm <- trimws(x)
    y <- gsub("\\s+", "+", searchterm)
    link <- paste0("http://gepris.dfg.de/gepris/OCTOPUS?keywords_criterion=",
                   y,
                   "&findButton=Finden&task=doSearchSimple&context=person")
    page <- xml2::read_html(link)
    namelist <- rvest::html_nodes(page, "h2 a")
    if(length(namelist) > 1) {
        print(paste("unambigious name, proceeding with first occurence:",
                    stringr::str_extract(namelist[1], ">.*?<")))
    }
    profil_link <- rvest::html_attr(namelist[1], "href")
    name <- rvest::html_text(namelist[1])
    id <- as.numeric(stringr::str_extract(profil_link, "\\d+"))
    if(length(namelist) == 0) {
        warning("Unknown Person")
        id <- "0"
        name <- NA
    }
    if(id_only == FALSE) {
        data.frame(id, name, searchterm, stringsAsFactors = FALSE)
    } else {
        as.vector(id)
    }

}
