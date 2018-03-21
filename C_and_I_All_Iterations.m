%% Script Description Header

% File Name: C_and_I_All_Iterations.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Iterates thorugh all commercial and industrial model runs.

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

C3_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Stem C&I Load Profiles/15-Minute Data/' ...
    'Vector Format/2_SCE_TOU-8B_Office_9_Vector.csv']);

C5_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Stem C&I Load Profiles/15-Minute Data/' ...
    'Vector Format/4_SCE_GS-3B_Food_Processing_8_Vector.csv']);

C6_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Stem C&I Load Profiles/15-Minute Data/' ...
    'Vector Format/5_SDGE_G-16_Manufacturing_7_Vector.csv']);

C9_Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
    'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/Los Angeles Grocery/' ...
    'Vector Format/Clean_Vector_2017_Los_Angeles_Grocery.csv']);

C10_Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
    'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/Los Angeles Industrial/' ...
    'Vector Format/Clean_Vector_2017_Los_Angeles_Industrial.csv']);

C11_Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
    'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Diego Office/' ...
    'Vector Format/Clean_Vector_2017_San_Diego_Office.csv']);

C15_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
    'Vector Format/PG&E_GreenButton_A-6_SMB_15_minute_Vector.csv']);

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
C1_Solar_Size_Input = 100 * (0.40/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C1_Total_Annual_Consumption));

% Stem SCE Office - mapped to SCE C&I solar profile
C3_Total_Annual_Consumption = sum(C3_Load_Profile_Data) * (15/60);
SCE_ComInd_Solar_PV_Total_Annual_Consumption = sum(SCE_ComInd_Solar_PV_Profile_Data) * (15/60);
C3_Solar_Size_Input = 100 * (0.40/(SCE_ComInd_Solar_PV_Total_Annual_Consumption/C3_Total_Annual_Consumption));

% Stem SCE Food Processing - mapped to SCE C&I solar profile
C5_Total_Annual_Consumption = sum(C5_Load_Profile_Data) * (15/60);
SCE_ComInd_Solar_PV_Total_Annual_Consumption = sum(SCE_ComInd_Solar_PV_Profile_Data) * (15/60);
C5_Solar_Size_Input = 100 * (0.40/(SCE_ComInd_Solar_PV_Total_Annual_Consumption/C5_Total_Annual_Consumption));

