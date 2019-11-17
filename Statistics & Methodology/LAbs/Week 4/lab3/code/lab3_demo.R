### Title:    Stats & Methods Lab 3 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2018-SEP-17
### Modified: 2018-SEP-18

###--------------------------------------------------------------------------###

### Preliminaries ###

rm(list = ls(all = TRUE)) # Clear workspace

set.seed(235711) # Set the random number seed

install.packages("mitools", repos = "http://cloud.r-project.org")

library(MLmetrics) # We'll need this for MSEs
library(mice)      # We'll need this for MI
library(mitools)   # We'll need this for MI pooling

setwd("") # Let's all set our working directory to the correct place

###--------------------------------------------------------------------------###

### Data I/O ###

dataDir <- "../data/"
fn1     <- "insurance.csv"
fn2     <- "bfiOE.rds"

ins <- read.csv(paste0(dataDir, fn1)) 
bfi <- readRDS(paste0(dataDir, fn2))

###--------------------------------------------------------------------------###

### Prediction & Cross-Validation ###

### Simple split-sample cross-validation:

## Split the data into training and validation sets:
ind   <- sample(1 : nrow(ins))
train <- ins[ind[1 : 1000], ]
valid <- ins[ind[1001 : nrow(ins)], ]

## Estimate three models:
out1 <- lm(charges ~ age + sex, data = train)
out2 <- update(out1, ". ~ . + region + children")
out3 <- update(out2, ". ~ . + bmi + smoker")

## Generate validation-set predictions:
p1 <- predict(out1, newdata = valid)
p2 <- predict(out2, newdata = valid)
p3 <- predict(out3, newdata = valid)

## Generate test MSEs from the validation data:
MSE(y_pred = p1, y_true = valid$charges)
MSE(y_pred = p2, y_true = valid$charges)
MSE(y_pred = p3, y_true = valid$charges)

###--------------------------------------------------------------------------###

### Three-way split

## Split the sample into training, validation, and testing sets:
train <- ins[ind[1 : 900], ]
valid <- ins[ind[901 : 1100], ]
test  <- ins[ind[1101 : nrow(ins)], ]

## Fit four competing models:
out0 <- lm(charges ~ age + sex, data = train)
out1 <- update(out0, ". ~ . + children")
out2 <- update(out0, ". ~ . + region")
out3 <- update(out0, ". ~ . + bmi")
out4 <- update(out0, ". ~ . + smoker")

## Estimate test MSEs for each model using the validation data:
mse <- c()
mse[1] <- MSE(y_pred = predict(out1, newdata = valid), y_true = valid$charges)
mse[2] <- MSE(y_pred = predict(out2, newdata = valid), y_true = valid$charges)
mse[3] <- MSE(y_pred = predict(out3, newdata = valid), y_true = valid$charges)
mse[4] <- MSE(y_pred = predict(out4, newdata = valid), y_true = valid$charges)

## Find the smallest test MSE:
which.min(mse)

## Re-estimate the chosen model using the pooled training and validation data:
out4.2 <- update(out4, data = rbind(train, valid))

## Estimate prediction error using the testing data:
MSE(y_pred = predict(out4.2, newdata = test), y_true = test$charges)

###--------------------------------------------------------------------------###

### K-Fold Cross-Validation

## Define values to demonstrate function's internals:
K      <- 5
k      <- 1
data   <- ins
models <- c("charges ~ age + sex + children",
            "charges ~ age + sex + region",
            "charges ~ age + sex + bmi",
            "charges ~ age + sex + smoker")
model  <- models[1]

## Specify a function to do K-Fold Cross-Validation with lm():
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

rm(list = c("K", "k", "data", "models", "model"))# Clean up

## Compare the four models from above using 10-fold cross-validation:
cv.lm(data   = rbind(train, valid),
      models = c("charges ~ age + sex + children",
                 "charges ~ age + sex + region",
                 "charges ~ age + sex + bmi",
                 "charges ~ age + sex + smoker")
      )

###--------------------------------------------------------------------------###

### Multiple Imputation ###

colMeans(is.na(bfi))

### Imputation Step

## Conduct MI using all of the defaults:
miceOut1 <- mice(bfi)

## Set a seed and specify a different number of imputations and iterations:
miceOut2 <- mice(bfi, m = 20, maxit = 10, seed = 235711)

## Define our own method vector:
meth        <- rep("norm", ncol(bfi))
names(meth) <- colnames(bfi)

meth["gender"]    <- "logreg"
meth["education"] <- "polr"

## Impute missing using the method vector from above:
miceOut3 <- mice(bfi, m = 20, maxit = 10, method = meth, seed = 235711)

## Use mice::quickpred to generate a predictor matrix:
predMat <- quickpred(bfi, mincor = 0.2, include = "gender")
predMat

## Impute missing using the predictor matrix from above:
miceOut4 <-
    mice(bfi, m = 20, maxit = 10, predictorMatrix = predMat, seed = 235711)
ls(miceOut4)

## Create list of multiply imputed datasets:
impList <- list()
for(m in 1 : miceOut4$m) impList[[m]] <- complete(miceOut4, m)

###--------------------------------------------------------------------------###

### Analysis Step

## Fit some regression models to the MI data:
fits1 <- lm.mids(E1 ~ gender, data = miceOut4)
fits2 <- lm.mids(E1 ~ gender + education, data = miceOut4)

## Fit a regression model to an arbitrary list of MI data:
fits3 <- lapply(impList,
                function(x) lm(E1 ~ age + gender + education, data = x)
                )

###--------------------------------------------------------------------------###

### Pooling Step

## Pool the fitted models:
poolFit1 <- pool(fits1)

## Summarize the pooled estimates:
summary(poolFit1)

## Compute the pooled R^2:
pool.r.squared(fits1)

## Compute increase in R^2:
pool.r.squared(fits2)[1] - pool.r.squared(fits1)[1]

## Do an F-test for the increase in R^2:
fTest <- pool.compare(fits2, fits1)

fTest$Dm     # Test statistic
fTest$pvalue # P-Value

## Pool an arbitrary list of fitted models:
poolFit3 <- MIcombine(fits3)

## Summarize pooled results:
summary(poolFit3)

## Compute wald tests from pooled results:
coef(poolFit3) / sqrt(diag(vcov(poolFit3)))
