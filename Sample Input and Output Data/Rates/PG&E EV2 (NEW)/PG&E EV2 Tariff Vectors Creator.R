#### Script Description Header ####

# File Name: PG&E EV2 Tariff Vectors Creator.R
# File Location: "GHG Signal Working Group/Rates/PG&E EV2"
# Project: CPUC SGIP GHG Working Group
# Description: Converts PG&E EV2 rate into time-series vectors for use in OSESMO's cost and constraint matrices.

#### User Inputs ####

# This script generates a time-series vector for the user's choice of year.
# This value must be input by the user to match the desired year to be modeled.

Data_Year <- 2017

Data_Timestep_Length = 60 # Timestep length, in minutes

#### Load Packages

# When you first begin using R, packages must be installed. This process only needs to be performed once.

# install.packages("tidyverse")
# install.packages("readr")
# install.packages("openxlsx")

# Packages must be loaded to the library every time you open up RStudio.

library(tidyverse)
library(readr)
library(openxlsx)
library(lubridate)

# Disable Scientific Notation

options(scipen = 999)

#### Define Working Directories ####

# Set working directory to project directory or source file location manually using Session -> Set Working Directory before running these

Code_WD <- getwd()
Clean_Rate_Data_WD <- file.path(Code_WD, Data_Year)

#### Load  & Clean Load Interval Data from Excel File ####

Start_Date_Time <- as.POSIXct(paste0(Data_Year, "-01-01 00:00:00"), tz = "America/Los_Angeles")
End_Date_Time <- as.POSIXct(paste0(Data_Year, "-12-31 23:55:00"), tz = "America/Los_Angeles")

PGE_EV2_Cost_Vectors.df <- data.frame(Date_Time = seq.POSIXt(Start_Date_Time, End_Date_Time, by = paste(Data_Timestep_Length, "min")))


#### Create Vectors for Energy and Demand Charges ####

# Values are for PG&E EV2, in US $.

Summer_Peak_Rate = 0.49616
Summer_Partial_Peak_Rate = 0.38567
Summer_Off_Peak_Rate = 0.18366

Winter_Peak_Rate = 0.36905
Winter_Partial_Peak_Rate = 0.35235
Winter_Off_Peak_Rate = 0.18366

# Note: Power factor charges are not included in this analysis. 
# Bills are assumed to be monthly, and fall at the end of every month, so there are no months that fall into both winter and summer periods.

# Create Summer vs. Winter Binary and Decimal Hour Variables

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Month = month(Date_Time)) %>%
  mutate(Day = day(Date_Time)) %>%
  mutate(Season = ifelse(Month %in% c(6:9), "Summer", "Winter")) %>% # Dates between June 1 and September 30 are considered "Summer"
  mutate(Hour_Decimal = hour(Date_Time) + minute(Date_Time)/60) # ex. 8:30 am = 8.5


# Summer Peak
# Summer Peak = June-September, 4:00 pm-9:00 pm

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Summer_Peak_Binary = ifelse(Season == "Summer" & 
                                     Hour_Decimal >= (12+4) & Hour_Decimal < (12+9), 1, 0))

# Summer Partial-Peak
# Summer Partial Peak = 3:00 pm to 4:00 pm, 9:00 pm to 12:00 am

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Summer_Partial_Peak_Binary = ifelse(Season == "Summer" & 
                                               ((Hour_Decimal >= (12+3) & Hour_Decimal < (12+4)) |
                                                  (Hour_Decimal >= (12 + 9) & Hour_Decimal < (12 + 12))), 1, 0))

# Summer Off-Peak
# Summer Off Peak = 12:00 am to 3:00 pm
# In other words, if it's summer and not peak or partial peak, it's off-peak.

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Summer_Off_Peak_Binary = ifelse(Season == "Summer" &
                                           Summer_Peak_Binary == 0 &
                                           Summer_Partial_Peak_Binary == 0, 1, 0))

# Winter Peak
# Winter Peak = October-May, 4:00 pm-9:00 pm

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Winter_Peak_Binary = ifelse(Season == "Winter" & 
                                       Hour_Decimal >= (12+4) & Hour_Decimal < (12+9), 1, 0))

