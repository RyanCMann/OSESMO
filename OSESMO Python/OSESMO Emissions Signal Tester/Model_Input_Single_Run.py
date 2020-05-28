## Script Description Header

# File Name: Model_Inputs_Single_Run.m
# File Location: "OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Allows user to define model inputs for a single model run.

## Model Inputs - Setup Parameters and Run Options
import datetime as dt
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

# OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = '/Users/Ryan/Library/Mobile Documents/com~apple~CloudDocs/Ryan\'s Stuff/2018/OSESMO/OSESMO Python'

# Import/Output Data Directory Location
Input_Output_Data_Directory_Location = '/Users/Ryan/Library/Mobile Documents/com~apple~CloudDocs/Ryan\'s Stuff/2018/OSESMO/Sample Input and Output Data'

# Show/Export Plots and Data Toggles

Show_Plots = True

Export_Plots = False

Export_Data = False

## Model Inputs - Model Data

# Modeling Team Name
# Name of the company or organization performing modeling.
Modeling_Team_Input = "OSESMO"

# Model Run Number
# Used by modelers to uniquely identify their own model runs.
Model_Run_Number_Input = 1

# Model Timestep Resolution
# Model timestep resolution, in minutes.
Model_Timestep_Resolution = 15


## Model Input - Storage Hardware Data

# Storage Type
# Storage system type (Lithium-Ion Battery, or Flow Battery).
Storage_Type_Input = "Lithium-Ion Battery"

# Storage Power Rating
# Nameplate storage system charge/discharge power rating (kW).
Storage_Power_Rating_Input = 500

# Usable Storage Capacity
# Usable storage energy capacity (kWh). Report usable capacity (accounting for depth of discharge), and not nameplate capacity.
Usable_Storage_Capacity_Input = 1000

# Single-Cycle RTE
# Single-cycle (or nameplate) storage round-trip efficiency (50%, 70%, or 85%).
Single_Cycle_RTE_Input = 0.85

# Parasitic Load
# Parasitic storage load, as a percentage of Storage Power Rating.
# Assumed to be 0.3%.
Parasitic_Storage_Load_Input = 0.003


# Emissions Forecast Signal
# Marginal emissions rate forecast signal sent to the energy storage system for it to optimize on.

Emissions_Forecast_Signal_Name_Input = "NP15 Real Time 5 Minute Emissions Signal"
Emissions_Forecast_Signal_Input = "Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv"

# Emissions Impact Evaluation Signal
# Marginal emissions rate signal used to evaluate emissions impact.
Emissions_Evaluation_Signal_Input = "Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv"


## Non-Reported Model Inputs

# These model inputs are not reported, as they are not common to all models.

# Start Time - Used in Plots
Start_Time_Input = dt.datetime(2017,1,1,0,0)  #2017-01-01 00:00


# State of Charge at Beginning and End of Year
# Initial and final state of charge of the battery at the beginning and end
# of the year.
Initial_Final_SOC = 0.3

# Model Time Padding
# Days of padding added to the end of each month to improve accuracy
# of simulation results given by optimization algorithm.
End_of_Month_Padding_Days = 3


## Run Storage Model

from OSESMO_EST import OSESMO_EST

OSESMO_EST(Modeling_Team_Input, Model_Run_Number_Input,
    Model_Timestep_Resolution,
    Storage_Type_Input, Storage_Power_Rating_Input, Usable_Storage_Capacity_Input,
    Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input,
    Emissions_Forecast_Signal_Name_Input, Emissions_Forecast_Signal_Input,
    Emissions_Evaluation_Signal_Input,
    OSESMO_Git_Repo_Directory, Input_Output_Data_Directory_Location, Start_Time_Input,
    Show_Plots, Export_Plots, Export_Data,
    Initial_Final_SOC, End_of_Month_Padding_Days)