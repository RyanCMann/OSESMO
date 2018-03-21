%% Script Description Header

% File Name: C_and_I_Calibration_Case_Iterations.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Iterates thorugh all commercial and industrial model runs
% used for inter-model calibration and comparison.

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

C16_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
    'Vector Format/PG&E_GreenButton_A-10S_MLB_15_minute_Vector.csv']);

PGE_ComInd_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv']);

SCE_ComInd_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv']);

SDGE_ComInd_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv']);

cd(OSESMO_Git_Repo_Directory)


%% Solar PV System Size Inputs

% Residential storage systems are sized to meet 80% of annual electricity
% consumption, as are small commercial systems. Medium and large commercial
% and industrial PV systems are sized to meet 40% of annual electricity
% consumption.

% Avalon East Bay Light Industrial - mapped to PG&E C&I solar profile
C1_Total_Annual_Consumption = sum(C1_Load_Profile_Data) * (15/60);
PGE_ComInd_Solar_PV_Total_Annual_Consumption = sum(PGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C1_40_Percent_Offset_Solar_Size_Input = 100 * (0.40/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C1_Total_Annual_Consumption));
C1_80_Percent_Offset_Solar_Size_Input = 100 * (0.80/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C1_Total_Annual_Consumption));

% Stem SDG&E Manufacturing - mapped to SDG&E C&I solar profile
C6_Total_Annual_Consumption = sum(C6_Load_Profile_Data) * (15/60);
SDGE_Solar_PV_Total_Annual_Consumption = sum(SDGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C6_40_Percent_Offset_Solar_Size_Input = 100 * (0.40/(SDGE_Solar_PV_Total_Annual_Consumption/C6_Total_Annual_Consumption));
C6_80_Percent_Offset_Solar_Size_Input = 100 * (0.80/(SDGE_Solar_PV_Total_Annual_Consumption/C6_Total_Annual_Consumption));

% PG&E GreenButton A-10S MLB - mapped to PG&E C&I solar profile
C16_Total_Annual_Consumption = sum(C16_Load_Profile_Data) * (15/60);
PGE_ComInd_Solar_PV_Total_Annual_Consumption = sum(PGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C16_40_Percent_Offset_Solar_Size_Input = 100 * (0.40/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C16_Total_Annual_Consumption));
C16_80_Percent_Offset_Solar_Size_Input = 100 * (0.80/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C16_Total_Annual_Consumption));

%% Storage System Size Inputs

% C1 (Avalon East Bay Light Industrial) Storage Sizing
C1_Storage_Power_Rating_Iter = 90;

% C6 (Stem SDG&E G-16 Manufacturing) Storage Sizing Iteration
C6_Storage_Power_Rating_Iter = 90;

% C16 (PG&E GreenButton A-10S MLB) Storage Sizing Iteration
C16_Storage_Power_Rating_Iter = 30;


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

Initial_Final_SOC = 0.3;

End_of_Month_Padding_Days = 3;

%% Model Input Iteration

Model_Type_Input_Iter = ["Storage Only", "Solar Plus Storage"];

