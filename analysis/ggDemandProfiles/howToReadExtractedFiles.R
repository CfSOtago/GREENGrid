library(readr)
f <- "~/Data/NZ_GREENGrid/safe/gridSpy/1min/data/rf_06_all_1min_data.csv.gz"
df <- readr::read_csv(f,
                      col_types = list(
                        hhID = col_character(),
                        r_dateTime = col_datetime(format = ""),
                        circuitLabel = col_character(),
                        circuitID = col_integer(),
                        powerW = col_double() # <- crucial - only applies to household level files, not circuit extracts.
                      )
                      )

summary(df)

# compare:
df <- readr::read_csv(f)

summary(df)
