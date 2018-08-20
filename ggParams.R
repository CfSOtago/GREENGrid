ggParams <<- list() # params holder

# Location of data
ggParams$projLoc <- findParentDirectory("GREENGrid")
ggParams$dataLoc <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HPS by default

ggParams$gsMasterFile <- "~/Syncplicity Folders/Green Grid Project Management Folder/Gridspy/Master list of Gridspy units.xlsx"
ggParams$hhAttributes <- paste0(ggParams$dataLoc, "cleanData/safe/survey/ggHouseholdAttributesSafe.csv")

# Rmd includes
ggParams$historyGenericRmd <- paste0(ggParams$projLoc, "/includes/historyGeneric.Rmd")
ggParams$supportGenericRmd <- paste0(ggParams$projLoc, "/includes/supportGeneric.Rmd")
ggParams$circulationGenericRmd <- paste0(ggParams$projLoc, "/includes/circulationGeneric.Rmd")

# Vars for Rmd
ggParams$pubLoc <- "[Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin"
ggParams$otagoHCS <- "the University of Otago's High-Capacity Central File Storage [HCS](https://www.otago.ac.nz/its/services/hosting/otago068353.html)"

# Misc
ggParams$b2Kb <- 1024 #http://whatsabyte.com/P1/byteconverter.htm
ggParams$b2Mb <- 1048576

