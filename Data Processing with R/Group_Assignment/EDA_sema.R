library(tidyverse)
library(corrplot)
library(ggplot2)
library(readr)


# Data check
weatherAUS <- read_csv("weatherAUS.csv")
  
ncol(weatherAUS) # 24 columns 
str(weatherAUS)
table(weatherAUS$Location)
summary(weatherAUS)

colMeans(is.na(weatherAUS)) # How many NAs we have for each column?

ggplot(weatherAUS,aes( x = RainToday)) + geom_bar() # How is "yes-no" split

#to see numeric values per "yes-no"
num_values_paired <- weatherAUS %>% 
  gather("NumericVar", "Value", c(3,4,5,9, 12:17))

gg1 <- ggplot(num_values_paired, aes(x = RainToday, y = Value, color= RainToday )) +
  geom_boxplot() + facet_wrap(.~NumericVar, ncol = 2, scales = "free") 
gg1

# see numeric values distributions
gg2 <-ggplot(data = num_values_paired, aes(x = Value, fill= NumericVar )) +
  geom_histogram() +
  scale_y_continuous("Number of days") +
  scale_x_continuous("value") +
  facet_wrap( .~ NumericVar, ncol = 2, scales = "free")
gg2

#correlation matrix
 
corr_data<- na.omit(weatherAUS[,c(3,4,5,9,12:17)])
corr_mat <- cor(corr_data)
corrplot(corr_mat, method="color")

# pair - scatter plot
pairs(corr_data, pch =5)







gg1 <- ggplot(num_values_paired, aes(x = RainTomorrow, y = Value, color= RainTomorrow )) +
  geom_boxplot() + facet_wrap(.~NumericVar, ncol = 2, scales = "free") 
gg1
