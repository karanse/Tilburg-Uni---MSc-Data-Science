## Group Assignement Programming with R 
## Dataset Weather in Australia, retrieved from: 
## https://www.kaggle.com/jsphyg/weather-dataset-rattle-package/version/1

## Shelly van Erp 
install.packages("caret")
install.packages("MASS")

library("caret")
library("dplyr")
library("ggplot2")
library("MLmetrics")   
library("leaps")      
library("MASS")
library("neuralnet")

weather <- read.delim("input/weatherAUS.csv", sep=",", stringsAsFactors = FALSE)

## use data to predict targets RainTomorrow (yes/no) 
## and RISK_MM (amount of rain tomorrow)

str(weather) # dataset has int, num and chr values

weather$RainToday <- factor(weather$RainToday)
weather$RainTomorrow <- factor(weather$RainTomorrow)
weather$WindDir3pm <- factor(weather$WindDir3pm)
weather$WindDir9am <- factor(weather$WindDir9am)
weather$WindGustDir <- factor(weather$WindGustDir)
weather$Location <- factor(weather$Location)

# Creating a new column with only the month number 
weather$Month <- substr(weather$Date, 6, 7)
weather$Month <- as.numeric(weather$Month)

# Making a function to convert a column with months to Australian seasons 

season <- function(Month) {
  Month[Month <= 2] <- "Summer"
  Month[Month >= 3 & Month <= 5] <- "Autumn"
  Month[Month >= 6 & Month <= 8] <- "Winter"
  Month[!(Month %in% c("Autumn", "Winter", "Summer"))] <- "Spring"
  Month
}

weather$Season <- weather$Month
weather$Season[weather$Season == 12] <- 0 
weather <- mutate_at(weather, vars(Season), funs(season))

weather$Season <- factor(weather$Season)
weather$Month <- factor(weather$Month)

#-------------------------------------------------------------------------------

# Checking missing data in dataset 
sapply(weather, function(x) sum(is.na(x)))

# 3267 missing values in both RISK_MM and RainTomorrow target variables
# Evaporation, Sunshine, Cloud9am and Cloud3pm almost miss half of observations

#-------------------------------------------------------------------------------

# Plotting the variables with lots of missing values against the Y variables,
# to see if they are important predictors.

#Evaporation, does not seem like a very good predictor for both y variables
ggplot(data = weather, aes(x = Evaporation, y = RISK_MM, color = RainTomorrow))+
  geom_point()

ggplot(data = weather, aes(x = RainTomorrow, y = Evaporation)) + 
  geom_boxplot()


# Sunshine does not seem like a good predictor for RISK_MM, could be helpful for 
# the RainTomorrow variable
ggplot(data = weather, aes(x = Sunshine, y = RISK_MM)) + 
  geom_point() +
  geom_smooth()

ggplot(data = weather, aes(x = RainTomorrow, y = Sunshine)) + 
  geom_boxplot()


# Cloud9am / Cloud3pm could be helpful for predicting both variables

ggplot(data = weather, aes(x = Cloud9pm, fill = RainTomorrow)) +
  geom_bar(position = "dodge")

ggplot(data = weather, aes(x = Cloud3pm, fill = RainTomorrow)) + 
  geom_bar(position = "dodge")

ggplot(data = weather, aes(x = Cloud9am, y = RISK_MM)) + 
  geom_bar(stat = "summary", fun.y = "mean")

ggplot(data = weather, aes(x = Cloud3pm, y = RISK_MM)) + 
  geom_bar(stat = "summary", fun.y = "mean")


#-------------------------------------------------------------------------------

# Handeling the missing data 
weather_clean <- weather 

# Deleting the 4 variables Evaporation, Sunshine, Cloud9am and Cloud3am
# As they contain over 1/3 of NA's
weather_clean$Evaporation <- NULL
weather_clean$Sunshine <- NULL
weather_clean$Cloud3pm <- NULL
weather_clean$Cloud9am <- NULL


# Deleting rows with missing values (caret only works with complete datasets)
weather_clean <- na.omit(weather_clean)
sapply(weather_clean, function(x) sum(is.na(x)))

# weather_clean dataset: 112925 observations instead of 145460

# Deleting the Date variable as it causes an error while predicting 
# (because it is automatically treated as a factor in models)
weather_clean$Date <- NULL

#-------------------------------------------------------------------------------

# splitting data into validation and training set (for target RISK_MM)

set.seed(1)

validation_index <- createDataPartition(y = weather_clean$RISK_MM, p=0.70, 
                                        list=FALSE)
validation <- weather_clean[-validation_index,]
training <- weather_clean[validation_index,]


#------------------------------------------------------------------------------

memory.limit()
memory.limit(size=56000)
# MSE normal linear regression without feature selection = 44.85, R2 = 0.31
full_linear <- lm(RISK_MM ~., data= training) 
summary(full_linear)
MSE(y_pred = predict(full_linear, validation), y_true = validation$RISK_MM)

# Backwards feature selection
backwards_model <- train(RISK_MM ~. , data = training,
                         method = "leapBackward", 
                         trControl = trainControl(method = "cv", number = 10),
                         na.action = na.exclude)

backwards_model$results

# MSE backward feature selection = 50.02
MSE(y_pred = predict(backwards_model, validation), y_true = validation$RISK_MM)

# Forwards feature selection
forwards_model <- train(RISK_MM ~. , data = training,
                        method = "leapForward", 
                        trControl = trainControl(method = "cv", number = 10),
                        na.action = na.exclude)

forwards_model$results

# MSE forward feature selection = 64.76
MSE(y_pred = predict(forwards_model, validation), y_true = validation$RISK_MM)

#-------------------------------------------------------------------------------

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


