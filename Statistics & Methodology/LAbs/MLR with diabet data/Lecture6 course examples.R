dDat <- read.csv("diabetes.csv")
colnames(dDat)[3]<- paste("bp")
colnames(dDat) <- tolower(colnames(dDat))


## simple linear regression
out1 <- lm(bp~age, data =dDat)
summary(out1)

## multiple linear regression
out2 <-lm(bp ~ age + bmi, data = dDat)
summary(out2)

## centering for improved interpretation
dDat$age30 <- dDat$age - 30
dDat$bmi25 <- dDat$bmi - 25

## Rerun the models with centered predictors:
out1.2 <- lm(bp ~ age30, data = dDat)
out2.2 <- lm(bp ~ age30 + bmi25, data = dDat )
summary(out1.2)
summary(out2.2)

## how much variablity in bp is explained by two models? __> R^2 check
s1 <-summary(out1.2); s2 <- summary(out2.2)

## extract R^2 values
r1.2 <- s1$r.squared; r2.2<-s2$r.squared
r1.2
r2.2


## Extracting F statistics
f1 <- s1$fstatistic; f2 <- s2$fstatistic
f1['value']
f2['value']

## compute p-values of F
pf(f1['value'], f1['numdf'], f1['dendf'], lower.tail = FALSE)

pf(f2['value'], f2['numdf'], f2['dendf'], lower.tail = FALSE)
# since the p-values are really small, R^2 is greater than zero


## model comparison - compute the delta of R^2
r2.2 - r1.2

##significance testing for model comparison

##Is that increase significantly greater than zero?
anova(out1.2, out2.2)

## model comparison with predictive performance
mse1.2 <- MSE(y_pred=predict(out1.2), y_true=dDat$bp)
mse2.2 <- MSE(y_pred = predict(out2.2), y_true = dDat$bp)
mse1.2
mse2.2

