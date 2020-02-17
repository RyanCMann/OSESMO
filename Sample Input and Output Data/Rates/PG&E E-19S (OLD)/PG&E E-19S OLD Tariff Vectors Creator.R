#### Script Description Header ####

# File Name: PG&E E-19S OLD Tariff Vectors Creator.R
# File Location: "GHG Signal Working Group/Rates/PG&E E-19S (OLD)"
# Project: CPUC SGIP GHG Working Group
# Description: Converts PG&E E-19S OLD rate into time-series vectors for use in OSESMO's cost and constraint matrices.

#### User Inputs ####

# This script generates a time-series vector for the user's choice of year.
# This value must be input by the user to match the desired year to be modeled.

Data_Year <- 2017

Data_Timestep_Length = 15 # Timestep length, in minutes

#### Load Packages

# When you first begin using R, packages must be installed. This process only needs to be performed once.

# install.packages("tidyverse")
# install.packages("readr")
# install.packages("openxlsx")

# Packages must be loaded to the library every time you open up RStudio.

library(tidyverse)
library(readr)
library(openxlsx)

# Disable Scientific Notation

options(scipen = 999)

#### Define Working Directories ####

# Set working directory to project directory or source file location manually using Session -> Set Working Directory before running these

Code_WD <- getwd()
Clean_Rate_Data_WD <- file.path(Code_WD, Data_Year)

#### Load  & Clean Load Interval Data from Excel File ####

Start_Date_Time <- as.POSIXct(paste0(Data_Year, "-01-01 00:00:00"), tz = "America/Los_Angeles")
End_Date_Time <- as.POSIXct(paste0(Data_Year, "-12-31 23:55:00"), tz = "America/Los_Angeles")

PGE_E19S_OLD_Cost_Vectors.df <- data.frame(Date_Time = seq.POSIXt(Start_Date_Time, End_Date_Time, by = paste(Data_Timestep_Length, "min")))


#### Create Vectors for Energy and Demand Charges ####

# Values are for PG&E E-19, Secondary Voltage, in US $.

Summer_Peak_Rate = 0.15178
Summer_Partial_Peak_Rate = 0.11127
Summer_Off_Peak_Rate = 0.08445

Winter_Partial_Peak_Rate = 0.10573
Winter_Off_Peak_Rate = 0.09111

# Note: Power factor charges are not included in this analysis. 
# Bills are assumed to be monthly, and fall at the end of every month, so there are no months that fall into both winter and summer periods.

# Create Summer vs. Winter Binary, Weekday/Weekend Binary, and Decimal Hour Variables

# Holidays for 2011-2018

New_Years_Day <- c("2011-01-01", "2012-01-01", "2013-01-01", "2014-01-01", "2015-01-01", "2016-01-01", "2017-01-01", "2018-01-01")
Presidents_Day <- c("2011-02-21", "2012-02-20", "2013-02-18", "2014-02-17", "2015-02-16", "2016-02-15", "2017-02-20", "2018-02-19")
Memorial_Day <- c("2011-05-30", "2012-05-28", "2013-05-27", "2014-05-26", "2015-05-25", "2016-05-30", "2017-05-29", "2018-05-28")
Independence_Day <- c("2011-07-04", "2012-07-04", "2013-07-04", "2014-07-04", "2015-07-04", "2016-07-04", "2017-07-04", "2018-07-04")
Labor_Day <- c("2011-09-05", "2012-09-03", "2013-09-02", "2014-09-01", "2015-09-07", "2016-09-05", "2017-09-04", "2018-09-03")
Veterans_Day <- c("2011-11-11", "2012-11-11", "2013-11-11", "2014-11-11", "2015-11-11", "2016-11-11", "2017-11-11", "2018-11-11")
Thanksgiving_Day <- c("2011-11-24", "2012-11-22", "2013-11-28", "2014-11-27", "2015-11-26", "2016-11-24", "2017-11-23", "2018-11-28")
Christmas_Day <- c("2011-12-25", "2012-12-25", "2013-12-25", "2014-12-25", "2015-12-25", "2016-12-25", "2017-12-25", "2018-12-25")

Holidays_List <- as.Date(c(New_Years_Day, Presidents_Day, Memorial_Day, Independence_Day, Labor_Day, Veterans_Day, Thanksgiving_Day, Christmas_Day), tz = "America/Los_Angeles")

