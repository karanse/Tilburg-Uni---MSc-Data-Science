### Title:    Stats & Methods Lab 1 Practice Script
### Author:   Kyle M. Lang
### Created:  2018-APR-10
### Modified: 2018-SEP-04


###          ###
### Overview ###
###          ###

## You will practice some basic EDA techniques, missing data descriptives, and
## outlier analysis.

## You will need three datasets to complete the following tasks: "bfiOE.rds",
## "tests.rds", and "airQual.rds". These datasets are all saved in the "data"
## directory for this set of lab materials.


###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "install.packages" function to install the "mice" package.


## 2) Use the "library" function to load the "MASS" and "mice" packages.
library(mice)
library(MASS)
## 3) Use the "paste0" function and the "readRDS" function to load the three
##    datasets into memory.

setwd("/Volumes/GoogleDrive/My Drive/My Documents/SemaDRive/TU DATA SCIENCE/Statistics & Methodology/LAbs/Week 2")
data_dir <- "./data/"

data_tests <- readRDS(paste0(data_dir, "tests.rds"))
data_airQual <- readRDS(paste0(data_dir,"airQual.rds"))
data_mtcars <- readRDS(paste0(data_dir,"mtcars.rds"))


##--EDA-----------------------------------------------------------------------##

### Use the "tests" data to answer the following questions:

## 1) What are the dimensions of these data?
dimension <- dim(data_tests)
dimension  #--->700 , 6

## 2) What is the mean "SATQ" score?
mean(data_tests$SATQ) #--->609.6414

## 3) What is the variance of the "SATQ" scores?
var(data_tests$SATQ) # ---> 13357.14

## 4) What is the median "SATV" score?
median(data_tests$SATV)  #---> 620

## 5) What is the MAD of the "SATV" scores?
mad(data_tests$SATV) # ---> 118.608

## 6) Create a histogram of the "ACT" variable.
hist(data_tests$ACT)

## 7) Create a kernel density plot of the "ACT" variable.
plot(density(data_tests$ACT))

## 8) Overlay a normal density on top of the "ACT" histogram.
hist(data_tests$ACT, probability = TRUE)
lines(x = x, y = dnorm(x, mean = m, sd = s))

## 9) Create a grouped boxplot that plots "ACT" by "education".
boxplot(SATV ~ gender, data = data_tests)

## 10) Create a frequency table of "education"
table(data_tests$education)
## 11) Create a contingency table that cross-classifies "gender" and "education"

table(data_tests$gender, data_tests$education)

## 12) Suppose a certain university admits any student with an ACT score of, at
##     least, 25. How many of the women these data would be admitted?
table(data_tests$gender, data_tests$ACT)

nrow(data_tests %>% filter(ACT >= 25 & gender == "female"))

##--Missing Data--------------------------------------------------------------##

### Use the "bfiOE" data to answer the following questions:

bfiOE <- readRDS(paste0(data_dir, "bfiOE.rds"))

## 1a) Compute the proportion of missing values for each variable.
colMeans(is.na(bfiOE))

## 1b) What is the percentage of missing data for "O1"?
mean(is.na(bfiOE$O1))

## 2a) Compute the covariance coverage matrix.
md.pairs(bfiOE)$rr / nrow(bfiOE)

## 2b) What is the covariance coverage between "E2" and "O4"?
#--> 0.9468085

## 3a) Compute the missing data patterns for these data.

missPat <- md.pattern(bfiOE)  
missPat
## 3b) How many distinct missing data patterns exist in these data?
#---> 28

## 3c) How many missing data patterns have only one missing value?
# ---> 338

## 3d) How many observations are affected by patterns that involve only one
##     missing value?


##--Outliers------------------------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1) Use Tukey's boxplot method to find possible and probable outliers in the
##    "Ozone", "Solar.R", "Wind", and "Temp" variables.
## 1b) Did you find any possible outliers?
## 1c) Did you find any probable outliers?
## 1d) Which, if any, observations were possible outliers on "Ozone"?
## 1e) Which, if any, observations were probable outliers on "Wind"?

## 2) Use the MAD method to find possible and probable outliers in the "Ozone",
##    "Solar.R", "Wind", and "Temp" variables.
## 2a) Did you find any potential outliers?
## 2b) Which, if any, observations are potential outliers on "Wind"?

### For Question 3, you will use different parameterizations of robust
### Mahalanobis distance (with MCD estimation) to check for multivariate
### outliers on the "Ozone", "Solar.R", "Wind", and "Temp" variables.

## 3a) Which, if any, observations are flagged as multivariate outliers when
##     using 75% of the sample for the MCD estimation and using a probability of
##     0.99 for the cutoff value?
## 3b) Which, if any, observations are flagged as multivariate outliers when
##     using 75% of the sample for the MCD estimation and using a probability of
##     0.999 for the cutoff value?
## 3c) Which, if any, observations are flagged as multivariate outliers when
##     using 50% of the sample for the MCD estimation and using a probability of
##     0.99 for the cutoff value
## 3d) Which, if any, observations are flagged as multivariate outliers when
##     using 50% of the sample for the MCD estimation and using a probability of
##     0.999 for the cutoff value?
## 3e) Based on the above, what consequences do you observe when changing the
##     fraction of the sample used for MCD estimation and when changing the
##     cutoff probability?
