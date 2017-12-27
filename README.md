# TopicFunder
TopicFunder is an R package that extracts funding information from the DFG-Database (GEPRIS) and produces dataframes for further analysis and visualization.
It originated as a by-product of a masters thesis at the University of Oldenburg, Germany and is developed and maintained by Nico B and Alena K.

## Disclaimer
The software in this package is for educational purposes only. It is provided WITHOUT ANY WARRANTY.
USE AT YOUR OWN RISK! 

## Installation 
devtools::install_github('NicoB-UOL/TopicFunder')

## Usage
This section is under development.

In generell there are two different ways to extract information. The first is single-usage based on one request at a time and the second chains multiple requests via the `apply`-family. In order to extract information about persons and subsequently projects three steps are necessary.  
1. Find the ID of the researcher  
   * this is done by entering the name of the person in question into  
   * `findeR` or `fasteR`     
2. use the ID to extract the corresponding projects  
   * `find_info` or `wrap_it`
3. visualize or analyze the data  
   * this can be done by using `plotteR` or `steps`
   * `steps` is experimental and will take a lot of time  
   
Most of these functions heavily rely on the rvest, xml2 and httr packages, which are used for scraping the information. It is recommended to check whether or not it is alright to scrape the data (for starters checking the robots.txt, drop a note to the homepage operator/admin etc.). Furthermore one should put a appropriate delay between the requests (we recommend atleast 5 seconds, `reqtime = 5`)

### Examples
* single-usage  
   * `findeR('Jürgen Gerhards, reqtime = 5)'`
      * which gives the ID: 1464373 | the name: Gerhards, Jürgen | and           the searchterm: Jürgen Gerhards