# Add Nearest Weekdays as Holidays
# If holiday falls on a Sunday, include the following Monday as an observed holiday.
# https://www.pge.com/tariffs/toudates.shtml

for(Holiday_Iter in seq_along(Holidays_List)){
  
  if(weekdays(Holidays_List[Holiday_Iter]) == "Sunday"){
    
    Holidays_List = c(Holidays_List, Holidays_List[Holiday_Iter] + 1)
    
  }
  
}

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Month = as.numeric(format(Date_Time, "%m"))) %>%
  mutate(Season = ifelse(as.numeric(format(Date_Time, "%m")) %in% c(5:10), "Summer", "Winter")) %>% # Dates between May 1 and October 31 are considered "Summer"
  mutate(Weekday_Weekend_Holiday = ifelse(weekdays(Date_Time) %in% c("Saturday", "Sunday") |
                                            as.Date(Date_Time, tz = "America/Los_Angeles") %in% Holidays_List, "Weekend/Holiday", "Weekday")) %>% # Monday-Friday = Weekday, Saturday & Sunday = Weekend
  mutate(Hour_Decimal = as.numeric(format(Date_Time, "%H")) + as.numeric(format(Date_Time, "%M"))/60) # ex. 8:30 am = 8.5


# Summer Peak

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Summer_Peak_Binary = ifelse(Season == "Summer" & 
                                     Weekday_Weekend_Holiday == "Weekday" & 
                                     Hour_Decimal >= 12 & Hour_Decimal < (12+6), 1, 0)) # Summer Peak = May-October, Monday-Friday, 12:00 noon-6:00 pm

# Summer Partial-Peak

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Summer_Partial_Peak_Binary = ifelse(Season == "Summer" & 
                                       Weekday_Weekend_Holiday == "Weekday" & 
                                       ((Hour_Decimal >= 8.5 & Hour_Decimal < (12)) |
                                       (Hour_Decimal >= (12 + 6) & Hour_Decimal < (12 + 9.5))), 1, 0)) # Summer Partial Peak = weekdays, 8:30 am to 12:00 noon, 6:00 pm to 9:30 pm

# Summer Off-Peak

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Summer_Off_Peak_Binary = ifelse(Season == "Summer" &
                                           Summer_Peak_Binary == 0 &
                                           Summer_Partial_Peak_Binary == 0, 1, 0)) # Summer Off Peak = 9:30 pm to 8:30 am on weekdays, all day on weekends
# In other words, if it's summer and not peak or partial peak, it's off-peak.


# Winter Partial-Peak

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Winter_Partial_Peak_Binary = ifelse(Season == "Winter" & 
                                               Weekday_Weekend_Holiday == "Weekday" & 
                                               (Hour_Decimal >= 8.5 & Hour_Decimal < (12 + 9.5)), 1, 0)) # Winter Partial Peak = weekdays, 8:30 am to 9:30 pm

# Winter Off-Peak

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Winter_Off_Peak_Binary = ifelse(Season == "Winter" &
                                           Winter_Partial_Peak_Binary == 0, 1, 0)) # Winter Off Peak = 9:30 pm to 8:30 am on weekdays, all day on weekends
# In other words, if it's winter and not partial peak, it's off-peak.


# PG&E Daylight Savings Time Adjustment - Shift Time Period Definitions back 1 Hour in March/April and October/November

# In PG&E Schedule E-19, the peak/partial-peak/off-period time definitions do not shift in sync with Daylight Savings Time.
# As a result, they must be adjusted back by one hour during the time period "between the second Sunday in march and the first Sunday in April,
# and for the period between the last Sunday in October and the first Sunday in November."

# Note: the second date in each sequence is the day before the First Sunday in April/November. 
# In the case of 2015, the day before the first Sunday in November (Sunday, November 1) is Saturday, October 31.

March_April_DST_Adjustment_Period_2015 <- seq.Date(as.Date("2015-03-08", tz = "America/Los_Angeles"), as.Date("2015-04-05", tz = "America/Los_Angeles"), by = "1 day")

March_April_DST_Adjustment_Period_2016 <- seq.Date(as.Date("2016-03-13", tz = "America/Los_Angeles"), as.Date("2016-04-02", tz = "America/Los_Angeles"), by = "1 day")

March_April_DST_Adjustment_Period_2017 <- seq.Date(as.Date("2017-03-12", tz = "America/Los_Angeles"), as.Date("2017-04-01", tz = "America/Los_Angeles"), by = "1 day")

