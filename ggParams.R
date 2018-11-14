ggParams <<- list() # params holder

# Location of data
ggParams$repoLoc <- findParentDirectory("GREENGrid")
ggParams$dataLoc <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HCS by default
ggParams$dataDOI <- "https://dx.doi.org/10.5255/UKDA-SN-853334"

ggParams$gsMasterFile <- paste0(ggParams$dataLoc, "Green Grid Project Management/Gridspy/Master list of Gridspy units.xlsx")
ggParams$hhAttributes <- paste0(ggParams$dataLoc, "cleanData/safe/survey/ggHouseholdAttributesSafe.csv")

# Rmd includes
ggParams$historyGenericRmd <- paste0(ggParams$repoLoc, "/includes/historyGeneric.Rmd")
ggParams$supportGenericRmd <- paste0(ggParams$repoLoc, "/includes/supportGeneric.Rmd")
ggParams$circulationGenericRmd <- paste0(ggParams$repoLoc, "/includes/circulationGeneric.Rmd")

# Vars for Rmd
ggParams$pubLoc <- "[Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin, New Zealand"
ggParams$otagoHCS <- "the University of Otago's High-Capacity Central File Storage [HCS](https://www.otago.ac.nz/its/services/hosting/otago068353.html)"

# Misc
ggParams$b2Kb <- 1024 #http://whatsabyte.com/P1/byteconverter.htm
ggParams$b2Mb <- 1048576

# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#a-colorblind-friendly-palette
# with grey
ggParams$cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# with black
ggParams$cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# see also
# https://www.r-bloggers.com/palettes-in-r/