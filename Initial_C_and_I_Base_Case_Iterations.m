%% Script Description Header

% File Name: Initial_C_and_I_Base_Case_Iterations.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Iterates thorugh all base-case commercial and industrial model runs.

clear;
clc;

%% Set Directory to Box Sync Folder

% OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = '/Users/ryanden/Desktop/OSESMO Git Repository/OSESMO';

% Box Sync Directory Location
Box_Sync_Directory_Location = '/Users/ryanden/Box Sync/GHG Signal Working Group';

cd(Box_Sync_Directory_Location)

%% Load Customer Load Data

C1_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Avalon Anonymized Commercial & Industrial/2017 Remapped/15-Minute Data/' ...
    'Vector Format/Clean_Vector_2017_East_Bay_Light_Industrial.csv']);

C6_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Stem C&I Load Profiles/15-Minute Data/' ...
    'Vector Format/5_SDGE_G-16_Manufacturing_7_Vector.csv']);

C10_Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
    'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/Los Angeles Industrial/' ...
    'Vector Format/Clean_Vector_2017_Los_Angeles_Industrial.csv']);

PGE_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv']);

SCE_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv']);

SDGE_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv']);

cd(OSESMO_Git_Repo_Directory)


%% Solar PV System Size Inputs for C1, C6, and C10

% Residential storage systems are sized to meet 80% of annual electricity
% consumption, as are small commercial systems. Medium and large commercial
% and industrial PV systems are sized to meet 40% of annual electricity
% consumption.

C1_Total_Annual_Consumption = sum(C1_Load_Profile_Data) * (15/60);
PGE_Solar_PV_Total_Annual_Consumption = sum(PGE_Solar_PV_Profile_Data) * (15/60);
C1_Solar_Size_Input = 100 * (0.40/(PGE_Solar_PV_Total_Annual_Consumption/C1_Total_Annual_Consumption));

C6_Total_Annual_Consumption = sum(C6_Load_Profile_Data) * (15/60);
SDGE_Solar_PV_Total_Annual_Consumption = sum(SDGE_Solar_PV_Profile_Data) * (15/60);
C6_Solar_Size_Input = 100 * (0.40/(SDGE_Solar_PV_Total_Annual_Consumption/C6_Total_Annual_Consumption));

C10_Total_Annual_Consumption = sum(C10_Load_Profile_Data) * (15/60);
SCE_Solar_PV_Total_Annual_Consumption = sum(SCE_Solar_PV_Profile_Data) * (15/60);
C10_Solar_Size_Input = 100 * (0.40/(SCE_Solar_PV_Total_Annual_Consumption/C10_Total_Annual_Consumption));


%% Storage System Size Inputs for C1, C6, and C10

% This sizing approach is inspired by an approach used by NREL in its paper
% "Optimal sizing of energy storage and photovoltaic power systems for
% demand charge mitigation, except using fractions of maximum power rating instead
% of fractions of maximum energy capacity.
% https://www.nrel.gov/docs/fy14osti/60291.pdf

% C1 (Avalon East Bay Light Industrial) Load Profile Summary Statistics
C1_Maximum_Demand = max(C1_Load_Profile_Data);
C1_Average_Demand = mean(C1_Load_Profile_Data);

% C6 (Stem SDG&E G-16 Manufacturing) Load Profile Summary Statistics
C6_Maximum_Demand = max(C6_Load_Profile_Data);
C6_Average_Demand = mean(C6_Load_Profile_Data);

% C10 (EnerNOC Los Angeles Industrial) Load Profile Summary Statistics
C10_Maximum_Demand = max(C10_Load_Profile_Data);
C10_Average_Demand = mean(C10_Load_Profile_Data);

% Create Set of 4 Storage Sizes (kW) between 0 kW and (Max-Average)
% Round size values to the nearest multiple of 50 kW.
% Add 30 kW (a common small SGIP storage size) as the smallest size.
% All batteries are 2-hour batteries - most common SGIP duration.