for Model_Type_Input = Model_Type_Input_Iter
    
    Load_Profile_Name_Input_Iter = ["Avalon GreenButton East Bay Light Industrial", ... % C1
        "Stem GreenButton SDG&E G-16 Manufacturing", ... % C6
        "PG&E GreenButton A-10S MLB"]; % C16
    
    for Load_Profile_Name_Input = Load_Profile_Name_Input_Iter
        
        if Model_Type_Input == "Storage Only"
            
            Solar_Profile_Name_Input = "No Solar";
            
            Solar_Size_Input_Iter = 0;
            
            ITC_Constraint_Input = 0;
            
            Solar_Installed_Cost_per_kW = 0;
            
        elseif Model_Type_Input == "Solar Plus Storage"
            
            ITC_Constraint_Input = 1;
            
            if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" % C1
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input_Iter = [C1_40_Percent_Offset_Solar_Size_Input, ...
                    C1_80_Percent_Offset_Solar_Size_Input];
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" % C6
                
                Solar_Profile_Name_Input = "CSI SDG&E Commercial & Industrial";
                
                Solar_Size_Input_Iter = [C6_40_Percent_Offset_Solar_Size_Input, ...
                    C6_80_Percent_Offset_Solar_Size_Input];
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" % C16
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input_Iter = [C16_40_Percent_Offset_Solar_Size_Input, ...
                    C16_80_Percent_Offset_Solar_Size_Input];
                
            end
            
        end
        
        for Solar_Size_Input = Solar_Size_Input_Iter
            
            % Solar Cost per kW - Call Solar_Installed_Cost_per_kW Function
            Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input);
            
            if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" % C1 - "E-19 Suite + A-1-STORAGE + A-6"
                
                Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)", "PG&E E-19S (OLD)"];
                
                if Model_Type_Input == "Solar Plus Storage"
                    % Only sites with solar are eligible to go on Option R.
                    Retail_Rate_Name_Input_Iter = ["PG&E E-19S-R (NEW)"];
                end
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" % C6 - "AL-TOU, AL-TOU-CP2, DG-R"
                
                Retail_Rate_Name_Input_Iter = ["SDG&E AL-TOU (NEW)"];
                
                if Model_Type_Input == "Solar Plus Storage"
                    % Only sites with solar are eligible to go on Option R.
                    Retail_Rate_Name_Input_Iter = ["SDG&E DG-R"];
                end
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" % C16 - "E-19 Suite"
                
                Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)"];
                
                if Model_Type_Input == "Solar Plus Storage"
                    % Only sites with solar are eligible to go on Option R.
                    Retail_Rate_Name_Input_Iter = ["PG&E E-19S-R (NEW)"];
                end
                
            end
            
            for Retail_Rate_Name_Input = Retail_Rate_Name_Input_Iter
                
                Storage_Type_Input_Iter = ["Lithium-Ion Battery", "Flow Battery"];
                
                for Storage_Type_Input = Storage_Type_Input_Iter
                    
                    if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" % C1
                        Storage_Power_Rating_Input_Iter = C1_Storage_Power_Rating_Iter;
                        
                    elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" % C6
                        Storage_Power_Rating_Input_Iter = C6_Storage_Power_Rating_Iter;
                        
                    elseif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" % C16
                        Storage_Power_Rating_Input_Iter = C16_Storage_Power_Rating_Iter;
                    end
                    
                    
                    for Storage_Power_Rating_Input = Storage_Power_Rating_Input_Iter
                        
                        if Storage_Type_Input == "Lithium-Ion Battery"
                            Usable_Storage_Capacity_Input = Storage_Power_Rating_Input * 2; % Most common SGIP duration for lithium-ion.
                            Single_Cycle_RTE_Input_Iter = 0.85;
                        elseif Storage_Type_Input == "Flow Battery"
                            Usable_Storage_Capacity_Input = Storage_Power_Rating_Input * 2; % Use 2-hour flow battery here.
                            Single_Cycle_RTE_Input_Iter = 0.7;
                        end
                        
                        for Single_Cycle_RTE_Input = Single_Cycle_RTE_Input_Iter
                            
                            % Storage Cost per kWh - Call Storage_Installed_Cost_per_kWh Function
                            Storage_Installed_Cost_per_kWh = Storage_Installed_Cost_per_kWh_Calculator(Customer_Class_Input, Storage_Type_Input);
                            
                            % Estimated Future Lithium-Ion Battery Installed Cost per kWh
                            % Used to calculate cycling penalty for lithium-ion batteries.
                            Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh = 100;
                            
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
                                Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh, ...
                                Cycle_Life, Storage_Depth_of_Discharge, Initial_Final_SOC, End_of_Month_Padding_Days)
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end