% Stem SDG&E Manufacturing - mapped to SDG&E C&I solar profile
C6_Total_Annual_Consumption = sum(C6_Load_Profile_Data) * (15/60);
SDGE_Solar_PV_Total_Annual_Consumption = sum(SDGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C6_Solar_Size_Input = 100 * (0.40/(SDGE_Solar_PV_Total_Annual_Consumption/C6_Total_Annual_Consumption));

% EnerNOC Los Angeles Grocery - mapped to SCE C&I solar profile
C9_Total_Annual_Consumption = sum(C9_Load_Profile_Data) * (15/60);
SCE_ComInd_Solar_PV_Total_Annual_Consumption = sum(SCE_ComInd_Solar_PV_Profile_Data) * (15/60);
C9_Solar_Size_Input = 100 * (0.40/(SCE_ComInd_Solar_PV_Total_Annual_Consumption/C9_Total_Annual_Consumption));

% EnerNOC Los Angeles Industrial - mapped to SCE C&I solar profile
C10_Total_Annual_Consumption = sum(C10_Load_Profile_Data) * (15/60);
SCE_Solar_PV_Total_Annual_Consumption = sum(SCE_ComInd_Solar_PV_Profile_Data) * (15/60);
C10_Solar_Size_Input = 100 * (0.40/(SCE_Solar_PV_Total_Annual_Consumption/C10_Total_Annual_Consumption));

% EnerNOC San Diego Office - mapped to SDG&E C&I solar profile
C11_Total_Annual_Consumption = sum(C11_Load_Profile_Data) * (15/60);
SDGE_ComInd_Solar_PV_Total_Annual_Consumption = sum(SDGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C11_Solar_Size_Input = 100 * (0.40/(SDGE_ComInd_Solar_PV_Total_Annual_Consumption/C11_Total_Annual_Consumption));

% PG&E GreenButton A-6 SMB - mapped to PG&E C&I solar profile
C15_Total_Annual_Consumption = sum(C15_Load_Profile_Data) * (15/60);
PGE_ComInd_Solar_PV_Total_Annual_Consumption = sum(PGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C15_Solar_Size_Input = 100 * (0.40/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C15_Total_Annual_Consumption));

% PG&E GreenButton A-10S MLB - mapped to PG&E C&I solar profile
C16_Total_Annual_Consumption = sum(C16_Load_Profile_Data) * (15/60);
PGE_ComInd_Solar_PV_Total_Annual_Consumption = sum(PGE_ComInd_Solar_PV_Profile_Data) * (15/60);
C16_Solar_Size_Input = 100 * (0.40/(PGE_ComInd_Solar_PV_Total_Annual_Consumption/C16_Total_Annual_Consumption));


%% Storage System Size Inputs

% This sizing approach is inspired by an approach used by NREL in its paper
% "Optimal sizing of energy storage and photovoltaic power systems for
% demand charge mitigation, except using fractions of maximum power rating instead
% of fractions of maximum energy capacity.
% https://www.nrel.gov/docs/fy14osti/60291.pdf

% Multiple sizes between 0 and (maximum customer load - average customer
% load) were tried for the base case model runs. Optimal systems were
% selected by picking the largest system size with an unsubsidized simple
% payback below 8 years.

% These selected system sizes are saved in
% GHG Signal Working Group/Models/OSESMO/Model Output Aggregation/Commercial & Industrial Model Runs/
% Base_Case_Commercial_and_Industrial_Simple_Payback_Selection.csv

cd(Box_Sync_Directory_Location)

Selected_System_Size_Data = readtable(['Models/OSESMO/Model Output Aggregation/Commercial & Industrial Model Runs/'...
    'Base Case Analysis and Size Selection/Base_Case_Commercial_and_Industrial_Simple_Payback_Selection.csv']);

Selected_System_Size_Data.Load_Profile_Name_Input = categorical(Selected_System_Size_Data.Load_Profile_Name_Input);
Selected_System_Size_Data.Model_Type_Input = categorical(Selected_System_Size_Data.Model_Type_Input);
Selected_System_Size_Data.Storage_Type_Input = categorical(Selected_System_Size_Data.Storage_Type_Input);
Selected_System_Size_Data.Retail_Rate_Name_Input = categorical(strcat(Selected_System_Size_Data.Retail_Rate_Utility, ...
    {' '}, Selected_System_Size_Data.Retail_Rate_Name_Output));

cd(OSESMO_Git_Repo_Directory)


%% Fixed Model Inputs

Modeling_Team_Input = "Enel EnerNOC/SGIP Working Group";

Model_Run_Number_Input = 0; % Initialize value, gets updated every model run.

Model_Timestep_Resolution = 15;

Customer_Class_Input = "Commercial and Industrial";

Parasitic_Storage_Load_Input = 0.003;

Storage_Control_Algorithm_Name = "OSESMO Economic Dispatch";

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
        "Stem GreenButton SCE TOU-8B Office", ... % C3
        "Stem GreenButton SCE GS-3B Food Processing", ... % C5
        "Stem GreenButton SDG&E G-16 Manufacturing", ... % C6
        "EnerNOC GreenButton Los Angeles Grocery", ... % C9
        "EnerNOC GreenButton Los Angeles Industrial", ... % C10
        "EnerNOC GreenButton San Diego Office", ... % C11
        "PG&E GreenButton A-6 SMB", ... % C15
        "PG&E GreenButton A-10S MLB"]; % C16
    
    for Load_Profile_Name_Input = Load_Profile_Name_Input_Iter
        
        if Model_Type_Input == "Storage Only"
            
            Solar_Profile_Name_Input = "No Solar";
            
            Solar_Size_Input = 0;
            
            ITC_Constraint_Input = 0;
            
            Solar_Installed_Cost_per_kW = 0;
            
        elseif Model_Type_Input == "Solar Plus Storage"
            
            ITC_Constraint_Input = 1;
            
            if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" % C1
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input = C1_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office" % C3
                
                Solar_Profile_Name_Input = "CSI SCE Commercial & Industrial";
                
                Solar_Size_Input = C3_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SCE GS-3B Food Processing" % C5
                
                Solar_Profile_Name_Input = "CSI SCE Commercial & Industrial";
                
                Solar_Size_Input = C5_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" % C6
                
                Solar_Profile_Name_Input = "CSI SDG&E Commercial & Industrial";
                
                Solar_Size_Input = C6_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Grocery" % C9
                
                Solar_Profile_Name_Input = "CSI SCE Commercial & Industrial";
                
                Solar_Size_Input = C9_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial" % C10
                
                Solar_Profile_Name_Input = "CSI SCE Commercial & Industrial";
                
                Solar_Size_Input = C10_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office" % C11
                
                Solar_Profile_Name_Input = "CSI SDG&E Commercial & Industrial";
                
                Solar_Size_Input = C11_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton A-6 SMB" % C15
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input = C15_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" % C16
                
                Solar_Profile_Name_Input = "CSI PG&E Commercial & Industrial";
                
                Solar_Size_Input = C16_Solar_Size_Input;
                
            end
            
            % Solar Cost per kW - Call Solar_Installed_Cost_per_kW Function
            Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input);
            
        end
        
        if Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" % C1 - "E-19 Suite + A-1-STORAGE + A-6"
            
            Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)", "PG&E E-19S (OLD)", ...
                "PG&E E-19S PDP (NEW)", "PG&E E-19S PDP (OLD)", ...
                "PG&E A-1-STORAGE (NEW)", "PG&E A-6 (OLD)", "PG&E A-6 PDP (OLD)"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "PG&E E-19S-R (NEW)", "PG&E E-19S-R (OLD)"];
            end
            
        elseif Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office" % C3 - "TOU-8 Suite"
            
            Retail_Rate_Name_Input_Iter = ["SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SCE TOU-8-R"];
            end
            
        elseif Load_Profile_Name_Input == "Stem GreenButton SCE GS-3B Food Processing" % C5 - "TOU-8 Suite"
            
            Retail_Rate_Name_Input_Iter = ["SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SCE TOU-8-R"];
            end
            
        elseif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" % C6 - "AL-TOU, AL-TOU-CP2, DG-R"
            
            Retail_Rate_Name_Input_Iter = ["SDG&E AL-TOU (NEW)", "SDG&E AL-TOU (OLD)", ...
                "SDG&E AL-TOU-CP2 (NEW)", "SDG&E AL-TOU-CP2 (OLD)"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SDG&E DG-R"];
            end
            
        elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Grocery" % C9 - "TOU-8 Suite"
            
            Retail_Rate_Name_Input_Iter = ["SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SCE TOU-8-R"];
            end
            
        elseif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial" % C10 - "TOU-8 Suite"
            
            Retail_Rate_Name_Input_Iter = ["SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SCE TOU-8-R"];
            end
            
        elseif Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office" % C11 "AL-TOU suite + AL-TOU DA CAISO"
            
            Retail_Rate_Name_Input_Iter = ["SDG&E AL-TOU (NEW)", "SDG&E AL-TOU (OLD)", ...
                "SDG&E AL-TOU-CP2 (NEW)", "SDG&E AL-TOU-CP2 (OLD)", ...
                "SDG&E AL-TOU (NEW) with DA CAISO"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "SDG&E DG-R"];
            end
            
        elseif Load_Profile_Name_Input == "PG&E GreenButton A-6 SMB" % C15 - "Everything except A-1 STORAGE or A-6"
            
            Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)", "PG&E E-19S (OLD)", ...
                "PG&E E-19S PDP (NEW)", "PG&E E-19S PDP (OLD)", ...
                "SCE TOU-8-B", "SCE TOU-8-CPP", "SCE TOU-8-RTP", ...
                "SDG&E AL-TOU (NEW)", "SDG&E AL-TOU (OLD)", ...
                "SDG&E AL-TOU-CP2 (NEW)", "SDG&E AL-TOU-CP2 (OLD)", ...
                "SDG&E AL-TOU (NEW) with DA CAISO"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "PG&E E-19S-R (NEW)", "PG&E E-19S-R (OLD)", ...
                    "SCE TOU-8-R", "SDG&E DG-R"];
            end
            
        elseif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" % C16 - "E-19 Suite"
            
            Retail_Rate_Name_Input_Iter = ["PG&E E-19S (NEW)", "PG&E E-19S (OLD)", ...
                "PG&E E-19S PDP (NEW)", "PG&E E-19S PDP (OLD)"];
            
            if Model_Type_Input == "Solar Plus Storage"
                % Only sites with solar are eligible to go on Option R.
                Retail_Rate_Name_Input_Iter = [Retail_Rate_Name_Input_Iter, "PG&E E-19S-R (NEW)", "PG&E E-19S-R (OLD)"];
            end
            
        end
        
        for Retail_Rate_Name_Input = Retail_Rate_Name_Input_Iter
            
            Storage_Type_Input_Iter = ["Lithium-Ion Battery", "Flow Battery"];
            
            for Storage_Type_Input = Storage_Type_Input_Iter
                
                % Find value in Selected Storage Power table
                Selected_Storage_Power_Table_Rows = ...
                    ((Selected_System_Size_Data.Load_Profile_Name_Input == char(Load_Profile_Name_Input)) & ...
                    (Selected_System_Size_Data.Model_Type_Input == char(Model_Type_Input)) & ...
                    (Selected_System_Size_Data.Storage_Type_Input == char(Storage_Type_Input)) & ...
                    (Selected_System_Size_Data.Retail_Rate_Name_Input == char(Retail_Rate_Name_Input)));
                
                Storage_Power_Rating_Input_Iter = table2array(Selected_System_Size_Data(Selected_Storage_Power_Table_Rows, 4));
                
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
                        
                        
                        % GHG Reduction Solution
                        
                        GHG_Reduction_Solution_Input_Iter = ["No GHG Reduction Solution", "GHG Signal Co-Optimization", "No-Charging Time Constraint", "Charging and Discharging Time Constraints"];


                        for GHG_Reduction_Solution_Input = GHG_Reduction_Solution_Input_Iter
                            
                            % Equivalent Cycling Constraint
                            
                            %                             Equivalent_Cycling_Constraint_Input_Iter = [0, 52, 130];
                            
                            Equivalent_Cycling_Constraint_Input_Iter = 0; % Reduced cycling constraint iteration to reduce modeling runtime.
                            
                            
                            for Equivalent_Cycling_Constraint_Input = Equivalent_Cycling_Constraint_Input_Iter
                                
                                % Annual RTE Constraint Input
                                
                                %                                 Annual_RTE_Constraint_Input_Iter = [0, 1];
                                
                                Annual_RTE_Constraint_Input_Iter = 0; % Reduced RTE constraint iteration to reduce modeling runtime.
                                
                                
                                for Annual_RTE_Constraint_Input = Annual_RTE_Constraint_Input_Iter
                                    
                                    if GHG_Reduction_Solution_Input ~= "GHG Signal Co-Optimization"
                                        
                                        Carbon_Adder_Incentive_Value_Input_Iter = 0;
                                        
                                        Emissions_Forecast_Signal_Input_Iter = "No Emissions Forecast Signal";
                                        
                                    elseif GHG_Reduction_Solution_Input == "GHG Signal Co-Optimization"
                                        
                                        Carbon_Adder_Incentive_Value_Input_Iter = [1, 15, 65];
                                        
                                        % Map Southern California load
                                        % profiles to SP15 emissions
                                        % signal, all others to NP15
                                        % emissions signals.
                                        if Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office" || ...
                                                Load_Profile_Name_Input ==  "Stem GreenButton SDG&E G-16 Manufacturing" || ...
                                                Load_Profile_Name_Input ==  "Stem GreenButton SCE GS-3B Food Processing" || ...
                                                Load_Profile_Name_Input ==  "EnerNOC GreenButton Los Angeles Grocery" || ...
                                                Load_Profile_Name_Input ==  "EnerNOC GreenButton Los Angeles Industrial" || ...
                                                Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office"
                                            
                                            Emissions_Forecast_Signal_Input_Iter = ["SP15 RT5M", "SP15 DA WattTime"];
                                            
                                        else
                                            
                                            Emissions_Forecast_Signal_Input_Iter = ["NP15 RT5M", "NP15 DA WattTime"];
                                            
                                        end
                                        
                                    end
                                    
                                    for Carbon_Adder_Incentive_Value_Input = Carbon_Adder_Incentive_Value_Input_Iter
                                        
                                        for Emissions_Forecast_Signal_Input = Emissions_Forecast_Signal_Input_Iter
                                            
                                            % Run Model, Increase Model Run Number Counter
                                            
                                            Model_Run_Number_Input = Model_Run_Number_Input + 1;
                                            
%                                             OSESMO(Modeling_Team_Input, Model_Run_Number_Input, Model_Type_Input, ...
%                                                 Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Name_Input, ...
%                                                 Retail_Rate_Name_Input, Solar_Profile_Name_Input, Solar_Size_Input, ...
%                                                 Storage_Type_Input, Storage_Power_Rating_Input, Usable_Storage_Capacity_Input, ...
%                                                 Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input, ...
%                                                 Storage_Control_Algorithm_Name, GHG_Reduction_Solution_Input, Equivalent_Cycling_Constraint_Input, ...
%                                                 Annual_RTE_Constraint_Input, ITC_Constraint_Input, ...
%                                                 Carbon_Adder_Incentive_Value_Input, Emissions_Forecast_Signal_Input, ...
%                                                 OSESMO_Git_Repo_Directory, Box_Sync_Directory_Location, Start_Time_Input, ...
%                                                 Show_Plots, Export_Plots, Export_Data, ...
%                                                 Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh, ...
%                                                 Cycle_Life, Storage_Depth_of_Discharge, Initial_Final_SOC, End_of_Month_Padding_Days)
                                            
                                        end
                                        
                                    end
                                    
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end