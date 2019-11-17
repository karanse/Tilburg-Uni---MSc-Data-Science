### Title:    Stats & Methods Lab 5 Practice Script
### Author:   Kyle M. Lang
### Created:  2018-SEP-24
### Modified: 2018-OCT-02


###          ###
### Overview ###
###          ###

## You will practice using MLR models for moderation analysis.

## You will need the "msq2.rds" data and the built-in R datasets "cps3" and
## "leafshape" (from the DAAG package). The "msq2.rds" dataset is available in
## the "data" directory for this lab.


###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "install.packages" function to install the "rockchalk" and "DAAG"
##    packages.
install.packages("rockchalk")
install.packages("DAAG")
## 2) Use the "library" function to load the "rockchalk" and "DAAG" packages.
library(rockchalk)
library(DAAG)
## 3) Use the "readRDS" function to load the "msq2.rds" dataset into your
##    workspace.
dataDir<-"../data/"
msq2 <- readRDS(paste0(dataDir,"msq2.rds"))
## 4) Use the "data" function to load the "cps3" and "leafshape" datasets into
##    your workspace.
data(cps3)
data("leafshape")

##--Continuous variable moderation--------------------------------------------##

### Use the "msq2" data to complete the following:

## 1a) Estimate a model that tests if the effect of Energetic Arousal on Tense
##     Arousal varies significantly as a function of Negative Affect, after
##     controlling for Positive Affect.

## Focal effect:
out0 <- lm(TA~EA, data=msq2)
summary(out0)
## Additive model:
out1 <- lm(TA~EA+NegAff +PA, data = msq2)
summary(out1)

## Moderation model:
out2 <- lm(TA~EA*NegAff+PA, data = msq2)
summary(out2)

## 1b) What is the value of the parameter estimate that quantifies the effect of
##     Negative Affect on the Energetic Arousal -> Tense Arousal effect, after
##     controlling for Positive Affect?
summary(out2)
## Answer:-----> 0.019562

## 1c) Does Negative Affect significantly moderate (at the alpha = 0.05 level)
##     the relationship between Energetic Arousal and Tense Arousal, after
##     controlling for Positive Affect?
summary(out2)
## Answer -------> yes  0.00162 **<0.05


## 1d) After controlling for Positive Affect, how does Negative Affect impact
##     the relationship between Energetic Arousal and Tense Arousal? Provide a
##     sentence interpreting the appropriate effect.
## Answer -------> after controlling PA, for a unit increase in EA, the expected increase is in
## TA is 0.019562 when NegAff =0


## 2a) Use the centering method to test the simple slopes of the model you
##     estimated in (1a) at Negative Affect values of 0, 10, and 20.

msq2$NegAff_0 <- msq2$NegAff-0
msq2$NegAff_10 <- msq2$NegAff-10
msq2$NegAff_20 <- msq2$NegAff-20

out2.0 <- lm(TA~EA*NegAff_0+PA, data = msq2)
out2.10 <- lm(TA~EA*NegAff_10+PA, data = msq2)
out2.20 <- lm(TA~EA*NegAff_20+PA, data = msq2)

## 2b) After controlling for Positive Affect, what is the simple slope of
##     Energetic Arousal on Tense Arousal when Negative Affect is 0.
summary(out2.0)
## Answer -------> 0.019562     0.297818

## 2c) Is the simple slope you estimated in (2b) statistically significant at
##     the alpha = 0.05 level?
## Answer -------> Yes (no change)


## 2d) After controlling for Positive Affect, what is the simple slope of
##     Energetic Arousal on Tense Arousal when Negative Affect is 10.
summary(out2.10)
## Answer -----> 0.019562    0.493442 

## 2e) Is the simple slope you estimated in (2d) statistically significant at
##     the alpha = 0.05 level?
## ---------> Yes, 

## 2f) After controlling for Positive Affect, what is the simple slope of
##     Energetic Arousal on Tense Arousal when Negative Affect is 20.
summary(out2.20)
## Answer --------> 0.019562    0.689067

## 2g) Is the simple slope you estimated in (2f) statistically significant at
##     the alpha = 0.05 level?
## Answer -------> Yes, 

## 3a) Use the 'rockchalk' package to test the same simple slopes you estimated
##     in (2a).

plotout2 <-  plotSlopes(out2,
                         plotx      = "EA",
                         modx       = "NegAff", #moderator
                         modxVals   = seq(0, 20, 10),
                         plotPoints = TRUE)

## 3b) Do the results of the centering approach agree with the results from
##     'rockchalk'?
#A Answer --->Yes

## 4a) Use the 'rockchalk' package to implement a Johnson-Neyman analysis of the
##     interaction you estimated in (1a).
testout2 <- testSlopes(plotout2)
ls(testout2)
ls(testout2$jn)

## 4b) What are the boundaries of the Johnson-Neyman region of significance?
testout2$jn$roots
## Answer ------->       lo (-46.539311)       hi ( -7.348106 )

 
## 4c) Where in the distribution of Negative Affect is the effect of Energetic
##     Arousal on Tense Arousal (controlling for Positive Affect) statistically
##     significant?
plot(testout2)
## Answer --------> 

