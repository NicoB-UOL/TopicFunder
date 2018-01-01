
TopicFunder
===========

TopicFunder is an R package that extracts funding information from the DFG-Database (GEPRIS) and produces dataframes for further analysis and visualization. It originated as a by-product of a masters thesis at the University of Oldenburg, Germany and is developed and maintained by Nico Blokker and Alena Klenke.

Disclaimer
----------

The software in this package is for educational purposes only. It is provided WITHOUT ANY WARRANTY. USE AT YOUR OWN RISK!

Installation
------------

`devtools::install_github('NicoB-UOL/TopicFunder')`

Usage
-----

This section is under development.

In generell there are two different ways to extract information. The first is single-usage based on one request at a time and the second chains multiple requests via the `apply`-family. In order to extract information about persons and subsequently projects three steps are necessary.
1. Find the ID of the researcher
+ this is done by entering the name of the person in question into
+ `findeR` or `fasteR`
2. use the ID to extract the corresponding projects
+ `find_info` or `wrap_it` 
3. visualize or analyze the data
+ this can be done by using `plotteR` or `steps` 
+ `steps` is experimental and will take a lot of time

Most of these functions heavily rely on the rvest, xml2 and httr packages, which are used for scraping the information. It is recommended to check whether or not it is alright to scrape the data (for starters checking the robots.txt, drop a note to the homepage operator/admin etc.). Furthermore one should put a appropriate delay between the requests (we recommend atleast 5 seconds, `reqtime = 5`)

Examples
--------

#### single-usage

-   `findeR('name', reqtime = 5)`
    -   which gives the Id, the name and the searchterm

``` r
library(TopicFundeR)
result <- findeR("Jürgen Gerhards", reqtime = 5)
result
```

    ##        id             name      searchterm
    ## 1 1464373 Gerhards, Jürgen Jürgen Gerhards

-   `find_info(ID, reqtime = 5)`
-   now we got the projecttitles, the project-ids, the number of projects and the affiliation additionally

``` r
df <- find_info(result$id, reqtime = 5)
str(df)
```

    ## 'data.frame':    12 obs. of  6 variables:
    ##  $ id             : num  1464373 1464373 1464373 1464373 1464373 ...
    ##  $ name           : chr  "Professor Dr. Jürgen  Gerhards" "Professor Dr. Jürgen  Gerhards" "Professor Dr. Jürgen  Gerhards" "Professor Dr. Jürgen  Gerhards" ...
    ##  $ projects       : chr  "Wie ausgeprägt ist die Solidarität zwischen den Bürgern und den Mitgliedsländern Europas?" "Die Wahl von Latein und Altgriechisch als schulische Fremdsprachen: Eine Distinktionsstrategie der oberen sozialen Klassen?" "Messung und Analyse von Prozessen des sozialen Wandels anhand der Vergabe von Vornamen: Aufbereitung und Auswertung des SOEP" "Die Europäische Union und die massenmediale Attribution von Verantwortung. Eine länder-, zeit- und medienvergle"| __truncated__ ...
    ##  $ project_id     : chr  "273553843" "321602695" "5404954" "5414296" ...
    ##  $ anzahl_projekte: int  12 12 12 12 12 12 12 12 12 12 ...
    ##  $ affiliation    : chr  "Adresse\n        \n                        \t\t\t\t\t\tFreie Universität Berlin Institut für Soziologie\n\t\t\t"| __truncated__ "Adresse\n        \n                        \t\t\t\t\t\tFreie Universität Berlin Institut für Soziologie\n\t\t\t"| __truncated__ "Adresse\n        \n                        \t\t\t\t\t\tFreie Universität Berlin Institut für Soziologie\n\t\t\t"| __truncated__ "Adresse\n        \n                        \t\t\t\t\t\tFreie Universität Berlin Institut für Soziologie\n\t\t\t"| __truncated__ ...

-   if we wanted we could already construct a network from this

``` r
plotteR(df, bipartite = TRUE)
```

![](README_files/figure-markdown_github/unnamed-chunk-3-1.png)

-   the blue circle in the middle is the researcher and the red boxes are their projects
-   one could add other researchers in the same way and merge the dataframes or chain the requests

#### multiple requests

-   to generate a network with more than one researcher we add two other names and use some of the other functions (`fasteR` and `wrap_it`) to generate the dataframe

``` r
names <- c('Jürgen Gerhards', 'Matthias Middell', 'Stefan Hornbostel')
ids <- sapply(names, fasteR, reqtime = 5, id_only = TRUE)
df <- wrap_it(ids, reqtime = 5)
plotteR(df, bipartite = T)
```

![](README_files/figure-markdown_github/unnamed-chunk-4-1.png)

-   this time we plot a one-mode instead of a two-mode projection of the network

``` r
plotteR(df, bipartite = F)
```

![](README_files/figure-markdown_github/unnamed-chunk-5-1.png)

#### exploring the DFG-network

-   At this point one might wonder, how the scientist is embedded into the network as a whole
-   in order to answer this question, we use `steps`:

``` r
# find the ID
result <- findeR("Jürgen Gerhards", reqtime = 5)

# find project IDs
df <- wrap_it(result$id, reqtime = 5)

# build dataframe with cooperating scientists ('neighbours')
df2 <- lapply(df$project_id, steps, reqtime = .5)
step1 <- do.call(rbind, df2)
df_step1 <- dplyr::distinct(step1, id, project_id, .keep_all = T)

# construct network and write out igraph-object
graph <- plotteR(df_step1, plotting = F, bipartite = F)

# extract and colour communities
library(igraph) # at this point we need to load igraph explicitly for further analysis
fg <- fastgreedy.community(graph)
V(graph)$colour <- membership(fg)

# get the scientists with highest and second highest degree
dg <- sort(degree(graph), decreasing = T)
dg[1:2]
```

    ##   Professor Dr. Jürgen  Gerhards Professor Dr. Hans-Peter  Müller 
    ##                               77                               49

``` r
# plot the network
plot(graph, 
     vertex.label = ifelse(V(graph)$name == "Professor Dr. Jürgen  Gerhards"|
                               V(graph)$name == "Professor Dr. Hans-Peter  Müller",
                           V(graph)$name, NA),
     vertex.size = 6, vertex.color = V(graph)$colour)
```

![](README_files/figure-markdown_github/unnamed-chunk-6-1.png)
