### Title:    Stats & Methods Lab 4 Practice Script
### Author:   Kyle M. Lang
### Created:  2018-SEP-24
### Modified: 2018-SEP-25


###          ###
### Overview ###
###          ###

## You will practice fitting MLR models with categorical predictor variables.

## You will need the built-in R datasets "bfi" (from the psych package) and
## "BMI" (from the wec) package.


###                   ###
### Tasks / Questions ###
###                   ###


##--Preliminaries-------------------------------------------------------------##

## 1) Use the "install.packages" function to install the "wec" package.
install.packages("wec", repos = "http://cloud.r-project.org")

## 2) Use the "library" function to load the "psych" and "wec" packages.
library(psych)
library(wec)
source("supportFunctions.R")

## 3) Use the "data" function to load the "bfi" and "BMI" datasets into your
##    workspace.

bmi <- data(BMI)
bfi <- data(bfi)

##--Factors-------------------------------------------------------------------##

### Use the "bfi" data to complete the following:
### -- You can ignore any missing data, for the purposes of these exercises.

## 1) Refer to the help file of the "bfi" dataset to find the correct levels for
##    the "gender" and "education" variables.
?bfi

## 2) Create factors for the "gender" and "education" variables with sensible
##    sets of labels for the levels.
z1 <- factor(bfi$gender, levels = c(1,2), labels = c("Males","Females"))
z2 <- factor(bfi$education, levels = c(1,2,3,4,5), labels = c("HS","finished", "some college", "college graduate", "graduate degree"))

# 3) How many women is this sample have graduate degrees?
table(z2,z1)
  ##-----> Answer: 266

## 4) What is the most frequently reported level of educational attainment among
##    men in this sample?
##-----> Answer: some college


##--Dummy codes---------------------------------------------------------------##

### Use the "BMI" data to complete the following:

## 1) How many levels does the "education" factor have?
levels(BMI$education)    ## Answer: --->3


## 2a) What is the reference level of the "sex" factor?
out1 <- lm(BMI ~ sex, data = BMI)
summary(out1)    ### Answer: ---> Male


## 2b) What is the reference level of the "education" factor?
out2 <- lm(BMI ~ education, data = BMI)
summary(out2) ### Answer: ---> lowest


## 3a) Run a linear regression model wherein "BMI" is predicted by dummy-coded
##     "sex" and "education."
##     -- Set the reference group to "male" for the "sex" factor
##     -- Set the reference group to "highest" for the "education" factor
BMI$education2 <- relevel(BMI$education, ref = "highest")
levels(BMI$education)
levels(BMI$education2)

out3 <- lm(data = BMI, BMI~sex + education2)
summary(out3)


## 3b) Is there a significant effect (at alpha = 0.05) of "sex" on "BMI" after
##     controlling for "education?"
summary(out3)  ### Answer: ---> yes because the pvalue is 0.000136 (<0.05)


## 3c) What is the expected BMI for males in the highest education group?
summary(out3)### Answer ---> intercept: 24.5456

##--Cell-means codes----------------------------------------------------------##

### Use the "BMI" data to complete the following:

## 1) Create a new variable by centering "BMI" on 25.
BMI$BMI2 <- BMI$BMI - 25

## 2a) Regress the centered BMI from (1) onto the set of cell-means codes for
##     "education."
out4 <- lm(data = BMI, BMI2~ education -1)
summary(out4)
summary.cellMeans(out4)

## 2b) Is there significant effect of education on BMI, at the alpha = 0.05
##     level?
## Answer ---> yes the pvalue is so small:  < 2.2e-16 (not sure)

## 2c) What is the value of the test statistic that you used to answer (2b)?
## Answer: ----> F statistics of the model : 53.66 (not sure)
  
## 2d) Is the mean BMI level in the "lowest" education group significantly
##     different from 25, at an alpha = 0.05 level?
  
## 2e) Is the mean BMI level in the "middle" education group significantly
##     different from 25, at an alpha = 0.05 level?
## 2f) Is the mean BMI level in the "highest" education group significantly
##     different from 25, at an alpha = 0.05 level?
## 2g) Keeping in mind that BMI = 25 is a commonly cited upper bound for
##     "healthy" weight, how would you interpret the findings in (2b) - (2f)?


##--Unweighted effects codes--------------------------------------------------##

### Use the "BMI" data to complete the following:

## 1) Regress "BMI" onto an unweighted effects-coded representation of
##    "education" and a dummy-coded representation of "childless."
##    -- Adjust the contrasts attribute of the "education" factor to implement
##       the unweighted effects coding.
contrasts(BMI$childless)
BMI$education3 <- BMI$education

contrasts(BMI$education)
contrasts(BMI$education3)
contrasts(BMI$education3) <- contr.sum(levels(BMI$education3))
contrasts(BMI$education3)
colnames(contrasts(BMI$education3)) <- c("lowest", "middle")

out5 <- lm(data=BMI, BMI~education3 + childless)
summary(out5)

## 2) Change the reference group (i.e., the omitted group) for the unweighted
##    effects codes that you implemented in (1) and rerun the model regressing
##    "BMI" onto "education" and "childless."
BMI$education5 <- BMI$education
BMI$education5 <- relevel(BMI$education5, ref = "highest" )
contrasts(BMI$education5) <- contr.sum(levels(BMI$education5))
contrasts(BMI$education5)
colnames(contrasts(BMI$education5)) <- c("highest", "lowest")
out6 <- lm(data = BMI, BMI ~ education5 + childless)
summary(out6)

## 3) What is the (most important/useful) purpose of rerunning the model as I've
##    asked you to do in (2)?

???
  
## 4a) What is the expected BMI (averaged across education groups) for people
##     with children?
  summary(out5) ## OR summary(out6)
### Answer:----->> Intercept: 25.57683


## 4b) What is the expected difference in BMI between the most highly educated
##     group and the average BMI across education groups, after controlling for
##     childlessness?
  ###---> educationhighest slope : -0.73465

## 4c) Is the difference you reported in (4b) significantly different from zero
##     at the alpha = 0.05 level?

## Answer:----> Yes the p vlaue is so small: 1.55e-15

## 4d) What is the expected difference in BMI between the middle education
##     group and the average BMI across education groups, after controlling for
##     childlessness?
summary(out5)
### Answer ----> -0.11403


## 4e) Is the difference you reported in (4d) significantly different from zero
##     at the alpha = 0.05 level?
### Answer: ---> No p vlaue is large : 0.195 

##--Weighted effects codes--------------------------------------------------##

### Use the "BMI" data to complete the following:

## 1) Regress "BMI" onto an weighted effects-coded representation of "education"
##    and a dummy-coded representation of "sex."
##    -- Adjust the contrasts attribute of the "education" factor to implement
##       the weighted effects coding.
BMI$education6 <- BMI$education
contrasts(BMI$education6) <- contr.wec(BMI$education, omitted = "lowest")
contrasts(BMI$education6)
contrasts(BMI$childless)


out7 <-lm(data=BMI, BMI ~ education6 + sex)
summary(out7)

## 2) Change the reference group (i.e., the omitted group) for the weighted
##    effects codes that you implemented in (1) and rerun the model regressing
##    "BMI" onto "education" and "sex."

BMI$education7 <- BMI$education
contrasts(BMI$education7) <- contr.wec(BMI$education, omitted = "highest")
contrasts(BMI$education7)

out8 <- lm(data = BMI, BMI~education7 + sex)
summary(out8)


## 3a) What is the average BMI for females?

## Answer: ---->intercept -  sexfemale slope: 25.24231 - 0.49864 = 24.74367


## 3b) What is the expected difference in BMI between the least educated group
##     and the average BMI, after controlling for sex?
## Answer: ---->  educationlowest slope : 1.15972

## 3c) Is the difference you reported in (3b) significantly different from zero
##     at the alpha = 0.01 level?
### Answer: ---> yes, pvalue is small :  < 2e-16 

## 3d) What is the expected difference in BMI between the most highly educated
##     group and the average BMI, after controlling for sex?
summary(out7)
### Answer: ----> educationlevelhighest slople: -0.69666


## 3e) Is the difference you reported in (3d) significantly different from zero
##     at the alpha = 0.01 level?
## Answer : ----> yes, pvalue is small: 1.17e-15


## 4a) Does education level explain a significant proportion of variance in BMI,
##     above and beyond sex?

out8 <- lm(data = BMI, BMI ~ sex)
out9 <- lm(data= BMI, BMI ~ sex + education)
s8 <- summary(out8)
s9 <- summary(out9)
s8$r.squared
s9$r.squared
anova(out8,out9)

## Answer: ----> yes, it explains anova output pvalue so small: 2.2e-16  (and R^2 increase a lot)

## 4b) What is the value of the test statistic that you used to answer (4a)?
## Answer: ---> F statistic: 54.229 

##----------------------------------------------------------------------------##