C1_Storage_Power_Rating_Iter_Raw = linspace(0, C1_Maximum_Demand-C1_Average_Demand, 5);
C1_Storage_Power_Rating_Iter_Rounded = round(C1_Storage_Power_Rating_Iter_Raw/50) * 50;
C1_Storage_Power_Rating_Iter = C1_Storage_Power_Rating_Iter_Rounded;
C1_Storage_Power_Rating_Iter(1) = 30;
%C1_Usable_Storage_Capacity_Iter = C1_Storage_Power_Rating_Iter * 2;
% C1_Storage_Power_Rating_Iter = [30, 100, 200, 300, 400];
% C1_Usable_Storage_Capacity_Iter = [60, 200, 400, 600, 800];

C6_Storage_Power_Rating_Iter_Raw = linspace(0, C6_Maximum_Demand-C6_Average_Demand, 5);
C6_Storage_Power_Rating_Iter_Rounded = round(C6_Storage_Power_Rating_Iter_Raw/50) * 50;
C6_Storage_Power_Rating_Iter = C6_Storage_Power_Rating_Iter_Rounded;
C6_Storage_Power_Rating_Iter(1) = 30;
%C6_Usable_Storage_Capacity_Iter = C6_Storage_Power_Rating_Iter * 2;
% C6_Storage_Power_Rating_Iter = [30, 100, 200, 300, 400];
% C6_Usable_Storage_Capacity_Iter = [60, 200, 400, 600, 800];

C10_Storage_Power_Rating_Iter_Raw = linspace(0, C10_Maximum_Demand-C10_Average_Demand, 5);
C10_Storage_Power_Rating_Iter_Rounded = round(C10_Storage_Power_Rating_Iter_Raw/50) * 50;
C10_Storage_Power_Rating_Iter = C10_Storage_Power_Rating_Iter_Rounded;
C10_Storage_Power_Rating_Iter(1) = 30;
%C10_Usable_Storage_Capacity_Iter = C10_Storage_Power_Rating_Iter * 2;
% C10_Storage_Power_Rating_Iter = [30, 200, 450, 650, 850];
% C10_Usable_Storage_Capacity_Iter = [60, 400, 900, 1350, 1700];

%% Fixed Model Inputs

Modeling_Team_Input = "Enel EnerNOC/SGIP Working Group";

Model_Run_Number_Input = 0; % Initialize value, gets updated every model run.

Model_Timestep_Resolution = 15;

Customer_Class_Input = "Commercial and Industrial";

Parasitic_Storage_Load_Input = 0.003;

Storage_Control_Algorithm_Name = "OSESMO Economic Dispatch";

GHG_Reduction_Solution_Input = "No GHG Reduction Solution";

Equivalent_Cycling_Constraint_Input = 0;

Annual_RTE_Constraint_Input = 0;

Carbon_Adder_Incentive_Value_Input = 0;

Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal";

Start_Time_Input = datetime("2017-01-01 00:00:00");

Show_Plots = 0; % 0 == Don"t show plots, 1 == show plots

Export_Plots = 1; % 0 = Don"t export plots, 1 = export plots

Export_Data = 1; % 0 = Don"t export data, 1 = export data

Padding_Days = 3;

%% Model Input Iteration

Model_Type_Input_Iter = ["Storage Only", "Solar Plus Storage"];

