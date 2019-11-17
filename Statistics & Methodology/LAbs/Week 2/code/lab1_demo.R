### Title:    Stats & Methods Lab 1 Demonstration Script
### Author:   Kyle M. Lang
### Created:  2018-APR-10
### Modified: 2018-SEP-04

library(MASS)
library(mice)

###--------------------------------------------------------------------------###

### Vectors ###

## Arithmetic with vectors works element-wise
y <- c(1, 2, 3, 4)
x <- rep(2, 4)

y + x
y - x
y / x
y * x

## Elements are recycled (silently) to make the vectors' lengths match
z <- c(1, 2)
y - z

## Recycling is what allows arithmetic between a vector and a "scalar"
y - 1
y * 3
y / 3

## Logical comparisons are also subject to recycling:
y == 4
y == 4 | y == 2
y == c(4, 2) # Hmm...that's weird. What's going on here?

#----Sema---- R first duplicate y itself and then compare it with Y value by value
## When doing arithmetic on a logical vector, TRUE = 1 and FALSE = 0:
v7 <- sample(c(TRUE, FALSE), 10, replace = TRUE)
v7
sum(v7)
mean(v7)

###--------------------------------------------------------------------------###

### Matrices ###

## Matrices are populated in column-major order, by default
m3 <- matrix(c(1 : 9), 3, 3)
m3

## The 'byrow' option allows us to swith the above to row-major order
m4 <- matrix(c(1 : 9), 3, 3, byrow = TRUE)
m4

## Arthmetic is still assumed element-wise
m4 + m3
m4 - m3
m4 / m3
m4 * m3

## "Matrix Multiplaction" has a special operator '%*%'
m4 %*% m3

## Arithmetic with matrices will also use recycling (in column-major order)
m5 <- matrix(sample(c(1 : 100), size = 9), ncol = 3)
m5

m6 <- m5[1 : 2, 1 : 3] # this means first two rows  and 3 columns
m7 <- m5[c(1, 3), 2]
m6
m7

m6 + m7
m8 <- c (1,2,3,4)
###--------------------------------------------------------------------------###

### Data Frames & Lists vs. Matrices ###

d1 <- data.frame(x = c(1 : 20),
                 y = c(1, -1),
                 z = seq(2, 20, 2)
                 )
d2 <- data.frame(a = sample(c(TRUE, FALSE), 20, replace = TRUE),
                 b = sample(c("foo", "bar"), 20, replace = TRUE),
                 c = runif(20)
                 )

d1
d2

## Data frames are actually lists of vectors (representing the columns)
is.data.frame(d2)
is.list(d2)

## Although they look like rectangular "matrices," from R's perspective, a data
## frame IS NOT a matrix
is.matrix(d2)

## Therefore, we cannot do matrix algebra with data frames
d1 %*% t(d1)
as.matrix(d1) %*% t(as.matrix(d1))

## We can do list-specific operations on data frames
lapply(d2, FUN = typeof)

## List-specific operations will break when applied to matices
m1 <- matrix(runif(15), ncol = 3)
m1
lapply(m1, FUN = typeof)
as.list(m1)

###--------------------------------------------------------------------------###

### File I/O ###

## The 'paste' function will join character strings
s1 <- "Hello"
s2 <- "World!"

paste(s1, s2)
paste(s1, s2, sep = "_")
paste0(s1, s2)

## We generally want to use 'paste' to build file paths:
dataDir  <- "data/"
outDir   <- "output/"
fileName <- "mtcars.rds"

## Read data from disk:
dat1 <- readRDS(paste0(dataDir, fileName))

## We have two versions of 'read.csv':
dat1 <- read.csv(paste0(dataDir, "mtcars.csv"), row.names = 1)   # US format
dat1 <- read.csv2(paste0(dataDir, "mtcars2.csv"), row.names = 1) # EU format

## Look at the top of the dataset:
head(dat1)

## See the order stats of each variable:
summary(dat1)

## See the internal structure of the object:
str(dat1)

## Save the summary:
saveRDS(summary(dat1), file = paste0(outDir, "dat1_summary.rds"))

###--------------------------------------------------------------------------###

### Compute Descriptive Stats ###

## Mean:
mean(dat1$wt)

## Variance:
var(dat1$wt)

## SD:
sd(dat1$wt)

## Median:
median(dat1$wt)

## MAD:
mad(dat1$wt)

