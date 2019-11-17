### Title:    Process Wave 6 WVS Data
### Author:   Kyle M. Lang
### Created:  2018-09-18
### Modified: 2018-09-18

### Inputs:
## 1) dataDir:  The relative path to the directory containing your data
## 2) fileName: The file name (including extension) of the Wave 6 WVS RData file

### Output:
## 1) A processed dataset called "wvs_data.rds" saved to the directory assigned 
##    to the "dataDir" variable

dataDir  <- "../data/"
fileName <- "Wv6_Data_R_v_2016_01_01.rdata"

###--END USER INPUT----------------------------------------------------------###

## Load the target variable names and imputations:
varNames <- readRDS(paste0(dataDir, "wvs_column_names.rds"))
imps     <- readRDS(paste0(dataDir, "wvs_imputations.rds"))

## Load the full Wave 6 WVS data:
load(paste0(dataDir, fileName))

## Try to confirm that we're working with the correct data:
check <- any(grepl("WV\\d_Data_R", ls()))
if(!check)
    stop("Cannot find data object. Are you sure you've downloaded the correct file?")

check <- all(WV6_Data_R$V1 == 6)
if(!check)
    stop("This does not appear to be Wave 6 data. Are you sure you've downloaded the correct file?")

## Subset the data and assign them to a simpler name:
dat0 <- WV6_Data_R[WV6_Data_R$V2 %in% c(156, 276, 356, 643, 840), varNames]
rm(WV6_Data_R)

## Replace missing values with imputations:
for(v in names(imps)) dat0[rownames(imps[[v]]), v] <- imps[[v]]

## Write out the processed data:
saveRDS(dat0, paste0(dataDir, "wvs_data.rds"))
