### Title:    Stats & Methods Lab Practice Script
### Author:   Kyle M. Lang
### Created:  2018-APR-10
### Modified: 2018-SEP-11


###          ###
### Overview ###
###          ###

## You will practice outlier analysis (carried over from last week) and some
## basic regression modeling.

## You will need the "airQual.rds" data from last week's lab for the outlier
## analysis. This dataset is available in the "data" directory for this lab. You
## will also analyze the built-in R dataset "longley."


###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "install.packages" function to install the "MLmetrics" package.
library(MLmetrics)
## 2) Use the "library" function to load the "MASS" and "MLmetrics" packages.
library(MASS)
## 3) Use the "paste0" function and the "readRDS" function to load the
##    "airQual.rds" data into your workspace.
dataDir <- "./data/"
airqual    <- "airQual.rds"

aqdata <- readRDS(paste0(dataDir, airqual))
## 4) Use the "data" function to load the "longley" dataset into your workspace.


##--Outliers------------------------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1) Use Tukey's boxplot method to find possible and probable outliers in the
##    "Ozone", "Solar.R", "Wind", and "Temp" variables.
bpOutliers <- function(x) {
  ## Compute inner and outer fences:
  iFen <- boxplot.stats(x, coef = 1.5)$stats[c(1, 5)]
  oFen <- boxplot.stats(x, coef = 3.0)$stats[c(1, 5)]
  
  ## Return the row indices of flagged 'possible' and 'probable' outliers:
  list(possible = which(x < iFen[1] | x > iFen[2]),
       probable = which(x < oFen[1] | x > oFen[2])
  )
}

lapply(aqdata[ , ], FUN = bpOutliers)
## 1b) Did you find any possible outliers?
# -> yes
## 1c) Did you find any probable outliers?

#-->No
## 1d) Which, if any, observations were possible outliers on "Ozone"?
bpOutliers(aqdata$Ozone)
# --> yes, 6

## 1e) Which, if any, observations were probable outliers on "Wind"?
#--> none

## 2) Use the MAD method (with a cuttoff of 2.5) to find potential outliers in
##    the "Ozone", "Solar.R", "Wind", and "Temp" variables.

madOutliers <- function(x, cut = 2.5, na.rm = TRUE) {
  ## Compute the median and MAD of x:
  mX   <- median(x, na.rm = na.rm)
  madX <- mad(x, na.rm = na.rm)
  
  ## Return row indices of observations for which |T_MAD| > cut:
  which(abs(x - mX) / madX > cut)
} 

rm(list = c("x", "cut", "na.rm", "mX", "madX"))# Clean up

## Find potential outliers in all numeric columns:
lapply(aqdata[ , ], FUN = madOutliers)
## 2a) Did you find any potential outliers?
# yes, ozone, wind, temp

## 2b) Which, if any, observations are potential outliers on "Wind"?
# 3 values

### For Question 3, you will use different parameterizations of robust
### Mahalanobis distance (with MCD estimation) to check for multivariate
### outliers on the "Ozone", "Solar.R", "Wind", and "Temp" variables.
mcdMahalanobis <- function(data, prob, ratio = 0.75) {
  ## Compute the MCD estimates of the mean and covariance matrix:
  stats <- cov.mcd(data, quantile.used = floor(ratio * nrow(data)))
  
  ## Compute robust squared Mahalanobis distances
  md <- mahalanobis(x = data, center = stats$center, cov = stats$cov)
  
  ## Find the cutoff value:
  crit <- qchisq(prob, df = ncol(data))
  
  ## Return row indices of flagged observations:
  which(md > crit)
}

rm(list = c("data", "prob", "ratio", "stats", "md", "crit"))

mcdMahalanobis(data = aqdata[ , -c(5,6)], prob = 0.99)
## 3a) Which, if any, observations are flagged as multivariate outliers when
##     using 75% of the sample for the MCD estimation and using a probability of
##     0.99 for the cutoff value?
# yes, 17 values

## 3b) Which, if any, observations are flagged as multivariate outliers when
##     using 75% of the sample for the MCD estimation and using a probability of
##     0.999 for the cutoff value?
mcdMahalanobis(data = aqdata[ , -c(5,6)], prob = 0.999)
# yes, 10 values

## 3c) Which, if any, observations are flagged as multivariate outliers when
##     using 50% of the sample for the MCD estimation and using a probability of
##     0.99 for the cutoff value
mcdMahalanobis(data = aqdata[ , -c(5,6)], prob = 0.99, ratio = 0.50)
#-->yes, 22 values

