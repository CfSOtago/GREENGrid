ggParams <<- list() # params holder

# Location of data
ggParams$projLoc <- findParentDirectory("nzGREENGrid")
ggParams$dataLoc <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/" # HPS by default
ggParams$gsMasterFile <- path.expand("~/Syncplicity Folders/Green Grid Project Management Folder/Gridspy/Master list of Gridspy units.xlsx")

# Rmd includes
ggParams$historyGenericRmd <- paste0(ggParams$projLoc, "/includes/historyGeneric.Rmd")
ggParams$supportGenericRmd <- paste0(ggParams$projLoc, "/includes/supportGeneric.Rmd")
ggParams$circulationGenericRmd <- paste0(ggParams$projLoc, "/includes/circulationGeneric.Rmd")

# Vars for Rmd
ggParams$pubLoc <- "[Centre for Sustainability](http://www.otago.ac.nz/centre-sustainability/), University of Otago: Dunedin"

# Misc
ggParams$b2Kb <- 1024 #http://whatsabyte.com/P1/byteconverter.htm
ggParams$b2Mb <- 1048576

