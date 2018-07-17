

WholesalePrices  <- "/Volumes/hum-csafe/Research Projects/GREEN Grid/_RAW DATA/EA_Wholesale_Prices/Wholesale_16-17_clean.csv"


print(paste0("Trying to load: ", WholesalePrices))
PricesDT <- data.table::as.data.table(readr::read_csv(WholesalePrices)) # reading data
PricesDT <- PricesDT[, dateTimeStartUTC := lubridate::dmy_hm(`Period start`)] # creating column based on orig. data
PricesDT <- PricesDT[, dateTimeStart := lubridate::force_tz(dateTimeStartUTC, tz = "Pacific/Auckland")] # changing time to NZST
PricesDT$dateTimeStartUTC <- NULL
PricesDT <- PricesDT[, dstFlag := lubridate::dst(dateTimeStart)] #
#PricesDT[, .(n = .N), keyby = .(month = lubridate::month(dateTimeStart), dstFlag)]
