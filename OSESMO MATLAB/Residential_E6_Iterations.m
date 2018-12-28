%% Script Description Header

% File Name: Residential_E6_Iterations.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Iterates thorugh all residential model runs.

clear;
clc;

%% Set Directory to Box Sync Folder

% OSESMO Git Repository Directory Location
OSESMO_Git_Repo_Directory = '/Users/ryanden/Desktop/OSESMO Git Repository/OSESMO/MATLAB Code';

% Box Sync Directory Location
Input_Output_Data_Directory_Location = '/Users/ryanden/Box Sync/GHG Signal Working Group';

cd(Input_Output_Data_Directory_Location)

%% Load Customer Load Data

% "WattTime GreenButton Residential Long Beach"
R2_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
    'Vector Format/Vector_Residential_Site2_2017_LongBeach.csv']);

% "WattTime GreenButton Residential Coulterville"
R3_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
    'Vector Format/Vector_Residential_Site3_2017_Coulterville.csv']);

% "Custom Power Solar GreenButton PG&E Albany Residential with EV"
R7_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Custom Power Solar Load Profiles/15-Minute Data/' ...
    'Vector Format/Custom_Power_Solar_PGE_Albany_Residential_EV_Vector.csv']);

% "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
R8_Load_Profile_Data = csvread(['Load Profile Data/' ...
    'Custom Power Solar Load Profiles/15-Minute Data/' ...
    'Vector Format/Custom_Power_Solar_PGE_Crockett_Residential_EV_Vector.csv']);

% "PG&E GreenButton Central Valley Residential Non-CARE"
R9_Load_Profile_Data = csvread(['Load Profile Data/PG&E Residential Central Valley 2015/' ...
    '2017 Remapped/15-Minute Data/' ...
    'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_Non_CARE.csv']);

% "PG&E GreenButton Central Valley Residential CARE"
R10_Load_Profile_Data = csvread(['Load Profile Data/PG&E Residential Central Valley 2015/' ...
    '2017 Remapped/15-Minute Data/' ...
    'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_CARE.csv']);

PGE_Resi_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Residential.csv']);

SCE_Resi_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SCE_Residential.csv']);

SDGE_Resi_Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
    'Selected Clean 2017 CSI Generation Profiles/'...
    '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
    'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Residential.csv']);

cd(OSESMO_Git_Repo_Directory)


%% Solar PV System Size Inputs for R2, R3, R7, R8, R9, and R10

% Residential storage systems are sized to meet 80% of annual electricity
% consumption, as are small commercial systems. Medium and large commercial
% and industrial PV systems are sized to meet 40% of annual electricity
% consumption.

R2_Total_Annual_Consumption = sum(R2_Load_Profile_Data) * (15/60);
SCE_Resi_Solar_PV_Total_Annual_Production = sum(SCE_Resi_Solar_PV_Profile_Data) * (15/60);
R2_Resi_Solar_Size_Input = round(10 * (0.80/(SCE_Resi_Solar_PV_Total_Annual_Production/R2_Total_Annual_Consumption)), 1);

R3_Total_Annual_Consumption = sum(R3_Load_Profile_Data) * (15/60);
PGE_Resi_Solar_PV_Total_Annual_Production = sum(PGE_Resi_Solar_PV_Profile_Data) * (15/60);
R3_Resi_Solar_Size_Input = round(10 * (0.80/(PGE_Resi_Solar_PV_Total_Annual_Production/R3_Total_Annual_Consumption)), 1);

R7_Total_Annual_Consumption = sum(R7_Load_Profile_Data) * (15/60);
PGE_Resi_Solar_PV_Total_Annual_Production = sum(PGE_Resi_Solar_PV_Profile_Data) * (15/60);
R7_Resi_Solar_Size_Input = round(10 * (0.80/(PGE_Resi_Solar_PV_Total_Annual_Production/R7_Total_Annual_Consumption)), 1);

