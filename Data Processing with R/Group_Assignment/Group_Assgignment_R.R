## Group Assignement Programming with R 
## Dataset Weather in Australia, retrieved from: 
## https://www.kaggle.com/jsphyg/weather-dataset-rattle-package/version/1

## Shelly van Erp 
install.packages("caret")
install.packages("tidyverse")
install.packages("leaps")

library("caret")
library("dplyr")
library("tidyr")
library("ggplot2")
library("leaps")
library("MASS")
library("mice")

weather <- read.delim("weatherAUS.csv", sep=",", stringsAsFactors = FALSE)

## use data to predict targets RainTomorrow (yes/no) 
## and RISK_MM (amount of rain tomorrow)

str(weather) # dataset has int, num and chr values

weather$RainToday <- factor(weather$RainToday)
weather$RainTomorrow <- factor(weather$RainTomorrow)
weather$WindDir3pm <- factor(weather$WindDir3pm)
weather$WindDir9am <- factor(weather$WindDir9am)
weather$WindGustDir <- factor(weather$WindGustDir)
weather$Location <- factor(weather$Location)

#Creating a new column with only the month number 
weather$Season <- substr(weather$Date, 6, 7)
weather$Season <- as.numeric(weather$Season)
weather$Season[weather$Season == 12] <- 0 


#Making a function to convert the Season column to the actual seasons 

season <- function(Month) {
  Month[Month <= 2] <- "Summer"
  Month[Month >= 3 & Month <= 5] <- "Autumn"
  Month[Month >= 6 & Month <= 8] <- "Winter"
  Month[!(Month %in% c("Autumn", "Winter", "Summer"))] <- "Spring"
  Month
}

mutate_at(weather, vars(Season), funs(season))
weather$Season <- factor(weather_copy$Season)


#-------------------------------------------------------------------------------

## Checking missing data in dataset 
sapply(weather, function(x) sum(is.na(x)))

#3267 missing values in both RISK_MM and RainTomorrow target variables
#Evaporation, Sunshine, Cloud9am and Cloud3pm almost miss half of observations

weather_copy <- weather 

#Deleting the columns with too many outliers in the dataset copy 
weather_copy$Evaporation <- NULL
weather_copy$Sunshine <- NULL
weather_copy$Cloud9am <- NULL
weather_copy$Cloud3pm <- NULL

#Deleting rows with missing values 
weather_copy <- na.omit(weather_copy)
sapply(weather_copy, function(x) sum(is.na(x)))

#-------------------------------------------------------------------------------

# splitting data into validation and training set (for target RISK_MM)

validation_index <- createDataPartition(weather_copy$RISK_MM, p=0.80, 
  list=FALSE)
validation <- weather[-validation_index,]
training <- weather[validation_index,]


#-------------------------------------------------------------------------------
##Stepwise feature selection using Caret, Leaps and MASS 

set.seed(123)

backwards_model <- train(RISK_MM ~. -Date, data = training,
                    method = "leapBackward", 
                    tuneGrid = data.frame(nvmax = 1:21),
                    trControl = trainControl(method = "cv", number = 10),
                    na.action = na.exclude)

backwards_model$results
summary(backwards_model$finalModel)

forwards_model <- train(RISK_MM ~. -Date, data = training,
                    method = "leapForward", 
                    tuneGrid = data.frame(nvmax = 1:21),
                    trControl = trainControl(method = "cv", number = 10),
                    na.action = na.exclude)

forwards_model$results