##--Binary Categorical moderators---------------------------------------------##

### Use the "cps3" data to complete the following:

## 1a) Estimate a model that tests if the effect of Years of Education on Real
##     Earnings in 1975 is significantly moderated by being Hispanic, after
##     controlling for Real Earnings in 1974.
##     HINT: The Hispanic variable is not a factor. You may want to change that.
cps3$hisp <- factor(cps3$hisp)
## Focal effect
out3 <- lm(re75~educ, data = cps3 )
summary(out3)

## Additive model
out4 <- lm(re75~educ + hisp +re74, data = cps3)
summary(out4)

## Moderation Model
out5 <- lm(re75~ re74+ educ*hisp, data = cps3)
summary(out5)

## 1b) After controlling for 1974 Earnings, does being Hispanic significantly
##     affect the relationship between Years of Education and 1975 Earnings at
##     the alpha = 0.05 level
summary(out5)
## Answer --------> yes,   0.00867 ***  < 0.05

## 1c) After controlling for 1974 Earnings, does being Hispanic significantly
##     affect the relationship between Years of Education and 1975 Earnings at
##     the alpha = 0.01 level?
summary(out5)
## Answer ------> No, 0.01503 * >0.01

## 2a) What is the simple slope of Years of Education on 1975 Earnings
##     (controlling for 1974 Earnings) for Non-Hispanic people?
summary(out5)
## Answer ------->  8.69986

## 2b) Is the simple slope from (2a) statistically significant at the
##     alpha = 0.05 level?
summary(out5)
## Answer ----------> No, 0.87260  > 0.05 

## 2c) What is the simple slope of Years of Education on 1975 Earnings
##     (controlling for 1974 Earnings) for Hispanic people?
cps3$hisp <- relevel(cps3$hisp, ref = "1")
out6 <- lm(re75~ re74+ educ*hisp, data = cps3)
summary(out6)
##Answer ------> -2.911e+02

## 2d) Is the simple slope from (2c) statistically significant at the
##     alpha = 0.05 level?
summary(out6)
## Answer -----> yes,  0.00867 **  <0.05

## 2e) Visualize the simple slopes compute above in an appropriate way.
plotOut5 <- plotSlopes(model      = out5,
                       plotx      = "educ",
                       modx       = "hisp",
                       plotPoints = FALSE)


##--Nominal categorical moderators--------------------------------------------##

### Use the "leafshape" data to complete the following:


## 1a) What are the levels of the "location" factor?
summary(leafshape$location)
## Answer ----> 6 level: Sabah, Panama, Costa Rica, N Queensland, S Queensland, Tasmania

## 1b) What are the group sizes for the "location" factor?
summary(leafshape$location)
## Answer ----> Sabah(80), Panama(55), CostaRica(50), N Queensland(61), S Queensland(31), Tasmania(9)


## 2a) Estimate a model that tests if the effect of Leaf Width on Leaf Length
##     differs significantly between Locations.

##Focal effect
out7 <- lm(bladelen ~ bladewid, data = leafshape)
summary(out7)

## Additive model
out8 <- lm(bladelen ~ bladewid + location, data = leafshape)
summary(out8)

## Moderation model
out9 <- lm(bladelen~ bladewid *location, data = leafshape)
summary(out9)

anova(out8, out9)


## 2b) Does the effect of Leaf Width on Leaf Length differ significantly
##     (alpha = 0.05) between Locations?
anova(out8, out9)
## Answer -------> yes, 0.0005903 *** <0.05

## 2c) What is the value of the test statistic that you used to answer (2b)?
## Answer ----> p vlaue 0.0005903

## 3a) What is the simple slope of Leaf Width on Leaf Length in Sabah?
leafshape$location <- relevel(leafshape$location, ref = "Sabah")
leafshape$location <- factor(leafshape$location )
out10 <- lm(bladelen~ bladewid *location, data = leafshape)
summary(out10)
## Answer -------->  1.5609


## 3b) Is the simple slope you reported in (3a) significant at the alpha = 0.05
##     level?
## Answer-------> no, 0.12360 > 0.05

## 3c) What is the simple slope of Leaf Width on Leaf Length in Panama?
## Answer--------> -0.3817


## 3d) Is the simple slope you reported in (3c) significant at the alpha = 0.05
##     level?
## Answer -----> No, 0.07659 > 0.05

## 3e) What is the simple slope of Leaf Width on Leaf Length in South
##     Queensland?
leafshape$location <- relevel(leafshape$location, ref = "S Queensland")
leafshape$location <- factor(leafshape$location )
out11 <- lm(bladelen~ bladewid *location, data = leafshape)
summary(out11)
## Answer -----> 0.95847

## 3f) Is the simple slope you reported in (3e) significant at the alpha = 0.05
##     level?
## Answer -----> yes, 0.01103  < 0.05

## 4a) In which Location is the effect of Leaf Width on Leaf Length strongest?
## Answer -----> Costa Rica

## 4b) What caveat might you want to place on the conclusion reported in (4a)?
##     HINT: Look at the answers to Question 1 of this section.

##----------------------------------------------------------------------------##