R8_Total_Annual_Consumption = sum(R8_Load_Profile_Data) * (15/60);
PGE_Resi_Solar_PV_Total_Annual_Production = sum(PGE_Resi_Solar_PV_Profile_Data) * (15/60);
R8_Resi_Solar_Size_Input = round(10 * (0.80/(PGE_Resi_Solar_PV_Total_Annual_Production/R8_Total_Annual_Consumption)), 1);

R9_Total_Annual_Consumption = sum(R9_Load_Profile_Data) * (15/60);
PGE_Resi_Solar_PV_Total_Annual_Production = sum(PGE_Resi_Solar_PV_Profile_Data) * (15/60);
R9_Resi_Solar_Size_Input = round(10 * (0.80/(PGE_Resi_Solar_PV_Total_Annual_Production/R9_Total_Annual_Consumption)), 1);

R10_Total_Annual_Consumption = sum(R10_Load_Profile_Data) * (15/60);
PGE_Resi_Solar_PV_Total_Annual_Production = sum(PGE_Resi_Solar_PV_Profile_Data) * (15/60);
R10_Resi_Solar_Size_Input = round(10 * (0.80/(PGE_Resi_Solar_PV_Total_Annual_Production/R10_Total_Annual_Consumption)), 1);


%% Storage System Size Inputs for R2, R3, R7, R8, R9, and R10

% 5 kW, 13.5 kWh is the most common SGIP residential storage size.
R2_Storage_Power_Rating_Iter = 5;

R3_Storage_Power_Rating_Iter = 5;

R7_Storage_Power_Rating_Iter = 5;

R8_Storage_Power_Rating_Iter = 5;

R9_Storage_Power_Rating_Iter = 5;

R10_Storage_Power_Rating_Iter = 5;


%% Fixed Model Inputs

Modeling_Team_Input = "Enel EnerNOC/SGIP Working Group";

Model_Run_Number_Input = 0; % Initialize value, gets updated every model run.

Model_Timestep_Resolution = 15;

Customer_Class_Input = "Residential";

Parasitic_Storage_Load_Input = 0.003;

Start_Time_Input = datetime("2017-01-01 00:00:00");

Show_Plots = 0; % 0 == Don't show plots, 1 == show plots

Export_Plots = 1; % 0 = Don't export plots, 1 = export plots

Export_Data = 1; % 0 = Don"t export data, 1 = export data

Initial_Final_SOC = 0.3;

End_of_Month_Padding_Days = 3;

%% Model Input Iteration

Model_Type_Input_Iter = ["Storage Only", "Solar Plus Storage"];

for Model_Type_Input = Model_Type_Input_Iter
    
%     Load_Profile_Name_Input_Iter = ["WattTime GreenButton Residential Long Beach", ...
%         "WattTime GreenButton Residential Coulterville", ...
%         "Custom Power Solar GreenButton PG&E Albany Residential with EV", ...
%         "Custom Power Solar GreenButton PG&E Crockett Residential with EV", ...
%         "PG&E GreenButton Central Valley Residential Non-CARE", ...
%         "PG&E GreenButton Central Valley Residential CARE"];

