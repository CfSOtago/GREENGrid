df <- readr::read_csv("~/Data/NZGreenGrid/safe/gridSpy/1min/dataExtracts/Heat Pump_2015-04-01_2016-03-31_observations.csv.gz",
                      col_types = cols(
                        hhID = col_character(),
                        r_dateTime = col_datetime(format = ""),
                        circuitLabel = col_character(),
                        circuitID = col_integer(),
                        powerW = col_double() # <- crucial !!!
                      )
)

summary(df)

# compare:
df <- readr::read_csv("~/Data/NZGreenGrid/safe/gridSpy/1min/dataExtracts/Heat Pump_2015-04-01_2016-03-31_observations.csv.gz")



df <- read_csv("/Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/Aurora_CPD/Edited_whole.csv",
               col_types =  cols(
    DateTime = col_character(),
    month = col_integer(),
    CPDmin12 = col_double(),
    CPDmin13 = col_double(),
    CPDmin14 = col_double(),
    CPDmin15 = col_double(),
    CPDmin16 = col_double()
  )
)

summary(df)
