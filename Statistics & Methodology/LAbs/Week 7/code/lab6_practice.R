### Title:    Stats & Methods Lab 6 Practice Script
### Author:   Kyle M. Lang
### Created:  2018-OCT-09
### Modified: 2018-OCT-09


###          ###
### Overview ###
###          ###

## You will practice regression diagnostics for MLR models.

## You will need the "airQual.rds" dataset which is available in the "data"
## directory for this lab.

dataDir <- "../data/"
airQual <- readRDS(paste0(dataDir, "airQual.rds"))

###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "install.packages" function to install the "moments", "lmtest",
##    and "sandwich" packages.

install.packages("lmtest"); install.packages("moments"); install.packages("sandwich")


## 2) Use the "library" function to load the "moments", "lmtest", and "sandwich"
##    packages.


library(MASS)     # For the 'Cars93' data
library(lmtest)   # Provides Breusch-Pagan and RESET Tests
library(moments)  # Provides skewness and kurtosis
library(sandwich)

## 3) Use the "readRDS" function to load the "airQual.rds" dataset into your
##    workspace.


##--Model specification-------------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1) Regress "Temp" onto "Ozone", "Wind", and "Solar.R".

out1 <- lm(data = airQual, Temp ~ Ozone + Wind + Solar.R)
summary(out1)

## 2a) Plot the residuals from the model estimated in (1) against its fitted
##     values.

plot(out1, which = 1) 

## 2b) What can you infer from the plot created in (2a)?

## 2c) What do you think is the best course of action to correct the issues
##     represented in the plot from (2a)?


## 3a) Conduct a Ramsey RESET test for the model estimated in (1).
##     -- Add the second and third powers of the fitted values.

out1.1 <- update(out1, ". ~ . + I(Ozone^2) + I(Ozone^3)+I(Wind^2)+I(Wind^3)+I(Solar.R^2)+I(Solar.R^3)")
resettest(out1.1) 
plot(out1.1, which = 1)

## 3b) What does the RESET test in (3a) tell you?

## 4a) Update the model estimated in (1) three times. In each new model, add the
##     square of exactly one of the predictor variables.
##     -- Each of these three models should be identical to the model from (1)
##        except for the inclusion of one quadratic term.

out1.2 <- update(out1, ". ~ . + I(Ozone^2)")
out1.3 <- update(out1, ". ~ . + I(Wind^2)")
out1.4 <- update(out1, ". ~ . + I(Solar.R^2)")


## 4b) For each of the updated models estimated in (4a) compute the same type of
##     residual plot that you created in (2a) and conduct a Ramsey RESET test as
##     you did in (3a).

plot(out1.2, which = 1)
plot(out1.3, which = 1)
plot(out1.4, which = 1)

resettest(out1.2) 
resettest(out1.3) 
resettest(out1.4) 

## 4c) Which predictor's quadratic term most improved the model specification?
#-- model 1.2 - Ozone

## 4d) Does the RESET test for the model you indicated in (4c) still suggest
##     significant misspecification?


##--Diagnostics---------------------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1) Regress "Temp" onto "Ozone", "Wind", "Solar.R", and the square of "Ozone".
##    -- In the following sections, this model will be referred to as "M0".

out2 <- lm(data = airQual, Temp ~ Ozone + Wind + Solar.R + I(Ozone^2))
summary(out2)

## 2a) Plot the residuals from the model estimated in (1) against its fitted
##     values.

plot(out2, which = 1)

## 2b) What can you infer from the plot created in (2a)?

## 75 obs jerk


## 3a) Conduct a Ramsey RESET test for the model estimated in (1).
##     -- Add the second and third powers of the fitted values.

out2.1 <-  update(out2, ". ~ . + I(Ozone^2) + I(Ozone^3) + I(Wind^2) + I(Wind^3) + I(Solar.R^2) + I(Solar.R^3)")


## 3b) Does the RESET test in (3a) suggest misspecification?

resettest(out2.1) 

## 4a) Evaluate the normality of the residuals from the model in (1) using a Q-Q
##     plot, the skewness, and the kurtosis.

skewness(resid(out2.1))  #resid(out1) gives the residual; the difference values with Y and Yhat
kurtosis(resid(out2))

## Check the normality of residual via Q-Q Plot:
qqnorm(resid(out2.1)) #residuals from fitted model
qqline(resid(out2.1))  #-->  3.804

## 4b) Create a kernel density plot of the residuals from the model in (1).

plot(density(out2.1$residuals))

## 4c) Judging by the information gained in (4a) and (4b), do you think it's
##     safe to assume normally distributed errors for the model in (1)?
#Yes


## 5a) Conduct a Breusch-Pagan test for the model estimated in (1).
## 5b) What does the Breusch-Pagan test from (4a) tell you?
## 5c) Do the Breusch-Pagan test and the residual plot from (2a) agree?


##--Robust SEs----------------------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1) Estimate the heteroscedasticity consistent (HC) asymptotic covariance
##    matrix for M0 (i.e., the model from [1] in the "Diagnostics" section).

## 2a) Use the HC covariance matrix from (1) to test the coefficients of M0 with
##     robust SEs.
## 2b) Compare the results from (2a) to the default tests of M0's coefficients.
##     What changes when using robust SEs?

## 3) Update M0 by adding the squares of "Wind" and "Solar.R".

## 4a) Using HC estimates of the SEs, conduct a nested model comparison to test
##     if adding the squares of "Wind" and "Solar.R" to M0 explains
##     significantly more variance in "Temp".
## 4b) What is the conclusion of the test in (4a)?
## 4c) Compare the test in (4a) to the default version that does not use HC
##     estimates of the SEs. What differs when using robust SEs?


##--Influential observations--------------------------------------------------##

### Use the "airQual" data to complete the following:

## 1a) Compute the studentized residuals of M0 (i.e., the model from [1] in the
##     "Diagnostics" section).
## 1b) Create an index plot of the residuals computed in (1a).
## 1c) What can you infer from the plot in (1b)?
## 1d) What are the observation numbers for the two most probable outliers
##     according to the residuals from (1a)?

## 2a) Compute the leverages of M0.
## 2b) Create an index plot of the leverages computed in (2a).
## 2c) What can you infer from the plot in (2b)?
## 2d) What are the observation numbers with the three highest leverages?

## 3a) Compute the Cook's distances of M0.
## 3b) Create an index plot of the distances computed in (3a).
## 3c) What can you infer from the plot in (3b)?
## 3d) What are the observation numbers for the five most influential cases
##     according to the distances from (3a)?
## 3e) What do you notice about the set of observations flagged as influential
##     cases in (3d), relative to the observations flagged as high leverage
##     points in (2d) and those flagged as outliers in (1d)?

## 4a) Remove the five most influential cases from (3d) and use the cleaned data
##     to rerun M0.
## 4b) Compare the results of the model in (4a) to the results of the original
##     M0. What changes when removing the influential cases?

##----------------------------------------------------------------------------##