% Removed WattTime load profiles - too small, not representative of typical
% solar or storage customers. Storage systems were oversized, weren't able
% to meet 52-equivalent-cycling requirement.

    Load_Profile_Name_Input_Iter = ["Custom Power Solar GreenButton PG&E Albany Residential with EV", ...
        "Custom Power Solar GreenButton PG&E Crockett Residential with EV", ...
        "PG&E GreenButton Central Valley Residential Non-CARE", ...
        "PG&E GreenButton Central Valley Residential CARE"];

    
    for Load_Profile_Name_Input = Load_Profile_Name_Input_Iter
        
        if Model_Type_Input == "Storage Only"
            
            Solar_Profile_Name_Input = "No Solar";
            
            Solar_Size_Input = 0;
            
            ITC_Constraint_Input = 0;
            
            Solar_Installed_Cost_per_kW = 0;
            
        elseif Model_Type_Input == "Solar Plus Storage"
            
            ITC_Constraint_Input = 1;
            
            if Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach"
                
                Solar_Profile_Name_Input = "CSI SCE Residential";
                
                Solar_Size_Input = R2_Resi_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville"
                
                Solar_Profile_Name_Input = "CSI PG&E Residential";
                
                Solar_Size_Input = R3_Resi_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Albany Residential with EV"
                
                Solar_Profile_Name_Input = "CSI PG&E Residential";
                
                Solar_Size_Input = R7_Resi_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
                
                Solar_Profile_Name_Input = "CSI PG&E Residential";
                
                Solar_Size_Input = R8_Resi_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE"
                
                Solar_Profile_Name_Input = "CSI PG&E Residential";
                
                Solar_Size_Input = R9_Resi_Solar_Size_Input;
                
            elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE"
                
                Solar_Profile_Name_Input = "CSI PG&E Residential";
                
                Solar_Size_Input = R10_Resi_Solar_Size_Input;
                
            end
            
            % Solar Cost per kW - Call Solar_Installed_Cost_per_kW Function
            Solar_Installed_Cost_per_kW = Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input, Solar_Size_Input);
            
        end
        
        if Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 1";
            
        elseif Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 1";
            
        elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Albany Residential with EV"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 1";
            
        elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 1";
            
        elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 2";
            
        elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE"
            
            Retail_Rate_Name_Input_Iter = "PG&E E-6 (NEW) Tier 2";
            
        end
        
        for Retail_Rate_Name_Input = Retail_Rate_Name_Input_Iter
            
            Storage_Type_Input_Iter = ["Lithium-Ion Battery", "Flow Battery"];
            
            for Storage_Type_Input = Storage_Type_Input_Iter
                
                if Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach"
                    Storage_Power_Rating_Input_Iter = R2_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville"
                    Storage_Power_Rating_Input_Iter = R3_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Albany Residential with EV"
                    Storage_Power_Rating_Input_Iter = R7_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
                    Storage_Power_Rating_Input_Iter = R8_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE"
                    Storage_Power_Rating_Input_Iter = R9_Storage_Power_Rating_Iter;
                    
                elseif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE"
                    Storage_Power_Rating_Input_Iter = R10_Storage_Power_Rating_Iter;
                    
                end
                
                for Storage_Power_Rating_Input = Storage_Power_Rating_Input_Iter
                    
                    if Storage_Type_Input == "Lithium-Ion Battery"
                        Usable_Storage_Capacity_Input = Storage_Power_Rating_Input * 2.7; % Most common SGIP duration for residential lithium-ion.
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
                        
                        
                        % Storage Control Algorithm Name
                        % Use Non-Economic Solar Self-Supply for E-1
                        % (including E-1 with SmartRate) if Solar Plus Storage
                        
                        if any(Retail_Rate_Name_Input == ["PG&E E-1 Tier 1", "PG&E E-1 Tier 1 SmartRate", "PG&E E-1 Tier 3", "PG&E E-1 Tier 3 SmartRate"]) && ...
                                Model_Type_Input == "Solar Plus Storage"
                            Storage_Control_Algorithm_Name = "OSESMO Non-Economic Solar Self-Supply";
                        else
                            Storage_Control_Algorithm_Name = "OSESMO Economic Dispatch";
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
                                        
                                        if Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach" % This is the only Southern California residential load profile.
                                            Emissions_Forecast_Signal_Input_Iter = ["SP15 RT5M", "SP15 DA WattTime"];
                                            
                                        elseif Load_Profile_Name_Input ~= "WattTime GreenButton Residential Long Beach"
                                            Emissions_Forecast_Signal_Input_Iter = ["NP15 RT5M", "NP15 DA WattTime"];
                                            
                                        end
                                        
                                    end
                                    
                                    for Carbon_Adder_Incentive_Value_Input = Carbon_Adder_Incentive_Value_Input_Iter
                                        
                                        for Emissions_Forecast_Signal_Input = Emissions_Forecast_Signal_Input_Iter
                                            
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
                                                OSESMO_Git_Repo_Directory, Input_Output_Data_Directory_Location, Start_Time_Input, ...
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
                
            end
            
        end
        
    end
    
end