# Winter Partial-Peak
# Winter Partial Peak = 3:00 pm to 4:00 pm, 9:00 pm to 12:00 am

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Winter_Partial_Peak_Binary = ifelse(Season == "Winter" & 
                                               ((Hour_Decimal >= (12+3) & Hour_Decimal < (12+4)) |
                                                  (Hour_Decimal >= (12 + 9) & Hour_Decimal < (12 + 12))), 1, 0))

# Winter Off-Peak
# Winter Off Peak = 12:00 am to 3:00 pm
# In other words, if it's winter and not peak or partial peak, it's off-peak.

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Winter_Off_Peak_Binary = ifelse(Season == "Winter" &
                                           Winter_Peak_Binary == 0 &
                                           Winter_Partial_Peak_Binary == 0, 1, 0))


# PG&E Daylight Savings Time Adjustment - Shift Time Period Definitions back 1 Hour in March/April and October/November

# In PG&E Schedule EV2, the peak/partial-peak/off-period time definitions do not shift in sync with Daylight Savings Time.
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
PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(DST_Adjustment_Flag = ifelse(as.Date(Date_Time, tz = "America/Los_Angeles") %in% DST_Adjustment_Period_Dates, 1, 0)) %>%
  mutate(Summer_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Peak_Binary)) %>% 
  mutate(Summer_Partial_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Partial_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Partial_Peak_Binary)) %>% 
  mutate(Summer_Off_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Summer_Off_Peak_Binary, n = (60/Data_Timestep_Length)), Summer_Off_Peak_Binary)) %>% 
  mutate(Winter_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Winter_Peak_Binary, n = (60/Data_Timestep_Length)), Winter_Peak_Binary)) %>% 
  mutate(Winter_Partial_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Winter_Partial_Peak_Binary, n = (60/Data_Timestep_Length)), Winter_Partial_Peak_Binary)) %>% 
  mutate(Winter_Off_Peak_Binary = ifelse(DST_Adjustment_Flag ==1, lag(Winter_Off_Peak_Binary, n = (60/Data_Timestep_Length)), Winter_Off_Peak_Binary))


# Check that all timesteps are accounted for, and that no timestep has a value of 1 in multiple columns

PGE_EV2_Cost_Vector_Check.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Check_Sum = Summer_Peak_Binary + Summer_Partial_Peak_Binary + Summer_Off_Peak_Binary + 
           Winter_Peak_Binary + Winter_Partial_Peak_Binary + Winter_Off_Peak_Binary) %>%
  filter(Check_Sum != 1)
# This dataframe should be empty (0 observations).

rm(PGE_EV2_Cost_Vector_Check.df)


#### Energy Rates ####

PGE_EV2_Cost_Vectors.df <- PGE_EV2_Cost_Vectors.df %>%
  mutate(Energy_Rates = (Summer_Peak_Binary * Summer_Peak_Rate) + 
           (Summer_Partial_Peak_Binary * Summer_Partial_Peak_Rate) +
           (Summer_Off_Peak_Binary * Summer_Off_Peak_Rate) +
           (Winter_Peak_Binary * Winter_Peak_Rate) + 
           (Winter_Partial_Peak_Binary * Winter_Partial_Peak_Rate) +
           (Winter_Off_Peak_Binary * Winter_Off_Peak_Rate))


#### Export Rate Data as CSV Outputs ####

# All data
write.csv(PGE_EV2_Cost_Vectors.df, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Dataframe Format", paste0(Data_Year, "_PGE_EV2_Cost_Dataframe.csv")), row.names = FALSE)

# Month Value Column Only
write.table(PGE_EV2_Cost_Vectors.df$Month, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_EV2_Month_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Day Value Column Only
write.table(PGE_EV2_Cost_Vectors.df$Day, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_EV2_Day_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')

# Energy Rates Variable Column
write.table(PGE_EV2_Cost_Vectors.df$Energy_Rates, file.path(Clean_Rate_Data_WD, paste0(Data_Timestep_Length, "-Minute Data"), "Vector Format", paste0(Data_Year, "_PGE_EV2_Energy_Rates_Vector.csv")), 
            row.names = FALSE, col.names = FALSE, sep = ',')