October_November_DST_Adjustment_Period_2015 <- seq.Date(as.Date("2015-10-25", tz = "America/Los_Angeles"), as.Date("2015-10-31", tz = "America/Los_Angeles"), by = "1 day")

October_November_DST_Adjustment_Period_2016 <- seq.Date(as.Date("2016-10-30", tz = "America/Los_Angeles"), as.Date("2016-11-05", tz = "America/Los_Angeles"), by = "1 day")

October_November_DST_Adjustment_Period_2017 <- seq.Date(as.Date("2017-10-29", tz = "America/Los_Angeles"), as.Date("2017-11-04", tz = "America/Los_Angeles"), by = "1 day")

DST_Adjustment_Period_Dates <- c(March_April_DST_Adjustment_Period_2015, March_April_DST_Adjustment_Period_2016, March_April_DST_Adjustment_Period_2017,
                                 October_November_DST_Adjustment_Period_2015, October_November_DST_Adjustment_Period_2016, October_November_DST_Adjustment_Period_2017)


# Shift All Binary Period Flags Back by 1 Hour

# Number of timesteps in 1 hour = (60 minutes/Data_Timestep_Length)
PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(DST_Adjustment_Flag = ifelse(as.Date(Date_Time, tz = "America/Los_Angeles") %in% DST_Adjustment_Period_Dates, 1, 0)) %>%
  mutate(Summer_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Peak_Binary)) %>% 
  mutate(Summer_Partial_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Partial_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Partial_Peak_Binary)) %>% 
  mutate(Summer_Off_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Off_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Off_Peak_Binary)) %>% 
  mutate(Winter_Partial_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Winter_Partial_Peak_Binary, n = (60/Data_Timestep_Length)), Winter_Partial_Peak_Binary)) %>% 
  mutate(Winter_Off_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Winter_Off_Peak_Binary, n = (60/Data_Timestep_Length)), Winter_Off_Peak_Binary))


# Check that all timesteps are accounted for, and that no timestep has a value of 1 in multiple columns

PGE_E19S_OLD_Cost_Vector_Check.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Check_Sum = Summer_Peak_Binary + Summer_Partial_Peak_Binary + Summer_Off_Peak_Binary + Winter_Partial_Peak_Binary + Winter_Off_Peak_Binary) %>%
  filter(Check_Sum != 1)
# This dataframe should be empty (0 observations).

rm(PGE_E19S_OLD_Cost_Vector_Check.df)


#### Energy Rates ####

PGE_E19S_OLD_Cost_Vectors.df <- PGE_E19S_OLD_Cost_Vectors.df %>%
  mutate(Energy_Rates = (Summer_Peak_Binary * Summer_Peak_Rate) + 
           (Summer_Partial_Peak_Binary * Summer_Partial_Peak_Rate) +
           (Summer_Off_Peak_Binary * Summer_Off_Peak_Rate) +
           (Winter_Partial_Peak_Binary * Winter_Partial_Peak_Rate) +
           (Winter_Off_Peak_Binary * Winter_Off_Peak_Rate))


#### Export Rate Data as CSV Outputs ####

# All data
write.csv(PGE_E19S_OLD_Cost_Vectors.df, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Dataframe Format", paste0(Data_Year, "_PGE_E19S_OLD_Cost_Dataframe.csv")), row.names = FALSE)

# Month Value Column Only
write.table(PGE_E19S_OLD_Cost_Vectors.df$Month, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_E19S_OLD_Month_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Summer Peak Binary Variable Column Only
write.table(PGE_E19S_OLD_Cost_Vectors.df$Summer_Peak_Binary, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_E19S_OLD_Summer_Peak_Binary_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Summer Partial-Peak Binary Variable Column Only
write.table(PGE_E19S_OLD_Cost_Vectors.df$Summer_Partial_Peak_Binary, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_E19S_OLD_Summer_Partial_Peak_Binary_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Winter Partial-Peak Binary Variable Column Only
write.table(PGE_E19S_OLD_Cost_Vectors.df$Winter_Partial_Peak_Binary, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_E19S_OLD_Winter_Partial_Peak_Binary_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Energy Rates Variable Column
write.table(PGE_E19S_OLD_Cost_Vectors.df$Energy_Rates, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_E19S_OLD_Energy_Rates_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')