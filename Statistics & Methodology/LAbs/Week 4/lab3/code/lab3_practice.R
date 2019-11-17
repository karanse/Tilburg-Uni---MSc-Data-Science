### Title:    Stats & Methods Lab Practice Script
### Author:   Kyle M. Lang
### Created:  2018-APR-10
### Modified: 2018-SEP-18


###          ###
### Overview ###
###          ###

## You will practice prediction, cross-validation, and multiple imputation.

## You will need the "yps.rds" and the "bfiANC2.rds" datasets to answer the
## following questions. These datasets are available in the "data" directory for
## this lab


###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "library" function to load the "MLmetrics" and "mice" packages.
library(MLmetrics) # We'll need this for MSEs
library(mice)      # We'll need this for MI
library(mitools) 
## 2) Use the "paste0" function and the "readRDS" function to load the
##    "yps.rds" and "bfiANC2.rds" datasets into your workspace.
dataDir <- "../data/"
fn3     <- "bfiANC2.rds"
fn4     <- "yps.rds"

bfia <- readRDS(paste0(dataDir, fn3)) 
yps <- readRDS(paste0(dataDir, fn4))


##--Prediction----------------------------------------------------------------##

### Use the "yps" data to complete the following:

## 1) Use the "set.seed" function to set the random number seed.

set.seed(235711)

## 2) Randomly split the sample into disjoint training, validation, and testing
##    sets with sample sizes of N = 700, N = 155, and N = 155, respectively.

ind2   <- sample(1 : nrow(yps))
train2 <- yps[ind2[1 : 700], ]
valid2 <- yps[ind2[701 : 855], ]
test2 <- yps[ind2[856:nrow(yps)],]

## 3a) Use the training data to estimate a baseline model that regresses
##     "Number.of.friends onto "Age" and "Gender".
out11 <- lm(data = train2, Number.of.friends ~ Age + Gender)

## 3b) Update the baseline model (from 3a) by adding "Keeping.promises",
##     "Empathy", "Friends.versus.money", and "Charity" as additional
##     predictors.
out12 <- update(out11, ".~. + Keeping.promises + Empathy + Friends.versus.money + Charity")

## 3c) Update the baseline model (from 3a) by adding "Branded.clothing",
##     "Entertainment.spending", "Spending.on.looks", and "Spending.on.gadgets"
##     as additional predictors.
out13 <- update(out11, ".~. + Branded.clothing + Entertainment.spending + Spending.on.looks + Spending.on.gadgets")

## 3d) Update the baseline model (from 3a) by adding "Workaholism",
##     "Reliability", "Responding.to.a.serious.letter", and "Assertiveness" as
##     additional predictors.
out14 <- update(out11, ".~. + Workaholism + Reliability +  Responding.to.a.serious.letter +Assertiveness")

## 4a) Compute the validation set MSEs for the three models you estimated in
##     (3b), (3c), and (3d).
p12 <- predict(out12, newdata = valid2)
p13 <- predict(out13, newdata = valid2)
p14 <- predict(out14, newdata = valid2)

MSE(y_pred = p12, y_true = valid2$Number.of.friends)
MSE(y_pred = p13, y_true = valid2$Number.of.friends)
MSE(y_pred = p14, y_true = valid2$Number.of.friends)

## 4b) Which model should be preferred, based on their relative prediction
##     errors?  --> Model 13

## 5a) Combine the training and validation sets that you created in (2).
data_pool <- rbind(train2, valid2)

## 5b) Using the combined data from (5a) and 5-fold cross-validation, compare
##     the three models defined in (3b), (3c), and (3d).


cv.lm <- function(data, models, K = 10) {
  ## Create a partition vector:
  part <- sample(rep(1 : K, ceiling(nrow(data) / K)))[1 : nrow(data)]
  
  ## Find the DV:
  dv <- trimws(strsplit(models[1], "~")[[1]][1])
  
  ## Apply over candidate models:
  sapply(X = models, FUN = function(model, data, dv, K, part) {
    ## Loop over K repititions:
    mse <- c()
    for(k in 1 : K) {
      ## Partition data:
      train <- data[part != k, ]
      valid <- data[part == k, ]
      
      ## Fit model, generate predictions, and save the MSE:
      fit    <- lm(model, data = train)
      pred   <- predict(fit, newdata = valid)
      mse[k] <- MSE(y_pred = pred, y_true = valid[ , dv])
    }
    ## Return the CVE:
    sum((table(part) / length(part)) * mse)
  },
  data = data,
  K    = K,
  dv   = dv,
  part = part)
}

