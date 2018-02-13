%% Script Description Header

% File Name: OSESMO_Inputs_and_Iteration.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Allows user to define model inputs, or iterate through a
% number of inputs.

clear;
clc;


%% User-Defined Inputs

% OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = '/Users/ryanden/Desktop/OSESMO Git Repository/OSESMO';

% Box Sync Directory Location
Box_Sync_Directory_Location = '/Users/ryanden/Box Sync/GHG Signal Working Group';

% System Type - Storage Only or Solar + Storage
System_Type_Input = "Storage Only";

% Carbon Reduction Strategies:
%
%  * "No Carbon Co-Optimization" - Carbon price is set to $0/metric ton,
%    battery is dispatched purely to maximize customer bill savings.
%
%  * "Direct Carbon Co-Optimization" - Carbon price is set to a nonzero value,
%    and the of battery is dispatched to co-optimize for both bill savings and
%    GHG reduction. Potential carbon price values include:
%        * $1/metric ton - arbitrarily low nonzero number
%        * $15/metric ton - current auction price
%        * $65/metric ton - current APCR price
%
%  * "IOU-Proposed Charge-Discharge Time Constraints" - following the Joint
%    IOU recommendation, at least 50% of charging must occur between
%    12:00 pm and 4:00 pm, and at least 50% of discharging must occur
%    between 4:00 pm and 9:00 pm. Carbon price is set to $0/metric ton.
%
%  * "PG&E-Proposed Charge-Discharge Time Constraints" - following the Joint
%    IOU recommendation, at least 50% of charging must occur between
%    9:00 am and 2:00 pm, and at least 50% of discharging must occur
%    between 4:00 pm and 9:00 pm. Charging cannot occur between 4:00 pm and 9:00 pm.
%    Carbon price is set to $0/metric ton.
%
%  * "Non-Positive GHG Constraint" - model is constrained to prevent
%    positive emissions. Note that due to the model structure, this
%    constraint is applied on a monthly basis. Carbon price is set to $0/metric ton.
%
%  * "Equivalent Cycling Constraint" - model is constrained such that
%    storage system must perform greater than 52 (residential) or 130
%    (commercial & industrial) cycles. Note that due to the model structure,
%    this constraint is applied on a monthly basis. Carbon price is set to $0/metric ton.
%
%  * "SGIP RTE Constraint" - model is constrained such that storage system
%    must achieve a first year operational round-trip efficiency of 69.6%.
%    Note that due to the model structure, this constraint is applied on a monthly basis. 
%    Carbon price is set to $0/metric ton.

Carbon_Reduction_Strategy = "Direct Carbon Co-Optimization";

% Carbon Adder Value - Used for Direct Carbon Co-Optimization Only
Carbon_Adder_per_Metric_Ton_Input_Value = 15; % Value of carbon adder, in $ per metric ton.

% Set Carbon Adder to 0 if Carbon Reduction Strategy is not Direct Carbon
% Co-Optimization

if Carbon_Reduction_Strategy ~= "Direct Carbon Co-Optimization"
    
    Carbon_Adder_per_Metric_Ton_Input_Value = 0; % Value of carbon adder, in $ per metric ton.
    
end

% Marginal Emissions Signals:

% Signals are available in both NP15 (Northern California congestion zone)
% and SP15 (Southern California congestion zone) variants.

%  * Real Time 5 Minute Emissions Signal "RT5M Emissions Signal"
%  * Day Ahead Market Forecasted Emissions Signal "DAM Forecasted Emissions Signal"
%  * WattTime Open Source Model Midnight-Before Forecasted Emissions Signal "WattTime Public Forecasted Emissions Signal"

Carbon_Forecast_Signal_Input = "NP15 RT5M Emissions Signal";

Carbon_Impact_Evaluation_Signal_Input = "NP15 RT5M Emissions Signal";

Utility_Tariff_Input = "PG&E E-19S (NEW)";

Load_Profile_Input = "EnerNOC GreenButton San Francisco Office";

% Start Time - Used in Plots
Start_Time_Input = datetime("2017-01-01 00:00:00");

% Show/Export Plots and Data Toggles

Show_Plots = 0; % 0 == Don't show plots, 1 == show plots

