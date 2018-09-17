### ----- About ---- 
# Master (make) file

####

# Housekeeping ----
rm(list=ls(all=TRUE)) # remove all objects from workspace

# Load GREENGrid package ----

print(paste0("#-> Load GREENGrid package"))
library(GREENGrid) # local utilities
print(paste0("#-> Done "))

# Set global package parameters ----
print(paste0("#-> Set up GREENGrid package "))
GREENGrid::setup()
print(paste0("#-> Done "))

# Load libraries needed in this .r file ----
localLibs <- c("rmarkdown")
loadLibraries(localLibs)

# Local functions ----

# --- Build report ----

# Via (parameterised) .Rmd

hhID <- "rf_06"  # <- change this to run over a different household

startTime <- proc.time()
print(paste0("#-- Rebuilding report for: ", hhID, "--#"))
# run the report .Rmd and render to pdf
rmdFile <- paste0(ggParams$repoLoc, "/dataProcessing/gridSpy/testHouseholdPower.Rmd")
rmarkdown::render(input = rmdFile,
                  output_format = "html_document",
                  params = list(hhID = hhID),
                  output_file = paste0(ggParams$repoLoc,"/dataProcessing/gridSpy/", hhID, "_gridSpy1mProcessingReport.html")
)
print(paste0("#-- Finished rebuilding report for: ", hhID, "--#"))
t <- proc.time() - startTime
print(paste0("Report rebuild completed in ", getDuration(t)))



