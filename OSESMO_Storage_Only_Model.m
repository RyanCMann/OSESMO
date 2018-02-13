%% Script Description Header

% File Name: OSESMO_Storage_Only_Model.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Simulates operation of energy storage system.
% Calculates customer savings, GHG reduction, and battery cycling.

function OSESMO_Storage_Only_Model(OSESMO_Git_Repo_Directory, Box_Sync_Directory_Location, ...
    System_Type_Input, Carbon_Reduction_Strategy, Carbon_Adder_per_Metric_Ton_Input_Value, ...
    Carbon_Forecast_Signal_Input, Carbon_Impact_Evaluation_Signal_Input, ...
    Load_Profile_Input, Start_Time_Input, Utility_Tariff_Input, ...
    Show_Plots, Export_Plots, Export_Data, ...
    Size_ES, P_ES_max, Eff_c, Eff_d, Auxiliary_Storage_Load, ...
    Installed_Cost_per_kWh, cycle_pen, delta_t, Padding_Days)

%% Set Directory to Box Sync Folder

cd(Box_Sync_Directory_Location)


%% Import Data from CSV Files

% Begin script runtime timer
tstart = tic;

% Import Load Profile Data

switch Load_Profile_Input
    
    case "EnerNOC GreenButton Los Angeles Grocery"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/Los Angeles Grocery/' ...
                'Vector Format/Clean_Vector_2017_Los_Angeles_Grocery.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/Los Angeles Grocery/' ...
                'Vector Format/Clean_Vector_2017_Los_Angeles_Grocery.csv']);
        end
        
    case "EnerNOC GreenButton Los Angeles Industrial"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/Los Angeles Industrial/' ...
                'Vector Format/Clean_Vector_2017_Los_Angeles_Industrial.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/Los Angeles Industrial/' ...
                'Vector Format/Clean_Vector_2017_Los_Angeles_Industrial.csv']);
        end
        
    case "EnerNOC GreenButton San Diego Office"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/San Diego Office/EnerNOC GreenButton/' ...
                'Vector Format/Clean_Vector_2017_San_Diego_Office.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Diego Office/EnerNOC GreenButton/' ...
                'Vector Format/Clean_Vector_2017_San_Diego_Office.csv']);
        end
        
    case "EnerNOC GreenButton San Francisco Industrial"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/San Francisco Industrial/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Industrial.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Francisco Industrial/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Industrial.csv']);
        end
        
    case "EnerNOC GreenButton San Francisco Office"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/San Francisco Office/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Office.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Francisco Office/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Office.csv']);
        end
        
    case "Avalon GreenButton East Bay Light Industrial"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/5-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_East_Bay_Light_Industrial.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/15-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_East_Bay_Light_Industrial.csv']);
        end
        
        
    case "Custom Power Solar GreenButton PG&E Albany Residential with EV"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/5-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Albany_Residential_EV_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/15-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Albany_Residential_EV_Vector.csv']);
        end
    
        
    case "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/5-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Crockett_Residential_EV_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/15-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Crockett_Residential_EV_Vector.csv']);
        end
        
        
    case "WattTime GreenButton Residential Berkeley"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site1_2017_Berkeley.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site1_2017_Berkeley.csv']);
        end
        
    case "WattTime GreenButton Residential Long Beach"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site2_2017_LongBeach.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site2_2017_LongBeach.csv']);
        end
        
    case "WattTime GreenButton Residential Coulterville"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site3_2017_Coulterville.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site3_2017_Coulterville.csv']);
        end
        
    case "WattTime GreenButton Residential San Francisco"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site4_2017_SanFrancisco.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site4_2017_SanFrancisco.csv']);
        end
        
    case "WattTime GreenButton Residential Oakland"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site5_2017_Oakland.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site5_2017_Oakland.csv']);
        end
        
    case "PG&E GreenButton A-1 SMB"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-1_SMB_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-1_SMB_15_minute_Vector.csv']);
        end
        
    case "PG&E GreenButton A-6 SMB"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-6_SMB_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-6_SMB_15_minute_Vector.csv']);
        end
        
    case "PG&E GreenButton A-10S MLB"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-10S_MLB_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-10S_MLB_15_minute_Vector.csv']);
        end
        
    case "PG&E GreenButton E-6 Residential"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_E-6_Residential_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_E-6_Residential_15_minute_Vector.csv']);
        end
        
    case "Stem GreenButton SCE GS-2B Hospitality"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/1_SCE_GS-2B_Hospitality_9_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/1_SCE_GS-2B_Hospitality_9_Vector.csv']);
        end
        
        
    case "Stem GreenButton SCE TOU-8B Office"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/2_SCE_TOU-8B_Office_9_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/2_SCE_TOU-8B_Office_9_Vector.csv']);
        end
        
    case "Stem GreenButton PG&E E-19 Office"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/3_PGE_E-19_Office_4_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/3_PGE_E-19_Office_4_Vector.csv']);
        end
        
    case "Stem GreenButton SCE GS-3B Food Processing"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/4_SCE_GS-3B_Food_Processing_8_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/4_SCE_GS-3B_Food_Processing_8_Vector.csv']);
        end
        
        
    case "Stem GreenButton SDG&E G-16 Manufacturing"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/5_SDGE_G-16_Manufacturing_7_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/5_SDGE_G-16_Manufacturing_7_Vector.csv']);
        end
        
        
    case "Stem GreenButton SDG&E AL-TOU Education"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/6_SDGE_AL-TOU_Education_10_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/6_SDGE_AL-TOU_Education_10_Vector.csv']);
        end
        
        
    case "Stem GreenButton PG&E E-19 Industrial"
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/7_PGE_E-19_Industrial_3_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/7_PGE_E-19_Industrial_3_Vector.csv']);
        end
        
end

Annual_Peak_Demand_Without_Storage = max(Load_Profile_Data);
Annual_Total_Electricity_Consumption_Without_Storage = sum(Load_Profile_Data) * delta_t;

% Import Marginal Emissions Rate Data Used as Forecast

switch Carbon_Forecast_Signal_Input
    
    case "NP15 RT5M Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 RT5M Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "NP15 DAM Forecasted Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '5-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '15-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 DAM Forecasted Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '5-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '15-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "NP15 WattTime Public Forecasted Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '5-Minute Data/Marginal GHG midnight before forecast_5min_NP15_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '15-Minute Data/Marginal GHG midnight before forecast_5min_NP15_Vector.csv']);
        end
        
    case "SP15 WattTime Public Forecasted Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '5-Minute Data/Marginal GHG midnight before forecast_5min_SP15_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '15-Minute Data/Marginal GHG midnight before forecast_5min_SP15_Vector.csv']);
        end
        
end


% Import Marginal Emissions Rate Data Used for Evaluation

switch Carbon_Impact_Evaluation_Signal_Input
    
    case "NP15 RT5M Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 RT5M Emissions Signal"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
end

% Import Carbon Adder Data

% Carbon Adder ($/kWh) = Marginal Emissions Rate (metric tons CO2/MWh) * ...
% Carbon Adder ($/metric ton) * (1 MWh/1000 kWh)
Carbon_Adder_Data = (Marginal_Emissions_Rate_Forecast_Data * ...
    Carbon_Adder_per_Metric_Ton_Input_Value)/1000;


% Import Volumetric (per kWh) Rate Data

switch Utility_Tariff_Input
    
    case "PG&E E-19S (OLD)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (OLD)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S-R (OLD)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Energy_Rates_Vector.csv']);
        end
           
    case "PG&E E-19S (NEW)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Energy_Rates_Vector.csv']);
        end
     
    case "PG&E E-19S PDP (NEW)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S-R (NEW)"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E A-1-STORAGE"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-1-STORAGE/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_A1_STORAGE_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-1-STORAGE/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_A1_STORAGE_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E EV-A"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E EV-A/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_EVA_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E EV-A/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_EVA_Energy_Rates_Vector.csv']);
        end
         
    case "SCE TOU-8-B"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-B/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-B/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-8-RTP"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-RTP/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_RTP_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-RTP/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_RTP_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E DG-R"
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Energy_Rates_Vector.csv']);
        end
        
end

% Select Demand Charge and Fixed-Charge Variable Values

