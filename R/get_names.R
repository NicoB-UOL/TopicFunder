#' @title PackageMA - get_names
#'
#' @description Search the GEPRIS-Database for a subject and it will return a list of names.
#'
#'
#' @param fachgebiet A character string (disciplin)
#'
#' @param fachkollegium A numeric of the structure see  'http://www.dfg.de/en/dfg_profile/statutory_bodies/review_boards/subject_areas/index.jsp'
#'
#' @param fach A numeric structure see above
#'
#' @param hits number of hits per request
#'
#' @return Returns a vector with names of the scientists working in that field
#'
#' @examples
#'
#' df <- get_names("Biologie", fachkollegium = 201, fach = 20105, hits = 10)
#'
#'
#' @export

get_names <- function(fachgebiet = "Biologie", fachkollegium = "%",fach = "%", hits  = 10, uni = "%"){

    fields <- c("Agrar-, Forstwissenschaften und Tiermedizin", "Bauwesen und Architektur",  "Biologie", "Chemie",
                "Geisteswissenschaften", "Geowissenschaften", "Informatik, Sytem- und Elektrotechnik", "Maschinenbau und Produktionstechnik",
                "Materialwissenschaft und Werkstofftechnik", "Mathematik", "Medizin", "Physik", "Sozial- und Verhaltenswissenschaften", "Wärmetechnik/Verfahrenstechnik")

    codes <- c(23, 45, 21, 31, 11, 34, 44, 41, 43, 33, 22, 32, 12, 42)

    field <- grep(fachgebiet, fields)
    fachgebiet <- codes[field]
    stopifnot(length(fachgebiet) == 1)
    message("See 'https://www.dfg.de/dfg_profil/gremien/fachkollegien/faecher/index.jsp' for structure details", "\n",
            "for example set 'fachkollegium' to 201 and 'fach' to 20105")
    link<- paste0("https://gepris.dfg.de/gepris/OCTOPUS?task=doKatalog&context=person",
                  "&fachgebiet=",
                  fachgebiet,
                  "&fachkollegium=",
                  fachkollegium,
                  "&fach=",
                  fach,
                  "&nurP",
                  "rojekteMitAB=false&bundesland=DEU%23&oldpeo=%23&peo=%23&zk_transf",
                  "erprojekt=false&teilprojekte=false&teilprojekte=true&bewilligungs",
                  "Status=&beginOfFunding=&gefoerdertIn=&oldGgsHunderter=0&ggsHunder",
                  "ter=0&einrichtungsart=",
                  uni,
                  "&orderBy=ort",
                  "&hitsPerPage=",
                  hits,
                  "&findButton=Finden")
    page <- xml2::read_html(link)
    namelist <- rvest::html_nodes(page, "h2 a")
    names <- stringr::str_extract(namelist, ">.*?<")
    names <- gsub(">|<", "", names)
    if(length(namelist) == 0){
        stop("No matching fields or results found. Please check spelling")
    }
    namelist <- rvest::html_attr(namelist, "href")
    ids <- as.numeric(stringr::str_extract(namelist, "\\d+"))

    df <- as.data.frame(cbind(names, ids), stringsAsFactors = FALSE)
    df$ids <- as.numeric(df$ids)
    df
}



