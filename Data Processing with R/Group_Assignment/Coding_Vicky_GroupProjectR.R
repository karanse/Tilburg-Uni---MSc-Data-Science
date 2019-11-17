## Vicky Mekes

# splitting data in train and test set (for target RainTomorrow) using weather_copy

set.seed(1)
trn_index <- createDataPartition(weather_clean$RainTomorrow, p = 0.7, list = FALSE)
trn_weather <- weather_clean[trn_index, ]
tst_weather <- weather_clean[-trn_index, ]

#-------------------------------------------------------------------------------

## Doing Principal Component Analysis for feature selection following up with KNN
install.packages("ggfortify")
library("ggfortify")

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
#edited, but color from factor variable RainTomorrow does not seem to be working

#-------------------------------------------------------------------------------
## Training a basic KNN model for target RainTomorrow

knn_weather <- train(RainTomorrow ~. -Date, method = "knn", data = trn_weather,
                     trControl = trainControl(method = 'cv', number = 10),
                     na.action = na.omit)
knn_weather
# k = 7 proves to be the most accurate (0.892)

## KNN model with PCA
#knn_pca <- train(as.factor(RainTomorrow) ~ PC1 + PC2, data = saved_pca, method = "knn", 
#preProcess = "pca", 
#na.action = na.omit,
#trControl = trainControl(method = 'cv', number = 10))
## warning message: too many ties in knn, components are too close together to build a knn model, see PCA plot                   
