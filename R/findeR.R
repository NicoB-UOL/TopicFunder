#' @title TopicFundeR
#'
#' @description Search the GEPRIS-Database for a name and extract the information.
#'    FindeR and find_info are best used for single names and IDs. For multiple
#'    values use fasteR and wrap_it for convenience.
#'
#' @param x A name put in quotation marks.
#'
#' @param reqtime A integer number specifying the seconds to wait between requests.
#'     Default is set to 0.
#'
#' @return Returns a dataframe consisting of a ID-Variable, the name-Variable
#'     and the input-Variable
#'
#' @examples findeR("Name Surname", reqtime = 5)
#' @examples findeR("Name")
#'
#' @export


findeR <- function(x, reqtime = 0) {
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
        name <- "error"
    }
    data.frame(id, name, searchterm, stringsAsFactors = FALSE)


}