Export_Plots = 0; % 0 = Don't export plots, 1 = export plots

Export_Data = 0; % 0 = Don't export data, 1 = export data

% Storage Parameters
% Based on public Tesla Powerpack inverter size, with 2-hour or 4-hour capacity.
% https://www.tesla.com/powerpack

P_ES_max = 250;  % Maximum charge/discharge rate, in kW

Size_ES = P_ES_max * 2;  % Size of storage system, in kWh

% Charge efficiency assumed to be square root of round-trip efficiency (Eff_c = Eff_d).
% Round-trip efficiency taken from Lazard's Levelized Cost of Storagereport (2017), pg. 130
% https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
Eff_c = sqrt(0.86);
%Eff_c = sqrt(0.75); 

% Discharge efficiency, assumed to be square root of round-trip efficiency (Eff_c = Eff_d).
Eff_d = sqrt(0.86);
%Eff_d = sqrt(0.75);

% Auxiliary load (parasitic losses due to electronics and HVAC) assumed to be 0.1% of inverter rating.
Auxiliary_Storage_Load = P_ES_max * 0.001;

% Took average value from range given in Lazard's Levelized Cost of Storage report (2017), pg. 14
% for Commercial & Industrial Lithium-Ion.
% https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
Installed_Cost_per_kWh = (643 + 720) / 2;

% Assumed 10-year expected useful life (as given in Lazard report, pg. 10) with daily cycling.
Cycle_Life = 10 * 365.25;

% Cycling penalty for battery, equal to cost divided by cycle life.
cycle_pen = (Size_ES * Installed_Cost_per_kWh) / Cycle_Life;

% Length of time step, in hours
delta_t = (15/60);

% Add 3 days of "padding" at the beginning and end of each month to improve accuracy
% of simulation behavior at beginning and end of month.
Padding_Days = 3;


%% Solar-Specific Inputs

% Solar Parameters

Size_PV = 100; % Size of PV array, in kW-DC

ITC_Constraint_Input = 0; % 1 means that the ITC solar charging constraint is applied, 0 means it does not apply.
                          % For instance, non-profits and municipal governments cannot claim the ITC.
                          
ITC_Solar_Charging_Target = 1; % Solar Charging Target Fraction - 0.75 = 75%, 1 = 100%
% The ITC "cliff" is at 75%, but the ITC is prorated. 
% 100% solar charging assumed to provide best system economics, although
% true optimum may actually be slighly below 100%.


%% Run Storage Model

switch System_Type_Input
    
    % Run Storage-Only Model
    case "Storage Only"
        
        OSESMO_Storage_Only_Model(OSESMO_Git_Repo_Directory, Box_Sync_Directory_Location, ...
            System_Type_Input, Carbon_Reduction_Strategy, Carbon_Adder_per_Metric_Ton_Input_Value, ...
            Carbon_Forecast_Signal_Input, Carbon_Impact_Evaluation_Signal_Input, ...
            Load_Profile_Input, Start_Time_Input, Utility_Tariff_Input, ...
            Show_Plots, Export_Plots, Export_Data, ...
            Size_ES, P_ES_max, Eff_c, Eff_d, Auxiliary_Storage_Load, ...
            Installed_Cost_per_kWh, cycle_pen, delta_t, Padding_Days)
        
    case "Solar Plus Storage"
        
        OSESMO_Solar_Plus_Storage_Model(OSESMO_Git_Repo_Directory, Box_Sync_Directory_Location, ...
            System_Type_Input, Carbon_Reduction_Strategy, Carbon_Adder_per_Metric_Ton_Input_Value, ...
            Carbon_Forecast_Signal_Input, Carbon_Impact_Evaluation_Signal_Input, ...
            Load_Profile_Input, Start_Time_Input, Utility_Tariff_Input, ...
            Show_Plots, Export_Plots, Export_Data, ...
            Size_ES, P_ES_max, Eff_c, Eff_d, Auxiliary_Storage_Load, ...
            Installed_Cost_per_kWh, cycle_pen, delta_t, Padding_Days, ...
            Size_PV, ITC_Constraint_Input, ITC_Solar_Charging_Target)
        
end