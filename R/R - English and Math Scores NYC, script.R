
##########################################################################################
################## SQLDF ELA breakdown
##########################################################################################
library(readxl)
library(mapdata)
library(plyr)
library(tidyverse)
library(ggplot2)
library(sqldf)
library(neuralnet)
library(reshape2)
library(randomForest)
library(pROC)
library(gridExtra)

#read in the excel sheet
#takes a while be paitent
ELA_c <- read_excel("PROJECT/3-8-2018-19/3-8_ELA_AND_MATH_RESEARCHER_FILE_2019.xlsx")#path to excel file
ELA <- ELA_c

#state total data frame
STATE_ELA <- sqldf("SELECT * from ELA where NAME like 'STATEWIDE -%'")
STATE_ELA <- STATE_ELA[,c(1,6:23)] #trim off columns 2,3,4,5 due to NA

#NRC total data frame
NRC_ELA <- sqldf("SELECT * from ELA where NAME like 'NRC -%'")
NRC_ELA <- NRC_ELA[,c(1:3,6:23)] #trim off columns 4 and 5 due to NA

#pull out only NRC needs from the data frame
NRC_NEEDS_ELA <- sqldf("SELECT * from NRC_ELA where NAME like '%NEEDS%'")
NRC_ELA <- sqldf("SELECT * from NRC_ELA where NAME NOT like '%NEEDS%'")#restore NRC with just the non NEEDS rows

#county total data frame
COUNTY_ELA <-  sqldf("SELECT * from ELA where NAME like '%COUNTY%'")
COUNTY_ELA <- COUNTY_ELA[,c(1,4,6:23)]

#district total data frame
DISTRICT_ELA <- sqldf("SELECT * from ELA where NAME like '%District%'")
DISTRICT_ELA <- DISTRICT_ELA[,c(1:4,6:23)]

# convertiing the test count to numeric
cols.nms <- colnames(ELA[,12:23])
ELA[cols.nms] <- sapply(ELA[cols.nms], as.numeric)
sapply(ELA, class)


# dropping unwanted columns
ELA <- ELA[,-c(14,16,18,20,21,22)]


