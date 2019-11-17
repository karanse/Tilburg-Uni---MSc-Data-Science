### Title:    Stats & Methods Lab 4 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2017-SEP-08
### Modified: 2018-SEP-25

rm(list = ls(all = TRUE))

set.seed(235711)

install.packages("wec", repos = "http://cloud.r-project.org")

library(wec)
source("supportFunctions.R")

## Load the example data
data(iris)

## Sample 100 rows to unbalance group sizes:
iris <- iris[sample(1 : nrow(iris), 100), ]

###--------------------------------------------------------------------------###

### Factor Variables ###

## Look at the 'Species' factor:
iris$Species
is.factor(iris$Species)

str(iris$Species)
summary(iris$Species)

## Factors have special attributes:
attributes(iris$Species)
attributes(iris$Petal.Length)
attributes(iris)

## Factors have labeled levels:
levels(iris$Species)
nlevels(iris$Species)

## Factors are not numeric variables:
mean(iris$Species)
var(iris$Species)
iris$Species - iris$Species

###--------------------------------------------------------------------------###

### Creating Factor Variables ###

x <- sample(c(1, 2, 3), size = 100, replace = TRUE)
x
class(x)

## Don't use any labels:
y <- factor(x)
y
class(y)
levels(y)

## Match labels to default levels:
z <- factor(x, labels = c("dog", "cat", "badger"))
z
table(x, z)

## Use a different labels -> levels mapping:
z2 <- factor(x, levels = c(2, 1, 3), labels = c("dog", "cat", "badger"))
z3 <- factor(x, labels = c("cat", "dog", "badger"))

## Compare:
all(z2 == z3)
all.equal(z2, z3)

levels(z2)
levels(z3)

table(x, z2)
table(x, z3)

###--------------------------------------------------------------------------###

### Dummy Codes ###

## Use a factor variable as a predictor:
out1 <- lm(Petal.Length ~ Species, data = iris)
summary(out1)

## Check the contrasts:
contrasts(iris$Species)

## Change the reference group:
iris$Species2 <- relevel(iris$Species, ref = "virginica")

levels(iris$Species)
levels(iris$Species2)

## How are the contrasts affected:
contrasts(iris$Species)
contrasts(iris$Species2)

## Which carries through to the models:
out2 <- lm(Petal.Length ~ Species2, data = iris)
summary(out1)
summary(out2)

###--------------------------------------------------------------------------###

### Cell-Means Codes ###

out3 <- lm(Petal.Length ~ Species - 1, data = iris)
summary(out3)
summary.cellMeans(out3)

###--------------------------------------------------------------------------###

### Unweighted Effects Codes ###

## Use the 'contr.sum' function to create unweighted effects-coded contrasts:
iris$Species3 <- iris$Species
contrasts(iris$Species3) <- contr.sum(levels(iris$Species3))
contrasts(iris$Species3)

## Use the fancy-pants Species factor:
out3 <- lm(Petal.Length ~ Species3, data = iris)
summary(out3)
contrasts(iris$Species3)

## How about some better names?
colnames(contrasts(iris$Species3)) <- c("setosa", "versicolor")
contrasts(iris$Species3)

out4 <- lm(Petal.Length ~ Species3, data = iris)
summary(out4)

## Change the reference group:
iris$Species4 <- iris$Species
levels(iris$Species4)
iris$Species4 <- relevel(iris$Species4, ref = "virginica")

levels(iris$Species)
levels(iris$Species4)

## Update the contrasts attribute:
contrasts(iris$Species4)
contrasts(iris$Species4) <- contr.sum(3)
contrasts(iris$Species4)

## Give some good names:
colnames(contrasts(iris$Species4)) <- c("virginica", "setosa")

## Use the new factor:
out5 <- lm(Petal.Length ~ Species4, data = iris)
summary(out4)
summary(out5)

###--------------------------------------------------------------------------###

### Weighted Effects Codes ###

## Use the 'contr.wec' function to create weighted effects-coded contrasts:
iris$Species5 <- iris$Species
contrasts(iris$Species5) <- contr.wec(iris$Species, omitted = "virginica")
contrasts(iris$Species5)

out6 <- lm(Petal.Length ~ Species5, data = iris)
summary(out6)

## Create contrast with a different reference level:
iris$Species6 <- iris$Species
contrasts(iris$Species6) <- contr.wec(iris$Species, omitted = "setosa")
contrasts(iris$Species6)

out7 <- lm(Petal.Length ~ Species6, data = iris)
summary(out7)

###--------------------------------------------------------------------------###

### Reverting to Default "Treatment" Contrasts ###

tmp <- iris$Species6
contrasts(tmp)

## Dummy codes without names:
contrasts(tmp) <- contr.treatment(nlevels(tmp))
contrasts(tmp)

## Named dummy codes (default):
tmp            <- iris$Species6
contrasts(tmp) <- contr.treatment(levels(tmp))
contrasts(tmp)

###--------------------------------------------------------------------------###

### Creating Code Matrices ###

## Create dummy codes with 'model.matrix':
d1 <- model.matrix(~Species, data = iris)
d1

## We don't want that leading column of 1's:
d2 <- model.matrix(~Species, data = iris)[ , -1]
d2

## Create other types of code matrices:
cm <- model.matrix(~Species - 1, data = iris)     # Cell-Means
cm
ec <- model.matrix(~Species3, data = iris)[ , -1] # Unweighted Effects Codes
ec
wec <- model.matrix(~Species5, data = iris)[ , -1] # Weighted Effects Codes
wec

## Give some better names:
colnames(d2)  <- c("versicolor.d", "virginica.d")
colnames(cm)  <- c("setosa.cm", "versicolor.cm", "virginica.cm")
colnames(ec)  <- c("setosa.ec", "versicolor.ec")
colnames(wec) <- c("setosa.wec", "versicolor.wec")

## Extend the 'iris' data.frame:
dat1 <- data.frame(iris, d2, cm, ec, wec)
head(dat1)

###--------------------------------------------------------------------------###

### Using Code Matrices ###

## Use the dummy codes:
out8 <- lm(iris$Petal.Length ~ d2)
summary(out8)

out9 <- lm(Petal.Length ~ versicolor.d + virginica.d, data = dat1)
summary(out9)

## Use the cell-means codes (incorrectly):
out10.0 <- lm(iris$Petal.Length ~ cm)
summary(out10.0)

## And...correctly:
out10.1 <- lm(iris$Petal.Length ~ cm - 1)
summary.cellMeans(out10.1)

out11 <-
    lm(Petal.Length ~ setosa.cm + versicolor.cm + virginica.cm - 1, data = dat1)
summary.cellMeans(out11)

## Use the unweighted effects codes:
out12 <- lm(iris$Petal.Length ~ ec)
summary(out12)

out13 <- lm(Petal.Length ~ setosa.ec + versicolor.ec, data = dat1)
summary(out13)

## Use the weighted effects codes:
out14 <- lm(iris$Petal.Length ~ wec)
summary(out14)

out15 <- lm(Petal.Length ~ setosa.wec + versicolor.wec, data = dat1)
summary(out15)

###--------------------------------------------------------------------------###
