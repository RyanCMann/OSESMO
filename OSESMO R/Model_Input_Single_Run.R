## Script Description Header

# File Name: OSESMO_Inputs_Single_Run_Option_S.m
# File Location: "~/Desktop/OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Allows user to define model inputs for a single model run.

## Model Inputs - Setup Parameters and Run Options
library(tidyverse)
options(scipen = 999) # Disable scientific notation.

# Set working directory to source file location.

# OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = getwd()

# Import/Output Data Directory Location
setwd(file.path("..", "Sample Input and Output Data"))
Input_Output_Data_Directory_Location = getwd()
setwd(OSESMO_Git_Repo_Directory)

# Show/Export Plots and Data Toggles

Show_Plots = 1 # 0 == Don't show plots, 1 == show plots

Export_Plots = 1 # 0 = Don't export plots, 1 = export plots

Export_Data = 1 # 0 = Don't export data, 1 = export data


## Model Inputs - Model Data

# Modeling Team Name
# Name of the company or organization performing modeling.
Modeling_Team_Input = "OSESMO"

# Model Run Number
# Used by modelers to uniquely identify their own model runs.
Model_Run_Number_Input = 1

# Model Type
# "Storage Only" or "Solar Plus Storage"
Model_Type_Input = "Solar Plus Storage"

# Model Timestep Resolution
# Model timestep resolution, in minutes.
Model_Timestep_Resolution = 60


## Model Inputs - Load & Rate Data

# Customer Class
# "Residential" or "Commercial and Industrial"
Customer_Class_Input = "Residential"

# Load Profile Name
# Name of the selected customer load profile.
Load_Profile_Name_Input = "PG&E GreenButton Central Valley Residential Non-CARE"

# Retail Rate Name
# Name of the selected retail rate.
Retail_Rate_Name_Input = "PG&E EV2 (NEW)"

# Export Compensation Rate Name
# Name of the selected export compensation rate.
Export_Compensation_Rate_Name_Input <- "PG&E EV2 (NEW) NEM 2"


## Model Input - Solar Data

# Solar Profile Name
# Name of selected solar production profile.
Solar_Profile_Name_Input = "CSI PG&E Residential"

# Solar Size kW
# Nameplate power rating of the solar PV system (kW-DC).
Solar_Size_Input = 10.8


## Model Input - Storage Hardware Data

# Storage Power Rating
# Nameplate storage system charge/discharge power rating (kW-AC).
Storage_Power_Rating_Input = 5

# Usable Storage Capacity
# Nameplate storage energy capacity (kWh-AC).
Storage_Energy_Capacity_Input = 13.5

# Single-Cycle RTE
# Single-cycle (or nameplate) storage round-trip efficiency (50%, 70%, or 85%).
Single_Cycle_RTE_Input = 0.85

## Model Input - Storage Control Algorithm Parameters

# ITC Constraint
# Is energy storage system taking the Incentive Tax Credit, and charging exclusively from solar photovoltaic system?
ITC_Constraint_Input = TRUE

# Site Export
# The maximum allowed amount of site export, in kW. If Inf, unlimited export allowed. If 0 kW, no export allowed, if negative, minimum import required.
Site_Export = Inf

# ESS Export
# If TRUE, the ESS is allowed to export to the grid.
# If FALSE, the ESS is not allowed to export to the grid.
ESS_Export = TRUE

# Carbon Adder Incentive Value - Used for GHG Signal Co-Optimization Only
Carbon_Adder_Incentive_Value_Input = 0 # Value of carbon adder, in $ per metric ton.


# Greenhouse Gas Emissions Rate Data:
# Marginal emissions rate forecast, available for both NP15 (Northern California congestion zone)
# and SP15 (Southern California congestion zone).
#  * No Emissions Forecast Signal
#  * Real Time 5 Minute Emissions Signal "RT5M"
Emissions_Signal_Input = "NP15 RT5M"


## Non-Reported Model Inputs

# These model inputs are not reported, as they are not common to all models.

# Start Time - Used in Plots
Start_Time_Input = as.POSIXct("2017-01-01 00:00", tz = "America/Los_Angeles")

# Solar Installed Cost per kW
# Taken from LBNL's Tracking the Sun 10 report, Tables B-2 and B-3 (pgs. 50 & 51) 
source("Solar_Installed_Cost_per_kW_Calculator.R")
Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input)


# Storage Installed Cost per kWh
# Used values from Lazard's Levelized Cost of Storage report (2017), pg. 19
# https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
source("Storage_Installed_Cost_per_kWh_Calculator.R")
Storage_Installed_Cost_per_kWh = Storage_Installed_Cost_per_kWh_Calculator(Customer_Class_Input, Storage_Type_Input = "Lithium-Ion Battery")

# Estimated Future Lithium-Ion Battery Installed Cost per kWh
# Used to calculate cycling penalty for lithium-ion batteries.
Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh = 100

# Storage Cycle Lifetime
# Assumed daily cycling over lifetime given in Lazard report, pg. 14.
# 10 years for lithium-ion batteries , 20 years for flow batteries.
Cycle_Life = 10 * 365.25

# State of Charge at Beginning and End of Year
# Initial and final state of charge of the battery at the beginning and end
# of the year.
Initial_Final_SOC = 0.5

# Model Time Padding
# Days of padding added to the end of each month to improve accuracy
# of simulation results given by optimization algorithm.
End_of_Month_Padding_Days = 3


## Run Storage Model
source("OSESMO.R")
OSESMO(Modeling_Team_Input, Model_Run_Number_Input, Model_Type_Input,
       Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Name_Input,
       Retail_Rate_Name_Input, Export_Compensation_Rate_Name_Input,
       Solar_Profile_Name_Input, Solar_Size_Input,
       Storage_Power_Rating_Input, Storage_Energy_Capacity_Input,
       Single_Cycle_RTE_Input,
       ITC_Constraint_Input, Site_Export, ESS_Export,
       Carbon_Adder_Incentive_Value_Input, Emissions_Signal_Input,
       OSESMO_Git_Repo_Directory, Input_Output_Data_Directory_Location, Start_Time_Input,
       Show_Plots, Export_Plots, Export_Data,
       Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh,
       Cycle_Life, Initial_Final_SOC, End_of_Month_Padding_Days)