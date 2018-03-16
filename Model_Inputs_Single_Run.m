%% Script Description Header

% File Name: OSESMO_Inputs_Single_Run.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Allows user to define model inputs for a single model run.

clear;
clc;


%% Model Inputs - Model Data

% Modeling Team Name
% Name of the company or organization performing modeling.
Modeling_Team_Input = "Enel EnerNOC/SGIP Working Group";

% Model Run Number
% Used by modelers to uniquely identify their own model runs.
Model_Run_Number_Input = 1;

% Model Type
% Storage Only or Solar Plus Storage
Model_Type_Input = "Solar Plus Storage";

% Model Timestep Resolution
% Model timestep resolution, in minutes.
Model_Timestep_Resolution = 15;


%% Model Inputs - Load & Rate Data

% Customer Class
% Customer class/building type (Residential, or Commercial and Industrial).
Customer_Class_Input = "Residential";

% Load Profile Name
% Name of the selected customer load profile.
Load_Profile_Name_Input = "PG&E GreenButton Central Valley Residential CARE";

% Retail Rate Name
% Name of the selected retail rate.
Retail_Rate_Name_Input = "PG&E EV-A (NEW)";


%% Model Input - Solar Data

% Solar Profile Name
% Name of selected solar production profile.
Solar_Profile_Name_Input = "CSI PG&E Residential";

% Solar Size kW
% Nameplate power rating of the solar PV system (kW-DC).
Solar_Size_Input = 10;


%% Model Input - Storage Hardware Data

% Storage Type
% Storage system type (Lithium-Ion Battery, or Flow Battery).
Storage_Type_Input = "Lithium-Ion Battery";

% Storage Power Rating
% Nameplate storage system charge/discharge power rating (kW).
Storage_Power_Rating_Input = 5;

% Usable Storage Capacity
% Usable storage energy capacity (kWh). Report usable capacity (accounting for depth of discharge), and not nameplate capacity.
Usable_Storage_Capacity_Input = 13.5;

% Single-Cycle RTE
% Single-cycle (or nameplate) storage round-trip efficiency (50%, 70%, or 85%).
Single_Cycle_RTE_Input = 0.85;

% Parasitic Load
% Parasitic storage load, as a percentage of Storage Power Rating.
% Assumed to be 0.03%.
Parasitic_Storage_Load_Input = 0.003;

%% Model Input - Storage Control Algorithm Parameters & GHG Reduction Solutions

% Storage Control Algorithms:
%
%  * "OSESMO Economic Dispatch" - a linear-program-based optimal control
%  strategy where the battery is dispatched so as to minimize the customer bill
%  savings while avoiding excessive battery cycling, and can co-optimize
%  for GHG reductions as well.
%
%  * "OSESMO Non-Economic Solar Self-Supply" - intended for customers on a
%  flat/tiered rate with solar plus storage, where there is no economic
%  incentive for the battery to dispatch. This dispatch mode adds
%  additional cost terms (P_PV(t) - P_ES_in(t)) to be minimized, which
%  represent all power produced by the PV system that is not stored in the
%  battery. The battery will still respond to economic signals when in this
%  mode (such as a tiered rate with SmartRate critical peak pricing), but
%  is not guaranteed to effectively reduce customer bills when in this mode.
%  The cycling penalty is also set to $0/equivalent cycle in this mode.

% Storage Control Algorithm Name
Storage_Control_Algorithm_Name = "OSESMO Economic Dispatch";

% GHG Reduction Solutions Reduction Strategies:
%
%  * "No GHG Reduction Solution" - Carbon price is set to $0/metric ton,
%    battery is dispatched purely to maximize customer bill savings.
%
%  * "GHG Signal Co-Optimization" - Carbon price is set to a nonzero value,
%    and the of battery is dispatched to co-optimize for both bill savings and
%    GHG reduction. Potential carbon price values include:
%        * $1/metric ton - arbitrarily low nonzero number
%        * $15/metric ton - current auction price
%        * $65/metric ton - current APCR price
%
%  * "No-Charging Time Constraint" - following a subset of PG&E"s
%    recommendation, charging cannot occur between 4:00 pm and 9:00 pm.
%    Carbon price is set to $0/metric ton.
%
%  * "Charging and Discharging Time Constraints" - following PG&E"s
%    recommendation, at least 50% of charging must occur between
%    9:00 am and 2:00 pm, and at least 50% of discharging must occur
%    between 4:00 pm and 9:00 pm. Charging cannot occur between 4:00 pm and 9:00 pm.
%    Carbon price is set to $0/metric ton.

%  * "IOU-Proposed Charge-Discharge Time Constraints" - following the Joint
%    IOU recommendation, at least 50% of charging must occur between
%    12:00 pm and 4:00 pm, and at least 50% of discharging must occur
%    between 4:00 pm and 9:00 pm. Carbon price is set to $0/metric ton.
%
%  * "Non-Positive GHG Constraint" - model is constrained to prevent
%    positive emissions. Note that due to the model structure, this
%    constraint is applied on a monthly basis. Carbon price is set to $0/metric ton.