switch Utility_Tariff_Input
    
    case "PG&E E-19S (OLD)"
        
        % Demand Charges - OLD PG&E E-19 Secondary Voltage
        Summer_Peak_DC = 18.64;
        Summer_Part_Peak_DC = 5.18;
        Summer_Noncoincident_DC = 17.56;
        Winter_Peak_DC = 0;  % There is no peak demand charge in the winter.
        Winter_Part_Peak_DC = 0.12;
        Winter_Noncoincident_DC = 17.56;
        
        % Fixed Per-Meter-Day Charge - OLD PG&E E-19 Secondary Voltage
        Fixed_Per_Meter_Day_Charge = 19.71253;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
    case "PG&E E-19S PDP (OLD)"
        
        % Demand Charges - OLD PG&E E-19 PDP Secondary Voltage
        Summer_Peak_DC = (18.64 - 5.70); % Includes PDP demand charge credit
        Summer_Part_Peak_DC = (5.18 - 1.41); % Includes PDP demand charge credit
        Summer_Noncoincident_DC = 17.56;
        Winter_Peak_DC = 0;  % There is no peak demand charge in the winter.
        Winter_Part_Peak_DC = 0.12;
        Winter_Noncoincident_DC = 17.56;
        
        % Fixed Per-Meter-Day Charge - OLD PG&E E-19 PDP Secondary Voltage
        Fixed_Per_Meter_Day_Charge = 19.71253;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "PG&E E-19S-R (OLD)"
        
        % Demand Charges - OLD PG&E E-19 Secondary Voltage - Option R
        Summer_Peak_DC = 1.50;
        Summer_Part_Peak_DC = 0.51;
        Summer_Noncoincident_DC = 17.56;
        Winter_Peak_DC = 0;  % There is no peak demand charge in the winter.
        Winter_Part_Peak_DC = 0.03;
        Winter_Noncoincident_DC = 17.56;
        
        % Fixed Per-Meter-Day Charge - OLD PG&E E-19 Secondary Voltage - Option R
        Fixed_Per_Meter_Day_Charge = 19.71253;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "PG&E E-19S (NEW)"
        
        % Demand Charges - NEW PG&E E-19 Secondary Voltage
        Summer_Peak_DC = 18.35;
        Summer_Part_Peak_DC = 2.85;
        Summer_Noncoincident_DC = 19.45;
        Winter_Peak_DC = 1.48;
        Winter_Part_Peak_DC = 0; % There is no part-peak demand charge in the winter.
        Winter_Noncoincident_DC = 19.45;
        
        % Fixed Per-Meter-Day Charge - NEW PG&E E-19 Secondary Voltage
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 720; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
    
    case "PG&E E-19S PDP (NEW)"
        
        % Demand Charges - NEW PG&E E-19 PDP Secondary Voltage
        Summer_Peak_DC = (18.35 - 5.70);
        Summer_Part_Peak_DC = (2.85 - 1.41);
        Summer_Noncoincident_DC = 19.45;
        Winter_Peak_DC = 1.48;
        Winter_Part_Peak_DC = 0; % There is no part-peak demand charge in the winter.
        Winter_Noncoincident_DC = 19.45;
        
        % Fixed Per-Meter-Day Charge - NEW PG&E E-19 PDP Secondary Voltage
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 720; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
                
    case "PG&E E-19S-R (NEW)"
        
        % Demand Charges - NEW PG&E E-19 Secondary Voltage - Option R
        Summer_Peak_DC = 1.48;
        Summer_Part_Peak_DC = 0.26;
        Summer_Noncoincident_DC = 19.45;
        Winter_Peak_DC = 0; % There is no peak demand charge in the winter.
        Winter_Part_Peak_DC = 0; % There is no part-peak demand charge in the winter.
        Winter_Noncoincident_DC = 19.45;
        
        % Fixed Per-Meter-Day Charge - NEW PG&E E-19 Secondary Voltage - Option R
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 720; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
    
     
    case "PG&E A-1-STORAGE"
        
        % Demand Charges - PG&E A-1-STORAGE, Single-Phase
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 3.75;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0; % There is no part-peak demand charge in the winter.
        Winter_Noncoincident_DC = 3.75;
        
        % Fixed Per-Meter-Day Charge - PG&E A-1-STORAGE, Single-Phase
        Fixed_Per_Meter_Day_Charge = 10;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    
    case "PG&E EV-A"
        
        % Demand Charges - PG&E EV?A
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E EV?A
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
      
    case "SCE TOU-8-B"
        
        % Demand Charges - SCE TOU-8-B (Below 2 kV)
        Summer_Peak_DC = 0; % There is no summer peak demand charge on this rate.
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 19.02;
        Winter_Peak_DC = 0;  % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 19.02;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-B (Below 2 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 658.17; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "SCE TOU-8-RTP"
        
        % Demand Charges - SCE TOU-8-RTP (Below 2 kV)
        Summer_Peak_DC = 0; % There is no summer peak demand charge on this rate.
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 19.02;
        Winter_Peak_DC = 0;  % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 19.02;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-RTP (Below 2 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 658.17; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
      
    case "SDG&E DG-R"  
        
        % Demand Charges - SDG&E DG-R, Secondary, <500 kW
        Summer_Peak_DC = 2.69;
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 12.24;
        Winter_Peak_DC = 0.56;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 12.24;
        
        % Fixed Per-Meter-Day Charge - SDG&E DG-R, Secondary, <500 kW
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 139.73; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
end


% Import Peak and Part-Peak Binary Variable Data
% (for tariffs with coincident peak or part-peak demand charges only)

switch Utility_Tariff_Input
    
    case "PG&E E-19S (OLD)"      
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_OLD_Winter_Partial_Peak_Binary_Vector.csv']);         
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_OLD_Winter_Partial_Peak_Binary_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (OLD)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Winter_Partial_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Winter_Partial_Peak_Binary_Vector.csv']);
        end
        
    case "PG&E E-19S-R (OLD)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_OLD_Winter_Partial_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_OLD_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_OLD_Winter_Partial_Peak_Binary_Vector.csv']);
        end   
        
        
    case "PG&E E-19S (NEW)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_NEW_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_NEW_Winter_Peak_Binary_Vector.csv']);
        end
        
      
    case "PG&E E-19S PDP (NEW)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Winter_Peak_Binary_Vector.csv']);
        end
        
        
    case "PG&E E-19S-R (NEW)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_NEW_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_NEW_Summer_Partial_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_PGE_E19SR_NEW_Winter_Peak_Binary_Vector.csv']);
        end
        
        
    case "SDG&E DG-R"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_DGR_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_DGR_Winter_Peak_Binary_Vector.csv']);
        end
        
end

% Import Month Data - Used to Filter Other Vectors

switch Utility_Tariff_Input
    
    case "PG&E E-19S (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19S_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19S_OLD_Month_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19S_PDP_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19S_PDP_OLD_Month_Vector.csv']);
        end
        
    case "PG&E E-19S-R (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19SR_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19SR_OLD_Month_Vector.csv']);
        end
              
    case "PG&E E-19S (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19S_NEW_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19S_NEW_Month_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19S_PDP_NEW_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19S_PDP_NEW_Month_Vector.csv']);
        end
        
    case "PG&E E-19S-R (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E19SR_NEW_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E19SR_NEW_Month_Vector.csv']);
        end
        
    case "PG&E A-1-STORAGE"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E A-1-STORAGE/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_A1_STORAGE_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E A-1-STORAGE/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_A1_STORAGE_Month_Vector.csv']);
        end
        
    case "PG&E EV-A"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E EV-A/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_EVA_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E EV-A/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_EVA_Month_Vector.csv']);
        end
        
    case "SCE TOU-8-B"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-8-B/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOU8B_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-8-B/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOU8B_Month_Vector.csv']);
        end
        
    case "SCE TOU-8-RTP"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-8-RTP/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_RTP_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-8-RTP/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_RTP_Month_Vector.csv']);
        end
        
    case "SDG&E DG-R"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_DGR_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_DGR_Month_Vector.csv']);
        end
        
end


% Import IOU-Proposed Charge and Discharge Hour Flag Vectors

if Carbon_Reduction_Strategy == "IOU-Proposed Charge-Discharge Time Constraints"
    
    if delta_t == (5/60)
        IOU_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/'...
            'Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv']);
        IOU_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/' ...
            'Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv']);
    elseif delta_t == (15/60)
        IOU_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/'...
            'Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv']);
        IOU_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/' ...
            'Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv']);
    end
    
end

% Import PG&E-Proposed Charge, No-Charge, and Discharge Hour Flag Vectors

if Carbon_Reduction_Strategy == "PG&E-Proposed Charge-Discharge Time Constraints"
    
    if delta_t == (5/60)
        PGE_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/5-Minute Data/' ...
            'Vector Format/2017_PGE_Charge_Hour_Flag_Vector.csv']);
        PGE_No_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/5-Minute Data/' ...
            'Vector Format/2017_PGE_No_Charge_Hour_Flag_Vector.csv']);
        PGE_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/5-Minute Data/' ...
            'Vector Format/2017_PGE_Discharge_Hour_Flag_Vector.csv']);
    elseif delta_t == (15/60)
        PGE_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/15-Minute Data/' ...
            'Vector Format/2017_PGE_Charge_Hour_Flag_Vector.csv']);
        PGE_No_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/15-Minute Data/' ...
            'Vector Format/2017_PGE_No_Charge_Hour_Flag_Vector.csv']);
        PGE_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
            'PG&E-Proposed Charge-Discharge Constraint/2017/15-Minute Data/' ...
            'Vector Format/2017_PGE_Discharge_Hour_Flag_Vector.csv']);
    end
    
end

%% Iterate Through Months & Filter Data to Selected Month

% Initialize Blank Variables to store optimal decision variable values for
% all months

% Initialize Decision Variable Vectors
P_ES_in = [];

P_ES_out = [];

Ene_Lvl = [];

P_max_NC = [];
    
P_max_peak = [];
    
P_max_part_peak = [];
    

% Initialize Monthly Cost Variable Vectors

Fixed_Charge_Vector = [];

NC_DC_wo_Storage_Vector = [];
NC_DC_w_Storage_Vector = [];

CPK_DC_wo_Storage_Vector = [];
CPK_DC_w_Storage_Vector = [];

CPP_DC_wo_Storage_Vector = [];
CPP_DC_w_Storage_Vector = [];
    
Energy_Charge_wo_Storage_Vector = [];
Energy_Charge_w_Storage_Vector = [];

Cycles_Vector = [];
Cycling_Penalty_Vector = [];


