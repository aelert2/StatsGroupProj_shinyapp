# K nearest neighbors research
# https://towardsdatascience.com/k-nearest-neighbors-algorithm-with-examples-in-r-simply-explained-knn-1f2c88da405c

library(data.table)
library(tidyverse)
library(ggrepel)

post_td_plays <- read_csv("post_td_plays.csv") # load data

plays <- post_td_plays %>% 
  select(game_seconds_remaining, score_differential, extra_point_type) %>% 
  na.omit(game_seconds_remaining) %>% 
  mutate(extra_point_type = as.factor(extra_point_type),
         game_seconds_remaining = as.integer(game_seconds_remaining),
         score_differential = as.integer(score_differential))

plays <- as.data.frame(plays)
summary(plays)
str(plays)

# pre-knn visualization
plays %>% 
  mutate(game_minutes_remaining = game_seconds_remaining / 60) %>% 
  filter(game_minutes_remaining <= 15) %>% 
  ggplot(aes(x = game_minutes_remaining, y = score_differential, group = extra_point_type)) +
  geom_point(aes(color = extra_point_type, alpha = .5)) +
  labs(x="Game Minutes Remaining", y = "Score Differential")

# Bc of the graph above, I think using KNN with these two predictors will be very difficult.

##############################################################################



# Generate a random number that is 90% of the total number of rows in dataset.
ran <- sample(1:nrow(plays), 0.8 * nrow(plays)) 

# the normalization function is created
nor <- function(x) { (x -min(x))/(max(x)-min(x)) }

# Run nomalization on first 2 coulumns of dataset because they are the predictors
# Predictors: game_seconds_remaining, score_differential
# Cl: extra_point_type
plays_norm <- as.data.frame(lapply(plays[,c(1,2)], nor))
summary(plays_norm)


# extract training set
plays_train <- plays_norm[ran,]

# extract testing set
plays_test <- plays_norm[-ran,]

# extract 3rd column of train dataset because it will be used as 'cl' argument in knn function.
plays_target_category <- plays[ran, 3]

# extract 3rd column of test dataset to measure the accuracy
plays_test_category <- plays[-ran, 3]

# dealing with 'train' and 'class' not being the same length for the knn algorithm
dim(plays_train)
dim(plays_target_category)

str(plays_train)
str(plays_target_category)

# load the package class
library(class)

# run knn function
preds <- knn(train=plays_train, test=plays_test, cl=plays_target_category, k = 10)

# create confusion matrix
tab <- table(preds, plays_test_category)
tab

# this function divides the correct predictions by total number of predictions that tell us how accurate the model is.
accuracy <- function(x){sum(diag(x) / (sum(rowSums(x))) ) * 100}
accuracy(tab)


# https://www.edureka.co/blog/knn-algorithm-in-r/
#install.packages('caret')
install.packages('e1071')
library(caret)
library(e1071)

confusionMatrix(table(preds, plays_test_category))

####################################################################
# adding more predictors 
colnames(post_td_plays)

plays2 <- post_td_plays %>% 
  select(game_seconds_remaining, score_differential, wp, over_under_line, weather_wind_mph, extra_point_type) %>% 
  na.omit(game_seconds_remaining) %>% 
  mutate(extra_point_type = as.factor(extra_point_type),
         game_seconds_remaining = as.integer(game_seconds_remaining),
         score_differential = as.integer(score_differential))

plays2 <- as.data.frame(plays2)
summary(plays2)
str(plays2)


ran2 <- sample(1:nrow(plays2), 0.9 * nrow(plays2)) 
nor <- function(x) { (x -min(x))/(max(x)-min(x)) }

# Predictors: game_seconds_remaining, score_differential, wp, over_under_line, weather_wind_mph
# Cl: extra_point_type
plays_norm2 <- as.data.frame(lapply(plays2[,c(1,2,3,4,5)], nor))
summary(plays_norm2)


# extract training set
plays_train2 <- plays_norm2[ran2,]

# extract testing set
plays_test2 <- plays_norm2[-ran2,]

# extract 3rd column of train dataset because it will be used as 'cl' argument in knn function.
plays_target_category2 <- plays2[ran2, 6]

# extract 3rd column of test dataset to measure the accuracy
plays_test_category2 <- plays2[-ran2, 6]

# dealing with 'train' and 'class' not being the same length for the knn algorithm
dim(plays_train2)
dim(plays_target_category2)

str(plays_train2)
str(plays_target_category2)

# load the package class
library(class)

# run knn function
preds2 <- knn(train=plays_train2, test=plays_test2, cl=plays_target_category2, k = 10)

# create confusion matrix
tab2 <- table(preds2, plays_test_category2)
tab2

# this function divides the correct predictions by total number of predictions that tell us how accurate the model is.
accuracy <- function(x){sum(diag(x) / (sum(rowSums(x))) ) * 100}
accuracy(tab2)

confusionMatrix(table(preds2, plays_test_category2))
