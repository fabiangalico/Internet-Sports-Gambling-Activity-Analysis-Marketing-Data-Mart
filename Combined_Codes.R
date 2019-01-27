####################################################################################################
# It takes about 7-10 mins to run this code, final result "Basetable_All" has 42649 obs, 163 variables
####################################################################################################


#import packages
if (!require("haven")) install.packages("haven"); library(haven)
if (!require("dplyr")) install.packages("dplyr");library(dplyr)
if (!require("tidyverse")) install.packages("tidyverse");library(tidyverse)
if (!require("lubridate")) install.packages("lubridate");library(lubridate)


#import tables 1 and 4 and merge them
demographics <- read_sas("RawDataIDemographics.sas7bdat")
analytic <- read_sas("AnalyticDataInternetGambling.sas7bdat")
analytic1 <- analytic[,-c(2,3,4,6)]
names(analytic1)[1] <- 'UserID'
names(analytic1)[2] <- 'Age'

basetable <- merge(x = demographics, y = analytic1, by = "UserID", all.x = TRUE)


#import and group poker table, creating new variables like mean, min and max amount
poker <- read_sas("RawDataIIIPokerChipConversions.sas7bdat")
str(poker)

poker$TransDateTime <- as.numeric(as.Date(as.character(poker$TransDateTime)))

poker1 <- poker %>% group_by(UserID) %>% summarise(Prod3_FirstDate = min(TransDateTime), 
                Prod3_LastDate = max(TransDateTime), Prod3_TotalDays = (Prod3_LastDate - Prod3_FirstDate))

poker2 <- poker %>% group_by(UserID) %>% filter(TransType == 124) %>%
  summarise(Buy_Prod3_Mean = mean(TransAmount), Buy_Prod3_Max = max(TransAmount),
            Buy_Prod3_Min = min(TransAmount), Buy_Prod3_Total = sum(TransAmount), Buy_Prod3_Count = n())

poker3 <- poker %>% group_by(UserID) %>% filter(TransType == 24) %>%
  summarise(Sell_Prod3_Mean = mean(TransAmount), Sell_Prod3_Max = max(TransAmount),
            Sell_Prod3_Min = min(TransAmount), Sell_Prod3_Total = sum(TransAmount), Sell_Prod3_Count = n())

Poker_All <- left_join(poker1, poker2, by='UserID') %>% left_join(., poker3, by='UserID')

Poker_All[ , 2:3] <- lapply(Poker_All[ , 2:3], as.Date)

# Change the table name to reflect the product type
prod3t<-Poker_All

####################################################################################################
# # aggregate by products (1-8), except product 3, it will be combined and the last stage.


# Read in the SAS data
UserAgg<-read_sas("RawDataIIUserDailyAggregation.sas7bdat")

# filter each product ID to separate dataframe, store in a filtered_list
filtered_list <- list()
for (i in seq(1:8)){
  filtered_list[[i]]<- UserAgg %>% filter(ProductID == i)
}

