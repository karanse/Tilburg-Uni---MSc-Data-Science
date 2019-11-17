### Title:    Stats & Methods Lab 2 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2017-SEP-08
### Modified: 2018-SEP-11

###--------------------------------------------------------------------------###

### Preliminaries ###

install.packages("MLmetrics", repos = "http://cloud.r-project.org")

rm(list = ls(all = TRUE)) # Clear workspace

library(MASS)      # We'll need this for robust stats
library(MLmetrics) # We'll need this for MSEs

#setwd("") # Let's all set our working directory to the correct place

###--------------------------------------------------------------------------###

### Data I/O ###

dataDir <- "./data/"
fn1     <- "tests.rds"
fn2     <- "mtcars.rds"



tests <- readRDS(paste0(dataDir, fn1)) 
cars  <- readRDS(paste0(dataDir, fn2))

###--------------------------------------------------------------------------###

### Outlier Analysis ###

## Compute the statistics underlying a boxplot:
boxplot.stats(tests$SATV)

## Assign function argument to demonstrate its internals:
x <- tests$SATV

## Define a function to implement the boxplot method:
bpOutliers <- function(x) {
    ## Compute inner and outer fences:
    iFen <- boxplot.stats(x, coef = 1.5)$stats[c(1, 5)]
    oFen <- boxplot.stats(x, coef = 3.0)$stats[c(1, 5)]
    
    ## Return the row indices of flagged 'possible' and 'probable' outliers:
    list(possible = which(x < iFen[1] | x > iFen[2]),
         probable = which(x < oFen[1] | x > oFen[2])
         )
}

rm(list = c("x", "iFen", "oFen"))# Clean up

## Flag potential outliers in all numeric columns:
lapply(tests[ , -c(1, 2)], FUN = bpOutliers)

###--------------------------------------------------------------------------###

## Assign function arguments to demonstrate its internals:
x     <- tests$SATV
cut   <- 2.5
na.rm <- TRUE

## Define a function to implement the MAD method:
madOutliers <- function(x, cut = 2.5, na.rm = TRUE) {
    ## Compute the median and MAD of x:
    mX   <- median(x, na.rm = na.rm)
    madX <- mad(x, na.rm = na.rm)
    
    ## Return row indices of observations for which |T_MAD| > cut:
    which(abs(x - mX) / madX > cut)
} 

rm(list = c("x", "cut", "na.rm", "mX", "madX"))# Clean up

## Find potential outliers in all numeric columns:
lapply(tests[ , -c(1, 2)], FUN = madOutliers)
    
###--------------------------------------------------------------------------###

## Assign function arguments to demonstrate its internals:
data  <- tests[ , -c(1, 2)]
prob  <- 0.99
ratio <- 0.75

## Define a function to implement a robust version of Mahalanobis distance
## using MCD estimation:
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

rm(list = c("data", "prob", "ratio", "stats", "md", "crit"))# Clean up

## Flag potential multivariate outliers:
mcdMahalanobis(data = tests[ , -c(1, 2)], prob = 0.99)

###--------------------------------------------------------------------------###

### Linear regression ###

## Fit a simple linear regression model:
lmOut1 <- lm(qsec ~ hp, data = cars)

## Evaluating the fitted models symbol doesn't give us much:
lmOut1

## Summarize the model:
summary(lmOut1)
plot(data=cars, qsec~hp)
## Look at the contents of the fitted model object and its summary:
ls(lmOut1)
ls(summary(lmOut1))

## Fit a multiple linear regression model:
lmOut2 <- lm(qsec ~ hp + wt, data = cars)

## Summarize the model:
s2 <- summary(lmOut2)
s2

## Extract R^2:
s2$r.squared

## Extract F-stat:
s2$fstatistic

## Extract coefficients:
coef(lmOut2)

## Extract residuals:
res2 <- resid(lmOut2)
res2

## Extract residual standard deviation/variance:
sig2 <- s2$sigma
sig2

sig2Sq <- sig2^2
sig2Sq

## Calculate the residual variance manually and compare:
sig2SqM <- sum(res2^2) / lmOut2$df.residual
sig2Sq - sig2SqM

## Extract fitted values (two ways):
yHat2.1 <- fitted(lmOut2)
yHat2.2 <- predict(lmOut2)

yHat2.1
yHat2.2

## Compare:
yHat2.1 - yHat2.2

## Compute confidence intervals:
confint(lmOut2)
confint(lmOut2, parm = "hp")
confint(lmOut2, parm = c("(Intercept)", "wt"), level = 0.99)

## Mean-center the horsepower variable (two ways):
hpMC1 <- cars$hp - mean(cars$hp)
hpMC2 <- scale(cars$hp, scale = FALSE)

hpMC1 - hpMC2
## Use mean-centered hp and wt in a model:
head(cars)
cars[ , c("hpMC", "wtMC")] <- scale(cars[ , c("hp", "wt")], scale = FALSE)
head(cars)

lmOut3 <- lm(qsec ~ hpMC + wtMC, data = cars)
summary(lmOut3)

###--------------------------------------------------------------------------###

### Model comparison ###

## Change in R^2:
s2$r.squared - summary(lmOut1)$r.squared

## Significant increase in R^2?
anova(lmOut1, lmOut2)

## Compare MSE values:
mse1 <- MSE(y_pred = predict(lmOut1), y_true = cars$qsec)
mse2 <- MSE(y_pred = predict(lmOut2), y_true = cars$qsec)

mse1
mse2

###--------------------------------------------------------------------------###
