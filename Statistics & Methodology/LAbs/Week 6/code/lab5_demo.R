### Title:    Stats & Methods Lab 5 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2016-APR-04
### Modified: 2018-OCT-01

rm(list = ls(all = TRUE))

## Install the new packages we'll need:
install.packages(c("car", "rockchalk"), repos = "http://cloud.r-project.org")

library(car)       # Provides 'Ginzberg' data
library(rockchalk) # For interaction probing

##----------------------------------------------------------------------------##

### Contiuous Variable Moderation ###

data(Ginzberg)

## Focal effect:
out0 <- lm(depression ~ fatalism, data = Ginzberg)
summary(out0)

## Additive model:
out1 <- lm(depression ~ fatalism + simplicity, data = Ginzberg)
summary(out1)

## Moderated model:
out2 <- lm(depression ~ fatalism * simplicity, data = Ginzberg)
summary(out2)   ## fatalism and simplicity has conditional effect, fatalizm --> simplicity

##----------------------------------------------------------------------------##

### Probing via Centering ###

## Center 'simplicity' on Mean & Mean +/- 1SD
m <- mean(Ginzberg$simplicity)
s <- sd(Ginzberg$simplicity)

Ginzberg$zMid <- Ginzberg$simplicity - m 
Ginzberg$zLo  <- Ginzberg$simplicity - (m - s)
Ginzberg$zHi  <- Ginzberg$simplicity - (m + s)

## Test SS at Mean - 1SD:  ## ss is simpicity score
out2.1 <- lm(depression ~ fatalism * zLo, data = Ginzberg)
summary(out2.1)

## Test SS at Mean:
out2.2 <- lm(depression ~ fatalism * zMid, data = Ginzberg)
summary(out2.2)


## Test SS for Mean + 1SD:
out2.3 <- lm(depression ~ fatalism * zHi, data = Ginzberg)
summary(out2.3)

##----------------------------------------------------------------------------##

### Probing via the 'rockchalk' Package ###

## First we use 'plotSlopes' to estimate the simple slopes:
plotOut1 <- plotSlopes(out2,
                       plotx      = "fatalism",
                       modx       = "simplicity", #moderator
                       modxVals   = "std.dev", # that is change 1 sd above and below for pick a point
                       plotPoints = TRUE)

## We can also get simple slopes at the quartiles of simplicity's distribution:
plotOut2 <- plotSlopes(out2,
                       plotx      = "fatalism",
                       modx       = "simplicity",
                       modxVals   = "quantile",
                       plotPoints = TRUE)

## Or we can manually pick some values:
range(Ginzberg$simplicity)
plotOut3 <- plotSlopes(out2,
                       plotx      = "fatalism",
                       modx       = "simplicity",
                       modxVals   = seq(0.5, 2.5, 0.5),
                       plotPoints = TRUE)

## Test the simple slopes via the 'testSlopes' function:
testOut1 <- testSlopes(plotOut1)
ls(testOut1)
testOut1$hypotests

#Sema:the values of m is the same when you check the summary of manual one, 2,2 - fatalism pvalue and slope
testOut2 <- testSlopes(plotOut2)
testOut2$hypotests

testOut3 <- testSlopes(plotOut3)
testOut3$hypotests


## Use the 'testSlopes' function to conduct a Johnson-Neyman analysis:
ls(testOut1)
ls(testOut1$jn)

## Region of significance:
testOut1$jn$roots

## Visualize the region of significance:
plot(testOut1)

#1. looking at plot is one way to understand probing interaction
##the simple slope(black line) decrease while simplicity incrhow ease. the points lower than 1.48 means simple 
#slope is significant. so this treshold allow us tho understand at a point whether if simple slope is 
#greater greater than zero
#if you probe the intereaction at simplicity level 1, the simple slope will be greater than zero.



##----------------------------------------------------------------------------##

### Binary Categorical Moderators ###

## Load data:
dat1 <- readRDS("../data/bfi_scored.rds")

## Focal effect:
out0 <- lm(neuro ~ agree, data = dat1)
summary(out0)

## Additive model:
out1 <- lm(neuro ~ agree + gender, data = dat1)
summary(out1)

## Moderated model:
out2 <- lm(neuro ~ agree * gender, data = dat1)
summary(out2)

## Test 'female' simple slope by changing reference group:
dat1$gender2 <- relevel(dat1$gender, ref = "female")

out2.1 <- lm(neuro ~ agree * gender2, data = dat1)
summary(out2.1)

##----------------------------------------------------------------------------##

### Nominal Categorical Moderators (G > 2) ###

## Load data:
data(iris)

## Focal effect:
out0 <- lm(Petal.Width ~ Sepal.Width, data = iris)
summary(out0)

## Additive model:
out1 <- lm(Petal.Width ~ Sepal.Width + Species, data = iris)
summary(out1)

## Moderated model:
out2 <- lm(Petal.Width ~ Sepal.Width * Species, data = iris)
summary(out2)

## Test for significant moderation:
anova(out1, out2) # we dont have only categorical variabes, also have numerical so we looked at anova.
#otherwise pvalues in outcome summary will help to udnerstand sgnificance (categorical variables)


## Test different simple slopes by changing reference group:
iris$Species2 <- relevel(iris$Species, ref = "virginica")
iris$Species3 <- relevel(iris$Species, ref = "versicolor")

out2.1 <- lm(Petal.Width ~ Sepal.Width * Species2, data = iris)
out2.2 <- lm(Petal.Width ~ Sepal.Width * Species3, data = iris)

summary(out2)
summary(out2.1)
summary(out2.2)

## Do the same test using 'rockchalk':
plotOut1 <- plotSlopes(model      = out2,
                       plotx      = "Sepal.Width",
                       modx       = "Species",
                       plotPoints = FALSE)

testOut1 <- testSlopes(plotOut1)
testOut1$hypotests