cv.lm(K = 5,
      data   = rbind(train2, valid2),
      models = c("Number.of.friends ~ Age + Gender + Keeping.promises + Empathy + Friends.versus.money + Charity",
                 "Number.of.friends ~ Age + Gender + Branded.clothing + Entertainment.spending + Spending.on.looks + Spending.on.gadgets",
                 "Number.of.friends ~ Age + Gender + Workaholism + Reliability +  Responding.to.a.serious.letter +Assertiveness"))

## 5c) Which model should be preferred, based on their relative cross-validation
##     errors? -->> model 13

## 5d) Does the result from (5c) agree with the result from (4b)?
## ----> yes

## 5e) Use the testing data that you set aside in (2) to estimate the prediction
##     error (i.e., test set MSE) of the model chosen in (5c).

p13.1 <- predict(out13, newdata = test2)
MSE(y_pred = p13.1, y_true = test2$Number.of.friends)

## ----->>> 1.065005

##--Multiple imputation-------------------------------------------------------##

### Use the "bfiANC2" data for the following:

## 1) Use the "mice" package, with the following setup, to create multiple
##    imputations of the "bfiANC2" data.
##    -- 25 imputations
##    -- 15 iterations
##    -- A random number seed of "314159"
##    -- All "A" variables imputed with predictive mean matching
##    -- All "N" variables imputed with Bayesian linear regression
##    -- All "C" variables imputed with linear regression using bootstrapping
##    -- A predictor matrix generated with the "quickpred" function using the
##       following setup:
##    ---- The minimum correlation set to 0.25
##    ---- The "age" and "gender" variables included in all elementary
##         imputation models
##    ---- The "id" variable excluded from all elementary imputation models

meth2        <- rep("norm", ncol(bfia))
names(meth2) <- colnames(bfia)
meth2[2:6] <- "pmm"
meth2[7:11] <- "norm.boot"
meth2[12:17] <- "norm"
meth2["education"] <- "polr"

predMat1 <- quickpred(bfia, mincor = 0.25, include = c("gender", "age","education"), exclude = "id")


miceOut11 <- mice(bfia, m = 25, maxit = 15, seed = 314159, method = meth2, predictorMatrix = predMat1)


## 2a) Use the "lm.mids" function to regress "A1" onto "C1", "N1", and
##     "education" using the multiply imputed data from (1)

out21 <- lm.mids(A1~C1 + N1 + education, data = miceOut11)

poolout21 <- pool(out21)
summary(poolout21)

## 2b) Use the "lm.mids" function to regress "A1" onto "C1", "N1", "education",
##     "age", and "gender" using the multiply imputed data from (1)
out22 <- lm.mids(A1 ~ C1 + N1 + education + age + gender, data = miceOut11)
poolout22 <- pool(out22)
summary(poolout22)

## 3a) What is the MI estimate of the slope of "age" on "A1" from (2b)?
##---->>  -0.02154926 


## 3b) Is the effect in (3a) significant at the alpha = 0.05 level?

## 4a) What is the MI estimate of the slope of "N1" on "A1" from (2a)?
## 4b) Is the effect in (4a) significant at the alpha = 0.01 level?

## 5a) What is the MI estimate of the R^2 from the model in (2a)?
pool.r.squared(out21)
## --->  0.06112815

## 5b) What is the MI estimate of the R^2 from the model in (2b)?
pool.r.squared(out22)
##--->  0.1107404


## 6a) What is the MI estimate of the increase in R^2 when going from the model
##     in (2a) to the model in (2b)?
pool.r.squared(out21)[1] - pool.r.squared(out22)[1]
##---->  -0.04961223

## 6b) Is the increase in R^2 from (6a) statistically significant at the
##     alpha = 0.05 level?
fTest1 <- pool.compare(out22, out21)

fTest1$Dm     # Test statistic
fTest1$pvalue # P-Value

##---> yes

## 6c) What is the value of the test statistic that you used to answer (6b)?
##-->  14.57271,  14.573




