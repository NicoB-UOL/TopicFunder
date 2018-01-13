#' @title TopicFundeR
#'
#' @description Used for extracting information of \textit{multiple} IDs.
#'
#'
#' @param ids Vector containing IDs
#'
#' @param reqtime A integer number specifying the seconds to wait between requests.
#'     Default is set to 0. Recommended is 5.
#'
#' @return Returns a dataframe consisting of a ID-Variable, the name-Variable
#'     and the input-Variable and several others.
#'
#' @examples wrap_it(ids, reqtime = 5)
#'
#' @export
#'
#'
wrap_it <- function(ids, reqtime = 0) {
    proj <- lapply(ids, TopicFundeR::find_info2, reqtime)
    if(length(ids) > 1){
        fun <- function(x){
            id <- proj[[x]]$id
            name <- proj[[x]]$name
            projects <- proj[[x]]$projects
            project_id <- proj[[x]]$project_id
            affiliation <- proj[[x]]$affiliation
            anzahl_projekte <- proj[[x]]$anzahl_projekte

            id0 <- rbind(id, name, projects, project_id, affiliation, anzahl_projekte)
        }
        id2 <- sapply(1:length(ids), fun)
        x <- data.frame(id2, stringsAsFactors = F)
        y <- as.data.frame(t(x), stringsAsFactors = F)
        rownames(y) <- 1:nrow(y)
        colnames(y) <- c("id", "name", "projects", "project_id", "affiliation", "anzahl_projekte")
        y
    } else {
        as.data.frame(unname(proj), stringsAsFactors = FALSE)
    }
}