sch_all <- sqldf("select * from ELA where NAME LIKE '%SCHOOL' and NAME not like '%DISTRICT'
             AND BEDSCODE <> 1")
sch_race <- sqldf("select NRC_CODE
                    ,NRC_DESC
                    ,COUNTY_DESC
                    ,BEDSCODE
                    ,NAME
                    ,ITEM_SUBJECT_AREA
                    ,ITEM_DESC
                    ,SUBGROUP_CODE
                    ,SUBGROUP_NAME
                    ,TOTAL_TESTED
                    ,L1_COUNT, L2_COUNT, L3_COUNT, L4_COUNT, MEAN_SCALE_SCORE
                    ,CASE WHEN SUBGROUP_CODE = 4 THEN 1 ELSE 0 END AS AMERICAN_INDIAN
                    ,CASE WHEN SUBGROUP_CODE = 5 THEN 1 ELSE 0 END AS BLACK_AMERICAN
                    ,CASE WHEN SUBGROUP_CODE = 6 THEN 1 ELSE 0 END AS LATINO
                    ,CASE WHEN SUBGROUP_CODE = 7 THEN 1 ELSE 0 END AS ASIAN
                    ,CASE WHEN SUBGROUP_CODE = 6 THEN 1 ELSE 0 END AS WHITE
                    ,CASE WHEN SUBGROUP_CODE = 6 THEN 1 ELSE 0 END AS MULTIRIACIAL
                  FROM sch_all where SUBGROUP_CODE in (4,5,6,7,8,9) ")

#grouping examples

##########################################################################################
################## Race breakdown PIE
##########################################################################################

RACE_DF <- sqldf("SELECT SUBGROUP_NAME, SUM(TOTAL_TESTED) from STATE_ELA 
                   where SUBGROUP_CODE = 4 or SUBGROUP_CODE = 5 or SUBGROUP_CODE = 6 or 
                   SUBGROUP_CODE = 7 or SUBGROUP_CODE = 8 or SUBGROUP_CODE = 9 
                   GROUP BY SUBGROUP_NAME 
                   ORDER BY SUM(TOTAL_TESTED)")

colnames(RACE_DF) <- c('SUBGROUP_NAME', 'TOTAL')

ggplot(RACE_DF, aes(x="", y=TOTAL, fill=SUBGROUP_NAME)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) +
  scale_fill_brewer(palette="Dark2")

##########################################################################################
################## Homes breakdown PIE
##########################################################################################

HOMES_DF <- sqldf("SELECT SUBGROUP_NAME, SUM(TOTAL_TESTED) from STATE_ELA 
                   where SUBGROUP_CODE = 15 or SUBGROUP_CODE = 16 or SUBGROUP_CODE = 20 or 
                   SUBGROUP_CODE = 21 
                   GROUP BY SUBGROUP_NAME 
                   ORDER BY SUM(TOTAL_TESTED)")

colnames(HOMES_DF) <- c('SUBGROUP_NAME', 'TOTAL')

options(scipen=10000)

ggplot(HOMES_DF, aes(x="", y=TOTAL, fill=SUBGROUP_NAME)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start=0) +
  scale_fill_brewer(palette="Dark2") 

##########################################################################################
################## ELA Mean Scale Score by County
##########################################################################################

#create a df based off of a selection from the main dataset
COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'ELA'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')

#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = rev(heat.colors(50))) +
  geom_path() +
  coord_map() + ggtitle('ELA Mean Scale Score by County')

##########################################################################################
################## Mathematics Mean Scale Score by County
##########################################################################################

#create a df based off of a selection from the main dataset
COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'Mathematics'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')

#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = cm.colors(50)) +
  geom_path() +
  coord_map() + ggtitle('Mathematics Mean Scale Score by County')


##########################################################################################
################## Male vs Female Math
##########################################################################################

#create a df based off of a selection from the main dataset
COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 2 AND ITEM_SUBJECT_AREA like 'Mathematics'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')

#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
f <- ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = cm.colors(50)) +
  geom_path() +
  coord_map() + ggtitle('Female Mathematics Mean Scale Score by County')

#---------------#

#create a df based off of a selection from the main dataset
COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 3 AND ITEM_SUBJECT_AREA like 'Mathematics'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')

#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
m <- ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = cm.colors(50)) +
  geom_path() +
  coord_map() + ggtitle('Male Mathematics Mean Scale Score by County')

grid.arrange(f,m, ncol = 2)


##########################################################################################
################## Male vs Female ELA
##########################################################################################

#create a df based off of a selection from the main dataset
COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 2 AND ITEM_SUBJECT_AREA like 'ELA'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')


#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
f <- ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = rev(heat.colors(50))) +
  geom_path() +
  coord_map() + ggtitle('Female ELA Mean Scale Score by County')

#---------------#

COUNTY_SUM_DF <- sqldf("SELECT NAME, SUBGROUP_NAME, TOTAL_TESTED, MEAN_SCALE_SCORE 
                 from COUNTY_ELA 
                 WHERE SUBGROUP_CODE is 3 AND ITEM_SUBJECT_AREA like 'ELA'
                 GROUP BY NAME
                 ORDER BY NAME")

COUNTY_SUM_DF <- data.frame(tolower(str_remove(COUNTY_SUM_DF$NAME, ' COUNTY')), 
                            COUNTY_SUM_DF$SUBGROUP_NAME, COUNTY_SUM_DF$TOTAL_TESTED, as.numeric(COUNTY_SUM_DF$MEAN_SCALE_SCORE))

colnames(COUNTY_SUM_DF) <- c('name', 'subgroup', 'total', 'mean_scale_score')


#create map
ny <- map_data('county', 'new york')
COUNTY_SUM_DF_MAP <- merge(ny, COUNTY_SUM_DF, by.x = 'subregion', by.y = 'name', all.x = TRUE, all.y = FALSE, sort = FALSE)
COUNTY_SUM_DF_MAP <- COUNTY_SUM_DF_MAP[order(COUNTY_SUM_DF_MAP$order),]


#create map with data
m <- ggplot(COUNTY_SUM_DF_MAP, aes(x=long,y=lat,group=group)) + 
  geom_polygon(aes(fill=mean_scale_score))+
  scale_fill_gradientn(colours = rev(heat.colors(50))) +
  geom_path() +
  coord_map() + ggtitle('Male ELA Mean Scale Score by County')


grid.arrange(f,m,ncol = 2)

##########################################################################################
################## Needs Mean Score Barplot
##########################################################################################

#create a df based off of a selection from the main dataset
NRC_NEEDS_MATH <- sqldf("SELECT NRC_DESC, ITEM_SUBJECT_AREA, MEAN_SCALE_SCORE 
                        from NRC_NEEDS_ELA
                        WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'Mathematics'
                        GROUP BY NRC_CODE")

#create a df based off of a selection from the main dataset
NRC_NEEDS_ELA_S <- sqldf("SELECT NRC_DESC, ITEM_SUBJECT_AREA, MEAN_SCALE_SCORE 
                          from NRC_NEEDS_ELA
                          WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'ELA'
                          GROUP BY NRC_CODE")

NEEDS_SUMMARY <- rbind(NRC_NEEDS_ELA_S, NRC_NEEDS_MATH)

NEEDS_SUMMARY <- data.frame(paste(NEEDS_SUMMARY$NRC_DESC, NEEDS_SUMMARY$ITEM_SUBJECT_AREA),
                            as.numeric(NEEDS_SUMMARY$MEAN_SCALE_SCORE), NEEDS_SUMMARY$NRC_DESC, NEEDS_SUMMARY$ITEM_SUBJECT_AREA)

colnames(NEEDS_SUMMARY) <- c('Desc', 'Score', 'Category', 'Subject')

order_nrc <- c('Urban-Suburban High Needs', 'Rural High Needs', 'Average Needs','Low Needs')

NEEDS_SUMMARY$Category <- factor(NEEDS_SUMMARY$Category, levels = order_nrc)

ggplot(NEEDS_SUMMARY, aes(x = Category, y = Score, fill = Subject)) +
  geom_bar(stat = 'identity', position=position_dodge()) +
  coord_cartesian(ylim = c(590,610)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle('Mean Score By Needs Category')

##########################################################################################
################## Grades Summary Mean Score Barplot
##########################################################################################

#create a df based off of a selection from the main dataset
STATE_G_MATH <- sqldf("SELECT ITEM_DESC, ITEM_SUBJECT_AREA, MEAN_SCALE_SCORE 
                        from STATE_ELA
                        WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'Mathematics'
                        GROUP BY ITEM_DESC")

#create a df based off of a selection from the main dataset
STATE_G_ELA <- sqldf("SELECT ITEM_DESC, ITEM_SUBJECT_AREA, MEAN_SCALE_SCORE 
                          from STATE_ELA
                          WHERE SUBGROUP_CODE is 1 AND ITEM_SUBJECT_AREA like 'ELA'
                          GROUP BY ITEM_DESC")

GRADES_SUMMARY <- rbind(STATE_G_ELA, STATE_G_MATH)

GRADES_SUMMARY <- data.frame(GRADES_SUMMARY$ITEM_DESC, GRADES_SUMMARY$ITEM_SUBJECT_AREA, 
                             as.numeric(GRADES_SUMMARY$MEAN_SCALE_SCORE))

colnames(GRADES_SUMMARY) <- c('Desc', 'Subject', 'Score')

ggplot(GRADES_SUMMARY, aes(x = Desc, y = Score, fill = Subject)) +
  geom_bar(stat = 'identity', position=position_dodge()) +
  coord_cartesian(ylim = c(590,610)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle('Mean Score By Grade Level Category')


##########################################################################################
################## Boxplots
##########################################################################################

# English Test
sch_race_eng <- sch_race[sch_race$ITEM_SUBJECT_AREA=="ELA",] # English
# boxplot Mean scale test score by NRC
ggplot(sch_race_eng, aes(x=NRC_DESC, y=MEAN_SCALE_SCORE, color=NRC_DESC))+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4,notch=TRUE)+
  labs(title="English Test: Mean Scale Score by Need Resource Capacity Categories",x="Need Resource Capacity", y = "Mean Scale Test Score")+ 
  theme_classic()

ggplot(sch_race_eng, aes(x=SUBGROUP_NAME, y=MEAN_SCALE_SCORE, color=SUBGROUP_NAME))+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4,notch=TRUE)+
  labs(title="English Test: Mean Scale Score by Race",x="Race", y = "Mean Scale Test Score")+ 
  theme_classic()


# English Test
sch_race_math <- sch_race[sch_race$ITEM_SUBJECT_AREA=="Mathematics",] # Mathematics

# boxplot Mean scale test score by NRC
ggplot(sch_race_math, aes(x=NRC_DESC, y=MEAN_SCALE_SCORE, color=NRC_DESC))+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4,notch=TRUE)+
  labs(title="Mathematics Test: Mean Scale Score by Need Resource Capacity Categories",x="Need Resource Capacity", y = "Mean Scale Test Score")+ 
  theme_classic()

ggplot(sch_race_math, aes(x=SUBGROUP_NAME, y=MEAN_SCALE_SCORE, color=SUBGROUP_NAME))+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4,notch=TRUE)+
  labs(title="Mathematics Test: Mean Scale Score by Race",x="Race", y = "Mean Scale Test Score")+ 
  theme_classic()
##########################################################################################
################## Modeling and Machine Learning
##########################################################################################

# 3. Preliminary Data Viz School level data - Race counts.
ggplot(sch_race, aes(x=MEAN_SCALE_SCORE))+
  geom_histogram(aes(y=..density..),fill="lightblue")+
  geom_density(alpha=.2,fill="blue")


# sch_race_1 <- sch_race[,11:15]
# Facet wrap for the Test level count and mean Scale score for subject and all grade
ggplot(data = melt(sch_race[,10:15]), mapping = aes(x = value)) +
  geom_histogram(bins = 20, fill="lightblue",color="red") + 
  facet_wrap(~variable, scales = 'free_x')

# subsetting by subject
# 1 English Test
sch_race_eng <- sch_race[sch_race$ITEM_SUBJECT_AREA=="ELA",] # English

ggplot(data = melt(sch_race_eng[,11:15]), mapping = aes(x = value)) + 
  geom_histogram(bins = 20, fill="lightblue", color="red") + 
  facet_wrap(~variable, scales = 'free_x')


#clean the nas out of df
sch_race_eng <- sch_race_eng[,-c(3)]
sch_race_eng <- na.omit(sch_race_eng)

# building linear regression model to predict mean scale score for english across all 3 : 8
# testing for collinearity
R_cor_eng <- cor(sch_race_eng[, c( "L1_COUNT",
                                   "L2_COUNT", "L3_COUNT", "L4_COUNT","MEAN_SCALE_SCORE")], use = "complete")
R_cor_eng
# there is collinearity between all vasriables except L2_count
# linear regression
linearm <- lm(MEAN_SCALE_SCORE~L2_COUNT + L1_COUNT + L3_COUNT + L4_COUNT , data=sch_race_eng)
summary(linearm)
sch_race_eng$Pred <- linearm$fitted.values
sch_race_eng$Resid <- linearm$residuals
plot(linearm)

# building maching learning model using RandomForest to predict mean scale score for english across all grades 3:8
sch_race_eng_1 <-sch_race_eng[,11:15] 
#  Train classifer (clf)
eng_1 <- randomForest(sch_race_eng_1[,-5],sch_race_eng_1[,5])
eng_1
#  Iterate
eng_1a <- randomForest(sch_race_eng_1[,-5],as.factor(sch_race_eng_1[,5]))
eng_1a


num_exmps = nrow(sch_race_eng_1)
L = replace(integer(num_exmps), sch_race_eng_1[,5]>=600, 1)
M <- sch_race_eng_1[,-5]

#Use Cross validation to build model
train_eng <- sample(c(1:num_exmps), size = num_exmps * 0.7, replace = FALSE)
eng_3 <- randomForest(M[train_eng,],as.factor(L[train_eng]))
#Generate propsoed answers using Cross validation
pred <- predict(eng_3, M[-train_eng,],type="prob")

#9. Plot ROC metric
plot(roc(L[-train_eng], as.numeric(pred[,1])))

# Build neural networt model


# neuralnetwork model
# eng_neutral <- neuralnet(MEAN_SCALE_SCORE ~ L1_COUNT + L2_COUNT + L3_COUNT  + L4_COUNT, 
#                        sch_race_eng_1, hidden =3, lifesign = "minimal", linear.output = FALSE, act.fct = "logistic",threshold = 0.1)
randIndex	<- sample(1:nrow(sch_race_eng_1))
head(randIndex)
nr<- nrow(sch_race_eng_1)
nr
eng_12_3	<- floor(2*nr/3)
eng_12_3

trainMSS <-sch_race_eng_1[randIndex[1:eng_12_3],]
testMSS <-sch_race_eng_1[randIndex[(eng_12_3+1):nr],]


eng_neutral <- neuralnet(MEAN_SCALE_SCORE ~ L1_COUNT + L2_COUNT + L3_COUNT  + L4_COUNT, 
                         trainMSS, hidden =5, lifesign = "minimal", linear.output = FALSE,threshold = 0.1)
summary(eng_neutral)
plot(eng_neutral)

pred <- compute(eng_neutral,testMSS)
head(pred$net.result)
summary(pred)
pred

