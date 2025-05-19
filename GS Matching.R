# Load required libraries
library(dplyr)
library(ggplot2)
library(rpart)
library(magrittr)
library(ggplot2)
library(foreign)
library(readxl)
library(haven)
library(reshape2)
library(readr)
library(tidyr)
library(matchingR)

# Clear workspace and set seed for reproducibility
rm(list=ls())
set.seed(717)

##################################
# Step 1: Process Officer Preferences
##################################
# Load officer rankings from Excel
matrix <- read_excel("~/Matching/matrix.xlsx", sheet = "Officers' ranking tranpose")
officer_colheader = colnames(matrix[-1])

# Transform rankings into preference scores 
# (1st choice = 3, 2nd = 2, 3rd = 1, Not explicitly ranked = 0.5, Others, = 0)
matrix[-1] %<>% lapply(function(x) ifelse(x==1, 3, 
                                        ifelse(x==2, 2,
                                               ifelse(x==3, 1, 
                                                      ifelse(x==0, 0.5, 0)))))
matrix[-1] %<>% lapply(function(x) ifelse(is.na(x)==T, 0, x))

# Convert to matrix format for matchingR
officer = data.matrix(matrix[,-1])

# Save to CSV for reference
write.csv(officer, "~/Matching/officer_posting_ranking.csv")

#############################
# Step 2: Process Director Preferences
#############################
# Load director's rankings from Excel
matrix <- read_excel("~/Matching/matrix.xlsx", sheet = "Directors' ranking tranpose")
posting_colheader = colnames(matrix[-1])

# Transform rankings into preference scores
matrix[-1] %<>% lapply(function(x) ifelse(x==1, 3, 
                                          ifelse(x==2, 2,
                                                 ifelse(x==3, 1, 
                                                        ifelse(x==0, 0.5, 0)))))
matrix[-1] %<>% lapply(function(x) ifelse(is.na(x)==T, 0, x))

# Convert to matrix format for matchingR
posting = data.matrix(matrix[,-1])

# Save to CSV for reference
write.csv(posting, "~/Matching/director_officer_ranking.csv")

#################################################
# Step 3: Stable Matching with Gale-Shapley
#################################################
matching = galeShapley.marriageMarket(officer, posting)

#################################################
# Step 3.1: Anaylse results from officers' perspectives
#################################################
results = as.data.frame(matching$proposals)
galeShapley.checkStability(officer, posting, matching$proposals, matching$engagements)

# Label results
names(results) = c("posting")
officer_colheader = as.data.frame(officer_colheader)
results = cbind(results, officer_colheader)
posting_colheader = as.data.frame(posting_colheader)
posting_colheader %<>% mutate(rowno = row_number())
results = merge(results, posting_colheader, by.x="posting", by.y="rowno", all.x=T)
results %<>% select(-posting, officer=officer_colheader, predictedposting=posting_colheader)

# Load actual posting results
finalposting =  read_excel("~/Matching/matrix.xlsx",  sheet = "final posting")
results = merge(results , finalposting, by="officer", all.x = T)
results[] %<>% lapply(function(x) as.character(x))

# Categorize prediction vs actual placement
results %<>% mutate(predictedchoice = ifelse(predictedposting==first_choice, "first choice",
                                             ifelse(predictedposting==second_choice, "second choice",
                                                    ifelse(predictedposting==third_choice, "third choice", "didnt get top 3"))))
results %<>% mutate(finalchoice = ifelse(final_posting==first_choice, "first choice",
                                         ifelse(final_posting==second_choice, "second choice",
                                                ifelse(final_posting==third_choice, "third choice", "didnt get top 3"))))
results$predictedchoice = ifelse(is.na(results$predictedchoice)==T, "didnt get top 3", results$predictedchoice)
results$finalchoice = ifelse(is.na(results$finalchoice)==T, "didnt get top 3", results$finalchoice)


# Check if predicted posting is within officer's choice set
matrix_officer = read_excel("~/Matching/matrix.xlsx", sheet = "officers' ranking tranpose")
colheader_officer = colnames(matrix_officer[-1])
tab = NULL
for (i in colheader_officer){
  predicted = results %>% filter(officer==i) %>% select(officer, predictedposting)
  choiceset = matrix_officer %>% select(posting = officer, i) %>% drop_na() %>% select(posting) %>% mutate(officer=i)
  choiceset = merge(choiceset, predicted, by="officer", all.x=T)
  choiceset %<>% mutate(inchoiceset = ifelse(predictedposting==posting, 1, 0))
  choiceset %<>% group_by(officer) %>% summarise(inchoiceset = max(inchoiceset))
  tab = rbind(tab, choiceset)
}

results = merge(results, tab, all.x=T, by="officer")
write.csv(results, "~/Matching/finalprediction_officers.csv")

#################################################
# Step 3.2: Analyse from Directors' Perspective
#################################################
results2 = as.data.frame(matching$engagements)

# Label results
names(results2) = c("officer")
posting_colheader$rowno = NULL
results2=cbind(results2, posting_colheader)
officer_colheader = as.data.frame(officer_colheader)
officer_colheader %<>% mutate(rowno = row_number())
results2 = merge(results2, officer_colheader, by.x="officer", by.y="rowno", all.x=T)
results2 %<>% select(-officer, posting=posting_colheader, predictedofficer=officer_colheader)

# Load actual posting results
finalposting2 =  read_excel("~/Matching/matrix.xlsx",  sheet = "final posting (directors)")
results2 = merge(results2, finalposting2, by="posting", all.x=T)
results2[] %<>% lapply(function(x) as.character(x))

# Categorize prediction vs actual placement
results2 %<>% mutate(predictedchoice = ifelse(predictedofficer==first_choice, "first choice",
                                              ifelse(predictedofficer==second_choice, "second choice",
                                                     ifelse(predictedofficer==third_choice, "third choice", "didnt get top 3"))))
results2 %<>% mutate(finalchoice = ifelse(final_officer==first_choice, "first choice",
                                          ifelse(final_officer==second_choice, "second choice",
                                                 ifelse(final_officer==third_choice, "third choice", "didnt get top 3"))))
results2$predictedchoice = ifelse(is.na(results2$predictedchoice)==T, "didnt get top 3", results2$predictedchoice)
results2$finalchoice = ifelse(is.na(results2$finalchoice)==T, "didnt get top 3", results2$finalchoice)

# Check if predicted officer is within director's choice set
matrix_posting = read_excel("~/Matching/matrix.xlsx", sheet = "directors' ranking tranpose")
colheader_posting = colnames(matrix_posting[-1])
tab = NULL

for (i in colheader_posting){
  predicted = results2 %>% filter(posting==i) %>% select(posting, predictedofficer)
  choiceset = matrix_posting %>% select(officer = posting, i) %>% drop_na() %>% select(officer) %>% mutate(posting=i)
  choiceset = merge(choiceset, predicted, by="posting", all.x=T)
  choiceset %<>% mutate(inchoiceset = ifelse(predictedofficer==officer, 1, 0))
  choiceset %<>% group_by(posting) %>% summarise(inchoiceset = max(inchoiceset))
  tab = rbind(tab, choiceset)
}

results2 = merge(results2, tab, all.x=T, by="posting")
write.csv(results2, "~/Matching/finalprediction_directors.csv")