GHG_Reduction_Solution_Input = "No GHG Reduction Solution";


% Equivalent Cycling Constraint
% Equivalent Cycling Constraint: must perform at least 0, 52, 130, or 260 cycles per year.
% Note that due to the model structure, this constraint is applied on a monthly basis.
Equivalent_Cycling_Constraint_Input = 0;


% Annual RTE Constraint
% Annual RTE Constraint: must exceed 0% or 69.6% annual round-trip efficiency (also known as SGIP or Operational RTE.)
% Note that due to the model structure, this constraint is applied on a monthly basis.
Annual_RTE_Constraint_Input = 0;


% ITC Constraint
% Is storage system taking the Incentive Tax Credit, and performing 100% solar self-consumption?
ITC_Constraint_Input = 1;


% Carbon Adder Incentive Value - Used for GHG Signal Co-Optimization Only
Carbon_Adder_Incentive_Value_Input = 0; % Value of carbon adder, in $ per metric ton.
% Carbon_Adder_Incentive_Value_Input = 15; % Value of carbon adder, in $ per metric ton.


% Emissions Forecast Signal:
% Marginal emissions rate forecast, available for both NP15 (Northern California congestion zone)
% and SP15 (Southern California congestion zone).
%  * No Emissions Forecast Signal
%  * Real Time 5 Minute Emissions Signal "RT5M"
%  * WattTime Open Source Model Midnight-Before Forecasted Emissions Signal "DA WattTime"
%  * Day Ahead Market Forecasted Emissions Signal "DAM"

Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal";


%% Non-Reported Model Inputs

% These model inputs are not reported, as they are not common to all models.

% OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = '/Users/ryanden/Desktop/OSESMO Git Repository/OSESMO';

% Box Sync Directory Location
Box_Sync_Directory_Location = '/Users/ryanden/Box Sync/GHG Signal Working Group';

% Start Time - Used in Plots
Start_Time_Input = datetime("2017-01-01 00:00:00");

% Show/Export Plots and Data Toggles

Show_Plots = 0; % 0 == Don't show plots, 1 == show plots

Export_Plots = 1; % 0 = Don't export plots, 1 = export plots

Export_Data = 1; % 0 = Don't export data, 1 = export data


% Solar Installed Cost per kW
% Taken from LBNL's Tracking the Sun 10 report, Tables B-2 and B-3 (pgs. 50 & 51) 

Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input);


% Storage Installed Cost per kWh
% Used values from Lazard's Levelized Cost of Storage report (2017), pg. 19
% https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
Storage_Installed_Cost_per_kWh = Storage_Installed_Cost_per_kWh_Calculator(Customer_Class_Input, Storage_Type_Input);

% Estimated Future Lithium-Ion Battery Installed Cost per kWh
% Used to calculate cycling penalty for lithium-ion batteries.
Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh = 100;

% Storage Cycle Lifetime
% Assumed daily cycling over lifetime given in Lazard report, pg. 14.
% 10 years for lithium-ion batteries , 20 years for flow batteries.

if Storage_Type_Input == "Lithium-Ion Battery"
    Cycle_Life = 10 * 365.25;
elseif Storage_Type_Input == "Flow Battery"
    Cycle_Life = 20 * 365.25;
end


% Storage Depth of Discharge
% Storage depth of discharge is the percentage of total battery capacity
% that is usable battery capacity. 80% for lithium-ion batteries, 100% for
% flow batteries. Used to calculate battery cost, whereas usable battery
% capacity is used as an input to operational simulation portion of model.

if Storage_Type_Input == "Lithium-Ion Battery"
    Storage_Depth_of_Discharge = 0.8;
elseif Storage_Type_Input == "Flow Battery"
    Storage_Depth_of_Discharge = 1;
end

% State of Charge at Beginning and End of Year
% Initial and final state of charge of the battery at the beginning and end
% of the year.
Initial_Final_SOC = 0.3;

% Model Time Padding
% Days of padding added to the end of each month to improve accuracy
% of simulation results given by optimization algorithm.
End_of_Month_Padding_Days = 3;


%% Run Storage Model

OSESMO(Modeling_Team_Input, Model_Run_Number_Input, Model_Type_Input, ...
    Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Name_Input, ...
    Retail_Rate_Name_Input, Solar_Profile_Name_Input, Solar_Size_Input, ...
    Storage_Type_Input, Storage_Power_Rating_Input, Usable_Storage_Capacity_Input, ...
    Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input, ...
    Storage_Control_Algorithm_Name, GHG_Reduction_Solution_Input, Equivalent_Cycling_Constraint_Input, ...
    Annual_RTE_Constraint_Input, ITC_Constraint_Input, ...
    Carbon_Adder_Incentive_Value_Input, Emissions_Forecast_Signal_Input, ...
    OSESMO_Git_Repo_Directory, Box_Sync_Directory_Location, Start_Time_Input, ...
    Show_Plots, Export_Plots, Export_Data, ...
    Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh, ...
    Cycle_Life, Storage_Depth_of_Discharge, Initial_Final_SOC, End_of_Month_Padding_Days)