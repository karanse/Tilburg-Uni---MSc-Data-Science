## Group Assignement Programming with R 
## Group Kruger 60A
## Group Members: 
## Vicky Mekes - u980683       
## Sema Karan - u924823       
## Shelly van Erp - u1266624  



## Dataset Weather in Australia, retrieved from: 
## https://www.kaggle.com/jsphyg/weather-dataset-rattle-package/version/1

## Load packages ---------------------------------------------------------------
rm(list=ls(all=TRUE))
library(caret)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(ggfortify)
library(leaps)
library(MASS)
library(mice)
library(MLmetrics)
library(neuralnet)


## Load data -------------------------------------------------------------------
weather <- read.delim("weatherAUS.csv", sep=",", stringsAsFactors = FALSE)
str(weather) # dataset has int, num and chr values

## Data Processing -------------------------------------------------------------

## 1. Variable Classes
weather$RainToday <- factor(weather$RainToday)
weather$RainTomorrow <- factor(weather$RainTomorrow)
weather$WindDir3pm <- factor(weather$WindDir3pm)
weather$WindDir9am <- factor(weather$WindDir9am)
weather$WindGustDir <- factor(weather$WindGustDir)
weather$Location <- factor(weather$Location)

## 2. Adding New Variables

#Creating a new column with only the month number 
weather$Season <- substr(weather$Date, 6, 7)
weather$Season <- as.numeric(weather$Season)
weather$Season[weather$Season == 12] <- 0 

convert_season <- function(Month) {
  Month[Month <= 2] <- "Summer"
  Month[Month >= 3 & Month <= 5] <- "Autumn"
  Month[Month >= 6 & Month <= 8] <- "Winter"
  Month[!(Month %in% c("Autumn", "Winter", "Summer"))] <- "Spring"
  Month
}

weather$Season <- convert_season(weather$Season)
weather$Season <- factor(weather$Season )

## 3. Missing Data

# shows absolute numbers of missing value
sapply(weather, function(x) sum(is.na(x))) 

# shows percentage of missig values per column
colMeans(is.na(weather)) 

# Removing columns & rows with NAs
weather_clean <- subset(weather, select = -c(Evaporation, Sunshine, 
                                             Cloud3pm, Cloud9am))
weather_clean <- na.omit(weather_clean)

sapply(weather_clean, function(x) sum(is.na(x)))

## Exploratory Data Analysis (EDA) ---------------------------------------------

# Distribution of the numberic values per each binary target value

num_values_paired <- weather_clean %>% 
  gather("NumericVar", "Value", c(3,4,5,7, 10:17, 19))

dist_yes <- ggplot(data = num_values_paired %>% filter(RainTomorrow == "Yes"),
                   aes(x = Value, color = NumericVar)) +
  geom_histogram() +
  scale_y_continuous("Number of days") +
  scale_x_continuous("value") +
  facet_wrap( .~ NumericVar, ncol = 2, scales = "free")
dist_yes

dist_no <- ggplot(data = num_values_paired %>% filter(RainTomorrow == "No"),
                  aes(x = Value, color = NumericVar)) +
  geom_histogram() +
  scale_y_continuous("Number of days") +
  scale_x_continuous("value") +
  facet_wrap( .~ NumericVar, ncol = 2, scales = "free")
dist_no

## Modelling Research Question 1 -----------------------------------------------

##------------Logistic Regression & Burato Algorithm----------------------------
# Prevent data leakage
weather_clean_r1 <- subset(weather_clean, select = -c(Date, RISK_MM))
weather_clean_r1$RainTomorrow <- relevel(factor(weather_clean_r1$RainTomorrow),
                                         ref = "Yes")

# Split data to train and test
set.seed(1)
trn_index = createDataPartition(y = weather_clean_r1$RainTomorrow, p = 0.70, 
                                list = FALSE)
trn_weather = weather_clean_r1[trn_index, ]
tst_weather = weather_clean_r1[-trn_index, ]

# Fit train data to logistic regression
set.seed(1)
weather_lgr = train(RainTomorrow ~ ., method = "glm",
                    family = binomial(link = "logit"), data = trn_weather,
                    trControl = trainControl(method = 'cv', number = 5))
weather_lgr

# Predict on test data
set.seed(1)
predicted_outcomes <- predict(weather_lgr, tst_weather)
predicted_outcomes[1:10]

# Calculate accuracy
accuracy <- sum(predicted_outcomes == tst_weather$RainTomorrow) /
  length(tst_weather$RainTomorrow)
accuracy

# Create confusion matrix
weather_confM <- confusionMatrix(predicted_outcomes, tst_weather$RainTomorrow)
weather_confM


# Sample Data
set.seed(1)
sample_index = createDataPartition(y = weather_clean_r1$RainTomorrow, p = 0.01, 
                                list = FALSE)
sample_weather = weather_clean_r1[sample_index, ]