for Model_Type_Input = Model_Type_Input_Iter
    
    Load_Profile_Name_Input_Iter = ["Avalon GreenButton East Bay Light Industrial", ...
        "Stem GreenButton SDG&E G-16 Manufacturing", ...
        "EnerNOC GreenButton Los Angeles Industrial"];
    
    for Load_Profile_Name_Input = Load_Profile_Name_Input_Iter
        
        if Model_Type_Input == "Storage Only"
            
            Solar_Profile_Name_Input = "No Solar";
            
            Solar_Size_Input = 0;
            
            ITC_Constraint_Input = 0;
            
            Solar_Installed_Cost_per_kW = 0;
            
        elseif Model_Type_Input == "Solar Plus Storage"
            
            ITC_Constraint_Input = 1;
            
            if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial"
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input = C1_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing"
                
                Solar_Profile_Name_Input = "CSI SDG&E Commercial & Industrial";
                
                Solar_Size_Input = C6_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial"
                
                Solar_Profile_Name_Input = "CSI SCE Commercial & Industrial";
                
                Solar_Size_Input = C10_Solar_Size_Input;
                
            end
            
            % Solar Cost per kW - Call Solar_Installed_Cost_per_kW Function
            Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input);
            
        end
        
        if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial"
            
            Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)", "PG&E E-19S (OLD)", ...
                "PG&E E-19S PDP (NEW)", "PG&E E-19S PDP (OLD)", ...
                "PG&E A-1-STORAGE (NEW)", "PG&E A-6 (OLD)", "PG&E A-6 PDP (OLD)"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "PG&E E-19S-R (NEW)", "PG&E E-19S-R (OLD)"];
            end
            
        elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing"
            Retail_Rate_Name_Input_Iter = ["SDG&E AL-TOU (NEW)", "SDG&E AL-TOU (OLD)", ...
                "SDG&E AL-TOU-CP2 (NEW)", "SDG&E AL-TOU-CP2 (OLD)"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SDG&E DG-R"];
            end
            
        elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial"
            Retail_Rate_Name_Input_Iter = ["SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SCE TOU-8-R"];
            end
            
        end
        
        for Retail_Rate_Name_Input = Retail_Rate_Name_Input_Iter
            
            Storage_Type_Input_Iter = ["Lithium-Ion Battery", "Flow Battery"];
            
            for Storage_Type_Input = Storage_Type_Input_Iter
                
                if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial"
                    Storage_Power_Rating_Input_Iter = C1_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing"
                    Storage_Power_Rating_Input_Iter = C6_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial"
                    Storage_Power_Rating_Input_Iter = C10_Storage_Power_Rating_Iter;
                end
                
                for Storage_Power_Rating_Input = Storage_Power_Rating_Input_Iter
                    
                    if Storage_Type_Input == "Lithium-Ion Battery"
                        Usable_Storage_Capacity_Input = Storage_Power_Rating_Input * 2; % Most common SGIP duration for lithium-ion.
                        Single_Cycle_RTE_Input_Iter = [0.7, 0.85];
                    elseif Storage_Type_Input == "Flow Battery"
                        Usable_Storage_Capacity_Input = Storage_Power_Rating_Input * 3; % Flow batteries typically have longer duration.
                        Single_Cycle_RTE_Input_Iter = 0.7;
                    end
                    
                    for Single_Cycle_RTE_Input = Single_Cycle_RTE_Input_Iter
                        
                        % Storage Cost per kWh - Call Storage_Installed_Cost_per_kWh Function
                        Storage_Installed_Cost_per_kWh = Storage_Installed_Cost_per_kWh_Calculator(Customer_Class_Input, Storage_Type_Input);
                        
                        % Storage Cycle Lifetime
                        if Storage_Type_Input == "Lithium-Ion Battery"
                            Cycle_Life = 10 * 365.25;
                        elseif Storage_Type_Input == "Flow Battery"
                            Cycle_Life = 20 * 365.25;
                        end
                        
                        % Storage Depth of Discharge
                        if Storage_Type_Input == "Lithium-Ion Battery"
                            Storage_Depth_of_Discharge = 0.8;
                        elseif Storage_Type_Input == "Flow Battery"
                            Storage_Depth_of_Discharge = 1;
                        end
                        
                        % Run Model, Increase Model Run Number Counter
                        
                        Model_Run_Number_Input = Model_Run_Number_Input + 1;
                        
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
                            Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, ...
                            Cycle_Life, Storage_Depth_of_Discharge, Initial_Final_SOC, End_of_Month_Padding_Days)
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end