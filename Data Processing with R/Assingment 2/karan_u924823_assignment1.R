## Sema Karan
## u-924823

## Load packages ---------------------------------------------------------------
library(dplyr)
library(ggplot2)

## Load data -------------------------------------------------------------------
olympics <- read.delim("input/olympics.txt", stringsAsFactors = FALSE)

## Question 1 -------------------------------------------------------------------

olympics_sorted_excl_games <- olympics %>% 
  select(-Games) %>% 
  arrange(Year, Event, Name)
answer1 <- olympics_sorted_excl_games

## Question 2 -------------------------------------------------------------------

olympics_relay_filtered <- olympics %>% 
  filter(grepl('Relay', Event) == TRUE)
answer2 <- olympics_relay_filtered

## Question 3 -------------------------------------------------------------------


olympics_title_added <- olympics %>% 
  mutate(Title = paste(as.character(Year), " ",  City))
answer3 <- olympics_title_added

## Question 4 -------------------------------------------------------------------

olympics_num_sports_agg <- olympics %>% 
  group_by(Competitor_Sex = Sex, Season, Year) %>% 
  summarise(Num_Sports = n_distinct(Sport))
answer4 <- olympics_num_sports_agg

## Question 5 -------------------------------------------------------------------

answer5 <- ggplot(data = olympics, aes(x = Sex, y = Height, fill = Sex)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(breaks = c("F", "M"), 
                    values=c("pink", "blue"))

## Question 6 -------------------------------------------------------------------

answer6 <- ggplot(data = olympics, aes(x = Age)) +
  geom_histogram(binwidth  = 3) +
  scale_y_continuous(name = "Number of Records")

## Question 7 -------------------------------------------------------------------

answer7 <- olympics %>% 
  group_by(Sex, Year) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(x = Year, y = count, fill = Sex)) +
  geom_bar(position = "dodge", stat = "identity")

## Question 8 -------------------------------------------------------------------

answer8 <- ggplot(data = olympics, aes(x = Height, y = Weight, color = "purple", shape = Sex)) +
  geom_point()

## Question 9 -------------------------------------------------------------------

team_by_name_len <- olympics %>% 
  mutate(Name_Length = nchar(Name)) %>% 
  group_by(Team) %>% 
  summarise(Median_Length = median(Name_Length)) %>% 
  arrange(desc(Median_Length)) %>% 
  top_n(8) 
team_by_name_len_sorted <-team_by_name_len %>% 
  arrange(Team)
answer9 <- team_by_name_len_sorted


## Question 10 -------------------------------------------------------------------

answer10 <- ggplot(data = (olympics %>% filter(NOC %in% c("NED", "BEL", "LUX"))), aes(x = NOC)) + 
  geom_bar(position = "dodge", stat = "count") +
  facet_grid(.~Season) +
  scale_y_continuous(name = "Number of Records", limits = c(0,600), position = "right") +
  scale_x_discrete(name = "National Olympic Committee")
  

## Question 11 -------------------------------------------------------------------

answer11 <- olympics %>% 
  filter(Team == "Refugee Olympic Athletes") %>%
  group_by(Name) %>% 
  summarise(Age = mean(Age)) %>% 
  ggplot(aes(x =  reorder(Name, -Age),  y = Age)) +
  geom_bar(stat = "identity",show.legend = FALSE, color = 'black') +
  coord_flip() +
  theme(text = element_text(family = "mono")) +
  scale_x_discrete(name="Name")


## Question 12 -------------------------------------------------------------------
 
answer12 <- olympics %>% 
  group_by(Season) %>% 
  summarise(Mean_Weight = mean(Weight),
            Std_Weight = sd(Weight)/sqrt(n())) %>% 
  ggplot(aes(x = Season, y = Mean_Weight)) +
  geom_point() + 
  geom_errorbar(aes(ymin = Mean_Weight -  Std_Weight,
                    ymax = Mean_Weight +  Std_Weight), width = 0.1) + 
  theme(panel.background = element_rect(colour = "cadetblue", size = 3))