# define fuction to aggregate the data into one observation per UserID
trasform_func<-function(ProdNumber, prefix_name) {
  
  ProdNumber$Date<-sapply(ProdNumber$Date,as.numeric)
  
  Agg_Sum <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at(c("Stakes", "Winnings","Bets"),sum, na.rm = TRUE)%>% 
    rename_at(vars(c("Stakes", "Winnings","Bets")), ~ c("sum_Stakes", "sum_Winnings","sum_Bets"))
  
  Agg_min <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at(c("Stakes", "Winnings","Bets"),min, na.rm = TRUE)%>% 
    rename_at(vars(c("Stakes", "Winnings","Bets")), ~ c("min_Stakes", "min_Winnings","min_Bets"))
  
  Agg_max <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at(c("Stakes", "Winnings","Bets"),max, na.rm = TRUE)%>% 
    rename_at(vars(c("Stakes", "Winnings","Bets")), ~ c("max_Stakes", "max_Winnings","max_Bets"))
  
  Agg_mean <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at(c("Stakes", "Winnings","Bets"),mean, na.rm = TRUE)%>% 
    rename_at(vars(c("Stakes", "Winnings","Bets")), ~ c("mean_Stakes", "mean_Winnings","mean_Bets"))
  
  Agg_count <- ProdNumber %>% group_by(UserID)%>% 
    summarise(count = n())%>% 
    rename_at(vars("count"), ~"Freq")
  
  Agg_Date_max <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at("Date",max, na.rm = TRUE)%>% 
    rename_at(vars("Date"), ~"Last_date_played")
  
  Agg_Date_min <- ProdNumber %>% group_by(UserID)%>% 
    summarise_at(("Date"),min, na.rm = TRUE)%>% 
    rename_at(vars("Date"), ~"First_date_played")
  
  
  ProdNumber_All <- left_join(Agg_Sum, Agg_min, by='UserID') %>%
    left_join(., Agg_max, by='UserID')%>%
    left_join(., Agg_mean, by='UserID') %>%
    left_join(., Agg_count, by='UserID')%>%
    left_join(., Agg_Date_max, by='UserID')%>%
    left_join(., Agg_Date_min, by='UserID')
  
  # change data type from char to date format
  ProdNumber_All$Last_date_played<-sapply(ProdNumber_All$Last_date_played,ymd)
  ProdNumber_All$First_date_played<-sapply(ProdNumber_All$First_date_played,ymd)
  
  # Caculate date different as TotalDaysActive
  ProdNumber_All$TotalDaysActive <-  ProdNumber_All$Last_date_played - ProdNumber_All$First_date_played
  
  # Caculate TotalGainLoss
  ProdNumber_All$TotalGainLoss <-  ProdNumber_All$sum_Winnings - ProdNumber_All$sum_Stakes
  
  names(ProdNumber_All) = paste0(prefix_name,"_", names(ProdNumber_All))
  
  print(prefix_name)
  
  return(ProdNumber_All)
}

# time the processing time
start_time <- Sys.time()
# loop for each product ID, store in transformed_list
transformed_list <- list()
for (i in seq(1:8)){
  # check if there is any empty table (prod 3)
  if (nrow(filtered_list[[i]])>0){
    transformed_list[[i]]<- trasform_func(filtered_list[[i]],paste0('Prod',i))
  }else {
    print(paste0("empty table at product # ", i))
    next}
  end_time <- Sys.time()
  print(end_time - start_time)
}

# remove prod 3 from the list before feeding the list to function below
prod3_rem_transformed_list<-transformed_list
prod3_rem_transformed_list[[3]]<- NULL

####################################################################################################
# rename UserID colname for all dataframe
df_list <- c(list(basetable), list(prod3t),prod3_rem_transformed_list)
renameFunction<-function(x){
  names(x)[1] <- 'UserID'
  return(x)
}
df_list <- lapply(df_list, renameFunction) 

# create final basetable
Basetable_All<- df_list %>%  Reduce(function(dtf1,dtf2) left_join(dtf1,dtf2,by="UserID"), .)

# Read in the SAS data
Appendix2_Countries<-read_sas("Appendix2_Countries.sas7bdat")
Appendix3_Language<-read_sas("Appendix3_Language.sas7bdat")
Appendix4_ApplicationsID<-read_sas("Appendix4_ApplicationsID.sas7bdat")

# Change country numbers to meaningful text
Basetable_All$Country <-as.integer (Basetable_All$Country)
Appendix2_Countries$Country <-as.integer (Appendix2_Countries$Country)
Basetable_All <- left_join(Basetable_All, Appendix2_Countries, by='Country')

# Change Language numbers to meaningful text
Basetable_All$Language <-as.integer (Basetable_All$Language)
Appendix3_Language$Language <-as.integer (Appendix3_Language$Language)
Basetable_All <- left_join(Basetable_All, Appendix3_Language, by='Language')

# Change ApplicationID numbers to meaningful text
Basetable_All$ApplicationID <-as.integer (Basetable_All$ApplicationID)
Appendix4_ApplicationsID$ApplicationID <-as.integer(Appendix4_ApplicationsID$ApplicationID)
Basetable_All <- left_join(Basetable_All, Appendix4_ApplicationsID, by='ApplicationID')

# Create Age_Range Column
basetable$Age_Range <- paste0((basetable$Age%/%10)*10,"-",((basetable$Age%/%10)+1)*10)

# Create Gender Label Column
Basetable_All$Gender_Label <- ifelse(Basetable_All$Gender == 1, "Male", "Female")


# Export the Basetable
write_sas(Basetable_All, "Group11_Basetable.sas7bdat")
save(Basetable_All,file="Group11_Basetable.Rdata")

