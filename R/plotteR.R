#' @title TopicFundeR
#'
#' @description Plots a rudimental network. Either a bipartite or normal one.
#'
#' @param x A Dataframe.
#'
#' @return Plots a Network to viewer.
#'
#' @examples plotteR(df)
#'
#' @export



plotteR <- function(df, bipartite = FALSE){

    edgelist <- dplyr::select(df, name, project_id)
    edgelist <- na.omit(edgelist)

    g <- igraph::graph_from_data_frame(edgelist, directed = FALSE)
    igraph::V(g)$type <- igraph::V(g)$name %in% edgelist[,1]
    igraph::V(g)$shape <- ifelse(igraph::V(g)$type, "circle", "square")
    igraph::V(g)$colour <- ifelse(igraph::V(g)$type, "cornflowerblue", "salmon")
    igraph::V(g)$name2 <- ifelse(igraph::V(g)$type, igraph::V(g)$name, NA)
    if(bipartite == TRUE) {
        plot(g, vertex.label.cex =  .8, vertex.label = igraph::V(g)$name2, vertex.color = igraph::V(g)$colour, edge.width = 2)
    } else {
        g <- igraph::bipartite.projection(g)
        g <- g$proj2
        plot(g, vertex.color = igraph::V(g)$colour, vertex.label.cex = .8, edge.width = 2)
    }
}
