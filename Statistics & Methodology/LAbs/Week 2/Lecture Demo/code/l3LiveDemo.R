### Title:    Lecture 3 Live Demo of EDA
### Author:   Kyle M. Lang
### Created:  2018-APR-06
### Modified: 2018-JUL-23

rm(list = ls(all = TRUE))

setwd("/Volumes/GoogleDrive/My Drive/My Documents/SemaDRive/TU DATA SCIENCE/Statistics & Methodology/LAbs/Week 2/Lecture Demo/")
dataDir  <- "./data/"
fileName <- "openpowerlifting.csv"

dat1 <- read.csv(paste0(dataDir, fileName))

## Fit some "sensible" models:
out1 <- lm(TotalKg ~ Sex + Equipment, data = dat1)
summary(out1)

out2 <- lm(BestSquatKg ~ Sex + Equipment, data = dat1)
summary(out2)

out3 <- lm(BestBenchKg ~ Sex + Equipment, data = dat1)
summary(out3)

out4 <- lm(BestDeadliftKg ~ Sex + Equipment, data = dat1)
summary(out4)

## (Grossly) summarize the data:
summary(dat1)
str(dat1)

## See how much missing data we have:
colMeans(is.na(dat1))

## Check distributions of single lifts:
hist(dat1$BestSquatKg)
hist(dat1$BestBenchKg)
hist(dat1$BestDeadliftKg)

## How many negative weights?
sum(dat1$BestSquatKg < 0, na.rm = TRUE)
sum(dat1$BestBenchKg < 0, na.rm = TRUE)
sum(dat1$BestDeadliftKg < 0, na.rm = TRUE)

## What about the distribution of the total?
hist(dat1$TotalKg)

### NOTE: Hmmm...those can't match. What's going on?

## Pull out single lifts:
bestLifts <- dat1[ , paste0("Best", c("Squat", "Bench", "Deadlift"), "Kg")]

## See if we can figure out how the total is computed:

t0 <- dat1$TotalKg 
# Veridical total
t1 <- rowSums(bestLifts)
# Naive total

all.equal(t0, t1) # compare

### NOTE: Only problem is the missing values.


t2 <- rowSums(bestLifts, na.rm = TRUE)
# ignore missing values

all.equal(t0, t2) # compare

### NOTE: Still no good; not just a matter of using available data.
###       Maybe missing single lifts are treated as zeros.

bestLifts2 <- bestLifts
bestLifts2[is.na(bestLifts2)] <- 0

t3 <- rowSums(bestLifts2)

all.equal(t0, t3) # Nope, maybe missing all single lifts makes a missing value

t4 <- t3
t4[t4 == 0] <- NA

all.equal(t0, t4) # Still no good, something else is happening

### NOTE: What about disqualified lifters?

table(dat1$Place)

table(place = dat1$Place, noTotal = is.na(t0)) # Ahh...that's interesting

### NOTE: Disqualified lifters and No-shows are missing totals

t5 <- t2
t5[dat1$Place %in% c("DD", "NS", "DQ")] <- NA

all.equal(t0, t5) # almost, only 3 jerks left

jerks <- which(is.na(t5) & !is.na(t0))
dat1[jerks, ]

### NOTE: The last three jerks were disqualified after getting a total

table(place = dat1$Place, negSquat = dat1$BestSquatKg < 0)
table(place = dat1$Place, negSquat = dat1$BestBenchKg < 0)
table(place = dat1$Place, negSquat = dat1$BestDeadliftKg < 0)

### NOTE: Mostly, negative weights belong to DQed lifters, but not entirely

screen <- dat1$Place != "DQ" &
    with(dat1, BestSquatKg < 0 | BestBenchKg < 0 | BestDeadliftKg < 0)
screen[is.na(screen)] <- FALSE

dat1[screen, ] # Data entry errors

## Who has the max total?
maxTotal <- dat1[which.max(dat1$TotalKg), ]
maxTotal

### NOTE: Hmm...1365.31 KG seems like a pretty extreme total. Is that legit?