set.seed(1)
boruta_weather_train <- Boruta(RainTomorrow ~ .,
                                  data = sample_weather,
                                  doTrace = 2)
boruta_weather_train

# Fit data  again onto logistic regression by excluding unimportant features

weather_clean_r1_1 <- subset(weather_clean, select = -c(Date, RISK_MM,Location, Season, WindDir3pm,
                                                        WindSpeed9am, WindDir9am))
weather_clean_r1_1$RainTomorrow <- relevel(factor(weather_clean_r1_1$RainTomorrow),
                                           ref = "Yes")
set.seed(1)
trn_index = createDataPartition(y = weather_clean_r1_1$RainTomorrow, p = 0.70, list = FALSE)
trn_weather = weather_clean_r1[trn_index, ]
tst_weather = weather_clean_r1[-trn_index, ]

set.seed(1)
weather_lgr = train(RainTomorrow ~ ., method = "glm",
                    family = binomial(link = "logit"), data = trn_weather,
                    trControl = trainControl(method = 'cv', number = 5))


set.seed(1)
predicted_outcomes <- predict(weather_lgr, tst_weather)
predicted_outcomes[1:10]

accuracy <- sum(predicted_outcomes == tst_weather$RainTomorrow) /
  length(tst_weather$RainTomorrow)
accuracy

weather_confM <- confusionMatrix(predicted_outcomes, tst_weather$RainTomorrow)
weather_confM

##---------------Principal Component Analysis(PCA) & KNN------------------------

## Split train- test
set.seed(1)
trn_index <- createDataPartition(weather_clean$RainTomorrow, p = 0.7, 
                                 list = FALSE)
trn_weather <- weather_clean[trn_index, ]
tst_weather <- weather_clean[-trn_index, ]

## PCA for feature selection
pca_weather <- prcomp(na.omit(weather_clean[,c(3:7,9, 12:21,23)]),
                      center = TRUE,
                      scale. = TRUE)
summary(pca_weather)
saved_pca <- pca_weather$x[, 1:17]
saved_pca <- cbind(saved_pca, RainTomorrow = factor(weather_clean$RainTomorrow))

autoplot(pca_weather) # quick plot without color and edits

ggplot(saved_pca, aes(x = PC1,y = PC2, color = "RainTomorrow"))+
  geom_point(size=3,alpha=0.5)+
  theme_classic()

## Fit the data to KNN

knn_weather <- train(RainTomorrow ~. -Date, method = "knn", data = trn_weather,
                     trControl = trainControl(method = 'cv', number = 10),
                     na.action = na.omit)
knn_weather
# k = 7 proves to be the most accurate (0.892)


## Modelling Research Question 2 -----------------------------------------------

##----------Linear Regression---------------------------------------------------
## Train-Test Split

validation_index <- createDataPartition(weather_clean$RISK_MM, p=0.80, 
                                        list=FALSE)
validation <- weather[-validation_index,]
training <- weather[validation_index,]

## 1. Backward Feature Selection

set.seed(1)
backwards_model <- train(RISK_MM ~. -Date, data = training,
                         method = "leapBackward", 
                         tuneGrid = data.frame(nvmax = 1:21),
                         trControl = trainControl(method = "cv", number = 10),
                         na.action = na.exclude)

backwards_model$results

## 2. Forward Feature Selection

forwards_model <- train(RISK_MM ~. -Date, data = training,
                        method = "leapForward", 
                        tuneGrid = data.frame(nvmax = 1:21),
                        trControl = trainControl(method = "cv", number = 10),
                        na.action = na.exclude)

forwards_model$results

##----------------Deep Learning-------------------------------------------------

# Deep Learning to get RISK_MM variable to be predicted accuractely 

# First all factor variables have to become dummy variables 
n <- names(weather_clean)
formula_bin <- as.formula(paste("~ ", paste(n, collapse= "+")))
binarized_train <- as.data.frame(model.matrix(formula_bin , data = training))
binarized_valid <- as.data.frame(model.matrix(formula_bin, data = validation))

binarized_train$`(Intercept)`<- NULL
binarized_valid$`(Intercept)`<- NULL


# Adding all variables in a formula to use in the neural network
n_bin <-names(binarized_train) 
formula_net <- as.formula(paste("RISK_MM ~", paste(n_bin[!n_bin %in% "RISK_MM"], 
                                                   collapse = "+"))) 

nn <- neuralnet(formula_net, data=binarized_train, hidden=3, rep=50, 
                linear.output=T, lifesign="full", algorithm="rprop+", 
                threshold=0.01, stepmax = 1000)

# Removing the target variable from the validation set to make predictions 
copy_bin_valid <- binarized_valid
copy_bin_valid$RISK_MM <- NULL

pred_nn <- neuralnet::compute(nn, copy_bin_valid)
predicted_values <- pred_nn$net.result

# simple neural network resulted in a MSE 
MSE(y_pred = predicted_values, y_true = validation$RISK_MM)
