for Month_Iter = 1:12 % Iterate through all months
    
    % Filter Load Profile Data to Selected Month
    Load_Profile_Data_Month = Load_Profile_Data(Month_Data == Month_Iter, :);
    
    % Filter Volumetric Rate Data to Selected Month
    Volumetric_Rate_Data_Month = Volumetric_Rate_Data(Month_Data == Month_Iter, :);
    
    % Filter Marginal Emissions Data to Selected Month
    
    Marginal_Emissions_Rate_Forecast_Data_Month = ...
        Marginal_Emissions_Rate_Forecast_Data(Month_Data == Month_Iter, :);
    
    % Filter Carbon Adder Data to Selected Month
    
    Carbon_Adder_Data_Month = Carbon_Adder_Data(Month_Data == Month_Iter, :);
    
    % Set Demand Charge Values Based on Month
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        
        Peak_DC = Summer_Peak_DC;
        Part_Peak_DC = Summer_Part_Peak_DC;
        Noncoincident_DC = Summer_Noncoincident_DC;
        
    else
        
        Peak_DC = Winter_Peak_DC;
        Part_Peak_DC = Winter_Part_Peak_DC;
        Noncoincident_DC = Winter_Noncoincident_DC;
        
    end
    
    
    % Filter Peak and Part-Peak Binary Data to Selected Month
    
    if Summer_Peak_DC > 0
        Summer_Peak_Binary_Data_Month = Summer_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Summer_Part_Peak_DC > 0
        Summer_Part_Peak_Binary_Data_Month = Summer_Part_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Winter_Peak_DC > 0
        Winter_Peak_Binary_Data_Month = Winter_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Winter_Part_Peak_DC > 0
        Winter_Part_Peak_Binary_Data_Month = Winter_Part_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    % Filter IOU-Proposed Charge and Discharge Hour Binary Data to Selected Month
    if Carbon_Reduction_Strategy == "IOU-Proposed Charge-Discharge Time Constraints"
        IOU_Charge_Hour_Binary_Data_Month = IOU_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        IOU_Discharge_Hour_Binary_Data_Month = IOU_Discharge_Hour_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    
    % Filter PG&E-Proposed Charge and Discharge Hour Binary Data to Selected Month
    if Carbon_Reduction_Strategy == "PG&E-Proposed Charge-Discharge Time Constraints"
        PGE_Charge_Hour_Binary_Data_Month = PGE_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        PGE_No_Charge_Hour_Binary_Data_Month = PGE_No_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        PGE_Discharge_Hour_Binary_Data_Month = PGE_Discharge_Hour_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    
    %% Add "Padding" to Beginning and End of Every Month of Data
    
    % Pad Load Profile Data
    Load_Profile_Data_Month_Padded = [Load_Profile_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
        Load_Profile_Data_Month;
        Load_Profile_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    
    
    % Pad Volumetric Rate Data
    Volumetric_Rate_Data_Month_Padded = [Volumetric_Rate_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
        Volumetric_Rate_Data_Month;
        Volumetric_Rate_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    
    % Pad Marginal Emissions Data
    
    Marginal_Emissions_Rate_Data_Month_Padded = ...
        [Marginal_Emissions_Rate_Forecast_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
        Marginal_Emissions_Rate_Forecast_Data_Month;
        Marginal_Emissions_Rate_Forecast_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    
    % Pad Carbon Adder Data
    
    Carbon_Adder_Data_Month_Padded = [Carbon_Adder_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
        Carbon_Adder_Data_Month;
        Carbon_Adder_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    
    
    % Pad Peak and Part-Peak Binary Data
  
    if Summer_Peak_DC > 0
        Summer_Peak_Binary_Data_Month_Padded = ...
            [Summer_Peak_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            Summer_Peak_Binary_Data_Month;
            Summer_Peak_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    if Summer_Part_Peak_DC > 0
        Summer_Part_Peak_Binary_Data_Month_Padded = ...
            [Summer_Part_Peak_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            Summer_Part_Peak_Binary_Data_Month;
            Summer_Part_Peak_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    if Winter_Peak_DC > 0
        Winter_Peak_Binary_Data_Month_Padded = ...
            [Winter_Peak_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            Winter_Peak_Binary_Data_Month;
            Winter_Peak_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    if Winter_Part_Peak_DC > 0
        Winter_Part_Peak_Binary_Data_Month_Padded = ...
            [Winter_Part_Peak_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            Winter_Part_Peak_Binary_Data_Month;
            Winter_Part_Peak_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    % Pad IOU-Proposed Charge and Discharge Hour Binary Data
    if Carbon_Reduction_Strategy == "IOU-Proposed Charge-Discharge Time Constraints"
        IOU_Charge_Hour_Binary_Data_Month_Padded = ...
            [IOU_Charge_Hour_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            IOU_Charge_Hour_Binary_Data_Month;
            IOU_Charge_Hour_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        IOU_Discharge_Hour_Binary_Data_Month_Padded = ...
            [IOU_Discharge_Hour_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            IOU_Discharge_Hour_Binary_Data_Month;
            IOU_Discharge_Hour_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    
    % Pad PG&E-Proposed Charge and Discharge Hour Binary Data
    if Carbon_Reduction_Strategy == "PG&E-Proposed Charge-Discharge Time Constraints"
        PGE_Charge_Hour_Binary_Data_Month_Padded = ...
            [PGE_Charge_Hour_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            PGE_Charge_Hour_Binary_Data_Month;
            PGE_Charge_Hour_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        PGE_No_Charge_Hour_Binary_Data_Month_Padded = ...
            [PGE_No_Charge_Hour_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            PGE_No_Charge_Hour_Binary_Data_Month;
            PGE_No_Charge_Hour_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        PGE_Discharge_Hour_Binary_Data_Month_Padded = ...
            [PGE_Discharge_Hour_Binary_Data_Month(1:(Padding_Days * 24 * (1/delta_t)));
            PGE_Discharge_Hour_Binary_Data_Month;
            PGE_Discharge_Hour_Binary_Data_Month(end-(Padding_Days * 24 * (1/delta_t) - 1):end)];
    end
    
    %% Initialize Cost Vector "c"
    
    % nts = numtsteps = number of timesteps
    numtsteps = length(Load_Profile_Data_Month_Padded);
    all_tsteps = linspace(1,numtsteps, numtsteps)';
    
    % x = [P_ES_in_grid(size nts); P_ES_out(size nts); Ene_Lvl(size nts);...
    % P_max_NC (size 1); P_max_peak (size 1); P_max_part_peak (size 1)];
    
    c_Month_Bill_Only = [(Volumetric_Rate_Data_Month_Padded * delta_t); ...
        (-Volumetric_Rate_Data_Month_Padded * delta_t); ...
        zeros(numtsteps, 1);
        Noncoincident_DC
        Peak_DC;
        Part_Peak_DC];      
        
    c_Month_Carbon_Only = [(Carbon_Adder_Data_Month_Padded * delta_t); ...
        (-Carbon_Adder_Data_Month_Padded * delta_t); ...
        zeros(numtsteps, 1);
        0
        0;
        0];
    
    c_Month_Degradation_Only = [(((Eff_c * cycle_pen)/(2 * Size_ES)) * delta_t) * ones(numtsteps,1); ...
        ((cycle_pen/(Eff_d * 2 * Size_ES)) * delta_t) * ones(numtsteps,1); ...
        zeros(numtsteps, 1);
        0
        0;
        0];
    
    c_Month = c_Month_Bill_Only + c_Month_Carbon_Only + c_Month_Degradation_Only;
    
    % This is the length of the vectors c and x, or the total number of decision variables.
    length_x = length(c_Month);
    
    
    %% State Variable Indices
    
    % P_ES_in = x(1:numtsteps);
    % P_ES_out = x(numtsteps+1:2*numtsteps);
    % Ene_Lvl = x(2*numtsteps+1:3*numtsteps);
    % P_max_NC = x(3*numtsteps+1);
    % P_max_peak = x(3*numtsteps+2);
    % P_max_part_peak = x(3*numsteps+3);
    
    %% State of Charge Constraint
    
    % This constraint represents conservation of energy as it flows into and out of the
    % energy storage system, while accounting for efficiency losses.
    
    %For t in [0, numsteps-1]:
    
    % E(t+1) = E(t) + [Eff_c*P_ES_in(t) - (1/Eff_d)*P_ES_out(t)] * delta_t
    
    % E(t) - E(t+1) + Eff_c*P_ES_in(t) * delta_t - (1/Eff_d)*P_ES_out(t) * delta_t = 0
    
    % An equality constraint can be transformed into two inequality constraints
    % Ax = 0 -> Ax <=0 , -Ax <=0
    
    % Number of rows in each inequality constraint matrix = (numtsteps - 1)
    % Number of columns in each inequality constraint matrix = number of
    % decision variables = length_x
    
    A_E = sparse(numtsteps-1,length_x);
    b_E = sparse(numtsteps-1,1);
    
    for n = 1:(numtsteps-1)
        A_E(n, n + (2 * numtsteps)) = 1;
        A_E(n, n + (2 * numtsteps) + 1) = -1;
        A_E(n, n) = Eff_c * delta_t;
        A_E(n, n + numtsteps) = (-1/Eff_d) * delta_t;
    end
    
    A_Month = [A_E;-A_E];
    
    b_Month = [b_E;-b_E];
    
    
    
    %% Energy Storage Charging Power Constraint
    
    % This constraint sets maximum and minimum values for P_ES_in.
    % The minimum is 0 kW, and the maximum is P_ES_Max.
    
    % P_ES_in >= 0 -> -P_ES_in <= 0
    
    % P_ES_in <= P_ES_max
    
    % Number of rows in inequality constraint matrix = numtsteps
    % Number of columns in inequality constraint matrix = length_x
    A_P_ES_in = sparse(numtsteps, length_x);
    
    
    for n = 1:numtsteps
        A_P_ES_in(n, n) = -1;
    end
    
    A_Month = [A_Month; A_P_ES_in; -A_P_ES_in];
    
    b_Month = [b_Month; sparse(numtsteps,1); P_ES_max * ones(numtsteps,1)];
    
    %% Energy Storage Discharging Power Constraint
    
    % This constraint sets maximum and minimum values for P_ES_out.
    % The minimum is 0 kW, and the maximum is P_ES_Max.
    
    % P_ES_out >= 0 -> -P_ES_out <= 0
    
    % P_ES_out <= P_ES_max
    
    A_P_ES_out = sparse(numtsteps, length_x);
    
    for n = 1:numtsteps
        A_P_ES_out(n, n + numtsteps) = -1;
    end
    
    A_Month = [A_Month; A_P_ES_out; -A_P_ES_out];
    
    b_Month = [b_Month; sparse(numtsteps,1); P_ES_max * ones(numtsteps,1)];
    
    %% State of Charge Minimum/Minimum Constraints
    
    % This constraint sets maximum and minimum values on the Energy Level.
    % The minimum value is 0, and the maximum value is Size_ES, the size of the
    % battery. Note: this optimization defines the range [0,Size_ES] as the
    % effective storage capacity of the battery, without accounting for
    % depth of discharge.
    
    % Ene_Lvl(t) >= 0 -> -Ene_Lvl(t) <=0
    
    A_Ene_Lvl_min = sparse(numtsteps, length_x);
    b_Ene_Lvl_min = sparse(numtsteps, 1);
    
    for n = 1:numtsteps
        A_Ene_Lvl_min(n, n + (2 * numtsteps)) = -1;
    end
    
    A_Month = [A_Month;A_Ene_Lvl_min];
    b_Month = [b_Month;b_Ene_Lvl_min];
    
    
    % Ene_Lvl(t) <= Size_ES
    
    A_Ene_Lvl_max = sparse(numtsteps, length_x);
    b_Ene_Lvl_max = Size_ES * ones(numtsteps,1);
    
    for n = 1:numtsteps
        A_Ene_Lvl_max(n, n + (2 * numtsteps)) = 1;
    end
    
    A_Month = [A_Month; A_Ene_Lvl_max];
    
    b_Month = [b_Month; b_Ene_Lvl_max];
    
    %% Initial State of Charge Constraint
    
    % This constraint initializes the state of charge of the battery at 50%.
    
    % E(0) = 0.5 * Size_ES -> E(0) <= 0.5 * Size_ES, -E(0) <= Size_ES
    
    A_Ene_Lvl_0 = sparse(1, length_x);
    
    A_Ene_Lvl_0(1, (2*numtsteps) + 1) = 1;
    
    b_Ene_Lvl_0 = 0.5 * Size_ES;
    
    A_Month = [A_Month; A_Ene_Lvl_0; -A_Ene_Lvl_0];
    
    b_Month = [b_Month; b_Ene_Lvl_0; -b_Ene_Lvl_0];
    
    %% Final State of Charge Constraints
    
    % This constraint fixes the final state of charge of the battery at 50%,
    % to prevent it from discharging completely in the final timesteps.
    
    % E(N) = 0.5 * Size_ES -> E(N) <= 0.5 * Size_ES, -E(N) <= Size_ES
    
    A_Ene_Lvl_N = sparse(1, length_x);
    
    A_Ene_Lvl_N(1, 3 * numtsteps) = 1;
    
    b_Ene_Lvl_N = 0.5 * Size_ES;
    
    A_Month = [A_Month; A_Ene_Lvl_N; -A_Ene_Lvl_N];
    
    b_Month = [b_Month; b_Ene_Lvl_N; -b_Ene_Lvl_N];
    
    
    %% Noncoincident Demand Charge Constraint
    
    % This constraint linearizes the noncoincident demand charge constraint.
    % Setting the demand charge value as a decision variable incentivizes
    % "demand capping" to reduce the value of max(P_load(t)) to an optimal
    % level without using the nonlinear max() operator.
    % The noncoincident demand charge applies across all 15-minute intervals.
    
    % P_load(t) + P_ES_in(t) - P_ES_out(t) <= P_max_NC for all t
    % P_ES_in(t) - P_ES_out(t) - P_max_NC <= - P_load(t) for all t
    
    if Noncoincident_DC > 0
        
        A_NC_DC = sparse(numtsteps, length_x);
        b_NC_DC = -Load_Profile_Data_Month_Padded;
        
        for n = 1:numtsteps
            A_NC_DC(n, n) = 1;
            A_NC_DC(n, n + numtsteps) = -1;
            A_NC_DC(n, (3*numtsteps) + 1) = -1;
            
        end
        
        A_Month = [A_Month; A_NC_DC];
        b_Month = [b_Month; b_NC_DC];
        
    end
    
    % Add P_max_NC >=0 Constraint
    % -P_max_NC <= 0
    % Note: this non-negativity constraint is added even if the noncoincident
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_NC goes to zero, and is not negative.
    
    A_NC_DC_gt0 = sparse(1, length_x);
    A_NC_DC_gt0(1, (3 * numtsteps) + 1) = -1;
    b_NC_DC_gt0 = 0;
    
    A_Month = [A_Month; A_NC_DC_gt0];
    b_Month = [b_Month; b_NC_DC_gt0];
    
    
    %% Coincident Peak Demand Charge Constraint
    
    % This constraint linearizes the coincident peak demand charge constraint.
    % This demand charge only applies for peak hours.
    
    % P_load(t) + P_ES_in(t) - P_ES_out(t) <= P_max_peak for Peak t only
    % P_ES_in(t) - P_ES_out(t) - P_max_peak <= - P_load(t) for Peak t only
    
    if Peak_DC > 0
        
        if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
            Peak_Indices = all_tsteps(Summer_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPK_DC = sparse(sum(Summer_Peak_Binary_Data_Month_Padded), length_x);
            b_CPK_DC = -Load_Profile_Data_Month_Padded(Summer_Peak_Binary_Data_Month_Padded == 1, :);
  
        else
            Peak_Indices = all_tsteps(Winter_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPK_DC = sparse(sum(Winter_Peak_Binary_Data_Month_Padded), length_x);
            b_CPK_DC = -Load_Profile_Data_Month_Padded(Winter_Peak_Binary_Data_Month_Padded == 1, :);
        end
        
        for n = 1:length(Peak_Indices)
            A_CPK_DC(n, Peak_Indices(n)) = 1;
            A_CPK_DC(n, numtsteps + Peak_Indices(n)) = -1;
            A_CPK_DC(n, (3*numtsteps) + 2) = -1;
        end
        
        A_Month = [A_Month; A_CPK_DC];
        b_Month = [b_Month; b_CPK_DC];
        
    end
    
    
    % Add P_max_peak >=0 Constraint
    % -P_max_peak <= 0
    % Note: this non-negativity constraint is added even if the coincident peak
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_peak goes to zero, and is not negative.
    
    A_CPK_DC_gt0 = sparse(1, length_x);
    A_CPK_DC_gt0(1, (3 * numtsteps) + 2) = -1;
    b_CPK_DC_gt0 = 0;
    
    A_Month = [A_Month; A_CPK_DC_gt0];
    b_Month = [b_Month; b_CPK_DC_gt0];
    
    
    %% Coincident Part-Peak Demand Charge Constraint
    
    % This constraint linearizes the coincident part-peak demand charge
    % constraint.
    % This demand charge only applies for part-peak hours.
    
    % P_load(t) + P_ES_in(t) - P_ES_out(t) <= P_max_part_peak for Part-Peak t only
    % P_ES_in(t) - P_ES_out(t) - P_max_part_peak <= - P_load(t) for Part-Peak t only
    
    if Part_Peak_DC > 0
        
        if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
            Part_Peak_Indices = all_tsteps(Summer_Part_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPP_DC = sparse(sum(Summer_Part_Peak_Binary_Data_Month_Padded), length_x);
            b_CPP_DC = -Load_Profile_Data_Month_Padded(Summer_Part_Peak_Binary_Data_Month_Padded == 1, :);
            
        else
            Part_Peak_Indices = all_tsteps(Winter_Part_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPP_DC = sparse(sum(Winter_Part_Peak_Binary_Data_Month_Padded), length_x);
            b_CPP_DC = -Load_Profile_Data_Month_Padded(Winter_Part_Peak_Binary_Data_Month_Padded == 1, :);
        end
        
        for n = 1:length(Part_Peak_Indices)
            A_CPP_DC(n, Part_Peak_Indices(n)) = 1;
            A_CPP_DC(n, numtsteps + Part_Peak_Indices(n)) = -1;
            A_CPP_DC(n, (3*numtsteps) + 3) = -1;
        end
        
        A_Month = [A_Month; A_CPP_DC];
        b_Month = [b_Month; b_CPP_DC];
        
        
    end
    
    % Add P_max_part_peak >=0 Constraint
    % -P_max_part_peak <= 0
    % Note: this non-negativity constraint is added even if the coincident part-peak
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_part_peak goes to zero, and is not negative.
    
    A_CPP_DC_gt0 = sparse(1, length_x);
    A_CPP_DC_gt0(1, (3 * numtsteps) + 3) = -1;
    b_CPP_DC_gt0 = 0;
    
    A_Month = [A_Month; A_CPP_DC_gt0];
    b_Month = [b_Month; b_CPP_DC_gt0];
    
    
    %% Optional Constraint - Investor-Owned-Utility-Proposed Charge-Discharge Hours
    
    if Carbon_Reduction_Strategy == "IOU-Proposed Charge-Discharge Time Constraints"
        
        % The Investor-Owned Utilities have suggested constraints on charging in particular hours
        % as a proposed method for reducing greenhouse gas emissions associated with storage dispatch.
        % Specifically, at least 50% of total charging would need to occur between 12:00 noon and 4:00 pm,
        % and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.
        
        % Derivation of charging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_in(t) between 12:00 and 4:00/sum of all P_ES_in(t) >= 0.5
        % Sum of all P_ES_in(t) between 12:00 and 4:00 >= 0.5 * sum of all P_ES_in(t)
        % 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00
        % 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00 <= 0
        % 0.5 * sum of all P_ES_in(t) not between 12:00 and 4:00 - 0.5 * sum of all P_ES_in(t)
        % between 12:00 and 4:00 <= 0.
        
        % Charging Constraint
        A_IOU_Charge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_in(t)
        A_IOU_Charge(1, 1:numtsteps) = 0.5;
        IOU_Charge_Hour_Indices = all_tsteps(IOU_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
        A_IOU_Charge(1, IOU_Charge_Hour_Indices) = -0.5;
        
        b_IOU_Charge = 0;
        
        A_Month = [A_Month; A_IOU_Charge];
        b_Month = [b_Month; b_IOU_Charge];
        
        % Derivation of discharging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
        % Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
        % 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
        % 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
        % 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
        % between 4:00 and 9:00 <= 0.
        
        % Discharging Constraint
        A_IOU_Discharge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_out(t)
        A_IOU_Discharge(1, numtsteps+1:2*numtsteps) = 0.5;
        IOU_Discharge_Hour_Indices = all_tsteps(IOU_Discharge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
        A_IOU_Discharge(1, numtsteps + IOU_Discharge_Hour_Indices) = -0.5;
        
        b_IOU_Discharge = 0;
        
        A_Month = [A_Month; A_IOU_Discharge];
        b_Month = [b_Month; b_IOU_Discharge];
        
    end
    
    
    %% Optional Constraint - PG&E-Proposed Charge-Discharge Hours
    
    if Carbon_Reduction_Strategy == "PG&E-Proposed Charge-Discharge Time Constraints"
        
        % PG&E has also suggested another set of time-based constraints on storage charging.
        % At least 50% of total charging would need to occur between 9:00 am and 2:00 pm,
        % and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.
        % In addition, storage would not be allowed to discharge between 4:00 pm and 9:00 pm.
        
        % Derivation of charging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_in(t) between 9:00 and 2:00/sum of all P_ES_in(t) >= 0.5
        % Sum of all P_ES_in(t) between 9:00 and 2:00 >= 0.5 * sum of all P_ES_in(t)
        % 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00
        % 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00 <= 0
        % 0.5 * sum of all P_ES_in(t) not between 9:00 and 2:00 - 0.5 * sum of all P_ES_in(t)
        % between 9:00 and 2:00 <= 0.
        
        % Charging Constraint
        A_PGE_Charge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_in(t)
        A_PGE_Charge(1, 1:numtsteps) = 0.5;
        PGE_Charge_Hour_Indices = all_tsteps(PGE_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
        A_PGE_Charge(1, PGE_Charge_Hour_Indices) = -0.5;
        
        b_PGE_Charge = 0;
        
        A_Month = [A_Month; A_PGE_Charge];
        b_Month = [b_Month; b_PGE_Charge];
        
        
        % No-Charging Constraint
        % Charging power in each timestep is set equal to 0 between 4:00 pm and 9:00 pm.
        % Because charging power is constrained to be greater than
        % zero, setting the sum of all charging power timesteps to 0 (a
        % single constraint across all timesteps) ensures that all values will be zero
        % without needing to set a constraint for each timestep.
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00 = 0
        % Because of nonnegative constraint on P_ES_in(t), this is
        % equivalent to a set of numtsteps constraints stating that
        % all P_ES_in(t) between 4:00 and 9:00 = 0 for each timestep.
        
        A_PGE_No_Charge = sparse(1, length_x);
        PGE_No_Charge_Hour_Indices = all_tsteps(PGE_No_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00
        A_PGE_No_Charge(1, PGE_No_Charge_Hour_Indices) = 1;
        
        b_PGE_No_Charge = 0;
        
        A_Month = [A_Month; A_PGE_No_Charge];
        b_Month = [b_Month; b_PGE_No_Charge];
        
        
        % Derivation of discharging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
        % Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
        % 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
        % 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
        % 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
        % between 4:00 and 9:00 <= 0.
        
        % Discharging Constraint
        A_PGE_Discharge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_out(t)
        A_PGE_Discharge(1, numtsteps+1:2*numtsteps) = 0.5;
        PGE_Discharge_Hour_Indices = all_tsteps(PGE_Discharge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
        A_PGE_Discharge(1, numtsteps + PGE_Discharge_Hour_Indices) = -0.5;
        
        b_PGE_Discharge = 0;
        
        A_Month = [A_Month; A_PGE_Discharge];
        b_Month = [b_Month; b_PGE_Discharge];
        
    end
    
    
    %% Optional Constraint - Non-Positive GHG Emissions Impact
    
    % Note - the system is following the forecast signal to obey
    % this constraint, not the evaluation signal. It may be necessary
    % to adjust this constraint to aim for a negative GHG impact
    % based on the forecast signal, in order to achieve a non-positive
    % GHG impact as measured by the evaluation signal.
    
    if Carbon_Reduction_Strategy == "Non-Positive GHG Constraint"
        
        % The sum of the net battery charge/discharge load in each
        % timestep, multiplied by the marginal emissions rate in each
        % timestep, must be less than or equal to 0.
        
        % A_Non_Positive_GHG is similar to c_Month_Carbon_Only,
        % but with Marginal Emissions Rate Data instead of Carbon Adder Data and transposed.
        A_Non_Positive_GHG = [(Marginal_Emissions_Rate_Data_Month_Padded * delta_t); ...
            (-Marginal_Emissions_Rate_Data_Month_Padded * delta_t); ...
            zeros(numtsteps, 1);
            0
            0;
            0]';
        
        b_Non_Positive_GHG = 0;
        
        A_Month = [A_Month; A_Non_Positive_GHG];
        b_Month = [b_Month; b_Non_Positive_GHG];
        
        
    end
    
    
    %% Optional Constraint - Equivalent Cycling Constraint
    
    % Note: due to the OSESMO model structure, the annual cycling requirement 
    % must be converted to an equivalent monthly cycling requirement.
    
    if Carbon_Reduction_Strategy == "Equivalent Cycling Constraint"
    
        % Set SGIP Cycling Requirement - 52 if residential, 130 if C&I
        if contains(lower(Load_Profile_Input), "residential")
            SGIP_Annual_Cycling_Requirement = 52;
        else
            SGIP_Annual_Cycling_Requirement = 130;
        end
        
        SGIP_Monthly_Cycling_Requirement = SGIP_Annual_Cycling_Requirement * ...
            (length(Load_Profile_Data_Month_Padded)/length(Load_Profile_Data));
        
        % Formula for equivalent cycles is identical to the one used to calculate Cycles_Month:
        % Equivalent Cycles = sum((P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)) + ...
        %    (P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)));
        
        % Equivalent Cycles >= SGIP_Monthly_Cycling Requirement
        % To convert to standard linear program form, multiply both sides by -1.
        % -Equivalent Cycles <= -SGIP_Monthly_Cycling_Requirement
        
        A_Equivalent_Cycles = sparse(1, length_x);
        
        % sum of all P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)
        A_Equivalent_Cycles(1, 1:numtsteps) = -(((Eff_c)/(2 * Size_ES)) * delta_t);
        
        % sum of all P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)
        A_Equivalent_Cycles(1, numtsteps+1:2*numtsteps) = -((1/(Eff_d * 2 * Size_ES)) * delta_t);
        
        b_Equivalent_Cycles = -SGIP_Monthly_Cycling_Requirement;
        
        A_Month = [A_Month; A_Equivalent_Cycles];
        b_Month = [b_Month; b_Equivalent_Cycles];
    
    end
    
    
    %% Optional Constraint - Operational/SGIP Round-Trip Efficiency Constraint
    
    % Note: due to the OSESMO model structure, the annual RTE requirement 
    % must be converted to an equivalent monthly RTE requirement.
    
    if Carbon_Reduction_Strategy == "SGIP RTE Constraint"
        
       % Formula for Operational/SGIP efficiency is identical to the one
       % used to calculate Operational_RTE_Percent:
       % Operational_RTE_Percent = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t) * 100;
       % Note that Auxiliary_Storage_Load has to be added to P_ES_in here.
       % During the calculation of Operational_RTE_Percent, it has already
       % been added previously, so it does not need to be included in the
       % formula the way it is here.
       
       % "The Commission concluded that storage devices should demonstrate
       % an average RTE of at least 66.5% over ten years (equivalent to a
       % first-year RTE of 69.6%) in order to qualify for SGIP incentive
       % payments." (Stem, Inc.'s Petition for Modification of Decision 15-11-027, pg. 2)
       
       % Operational RTE Percent >= 69.6
       % (sum(P_ES_out) * delta_t)/((sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t) * 100 >= 69.6
       % (sum(P_ES_out) * delta_t) >= 0.696 * (sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t)
       % To convert to standard linear program form, multiply both sides by -1.
       % -(sum(P_ES_out) * delta_t) <= -0.696 * (sum(P_ES_in) * delta_t) -(sum(Auxiliary_Storage_Load) * delta_t)
       % -(sum(P_ES_out) * delta_t) + 0.696 * (sum(P_ES_in) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)
       % 0.696 * (sum(P_ES_in) * delta_t) -(sum(P_ES_out) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)
                    
       A_SGIP_RTE = sparse(1, length_x);
       
       % sum of all (P_ES_in(t) * (0.696 * delta_t)
       A_SGIP_RTE(1, 1:numtsteps) = (0.696 * delta_t);
       
       % sum of all P_ES_out(t) * -delta_t
       A_SGIP_RTE(1, numtsteps+1:2*numtsteps) = -delta_t;
       
       % (sum(Auxiliary_Storage_Load) * delta_t)
       b_SGIP_RTE = -((numtsteps * Auxiliary_Storage_Load) * delta_t);
       
       A_Month = [A_Month; A_SGIP_RTE];
       b_Month = [b_Month; b_SGIP_RTE];
       
    end
    
    
    %% Run LP Optimization Algorithm
    
    options = optimset('Display','none'); % Suppress "Optimal solution found" message.
    
    x_Month = linprog(c_Month,A_Month,b_Month, [], [], [], [], options); % Set Aeq, beq, LB, UB to []
    
    sprintf('Optimization complete for Month %d.', Month_Iter)
    
    %% Separate Decision Variable Vectors
    
    P_ES_in_Month_Padded = x_Month(1:numtsteps);
    
    P_ES_out_Month_Padded = x_Month(numtsteps+1:2*numtsteps);
    
    Ene_Lvl_Month_Padded = x_Month(2*numtsteps+1:3*numtsteps);
    
    
    %% Add Auxiliary Load/Parasitic Losses to P_ES_in
    
    P_ES_in_Month_Padded = P_ES_in_Month_Padded + Auxiliary_Storage_Load;
    
    
    %% Remove "Padding" from Decision Variables
    
    P_ES_in_Month_Unpadded = P_ES_in_Month_Padded((Padding_Days * 24 * ...
        (1/delta_t)+1):(end-(Padding_Days * 24 * (1/delta_t))));
    
    P_ES_out_Month_Unpadded = P_ES_out_Month_Padded((Padding_Days * 24 * ...
        (1/delta_t)+1):(end-(Padding_Days * 24 * (1/delta_t))));
    
    Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded((Padding_Days * 24 * ...
        (1/delta_t)+1):(end-(Padding_Days * 24 * (1/delta_t))));
    
    
    %% Calculate Monthly Peak Demand Using 15-Minute Intervals
    
    % Demand Charges are Based on 15-minute interval periods.
    % If the model has 15-minute timestep resolution, the decision
    % variables can be used directly as maximum coincident and noncoincident demand values.
    % Otherwise (such as with 5-minute timestep resolution), maximum
    % demand must be calculated by taking 15-minute averages of the
    % demand values, and then calculating the maximum of these averages.
    
    if delta_t < (15/60)
        
        % Noncoincident Maximum Demand With and Without Storage
               
            % Create Net Load Profile
            Net_Load_Profile_Data_Month_5_Min = (Load_Profile_Data_Month + ...
                P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded);
            
            % Number of timesteps to average to get 15-minute net load data.
            Reshaped_Rows_Num = (15/60)/delta_t;
            
            % Reshape load data so that each 15-minute increment's data
            % is in the same column. This creates an array with 3 rows for 5-minute data.
            Load_Profile_Data_Month_Reshaped = reshape(Load_Profile_Data_Month, Reshaped_Rows_Num, ...
                length(Load_Profile_Data_Month)/Reshaped_Rows_Num);
            
            Net_Load_Profile_Data_Month_5_Min_Reshaped = reshape(Net_Load_Profile_Data_Month_5_Min, ...
                Reshaped_Rows_Num, length(Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            % Create 15-minute load profiles by calculating the average of each column.
            Load_Profile_Data_Month_15_Min = mean(Load_Profile_Data_Month_Reshaped, 1);
            Net_Load_Profile_Data_Month_15_Min = mean(Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            % Calculate Noncoincident Maximum Demand
            P_max_NC_Month_Without_Storage = max(Load_Profile_Data_Month_15_Min);
            P_max_NC_Month_With_Storage = max(Net_Load_Profile_Data_Month_15_Min);
               
        
        % Coincident Peak Demand With and Without Storage
        
        if Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                
                % Create Coincident Peak Load and Net Load Profiles
                Coincident_Peak_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :);
                
                Coincident_Peak_Net_Load_Profile_Data_Month_5_Min = ...
                    Net_Load_Profile_Data_Month_5_Min(Summer_Peak_Binary_Data_Month == 1, :);
                
            else
                
                % Create Coincident Peak Load and Net Load Profiles
                Coincident_Peak_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :);
                
                Coincident_Peak_Net_Load_Profile_Data_Month_5_Min = ...
                    Net_Load_Profile_Data_Month_5_Min(Winter_Peak_Binary_Data_Month == 1, :);
                
            end
            
            % Reshape load data so that each 15-minute increment's data
            % is in the same column. This creates an array with 3 rows for 5-minute data.
            Coincident_Peak_Load_Profile_Data_Month_Reshaped = ...
                reshape(Coincident_Peak_Load_Profile_Data_Month, Reshaped_Rows_Num, ...
                length(Coincident_Peak_Load_Profile_Data_Month)/Reshaped_Rows_Num);
            
            Coincident_Peak_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(Coincident_Peak_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(Coincident_Peak_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            % Create 15-minute load profiles by calculating the average of each column.
            Coincident_Peak_Load_Profile_Data_Month_15_Min = ...
                mean(Coincident_Peak_Load_Profile_Data_Month_Reshaped, 1);
            
            Coincident_Peak_Net_Load_Profile_Data_Month_15_Min = ...
                mean(Coincident_Peak_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            % Calculate Coincident Peak Demand
            P_max_CPK_Month_Without_Storage = max(Coincident_Peak_Load_Profile_Data_Month_15_Min);
            P_max_CPK_Month_With_Storage = max(Coincident_Peak_Net_Load_Profile_Data_Month_15_Min);
            
        else
            
            % If there is no Coincident Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
            P_max_CPK_Month_Without_Storage = 0;
            P_max_CPK_Month_With_Storage = 0;
            
        end
        
        
        % Coincident Part-Peak Demand With and Without Storage
        
        if Part_Peak_DC > 0
        
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                
                % Create Coincident Part-Peak Load and Net Load Profiles
                Coincident_Part_Peak_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :);
                
                Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min = ...
                    Net_Load_Profile_Data_Month_5_Min(Summer_Part_Peak_Binary_Data_Month == 1, :);
                
            else
                
                % Create Coincident Part-Peak Load and Net Load Profiles
                Coincident_Part_Peak_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :);
                
                Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min = ...
                    Net_Load_Profile_Data_Month_5_Min(Winter_Part_Peak_Binary_Data_Month == 1, :);
                
            end
            
            % Reshape load data so that each 15-minute increment's data
            % is in the same column. This creates an array with 3 rows for 5-minute data.
            Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped = ...
                reshape(Coincident_Part_Peak_Load_Profile_Data_Month, Reshaped_Rows_Num, ...
                length(Coincident_Part_Peak_Load_Profile_Data_Month)/Reshaped_Rows_Num);
            
            Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            % Create 15-minute load profiles by calculating the average of each column.
            Coincident_Part_Peak_Load_Profile_Data_Month_15_Min = ...
                mean(Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped, 1);
            
            Coincident_Part_Peak_Net_Load_Profile_Data_Month_15_Min = ...
                mean(Coincident_Part_Peak_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            % Calculate Coincident Part-Peak Demand
            P_max_CPP_Month_Without_Storage = max(Coincident_Part_Peak_Load_Profile_Data_Month_15_Min);
            P_max_CPP_Month_With_Storage = max(Coincident_Part_Peak_Net_Load_Profile_Data_Month_15_Min);
        
        else
            
            % If there is no Coincident Part-Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
            P_max_CPP_Month_Without_Storage = 0;
            P_max_CPP_Month_With_Storage = 0;
            
        end
        
        
    elseif delta_t == (15/60)
        
        % Noncoincident Maximum Demand With and Without Storage
        
        P_max_NC_Month_Without_Storage = max(Load_Profile_Data_Month);
        P_max_NC_Month_With_Storage = x_Month(3*numtsteps+1);
        
        
        % Coincident Peak Demand With and Without Storage
        
        if Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                P_max_CPK_Month_Without_Storage = ...
                    max(Load_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :));
            else
                P_max_CPK_Month_Without_Storage = ...
                    max(Load_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :));
            end
            
            P_max_CPK_Month_With_Storage = x_Month(3*numtsteps+2);
            
        else
            
            % If there is no Coincident Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
            P_max_CPK_Month_Without_Storage = 0;
            P_max_CPK_Month_With_Storage = 0;
            
        end
        
        
        % Coincident Part-Peak Demand With and Without Storage
        
        if Part_Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                P_max_CPP_Month_Without_Storage = ...
                    max(Load_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :));
            else
                P_max_CPP_Month_Without_Storage = ...
                    max(Load_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :));
            end
            
            P_max_CPP_Month_With_Storage = x_Month(3*numtsteps+3);
            
        else
            
            % If there is no Coincident Part-Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
            P_max_CPP_Month_Without_Storage = 0;
            P_max_CPP_Month_With_Storage = 0;
            
        end
        
        
    else
        
        error('Timestep is larger than 15 minutes. Cannot properly calculate billing demand.')
        
    end
    
    
    %% Calculate Monthly Bill Cost with and Without Storage
    
    % Monthly Cost from Daily Fixed Charge
    % This value is not affected by the presence of storage.
    Fixed_Charge_Month = Fixed_Per_Meter_Month_Charge + (Fixed_Per_Meter_Day_Charge * length(Load_Profile_Data_Month)/(24 * (1/delta_t)));
    
    % Monthly Cost from Noncoincident Demand Charge - Without Storage
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        NC_Demand_Charge_Month_Without_Storage = Summer_Noncoincident_DC * P_max_NC_Month_Without_Storage;
    else
        NC_Demand_Charge_Month_Without_Storage = Winter_Noncoincident_DC * P_max_NC_Month_Without_Storage;
    end
    
    % Monthly Cost from Noncoincident Demand Charge - With Storage
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        NC_Demand_Charge_Month_With_Storage = Summer_Noncoincident_DC * P_max_NC_Month_With_Storage;
    else
        NC_Demand_Charge_Month_With_Storage = Winter_Noncoincident_DC * P_max_NC_Month_With_Storage;
    end
    
    
    % Monthly Cost from Coincident Peak Demand Charge - Without Storage
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPK_Demand_Charge_Month_Without_Storage = Summer_Peak_DC * P_max_CPK_Month_Without_Storage;
    else
        % There is no coincident peak demand charge in the winter.
        CPK_Demand_Charge_Month_Without_Storage = 0;
    end
    
    
    % Monthly Cost from Coincident Peak Demand Charge - With Storage
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPK_Demand_Charge_Month_With_Storage = Summer_Peak_DC * P_max_CPK_Month_With_Storage;
    else
        % There is no coincident peak demand charge in the winter.
        CPK_Demand_Charge_Month_With_Storage = 0;
    end
    
    
    % Monthly Cost from Coincident Part-Peak Demand Charge - Without Storage
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPP_Demand_Charge_Month_Without_Storage = Summer_Part_Peak_DC * P_max_CPP_Month_Without_Storage;
    else
        CPP_Demand_Charge_Month_Without_Storage = Winter_Part_Peak_DC * P_max_CPP_Month_Without_Storage;
    end
    
    
    % Monthly Cost from Coincident Part-Peak Demand Charge - With Storage
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPP_Demand_Charge_Month_With_Storage = Summer_Part_Peak_DC * P_max_CPP_Month_With_Storage;
    else
        CPP_Demand_Charge_Month_With_Storage = Winter_Part_Peak_DC * P_max_CPP_Month_With_Storage;
    end
    
    
    % Monthly Cost from Volumetric Energy Rates - Without Storage
    Energy_Charge_Month_Without_Storage = (Load_Profile_Data_Month' * Volumetric_Rate_Data_Month) * delta_t;
    
    % Monthly Cost from Volumetric Energy Rates - With Storage
    Net_Load_Profile_Month = Load_Profile_Data_Month + P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded;
    Energy_Charge_Month_With_Storage = (Net_Load_Profile_Month' * Volumetric_Rate_Data_Month) * delta_t;
    
    
    % Monthly Cycling Penalty
    
    Cycles_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c)/(2 * Size_ES)) * delta_t)) + ...
        (P_ES_out_Month_Unpadded * ((1/(Eff_d * 2 * Size_ES)) * delta_t)));
    
    Cycling_Penalty_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c * cycle_pen)/(2 * Size_ES)) * delta_t)) + ...
        (P_ES_out_Month_Unpadded * ((cycle_pen/(Eff_d * 2 * Size_ES)) * delta_t)));
    
    
    %% Concatenate Decision Variable & Monthly Cost Values from Month Iteration
    
    % Decision Variable Concatenation
    P_ES_in = [P_ES_in; P_ES_in_Month_Unpadded];
    
    P_ES_out = [P_ES_out; P_ES_out_Month_Unpadded];
    
    Ene_Lvl = [Ene_Lvl; Ene_Lvl_Month_Unpadded];
    
    P_max_NC = [P_max_NC; P_max_NC_Month_With_Storage];
    
    P_max_peak = [P_max_peak; P_max_CPK_Month_With_Storage];
    
    P_max_part_peak = [P_max_part_peak; P_max_CPP_Month_With_Storage];
    
    
    % Monthly Cost Variable Concatenation
    Fixed_Charge_Vector = [Fixed_Charge_Vector; Fixed_Charge_Month];
    
    NC_DC_wo_Storage_Vector = [NC_DC_wo_Storage_Vector; NC_Demand_Charge_Month_Without_Storage];
    NC_DC_w_Storage_Vector = [NC_DC_w_Storage_Vector; NC_Demand_Charge_Month_With_Storage];
    
    CPK_DC_wo_Storage_Vector = [CPK_DC_wo_Storage_Vector; CPK_Demand_Charge_Month_Without_Storage];
    CPK_DC_w_Storage_Vector = [CPK_DC_w_Storage_Vector; CPK_Demand_Charge_Month_With_Storage];
    
    CPP_DC_wo_Storage_Vector = [CPP_DC_wo_Storage_Vector; CPP_Demand_Charge_Month_Without_Storage];
    CPP_DC_w_Storage_Vector = [CPP_DC_w_Storage_Vector; CPP_Demand_Charge_Month_With_Storage];
    
    Energy_Charge_wo_Storage_Vector = [Energy_Charge_wo_Storage_Vector; Energy_Charge_Month_Without_Storage];
    Energy_Charge_w_Storage_Vector = [Energy_Charge_w_Storage_Vector; Energy_Charge_Month_With_Storage];
    
    Cycles_Vector = [Cycles_Vector; Cycles_Month];
    
    Cycling_Penalty_Vector = [Cycling_Penalty_Vector; Cycling_Penalty_Month];
    
    
end

% Report total script runtime.

telapsed = toc(tstart);

sprintf('Elapsed time to run the optimization model is %0.0f seconds.', telapsed)


%% Plot Energy Storage Dispatch Schedule

numtsteps_year = length(Load_Profile_Data);

t = Start_Time_Input + linspace(0, ((numtsteps_year-1) * delta_t)/(24), numtsteps_year);

P_ES = P_ES_out - P_ES_in;

if Show_Plots == 1
    
    figure
    plot(t, P_ES,'r')
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Energy Storage Output (kW)','FontSize',15);
    title('Energy Storage Dispatch Profile','FontSize',15)
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Storage Dispatch Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Storage Dispatch Plot");
        
    end
    
end


%% Plot Energy Storage Energy Level

if Show_Plots == 1
    
    figure
    plot(t, Ene_Lvl,'r')
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Energy Storage Energy Level (kWh)','FontSize',15);
    title('Energy Storage Energy Level','FontSize',15)
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Energy Level Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Energy Level Plot");
        
    end
    
end


%% Plot Volumetric Electricity Price Schedule and Marginal Carbon Emission Rates

if Show_Plots == 1
    
    
    figure
    plot(t, Volumetric_Rate_Data, t, Marginal_Emissions_Rate_Evaluation_Data/10)
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('($/kWh) or (metric tons/kWh)/10','FontSize',15);
    title('Electricity Rates and Marginal Emissions Rates','FontSize',15)
    legend('Electricity Rates ($/kWh)','Marginal Carbon Emissions Rate (metric tons/kWh)/10', ...
        'Location','NorthOutside')
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Energy Price and Carbon Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Energy Price and Carbon Plot");
        
    end
    
end

%% Plot Coincident and Non-Coincident Demand Charge Schedule

% Create Summer/Winter Binary Flag Vector
Summer_Binary_Data = sum(Month_Data == First_Summer_Month:Last_Summer_Month, 2);

Winter_Binary_Data = sum(Month_Data == [1:(First_Summer_Month-1), (Last_Summer_Month+1):12], 2);

% Create Total-Demand-Charge Vector
% Noncoincident Demand Charge is always included (although it may be 0).
% Coincident Peak and Part-Peak values are only added if they are non-zero
% and a binary-flag data input is available.

Total_DC = (Winter_Noncoincident_DC * Winter_Binary_Data) + ...
    (Summer_Noncoincident_DC * Summer_Binary_Data);

if Winter_Peak_DC > 0
    Total_DC = Total_DC + (Winter_Peak_DC * Winter_Peak_Binary_Data);
end

if Winter_Part_Peak_DC > 0
    Total_DC = Total_DC + (Winter_Part_Peak_DC * Winter_Part_Peak_Binary_Data);
end

if Summer_Peak_DC > 0
    Total_DC = Total_DC + (Summer_Peak_DC * Summer_Peak_Binary_Data);
end

if Summer_Part_Peak_DC > 0
    Total_DC = Total_DC + (Summer_Part_Peak_DC * Summer_Part_Peak_Binary_Data);
end

if Show_Plots == 1
    
    figure
    plot(t, Total_DC,'Color',[0,0.5,0])
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Total Demand Charge ($/kW)','FontSize',15);
    title('Coincident + Non-Coincident Demand Charge Schedule','FontSize',15)
    
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Demand Charge Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Demand Charge Plot");
        
    end
    
end


%% Plot Load & Net Load

if Show_Plots == 1
    
    figure
    plot(t, Load_Profile_Data,'k', t, Load_Profile_Data - P_ES,'r')
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Load (kW)','FontSize',15);
    title('Original and Net Load','FontSize',15)
    legend('Original Load','Net Load with Storage', 'Location','NorthOutside')
    set(gca,'FontSize',15);
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Net Load Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Net Load Plot");
        
    end
    
    
end


Annual_Peak_Demand_With_Storage = max(Load_Profile_Data - P_ES);

Annual_Total_Electricity_Consumption_With_Storage = sum(Load_Profile_Data - P_ES) * delta_t;

Peak_Demand_Reduction_Percentage = ...
    ((Annual_Peak_Demand_Without_Storage - Annual_Peak_Demand_With_Storage)/...
    Annual_Peak_Demand_Without_Storage) * 100;

Energy_Consumption_Increase_Percentage = ...
    ((Annual_Total_Electricity_Consumption_With_Storage - ...
    Annual_Total_Electricity_Consumption_With_Storage)/...
    Annual_Total_Electricity_Consumption_With_Storage) * 100;

sprintf('Annual peak noncoincident demand without storage is %0.00f kW', ...
    Annual_Peak_Demand_Without_Storage)

sprintf('Peak demand with storage is %0.00f kW, representing a DECREASE OF %0.02f%%.', ...
    Annual_Peak_Demand_With_Storage, Peak_Demand_Reduction_Percentage)

sprintf('Annual total electricity consumption without storage is %0.00f kWh.', ...
    Annual_Total_Electricity_Consumption_Without_Storage)

sprintf('Electricity consumption with storage is %0.00f kWh, representing an INCREASE OF %0.02f%%.', ...
    Annual_Total_Electricity_Consumption_With_Storage, Energy_Consumption_Increase_Percentage)


%% Plot Monthly Costs as Bar Plot

% Plot Monthly Costs Without Storage

Monthly_Costs_Matrix_Without_Storage = [Fixed_Charge_Vector, NC_DC_wo_Storage_Vector, ...
    CPK_DC_wo_Storage_Vector, CPP_DC_wo_Storage_Vector, Energy_Charge_wo_Storage_Vector, ...
    zeros(size(Fixed_Charge_Vector))];

Annual_Costs_Vector_Without_Storage = [sum(Fixed_Charge_Vector); ...
    sum(NC_DC_wo_Storage_Vector) + sum(CPK_DC_wo_Storage_Vector) + sum(CPP_DC_wo_Storage_Vector);...
    sum(Energy_Charge_wo_Storage_Vector)];


if Show_Plots == 1
    
    figure
    bar(Monthly_Costs_Matrix_Without_Storage, 'stacked')
    xlim([0.5, 12.5])
    xlabel('Month','FontSize',15);
    ylabel('Cost ($/Month)','FontSize',15);
    title('Monthly Costs, Without Storage','FontSize',15)
    legend('Fixed Charges','NC DC', 'CPK DC','CPP DC', 'Energy Charge', 'Cycling Penalty', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
    
    % Save y-limit from Without Storage plot for use in With Storage plot
    wo_Storage_yl = ylim;
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Costs without Storage Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Costs without Storage Plot");
        
    end
    
end


% Plot Monthly Costs With Storage

Monthly_Costs_Matrix_With_Storage = [Fixed_Charge_Vector, NC_DC_w_Storage_Vector, ...
    CPK_DC_w_Storage_Vector, CPP_DC_w_Storage_Vector, Energy_Charge_w_Storage_Vector, ...
    Cycling_Penalty_Vector];

Annual_Costs_Vector_With_Storage = [sum(Fixed_Charge_Vector); ...
    sum(NC_DC_w_Storage_Vector) + sum(CPK_DC_w_Storage_Vector) + sum(CPP_DC_w_Storage_Vector);...
    sum(Energy_Charge_w_Storage_Vector)];

if Show_Plots == 1
    
    figure
    bar(Monthly_Costs_Matrix_With_Storage, 'stacked')
    xlim([0.5, 12.5])
    ylim(wo_Storage_yl)
    xlabel('Month','FontSize',15);
    ylabel('Cost ($/Month)','FontSize',15);
    title('Monthly Costs, With Storage','FontSize',15)
    legend('Fixed Charges','NC DC', 'CPK DC','CPP DC', 'Energy Charge', 'Cycling Penalty', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Costs with Storage Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Costs with Storage Plot");
        
    end
    
end

% Plot Monthly Savings From Storage

Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_Without_Storage - ...
    Monthly_Costs_Matrix_With_Storage;


if Show_Plots == 1
    
    % Remove fixed charges, battery cycling costs.
    
    Monthly_Savings_Matrix_Plot = Monthly_Savings_Matrix_From_Storage(:, 2:5);
    
    figure
    bar(Monthly_Savings_Matrix_Plot, 'stacked')
    xlim([0.5, 12.5])
    xlabel('Month','FontSize',15);
    xticks(linspace(1,12,12));
    ylabel('Savings ($/Month)','FontSize',15);
    title('Monthly Savings From Storage','FontSize',15)
    legend('NC DC', 'CPK DC','CPP DC', 'Energy Charge', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
    
    if Export_Plots == 1
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Savings from Storage Plot.png");
        
        saveas(gcf, "Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
            Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
            " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
            (delta_t * 60) + "-Minute Data" + "/" + ...
            Utility_Tariff_Input + "/" + Load_Profile_Input + "/Monthly Savings from Storage Plot");
        
    end
    
    
end


%% Report Annual Savings

% Report Baseline Cost without Storage
Year_1_Costs_Without_Storage = sum(sum(Monthly_Costs_Matrix_Without_Storage));

Year_1_Savings = sum(sum(Monthly_Savings_Matrix_From_Storage));

Year_1_Savings_Percent = (Year_1_Savings/Year_1_Costs_Without_Storage) * 100;

Battery_Cost = Size_ES * Installed_Cost_per_kWh;

Simple_Payback = Battery_Cost/Year_1_Savings;

sprintf('Annual cost savings is $%0.0f, representing %0.2f %% of the original $%0.0f bill.', ...
    Year_1_Savings, Year_1_Savings_Percent, Year_1_Costs_Without_Storage)

sprintf('The storage system has a simple payback of %0.0f years, not including incentives.', ...
    Simple_Payback)


%% Report Cycling/Degradation Penalty

Year_1_Cycles = sum(Cycles_Vector);
Year_1_Cycling_Penalty = sum(Cycling_Penalty_Vector);
sprintf('The battery cycles %0.0f times annually, with a degradation cost of $%0.0f.', ...
    Year_1_Cycles, Year_1_Cycling_Penalty)

%% Report Operational/"SGIP" Round-Trip Efficiency

Operational_RTE_Percent = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t) * 100;

sprintf('The battery has an Operational/"SGIP" Round-Trip Efficiency of %0.2f%%.', ...
    Operational_RTE_Percent)


%% Report Operational/"SGIP" Capacity Factor

% The SGIP Handbook uses the following definition of capacity factor for
% storage resources, based on the assumption that 60% of hours are
% available for discharge. The term "hours of data available" is equal to
% the number of hours in the year here. For actual operational data, it's
% the number of hours where data is available, which may be less than the
% number of hours in the year. Here, the number of hours in the year is
% calculated by multiplying the number of timesteps of original load profile data
% by the timestep length delta_t. This returns 8760 hours during
% non-leap years and 8784 during leap years.

% Capacity Factor = (kWh Discharge)/(Hours of Data Available x Rebated Capacity (kW) x 60%)

Operational_Capacity_Factor = ((sum(P_ES_out) * delta_t)/((length(Load_Profile_Data) * delta_t) * P_ES_max * 0.6)) * 100;

sprintf('The battery has an Operational/"SGIP" Capacity Factor of %0.2f%%.', ...
    Operational_Capacity_Factor)

%% Report Emissions Impact

% This approach multiplies net load by marginal emissions factors to
% calculate total annual emissions. This is consistent with the idea that
% the customer would pay an adder based on marginal emissions factors.
% Typically, total annual emissions is calculated using average emissions
% values, not marginal emissions values.

% https://www.pge.com/includes/docs/pdfs/shared/environment/calculator/pge_ghg_emission_factor_info_sheet.pdf

% (tons/kWh) = (tons/MWh) * (MWh/kWh)
Baseline_Emissions_Metric_Tons = (Marginal_Emissions_Rate_Evaluation_Data' * Load_Profile_Data * ...
    (1/1000) * delta_t);

Emissions_Reduction_Metric_Tons = Marginal_Emissions_Rate_Evaluation_Data' * ...
    (P_ES_out - P_ES_in) * (1/1000) * delta_t;

With_Storage_Emissions_Metric_Tons = Baseline_Emissions_Metric_Tons - Emissions_Reduction_Metric_Tons;

Y1_Emissions_Reduction_Pct_of_Baseline = ...
    (Emissions_Reduction_Metric_Tons/Baseline_Emissions_Metric_Tons) * 100;

if Emissions_Reduction_Metric_Tons < 0
    sprintf('Installing energy storage INCREASES marginal carbon emissions \n by %0.2f metric tons per year.', ...
        -Emissions_Reduction_Metric_Tons)
    sprintf('This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', ...
        -Y1_Emissions_Reduction_Pct_of_Baseline, With_Storage_Emissions_Metric_Tons)
else
    sprintf('Installing energy storage DECREASES marginal carbon emissions \n by %0.2f metric tons per year.', ...
        Emissions_Reduction_Metric_Tons)
    sprintf('This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', ...
        Y1_Emissions_Reduction_Pct_of_Baseline, With_Storage_Emissions_Metric_Tons)
end


%% Write Outputs to CSV

Performance_Metric_Outputs = [Size_ES, P_ES_max, Eff_c, Eff_d, ...
    Auxiliary_Storage_Load, Installed_Cost_per_kWh, cycle_pen, delta_t, Padding_Days, ...
    Annual_Peak_Demand_Without_Storage, Annual_Peak_Demand_With_Storage, ...
    Annual_Total_Electricity_Consumption_Without_Storage, Annual_Total_Electricity_Consumption_With_Storage, ...
    Peak_Demand_Reduction_Percentage, Energy_Consumption_Increase_Percentage, ...
    Year_1_Costs_Without_Storage, Year_1_Savings, Year_1_Savings_Percent, Battery_Cost, ...
    Simple_Payback, Year_1_Cycles, Year_1_Cycling_Penalty, Operational_RTE_Percent, ...
    Operational_Capacity_Factor, Baseline_Emissions_Metric_Tons, Emissions_Reduction_Metric_Tons, ...
    With_Storage_Emissions_Metric_Tons, Y1_Emissions_Reduction_Pct_of_Baseline];

Bill_Component_Cost_Outputs = [Annual_Costs_Vector_Without_Storage, Annual_Costs_Vector_With_Storage];

if Export_Data == 1
    
    csvwrite("Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
        Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
        " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
        (delta_t * 60) + "-Minute Data" + "/" + ...
        Utility_Tariff_Input + "/" + Load_Profile_Input + ...
        "/Performance Metric Outputs.csv", Performance_Metric_Outputs);
    
    csvwrite("Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + ...
        Carbon_Reduction_Strategy + "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + ...
        " Carbon Adder/" + Carbon_Impact_Evaluation_Signal_Input + "/" + ...
        (delta_t * 60) + "-Minute Data" + "/" + ...
        Utility_Tariff_Input + "/" + Load_Profile_Input + "/Bill Component Cost Outputs.csv", ...
        Bill_Component_Cost_Outputs);
    
    csvwrite("Models/OSESMO/Model Outputs/" + System_Type_Input + "/" + Carbon_Reduction_Strategy + ...
        "/" + "$" + Carbon_Adder_per_Metric_Ton_Input_Value + " Carbon Adder/" + ...
        Carbon_Impact_Evaluation_Signal_Input + "/" + ...
        (delta_t * 60) + "-Minute Data" + "/" + Utility_Tariff_Input + "/" + ...
        Load_Profile_Input + "/Storage Dispatch Profile Output.csv", P_ES);
    
end


%% Return to OSESMO Git Repository Directory

cd(OSESMO_Git_Repo_Directory)


end