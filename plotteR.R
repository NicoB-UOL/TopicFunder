#' @title PackageMA - plotteR
#'
#' @description Wraps around igraph-functions and plots a rudimental network. Either a bipartite or normal one.
#'
#' @param x A Dataframe.
#'
#' @param bipartite If TRUE returns a two-mode network, otherwise a one-mode network
#'
#' @param plotting If TRUE the network will be plotted (default option). Otherwise the graph is returned.
#'
#' @return Plots a Network to viewer.
#'
#' @examples plotteR(df)
#'
#' @export



plotteR <- function(df, bipartite = FALSE, plotting = TRUE){

    edgelist <- dplyr::select(df, name, project_id)
    edgelist <- na.omit(edgelist)

    g <- igraph::graph_from_data_frame(edgelist, directed = FALSE)
    igraph::V(g)$type <- igraph::V(g)$name %in% edgelist[,1]
    igraph::V(g)$shape <- ifelse(igraph::V(g)$type, "circle", "square")
    igraph::V(g)$colour <- ifelse(igraph::V(g)$type, "cornflowerblue", "salmon")
    igraph::V(g)$name2 <- ifelse(igraph::V(g)$type, igraph::V(g)$name, NA)
    if(plotting == TRUE) {
        if(bipartite == TRUE) {
            plot(g, vertex.label.cex =  .8, vertex.label = igraph::V(g)$name2, vertex.color = igraph::V(g)$colour, edge.width = 2)
        } else {
            g <- igraph::bipartite.projection(g)
            g <- g$proj2
            plot(g, vertex.color = igraph::V(g)$colour, vertex.label.cex = .8, edge.width = 2)
        }
    } else if (bipartite == FALSE){
        g <- igraph::bipartite.projection(g)
        g <- g$proj2
    } else {
        g
    }
}