## Range:
range(dat1$wt)
min(dat1$wt)
max(dat1$wt)

## Quantiles:
quantile(dat1$wt, prob = c(0.5, 0.95))

## Calculate the correlation matrix
cor(dat1)
cor(dat1, method = "spearman")

## Calculate covariance matrix
cov(dat1)

## Compute variable means:
colMeans(dat1)  # this same with sapply one just below
sapply(dat1, FUN = mean)
## Compute variable SDs:
sapply(dat1, FUN = sd)

## Compute variable medians:
sapply(dat1, FUN = median)

## Compute robust (MCD) estimates of summary stats:
tmp <- cov.rob(dat1, quantile.used = floor(0.75 * nrow(dat1)), method = "mcd")  # this cov.rob function brings the 
#roboust statistic which means exludes outliers etc.


tmp$center
tmp$cov

## Compute frequency tables:
table(dat1$carb)
table(trans = dat1$am, gears = dat1$gear)
with(dat1, table(cyl, carb))

###--------------------------------------------------------------------------###

### Simple Inferential Analyses ###

## Simple mean differences:
t.test(mpg ~ am, data = mtcars)

## Bivariate correlation:
cor(x = mtcars$wt, y = mtcars$mpg)
cor.test(x = mtcars$wt, y = mtcars$mpg)

## Correlation with directional hypothesis:
cor.test(x = mtcars$disp, y = mtcars$qsec, alternative = "less")

###--------------------------------------------------------------------------###

### Missing Data Descriptives ###

bfi <- readRDS(paste0(dataDir, "bfiANC.rds"))

## Compute variable-wise percents missing:
colMeans(is.na(bfi))

## Find missing data patterns:
missPat <- md.pattern(bfi)  
missPat

## Close the graphics device:
dev.off()

## Compute covariance coverage:
md.pairs(bfi)$rr / nrow(bfi)

###--------------------------------------------------------------------------###

### A Bit of EDA ###

tests <- readRDS(paste0(dataDir, "tests.rds"))

## Summarize the dataset:
summary(tests)

## Generate boxplots of SAT scores with grouping by gender:
boxplot(SATV ~ gender, data = tests)
boxplot(SATQ ~ gender, data = tests)

## Generate a histogram of age:
hist(tests$age)

## Generate a kernel density plot of age:
plot(density(tests$age))

## Overlay normal density onto histogram:
m <- mean(tests$age)
s <- sd(tests$age)
x <- seq(10, 70, length.out = 1000)

hist(tests$age, probability = TRUE)
lines(x = x, y = dnorm(x, mean = m, sd = s))

## Create a bi-variate scatterplot:
plot(x = tests[ , "age"], y = tests[ , "SATV"])

## Create a scatterplot matrix:
pairs(tests[ , -c(1, 2)])

###--------------------------------------------------------------------------###

### Outlier Analysis ###

## Compute the statistics underlying a boxplot:
boxplot.stats(tests$SATV)

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

## Flag potential outliers in all numeric columns:
lapply(tests[ , -c(1, 2)], FUN = bpOutliers)

###--------------------------------------------------------------------------###

## Define a function to implement the MAD method:
madOutliers <- function(x, cut = 2.5, na.rm = TRUE) {
    ## Compute the median and MAD of x:
    mX   <- median(x, na.rm = na.rm)
    madX <- mad(x, na.rm = na.rm)
    
    ## Return row indices of observations for which |T_MAD| > cut:
    which(abs(x - mX) / madX > cut)
} 

## Find potential outliers in all numeric columns:
lapply(tests[ , -c(1, 2)], FUN = madOutliers)
    
###--------------------------------------------------------------------------###

## Define a function to implement a robust version of Mahalanobis distance
## using MCD estimation:
mcdMahalanobis <- function(data, prob, ratio = 0.75) {
    ## Compute the MCD estimates of the mean and covariance matrix:
    stats <- cov.mcd(data, quantile.used = floor(ratio * nrow(data)))
    
    ## Compute robust Mahalanobis distances
    md <- mahalanobis(x = data, center = stats$center, cov = stats$cov)
    
    ## Find the cutoff value:
    crit <- qchisq(prob, df = ncol(data))
    
    ## Return row indices of flagged observations:
    which(md > crit)
}

## Flag potential multivariate outliers:
mcdMahalanobis(data = tests[ , -c(1, 2)], prob = 0.99)

