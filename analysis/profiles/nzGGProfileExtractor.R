# Code to run the parameterised profile extractor
circuitPattern <- "Heat Pump"
dateFrom <- "2015-04-01"
dateTo <- "2016-03-31"

# Load packages ----
library(nzGREENGrid) # gg utilities
library(rmarkdown)

# Local parameters ----
fullFb <- 0 # switch on (1) or off (0) full feedback
localTest <- 0 # test on local data source (1) or full HPS (0) data?

b2Kb <- 1024 #http://whatsabyte.com/P1/byteconverter.htm
b2Mb <- 1048576

projLoc <- findParentDirectory("nzGREENGrid")

gsMasterFile <- path.expand("~/Syncplicity Folders/Green Grid Project Management Folder/Gridspy/Master list of Gridspy units.xlsx")

# Local functions ----

if(localTest == 1){
  # Local test
  dPath <- "~/Data/NZGreenGrid/" # BA laptop test set
  fpath <- paste0(dPath,"gridspy/1min_orig/") # location of original data
  outPath <- paste0(dPath, "safe/gridSpy/1min/") # place to save them / load from
} else {
  # HPS data source
  dPath <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HPS
  fpath <- paste0(dPath,"_RAW DATA/GridSpyData/") # location of data
  outPath <- paste0(dPath, "Clean_data/safe/gridSpy/1min/") # place to save them
}

# run the extractor .Rmd and render to pdf
rmarkdown::render(input = "analysis/profiles/nzGGProfileExtractorTemplate.Rmd",
                  output_format = "pdf_document",
                  params = list(circuitPattern = circuitPattern, dateFrom = dateFrom, dateTo = dateTo),
                  output_file = paste0("ggProfile_", circuitPattern, "_", dateFrom, "_", dateTo, ".pdf"))