## 3d) Which, if any, observations are flagged as multivariate outliers when
##     using 50% of the sample for the MCD estimation and using a probability of
##     0.999 for the cutoff value?
mcdMahalanobis(data = aqdata[ , -c(5,6)], prob = 0.999, ratio = 0.50)
# --> yes, 18 values

## 3e) Based on the above, what consequences do you observe when changing the
##     fraction of the sample used for MCD estimation and when changing the
##     cutoff probability?


##--Simple linear regression--------------------------------------------------##

### Use the "longley" data for the following:

data("longley")

## 1) Regress "GNP" onto "Year."
out1 <- lm(GNP ~ Year, data = longley)
## 2) What proportion of variability in "GNP" is explained by "Year?"
s1 <- summary(out1)
round(s1$r.squared,3)

## 3a) What is the slope of "Year" on "GNP?"  ---> 20.778
s2 <- summary(out1)
s2$coefficients

## 3b) Is the effect of "Year" on "GNP" statistically significant at the
##     alpha = 0.05 level?

## 3c) Is the effect of "Year" on "GNP" statistically significant at the
##     alpha = 0.01 level?

## 4) What is the residual variance for the model estimated in Step 1?
s1_sig <- s1$sigma
s1_var <- s1_sig^2
round(s1_var,2)

## 5a) What is the 95% confidence interval (CI) for the intercept of the model
##     estimated in Step 1?

confint(out1)

## 5b) What is the 99% confidence interval (CI) for the intercept of the model
##     estimated in Step 1?
confint(out1, parm = c("(Intercept)", "Year"), level = 0.99)
## 6) Regress "GNP" onto "Population."
out2 <- lm(GNP ~ Population, data = longley)
s2 <-summary(out2)

## 7a) What is the standard error of the slope of "Population" on "GNP?" ---> 
s2
## 7b) Is the effect of "Population" on "GNP" statistically significant at the
##     alpha = 0.05 level?


##--Multiple linear regression------------------------------------------------##

### Use the "longley" data for the following:

## 1) Regress "GNP" onto "Year" and "Population."
out3 <- lm(GNP ~ Year + Population, data = longley)

## 2) Is there a significant effect (alpha = 0.05) of "Population" on "GNP"
##    after controlling for "Year?" 
summary(out3) #---> No, pvalues is >0.05

## 3) Regress "GNP" onto "Year" and "Employed."
out4 <- lm(GNP ~ Year + Employed, data=longley)
summary(out4)

## 4a) What is the partial effect of "Employed" on "GNP", after controlling for
##     "Year?"  ---> 8.419

## 4b) Is the partial effect of "Employed" on "GNP" statistically significant at
##     the alpha = 0.05 level?

## 5) Regress "GNP" onto "Year" and "Unemployed."

## 6a) What is the partial effect of "Unemployed" on "GNP", after controlling
##     for "Year?" 
## 6b) Is the partial effect of "Unemployed" on "GNP" statistically significant
##     at the alpha = 0.05 level?


##--Model comparison----------------------------------------------------------##

### Use the "longley" data for the following:

## 1a) What is the difference in R-squared between the simple linear regression
##     of "GNP" onto "Year" and the multiple linear regression of "GNP" onto
##     "Year" and "Population?"
s1 <- summary(out1)
s3 <- summary(out3)
 s3$r.squared -s1$r.squared 

## 1b) Is this increase in R-squared significantly different from zero at the
##     alpha = 0.05 level? 
anova(out1,out3) #---> No, greated than alpha

## 1c) What is the value of the test statistic that you used to answer (1b)?
 # ---> 0.5397

## 2a) What is the MSE for the model that regresses "GNP" onto "Year" and
##     "Employed?"
mse4 <- MSE(y_pred = predict(out4), y_true = longley$GNP)
mse4
## 2b) What is the MSE for the model that regresses "GNP" onto "Year" and
##     "Unemployed?"
out5 <- lm(GNP ~ Year + Unemployed, data = longley)
mse5 <- MSE(y_pred = predict(out5), y_true = longley$GNP)
mse5
## 2c) According to the MSE values calculated above, is "Employed" or
##     "Unemployed" the better predictor of "GNP?"
## 2d) Could we do the comparison in (2c) using an F-test for the difference in
##     R-squared values? Why or why not?
