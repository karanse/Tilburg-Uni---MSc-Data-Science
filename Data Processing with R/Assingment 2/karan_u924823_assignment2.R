## Sema Karan
## u924823

## Load packages ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(caret)

## Load data -------------------------------------------------------------------
development <- read.delim("input/countries_development.txt", stringsAsF = F)
population <- read.delim("input/countries_population.txt", stringsAsF = F)
olympics <- read.delim("input/countries_olympics.txt", stringsAsF = F)

## Question 1 ------------------------------------------------------------------
answer1 <- function(data_frame, num) {
  data_filtered <- data_frame %>% 
    filter(PERC_INTERNET_USERS >= num) %>% 
    select(COUNTRY)
  
  unique(data_filtered$COUNTRY)
}

answer1(development, 95)

## Question 2 ------------------------------------------------------------------
answer2 <- function(data_frame, string) {
  if (string %in% c(data_frame$NOC)) {
    data_filtered <- data_frame %>% 
      filter(NOC == string) %>% 
      select(-NOC)
  } else if (string %in% c(data_frame$Team)) {
    data_filtered <- data_frame %>% 
      filter(Team == string) %>% 
      select(-Team) 
  }
  data_filtered
}

answer2(olympics, "SWE")
answer2(olympics, "Switzerland-2")

## Question 3 ------------------------------------------------------------------
development_round <- mutate_at(development, 
                               vars(GDP_PER_CAP:PERC_FEMALE_PARLIAMENT), 
                                 funs(round), digits = 2)
answer3 <- development_round

answer3[1:3, ]

## Question 4 ------------------------------------------------------------------
data_new_names <- population
names(data_new_names) <- substring(names(data_new_names), 2)
names(data_new_names)[1] <- "Country"

answer4 <- data_new_names %>% 
  filter(Country == "Netherlands") %>%
  select(-Country) %>% 
  gather(key = "Year", value = "Population") %>% 
  ggplot(aes(x = Year, y = Population)) + geom_point()

answer4

## Question 5 ------------------------------------------------------------------  
 merged_data <- population %>% 
  inner_join(development, by = c("Country" = "COUNTRY"))
answer5 <- merged_data

answer5[1:3, ]

## Question 6 ------------------------------------------------------------------
set.seed(1)
equal_work_reg <- train(EQUAL_WORK  ~ EQUAL_PAY + COUNTRY, method = "glm",
                        family = binomial(link = "logit"), data = development, 
                        trControl = trainControl(method = "cv", number = 10))
answer6 <- max(equal_work_reg$results$Accuracy)

## Question 7 ------------------------------------------------------------------
set.seed(1) 
development$EQUAL_PAY <- relevel(factor(development$EQUAL_PAY), ref = "YES")
trn_index <- createDataPartition(y = development$EQUAL_PAY, p = 0.60, 
                                 list = FALSE)
trn_develop <- development[trn_index, ]
tst_develop <- development[-trn_index, ]

pay_knn = train(EQUAL_PAY ~ GDP_PER_CAP, method = "knn", 
                data = trn_develop, trControl = trainControl(method = 'cv', 
                                                             number = 5))
predicted_outcomes <- predict(pay_knn, tst_develop)
pay_confM <- confusionMatrix(predicted_outcomes, 
                             tst_develop$EQUAL_PAY) 
pay_confM

answer7_trn <- trn_develop
answer7_tst <- tst_develop

## Question 8 ------------------------------------------------------------------
geography <- read.delim("input/countries_geography.txt", stringsAsF = F)

# check NOC with more than 1 team  in olympics which may need aggregation
check2 <- olympics %>% 
  group_by(NOC) %>% 
  summarise(team_count = n_distinct(Team)) %>% 
  filter(team_count > 1)
unique((olympics %>% 
          filter(NOC %in% check2$NOC))$Team)

#String cleaning to match countries--------------
# Remove "-" and any number from olympics$Team 
olympics$Team <- gsub('[0-9]+', '', olympics$Team)
olympics$Team <- gsub('-', '', olympics$Team)

# Remove the whitespaces on right from geography$Country
geography$Country <- trimws(geography$Country, which = c("right"))

check <- as.data.frame(olympics %>% 
                         mutate(Country = Team) %>% 
                         group_by(Country, Season, Team) %>% 
                         mutate(Country2 = Country) %>% 
                         summarise(Medals = sum(Medals)) %>% 
                         full_join((geography %>% mutate(Country3 = Country)),
                                   by = "Country") %>% 
                         mutate(check = (Team == Country3)) %>% 
                         filter(is.na(check)==TRUE))

# Change some geopgraphy$Country and  olympics$Team to match
geography$Country <- gsub('Korea, North', 'North Korea', geography$Country)
geography$Country <- gsub('Korea, South', 'South Korea', geography$Country)
geography$Country <- gsub('Bahamas, The', 'Bahamas', geography$Country)
olympics$Team <- gsub('Great Britain', 'United Kingdom', olympics$Team)
olympics$Team <- gsub('United States Virgin Islands', 'United States', 
                      olympics$Team)
olympics$Team <- gsub('Congo (Kinshasa)', "Congo", 
                      olympics$Team)
olympics$Team <- gsub('Congo (Brazzaville)', "Congo", 
                      olympics$Team)
geography$Country <- gsub('Congo, Democratic Republic of the', 
                          'Congo, Republic of the', geography$Country)
geography$Country <- gsub('Congo, Democratic Republic of the', 
                          'Congo, Republic of the', geography$Country)


cleaned_merged_data <- as.data.frame(olympics %>% 
  group_by(Country = Team, Season) %>% 
  summarise(Medals = sum(Medals)) %>% 
  left_join(geography, by = "Country"))

answer8 <- cleaned_merged_data
answer8[1:6, ]  


## Question 9 ------------------------------------------------------------------
dev_discrete <- development

dev_discrete$PERC_FEMALE_SECONDARY_EDU <- cut(
  dev_discrete$PERC_FEMALE_SECONDARY_EDU, breaks = c (0,40,60,100), 
  labels = c("UNDER_REPRESENTED", "APPROX_EQUAL", "OVER_REPRESENTED"))

dev_discrete$PERC_FEMALE_LABOR_FORCE <- cut(
  dev_discrete$PERC_FEMALE_LABOR_FORCE, breaks = c (0,40,60,100), 
  labels = c("UNDER_REPRESENTED", "APPROX_EQUAL", "OVER_REPRESENTED"))

dev_discrete$PERC_FEMALE_PARLIAMENT <- cut(
  dev_discrete$PERC_FEMALE_PARLIAMENT , breaks = c (0,40,60,100), 
  labels = c("UNDER_REPRESENTED", "APPROX_EQUAL", "OVER_REPRESENTED"))

dev_discrete[1:3, ]

set.seed(1)
PERC_FEMALE_LABOR_FORCE_knn = train(PERC_FEMALE_LABOR_FORCE ~ GDP_PER_CAP + 
                                      CO2_PER_CAP + 
                                      PERC_INTERNET_USERS + 
                                      SCIENTIFIC_ARTICLES_PER_YR, 
                                    method = "knn", data = dev_discrete,
                   trControl = trainControl(method = 'cv', number = 3))

plot_knn_results <- function(fit_knn) {
  ggplot(fit_knn$results, aes(x = k, y = Accuracy)) +
    geom_bar(stat = "identity") +
    scale_x_discrete("value of k", limits = fit_knn$results$k) +
    scale_y_continuous("accuracy")
}

plot_knn_results(PERC_FEMALE_LABOR_FORCE_knn)

answer9 <- PERC_FEMALE_LABOR_FORCE_knn
