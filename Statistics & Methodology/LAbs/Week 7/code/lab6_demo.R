### Title:    Stats & Methods Lab 6 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2017-OCT-08
### Modified: 2018-OCT-09

install.packages(c("lmtest", "moments", "sandwich"),
                 repos = "http://cloud.r-project.org")

library(MASS)     # For the 'Cars93' data
library(lmtest)   # Provides Breusch-Pagan and RESET Tests
library(moments)  # Provides skewness and kurtosis
library(sandwich) # Provided HC variance estimators

## Load some data:
data(Cars93)

##----------------------------------------------------------------------------##

#predictors distribution#
## Check skewness of 'Price'
skewness(Cars93$Price)  # when it's positive means right skewed

## Create a kernel density plot of 'Price'
plot(density(Cars93$Price))

## Check kurtosis of 'Horsepower'
kurtosis(Cars93$Horsepower)

## Is this excess kurtosis?
kurtosis(rnorm(10000)) #it creates normal distribution points around 3 and horsepwer is sth 3.9 not so far from normal disribution


##----------------------------------------------------------------------------##

#residual assumption checks
out1 <- lm(Price ~ Horsepower + MPG.city + Passengers, data = Cars93)
summary(out1)

## Check normality of residuals via skewness and kurtosis:
skewness(resid(out1))  #resid(out1) gives the residual; the difference values with Y and Yhat
kurtosis(resid(out1))

## Check the normality of residual via Q-Q Plot:
qqnorm(resid(out1)) #residuals from fitted model
qqline(resid(out1)) # add the reference line  
#based on a qqplot there are residuals that are not on the line

## Residuals vs. Predicted plot:
plot(out1, which = 1)  # it shows that you don t have cosntant errors (sometime around red lines sth more spread)
#which means there might be heredosticity

## Q-Q Plot:
plot(out1, which = 2)  #gives the observation that are problematic n=59 and n=28 in this case

## Scale-Location Plot:
plot(out1, which = 3)

## Cook's Distance Plot:
plot(out1, which = 4)

## Residuals vs. Leverage Plot:
plot(out1, which = 5)  #

##----------------------------------------------------------------------------##

#Treating Heteroscedasticity
## Run the Breusch-Pagan Test:
bptest(out1)  #we're interested pvalue. H0:there is no heterosadicity: error rate is constant, HA: no there is
#p-value >0.05 barely non significant, you cannot reject H0 but from graphs it's more clear to see a heterspcacirty
#so the thest itself may not super confirmatory

## Make a simple residual plot:
plot(y = resid(out1), x = fitted(out1))
abline(h = 0)

## Compute HC estimate of the ACOV (asymtomatic covarience matrix):
covHC1 <- vcovHC(out1)

## Do a robust test of the coefficients:
coeftest(out1, vcov = covHC1)

## Compare the default version:
summary(out1)$coefficients

## Extend 'out1' by adding some interactions:
out1.2 <- update(out1, ". ~ . + Horsepower*MPG.city + Passengers*MPG.city")
summary(out1.2)

## Compare the 'out1' and 'out1.2' models using robust SEs:
covHC1.2 <- vcovHC(out1.2)
waldtest(out1, out1.2, vcov = covHC1.2) #we use waldtest allows to see diffrernece 
 
## OR
waldtest(out1, out1.2, vcov = vcovHC)

##----------------------------------------------------------------------------##

#Model Specification (are we specifying our modle correctly)
out2 <- lm(MPG.city ~ Horsepower + Fuel.tank.capacity + Weight, data = Cars93)
summary(out2)

## Residuals vs. Predicted plot:
plot(out2, which = 1)

## Q-Q Plot:
plot(out2, which = 2)

## Scale-Location Plot:
plot(out2, which = 3)

## Cook's Distance Plot:
plot(out2, which = 4)

## Residuals vs. Leverage Plot:
plot(out2, which = 5)

##----------------------------------------------------------------------------##

## Run the Ramsey RESET test:
resettest(out2)  #this test check whether the adds improved model or not. your original model without polynamial didint specifified.
#this test hust tell if you correctly specified. 

## Update the model:
out2.1 <- update(out2, ". ~ . + I(Horsepower^2)") #weadded a quadratic term
summary(out2.1)

## Residuals vs. Predicted plot:
plot(out2.1, which = 1) #then check again all plots to see there is a difference but you dont see as you expected constant

## Q-Q Plot:
plot(out2.1, which = 2) #not on the line  all the dots

## Scale-Location Plot:
plot(out2.1, which = 3)

## Cook's Distance Plot:
plot(out2.1, which = 4)

## Residuals vs. Leverage Plot:
plot(out2.1, which = 5)

##----------------------------------------------------------------------------##


#Influential Observations

## Externally studentized residuals to check for outliers:
sr2 <- rstudent(out2.1)
sr2 

## Create index plot of studentized residuals:
plot(sr2)

## Find outliers:
badSr2 <- which(abs(sr2) > 3)
badSr2

## Compute leverages to find high-leverage points:
lev2 <- hatvalues(out2.1)
lev2

## Create index plot of leverages:
plot(lev2)

## Find most extreme leverages:
lev2.s <- sort(lev2, decreasing = TRUE)
lev2.s

## Store the observation numbers for the most extreme leverages:
badLev2 <- as.numeric(names(lev2.s[1 : 4]))
badLev2

badLev2 <- which(lev2 > 0.23)
badLev2

##----------------------------------------------------------------------------##

## Compute a panel of leave-one-out influence measures:
im2 <- influence.measures(out2.1)
im2

## Compute measures of influence:
dff2 <- dffits(out2.1)
dff2

cd2  <- cooks.distance(out2.1)
cd2

dfb2 <- dfbetas(out2.1)
dfb2

## Create index plots for measures of influence:
plot(dff2)
plot(cd2)

plot(dfb2[ , 1])
plot(dfb2[ , 2])
plot(dfb2[ , 3])
plot(dfb2[ , 4])
plot(dfb2[ , 5])

## Find the most influential observation:
maxCd   <- which.max(cd2)
maxDff  <- which.max(abs(dff2))
maxDfbI <- which.max(abs(dfb2[ , 1]))
maxDfbQ <- which.max(abs(dfb2[ , 5]))

maxCd
maxDff
maxDfbI
maxDfbQ

##----------------------------------------------------------------------------##

## Exclude the outliers:
Cars93.o <- Cars93[-badSr2, ]

## Refit the quadratic model:
out2.1o <- update(out2.1, data = Cars93.o)

summary(out2.1)
summary(out2.1o)

##----------------------------------------------------------------------------##

## Exclude the high-leverage points:
Cars93.l <- Cars93[-badLev2, ]

## Refit the quadratic model:
out2.1l <- update(out2.1, data = Cars93.l)

summary(out2.1)
summary(out2.1l)

##----------------------------------------------------------------------------##

## Exclude the most influential observation:
Cars93.i <- Cars93[-maxCd, ]

## Refit the quadratic model:
out2.1i <- update(out2.1, data = Cars93.i)

summary(out2.1)
summary(out2.1i)

##----------------------------------------------------------------------------##

## Exclude the observation with greatest influence on the quadratic term:
Cars93.q <- Cars93[-maxDfbQ, ]

## Refit the quadratic model:
out2.1q <- update(out2.1, data = Cars93.q)

summary(out2.1)
summary(out2.1q)

##----------------------------------------------------------------------------##


