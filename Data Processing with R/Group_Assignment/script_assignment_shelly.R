
## working directory, loading packages and the dataset
setwd("~/Desktop/Pre-master information and communication sciences/Data science for humanities/Assignments/Assignment 2")
library(lsr)
library(dplyr)
library(ggplot2)
library(class)
library(psych)
library(devtools)
install_github("ggbiplot", "vqv")
library(ggbiplot)
ds4h <- read.csv("data.csv", stringsAsFactors = TRUE, header = TRUE)
View(ds4h)
str(ds4h)
describe(ds4h)

## inspect the dataset 

table(ds4h$diagnosis)

pairs(ds4h[3:10], main="Breast cancer dataset (red=melignant,green=benign)", 
      pch=21, bg=c("red", "green3")[unclass(ds4h$diagnosis)])

## percentage of benign and malignant diagnosis
round(prop.table(table(ds4h$diagnosis)) *100, digits = 1)

## create a function that normalizes the continuous predictors
ds4h_norm <- ds4h
ds4h_norm$radius_mean <- scale(ds4h$radius_mean, center = TRUE, scale = TRUE)
ds4h_norm$texture_mean <- scale(ds4h$texture_mean, center = TRUE, scale = TRUE)
ds4h_norm$perimeter_mean <- scale(ds4h$perimeter_mean, center = TRUE, scale = TRUE)
ds4h_norm$area_mean <- scale(ds4h$area_mean, center = TRUE, scale = TRUE)
ds4h_norm$smoothness_mean <- scale(ds4h$smoothness_mean, center = TRUE, scale = TRUE)
ds4h_norm$compactness_mean <- scale(ds4h$compactness_mean, center = TRUE, scale = TRUE)
ds4h_norm$concavity_mean <- scale(ds4h$concavity_mean, center = TRUE, scale = TRUE)
ds4h_norm$concave.points_mean <- scale(ds4h$concave.points_mean, center = TRUE, scale = TRUE)

##plots of the variables
library(ggvis)
ds4h_norm %>% ggvis(~radius_mean, ~texture_mean, fill= ~diagnosis) %>% layer_points()
ds4h_norm %>% ggvis(~perimeter_mean, ~area_mean, fill= ~diagnosis) %>% layer_points()
ds4h_norm %>% ggvis(~smoothness_mean, ~compactness_mean, fill= ~diagnosis) %>% layer_points()
ds4h_norm %>% ggvis(~concavity_mean, ~concave.points_mean, fill= ~diagnosis) %>% layer_points()

## return values of 'diagnosis' levels
x=levels(ds4h_norm$diagnosis)

#print malignant correlation matrix
print(x[1])
cor(ds4h[ds4h_norm$diagnosis==x[1],3:10])

## print benign correlation matrix
print(x[2])
cor(ds4h[ds4h_norm$diagnosis==x[2],3:10])

## compose the training and test dataset randomly
ind <- sample(2, nrow(ds4h_norm), replace = TRUE, prob = c(0.75, 0.25))

ds4h.training <- ds4h_norm[ind==1, 3:10]
head(ds4h.training)

ds4h.test <- ds4h_norm[ind==2, 3:10]
head(ds4h.test)


#compose training lable
ds4h.trainlabels <- ds4h_norm[ind==1,2]
print(ds4h.trainlabels)
#compose test lable
ds4h.testlabels <- ds4h_norm[ind==2,2]
print(ds4h.testlabels)

## build the knn model
ds4h_pred <- knn(train = ds4h.training, test = ds4h.test, cl=ds4h.trainlabels, k=20)

## inspect ds4h_pred
ds4h_pred

#put the labels in a dataframe

ds4hTestLabels <- data.frame(ds4h.testlabels)

# Merge `ds4h_pred` and `ds4h.testlabels` 
merge <- data.frame(ds4h_pred, ds4h.testlabels)

# Specify column names for `merge`
names(merge) <- c("Predicted diagnosis", "Observed diagnosis")

# Inspect `merge` 
merge

## table with percentages outcome

round(prop.table(table(merge)) *100, digits = 2)

### log transform the predictors
log.ds4h <- log(ds4h[, 3:10])
ds4h.diagnosis <- ds4h[,2]
log.ds4h <- data.matrix(log.ds4h)
log.ds4h[is.infinite(log.ds4h)] <- -99999
# apply PCA 

ds4h.pca <- prcomp(log.ds4h,
                 center = TRUE,
                 scale. = TRUE)

## print ds4h.pca
print(ds4h.pca)


## plot ds4h.pca
plot(ds4h.pca, type = "l")

## describe dsh4 pca & plot 
summary(ds4h.pca)


g <- ggbiplot(ds4h.pca, obs.scale = 1, var.scale = 1, 
              groups = ds4h.diagnosis, ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)






