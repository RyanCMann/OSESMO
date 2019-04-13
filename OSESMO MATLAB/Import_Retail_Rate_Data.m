function [Retail_Rate_Master_Index, Retail_Rate_Effective_Date, ...
    Volumetric_Rate_Data, Summer_Peak_DC, Summer_Part_Peak_DC, Summer_Noncoincident_DC, ...
    Winter_Peak_DC, Winter_Part_Peak_DC, Winter_Noncoincident_DC, ...
    Fixed_Per_Meter_Day_Charge, Fixed_Per_Meter_Month_Charge, ...
    First_Summer_Month, Last_Summer_Month, Month_Data, ...
    Summer_Peak_Binary_Data, Summer_Part_Peak_Binary_Data, ...
    Winter_Peak_Binary_Data, Winter_Part_Peak_Binary_Data] = Import_Retail_Rate_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Retail_Rate_Name_Input)

%% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)


%% Import Volumetric (per kWh) Rate Data

switch Retail_Rate_Name_Input
    
    case "PG&E E-1 Tier 1"
        
        Retail_Rate_Master_Index = "R1";
        Retail_Rate_Effective_Date = "2017-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 1/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier1_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 1/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier1_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 3"
        
        Retail_Rate_Master_Index = "R1";
        Retail_Rate_Effective_Date = "2017-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 3/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier3_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 3/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier3_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 1 SmartRate"
        
        Retail_Rate_Master_Index = "R2";
        Retail_Rate_Effective_Date = "2017-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 1 SmartRate/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier1_SmartRate_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 1 SmartRate/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier1_SmartRate_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 3 SmartRate"
        
        Retail_Rate_Master_Index = "R2";
        Retail_Rate_Effective_Date = "2017-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 3 SmartRate/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier3_SmartRate_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-1 Tier 3 SmartRate/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E1_Tier3_SmartRate_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E EV-A (NEW)"
        
        Retail_Rate_Master_Index = "R3";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E EV-A (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_EVA_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E EV-A (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_EVA_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E DR-SES"
        
        Retail_Rate_Master_Index = "R4";
        Retail_Rate_Effective_Date = "2017-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DR-SES/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_DR_SES_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DR-SES/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_DR_SES_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-6 (NEW) Tier 1"
        
        Retail_Rate_Master_Index = "R5";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 1/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E6_NEW_Tier1_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 1/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E6_NEW_Tier1_Energy_Rates_Vector.csv']);
        end
     
    case "PG&E E-6 (NEW) Tier 2"
        
        Retail_Rate_Master_Index = "R5";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 2/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E6_NEW_Tier2_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 2/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E6_NEW_Tier2_Energy_Rates_Vector.csv']);
        end
        
    case "LADWP R-1B (OLD)"
        
        Retail_Rate_Master_Index = "R6";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/LADWP R-1B (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_LADWP_R1B_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/LADWP R-1B (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_LADWP_R1B_OLD_Energy_Rates_Vector.csv']);
        end        
        
    case "PG&E E-TOU-C (NEW) Tier 1"
        
        Retail_Rate_Master_Index = "R7";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 1/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_ETOUC_NEW_Tier_1_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 1/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_ETOUC_NEW_Tier_1_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-TOU-C (NEW) Tier 2"
        
        Retail_Rate_Master_Index = "R7";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 2/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_ETOUC_NEW_Tier_2_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 2/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_ETOUC_NEW_Tier_2_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-D-4-9PM (NEW) Tier 1"
        
        Retail_Rate_Master_Index = "R8";
        Retail_Rate_Effective_Date = "2019-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 1/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOUD_4_9PM_NEW_Tier_1_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 1/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOUD_4_9PM_NEW_Tier_1_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-D-4-9PM (NEW) Tier 2"
        
        Retail_Rate_Master_Index = "R8";
        Retail_Rate_Effective_Date = "2019-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 2/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOUD_4_9PM_NEW_Tier_2_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 2/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOUD_4_9PM_NEW_Tier_2_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E A-1-STORAGE (NEW)"
        
        Retail_Rate_Master_Index = "C1";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-1-STORAGE (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_A1_STORAGE_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-1-STORAGE (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_A1_STORAGE_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E A-6 (OLD)"
        
        Retail_Rate_Master_Index = "C2";
        Retail_Rate_Effective_Date = "2017-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-6 (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_A6_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-6 (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_A6_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E A-6 PDP (OLD)"
        
        Retail_Rate_Master_Index = "C3";
        Retail_Rate_Effective_Date = "2017-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-6 PDP (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_A6_PDP_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E A-6 PDP (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_A6_PDP_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S (OLD)"
        
        Retail_Rate_Master_Index = "C4";
        Retail_Rate_Effective_Date = "2017-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S (NEW)"
        
        Retail_Rate_Master_Index = "C5";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (OLD)"
        
        Retail_Rate_Master_Index = "C6";
        Retail_Rate_Effective_Date = "2017-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S PDP (NEW)"
        
        Retail_Rate_Master_Index = "C7";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S PDP (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19S_PDP_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S-R (OLD)"
        
        Retail_Rate_Master_Index = "C8";
        Retail_Rate_Effective_Date = "2017-03-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "PG&E E-19S-R (NEW)"
        
        Retail_Rate_Master_Index = "C9";
        Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/PG&E E-19S-R (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_PGE_E19SR_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-8-B"
        
        Retail_Rate_Master_Index = "C10";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-B/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-B/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-8-CPP"
        
        Retail_Rate_Master_Index = "C11";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-CPP/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_CPP_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-CPP/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_CPP_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-8-R"
        
        Retail_Rate_Master_Index = "C12";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-R/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8R_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-R/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8R_Energy_Rates_Vector.csv']);
        end
        
    case "SCE TOU-8-RTP"
        
        Retail_Rate_Master_Index = "C13";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-RTP/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_RTP_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SCE TOU-8-RTP/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_RTP_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (OLD)"
        
        Retail_Rate_Master_Index = "C14";
        Retail_Rate_Effective_Date = "2016-08-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (NEW)"
        
        Retail_Rate_Master_Index = "C15";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E AL-TOU-CP2 (OLD)"
        
        Retail_Rate_Master_Index = "C16";
        Retail_Rate_Effective_Date = "2016-08-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E AL-TOU-CP2 (NEW)"
        
        Retail_Rate_Master_Index = "C17";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (NEW) with DA CAISO"
        
        Retail_Rate_Master_Index = "C18";
        Retail_Rate_Effective_Date = "Hypothetical Rate";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Energy_Rates_Vector.csv']);
        end
        
    case "SDG&E DG-R"
        
        Retail_Rate_Master_Index = "C19";
        Retail_Rate_Effective_Date = "2018-01-01";
        
        if delta_t == (5/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Energy_Rates_Vector.csv']);
        elseif delta_t == (15/60)
            Volumetric_Rate_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_DGR_Energy_Rates_Vector.csv']);
        end
        
end


%% Select Demand Charge and Fixed-Charge Variable Values

switch Retail_Rate_Name_Input
    
    case "PG&E E-1 Tier 1"
        
        % Demand Charges - PG&E E-1, Tier 1
        % There are no demand charges on this rate.
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-1, Tier 1
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E E-1 Tier 3"
        
        % Demand Charges - PG&E E-1, Tier 3
        % There are no demand charges on this rate.
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-1, Tier 3
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E E-1 Tier 1 SmartRate"
        
        % Demand Charges - PG&E E-1, Tier 1, with SmartRate
        % There are no demand charges on this rate.
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-1, Tier 1, with SmartRate
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E E-1 Tier 3 SmartRate"
        
        % Demand Charges - PG&E E-1, Tier 3, with SmartRate
        % There are no demand charges on this rate.
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-1, Tier 3, with SmartRate
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E EV-A (NEW)"
        
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
        
        
    case "SDG&E DR-SES"
        
        % Demand Charges - SDG&E DR-SES
        
        % There are no demand charges on this rate.
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - SDG&E DR-SES
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "PG&E E-6 (NEW) Tier 1"
        
        % Demand Charges - PG&E E-6 NEW Tier 1
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-6 NEW Tier 1
        Fixed_Per_Meter_Day_Charge = 0.32854;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E E-6 (NEW) Tier 2"
        
        % Demand Charges - PG&E E-6 NEW Tier 2
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-6 NEW Tier 2
        Fixed_Per_Meter_Day_Charge = 0.32854;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "LADWP R-1B (OLD)"
        
        % Demand Charges - LADWP R-1B OLD
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - LADWP R-1B OLD
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 12; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "PG&E E-TOU-C (NEW) Tier 1"
        
        % Demand Charges - PG&E E-TOU-C (NEW) Tier 1
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-TOU-C (NEW) Tier 1
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "PG&E E-TOU-C (NEW) Tier 2"
        
        % Demand Charges - PG&E E-TOU-C (NEW) Tier 2
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E E-TOU-C (NEW) Tier 2
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "SCE TOU-D-4-9PM (NEW) Tier 1"
        
        % Demand Charges - SCE TOU-D-4-9PM (NEW) Tier 1
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-D-4-9PM (NEW) Tier 1
        Fixed_Per_Meter_Day_Charge = 0.031;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "SCE TOU-D-4-9PM (NEW) Tier 2"
        
        % Demand Charges - SCE TOU-D-4-9PM (NEW) Tier 2
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-D-4-9PM (NEW) Tier 2
        Fixed_Per_Meter_Day_Charge = 0.031;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
    case "PG&E A-1-STORAGE (NEW)"
        
        % Demand Charges - PG&E A-1-STORAGE (NEW), Single-Phase
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 3.75;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0; % There is no part-peak demand charge in the winter.
        Winter_Noncoincident_DC = 3.75;
        
        % Fixed Per-Meter-Day Charge - PG&E A-1-STORAGE (NEW), Single-Phase
        Fixed_Per_Meter_Day_Charge = 10;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "PG&E A-6 (OLD)"
        
        % Demand Charges - PG&E A-6 (OLD), Single-Phase
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E A-6 (OLD), Single-Phase
        Fixed_Per_Meter_Day_Charge = (0.32854 + 0.20107);  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "PG&E A-6 PDP (OLD)"
        
        % Demand Charges - PG&E A-6 PDP (OLD), Single-Phase
        Summer_Peak_DC = 0;
        Summer_Part_Peak_DC = 0;
        Summer_Noncoincident_DC = 0;
        Winter_Peak_DC = 0;
        Winter_Part_Peak_DC = 0;
        Winter_Noncoincident_DC = 0;
        
        % Fixed Per-Meter-Day Charge - PG&E A-6 PDP (OLD), Single-Phase
        Fixed_Per_Meter_Day_Charge = (0.32854 + 0.20107);  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 0; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
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
        
        
    case "PG&E E-19S PDP (NEW)"
        
        % Demand Charges - NEW PG&E E-19 PDP Secondary Voltage
        % NEW PDP demand charge credits are only 75 percent of the OLD
        % demand charge credits, because the NEW PDP event length is only
        % 3 hours, vs. 4 hours in the OLD E-19 PDP, with the same PDP adder.
        Summer_Peak_DC = (18.35 - (5.70 * 0.75));
        Summer_Part_Peak_DC = (2.85 - (1.41 * 0.75));
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
        
        
    case "SCE TOU-8-B"
        
        % Demand Charges - SCE TOU-8-B (Primary Voltage, between 2 kV and 50 kV)
        Summer_Peak_DC = 21.79;
        Summer_Part_Peak_DC = 4.11;
        Summer_Noncoincident_DC = 18.79;
        Winter_Peak_DC = 0;  % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 18.79;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-B (Primary Voltage, between 2 kV and 50 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 314.30; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "SCE TOU-8-CPP"
        
        % Demand Charges - SCE TOU-8-CPP (Primary Voltage, between 2 kV and 50 kV)
        Summer_Peak_DC = (21.79 - 11.82);
        Summer_Part_Peak_DC = 4.11;
        Summer_Noncoincident_DC = 18.79;
        Winter_Peak_DC = 0;  % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 18.79;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-CPP (Primary Voltage, between 2 kV and 50 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 314.30; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "SCE TOU-8-R"
        
        % Demand Charges - SCE TOU-8-R (Primary Voltage, between 2 kV and 50 kV)
        Summer_Peak_DC = 0; % There is no summer peak demand charge on this rate.
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 14.92;
        Winter_Peak_DC = 0; % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 14.92;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-R (Primary Voltage, between 2 kV and 50 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 314.30; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "SCE TOU-8-RTP"
        
        % Demand Charges - SCE TOU-8-RTP (Primary Voltage, from 2 kV to 50 kV)
        Summer_Peak_DC = 0; % There is no summer peak demand charge on this rate.
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 18.79;
        Winter_Peak_DC = 0;  % There is no winter peak demand charge on this rate.
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 18.79;
        
        % Fixed Per-Meter-Day Charge - SCE TOU-8-RTP (Primary Voltage, from 2 kV to 50 kV)
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 314.30; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 9; % September is the last summer month for this rate.
        
        
    case "SDG&E AL-TOU (OLD)"
        
        % Demand Charges - SDG&E AL-TOU (OLD), Secondary
        % UDC demand charges taken from PDF pg. 2 - Effective August 1, 2016
        % EECC summer peak demand charge taken from PDF pg. 53 - Effective August 1, 2016
        % Fixed charges are missing from PDF tariff sheet. Used Tier 1 fixed charges.
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = (9.54 + 9.91) * 1.0578; % Includes EECC max on-peak demand charge
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 22.82 * 1.0578;
        Winter_Peak_DC = 7.01 * 1.0578;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 22.82 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E AL-TOU (OLD), Secondary
        % Taken from PDF pg.  - Effective
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 116.44 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "SDG&E AL-TOU (NEW)"
        
        % Demand Charges - SDG&E AL-TOU (NEW), Secondary
        % Taken from PDF pg. 4 - Effective Jan. 1 2018
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = (16.63 + 10.99) * 1.0578; % Includes EECC max on-peak demand charge
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 21.09 * 1.0578;
        Winter_Peak_DC = 16.61;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 21.09 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E AL-TOU (NEW), Secondary
        % Taken from PDF pg. 3 - Effective Dec. 1 2017
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 139.73 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "SDG&E AL-TOU-CP2 (OLD)"
        
        % Demand Charges - SDG&E AL-TOU-CP2 (OLD), Secondary
        % UDC demand charges taken from PDF pg. 2 - Effective August 1, 2016
        % EECC summer peak demand charge taken from PDF pg. 53 - Effective August 1, 2016
        % Fixed charges are missing from PDF tariff sheet. Used Tier 1 fixed charges.
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = 9.54 * 1.0578; % No EECC max on-peak demand charge
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 22.82 * 1.0578;
        Winter_Peak_DC = 7.01 * 1.0578;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 22.82 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E AL-TOU-CP2 (OLD), Secondary
        % Taken from PDF pg.  - Effective
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 116.44 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 5; % May is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "SDG&E AL-TOU-CP2 (NEW)"
        
        % Demand Charges - SDG&E AL-TOU-CP2 (NEW), Secondary
        % Taken from PDF pg. 4 - Effective Jan. 1 2018
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = 16.63 * 1.0578; % Does not includes EECC max on-peak demand charge - not included for CPP customers
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 21.09 * 1.0578;
        Winter_Peak_DC = 16.61;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 21.09 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E AL-TOU-CP2 (NEW), Secondary
        % Taken from PDF pg. 3 - Effective Dec. 1 2017
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 139.73 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "SDG&E AL-TOU (NEW) with DA CAISO"
        
        % Demand Charges - SDG&E AL-TOU (NEW) with DA CAISO, Secondary
        % Taken from PDF pg. 4 - Effective Jan. 1 2018
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = (16.63 + 10.99) * 1.0578; % Includes EECC max on-peak demand charge
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 21.09 * 1.0578;
        Winter_Peak_DC = 16.61;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 21.09 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E AL-TOU (NEW) with DA CAISO, Secondary
        % Taken from PDF pg. 3 - Effective Dec. 1 2017
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 139.73 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
        
    case "SDG&E DG-R"
        
        % Demand Charges - SDG&E DG-R, Secondary, <500 kW
        % Includes 5.78-percent City of SD Franchise Fee.
        
        Summer_Peak_DC = 2.69 * 1.0578;
        Summer_Part_Peak_DC = 0; % There is no summer part-peak demand charge on this rate.
        Summer_Noncoincident_DC = 12.24 * 1.0578;
        Winter_Peak_DC = 0.56 * 1.0578;
        Winter_Part_Peak_DC = 0; % There is no winter part-peak demand charge on this rate.
        Winter_Noncoincident_DC = 12.24 * 1.0578;
        
        % Fixed Per-Meter-Day Charge - SDG&E DG-R, Secondary, <500 kW
        Fixed_Per_Meter_Day_Charge = 0;  % $ per meter per day
        Fixed_Per_Meter_Month_Charge = 139.73 * 1.0578; % $ per meter per month
        
        % Summer Months
        First_Summer_Month = 6; % June is the first summer month for this rate.
        Last_Summer_Month = 10; % October is the last summer month for this rate.
        
end


%% Import Month Data - Used to Filter Other Vectors

switch Retail_Rate_Name_Input
    
    case "PG&E A-1-STORAGE (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E A-1-STORAGE (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_A1_STORAGE_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E A-1-STORAGE (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_A1_STORAGE_Month_Vector.csv']);
        end
        
    case "PG&E A-6 (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E A-6 (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_A6_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E A-6 (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_A6_OLD_Month_Vector.csv']);
        end
        
        
    case "PG&E A-6 PDP (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E A-6 PDP (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_A6_PDP_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E A-6 PDP (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_A6_PDP_OLD_Month_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 1"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 1/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier1_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 1/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier1_Month_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 1 SmartRate"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 1 SmartRate/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier1_SmartRate_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 1 SmartRate/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier1_SmartRate_Month_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 3"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 3/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier3_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 3/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier3_Month_Vector.csv']);
        end
        
    case "PG&E E-1 Tier 3 SmartRate"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 3 SmartRate/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier3_SmartRate_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-1 Tier 3 SmartRate/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E1_Tier3_SmartRate_Month_Vector.csv']);
        end
        
    case "PG&E E-6 (NEW) Tier 1"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 1/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E6_NEW_Tier1_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 1/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E6_NEW_Tier1_Month_Vector.csv']);
        end
        
    case "PG&E E-6 (NEW) Tier 2"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 2/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_E6_NEW_Tier2_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-6 (NEW) Tier 2/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_E6_NEW_Tier2_Month_Vector.csv']);
        end
        
    case "LADWP R-1B (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/LADWP R-1B (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_LADWP_R1B_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/LADWP R-1B (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_LADWP_R1B_OLD_Month_Vector.csv']);
        end
        
    case "PG&E E-TOU-C (NEW) Tier 1"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 1/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_ETOUC_NEW_Tier_1_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 1/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_ETOUC_NEW_Tier_1_Month_Vector.csv']);
        end
        
    case "PG&E E-TOU-C (NEW) Tier 2"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 2/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_ETOUC_NEW_Tier_2_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E E-TOU-C (NEW) Tier 2/2017/15-Minute Data/Vector Format/'...
                '2017_PGE_ETOUC_NEW_Tier_2_Month_Vector.csv']);
        end
        
    case "SCE TOU-D-4-9PM (NEW) Tier 1"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 1/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOUD_4_9PM_NEW_Tier_1_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 1/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOUD_4_9PM_NEW_Tier_1_Month_Vector.csv']);
        end
        
    case "SCE TOU-D-4-9PM (NEW) Tier 2"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 2/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOUD_4_9PM_NEW_Tier_2_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-D-4-9PM (NEW) Tier 2/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOUD_4_9PM_NEW_Tier_2_Month_Vector.csv']);
        end
        
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
        
    case "PG&E EV-A (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/PG&E EV-A (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_PGE_EVA_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/PG&E EV-A (NEW)/2017/15-Minute Data/Vector Format/'...
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
        
    case "SCE TOU-8-CPP"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-8-CPP/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_CPP_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-8-CPP/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_CPP_Month_Vector.csv']);
        end
        
    case "SCE TOU-8-R"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-8-R/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOU8R_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-8-R/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOU8R_Month_Vector.csv']);
        end
        
    case "SCE TOU-8-RTP"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SCE TOU-8-RTP/2017/5-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_RTP_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SCE TOU-8-RTP/2017/15-Minute Data/Vector Format/'...
                '2017_SCE_TOU8_RTP_Month_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_OLD_Month_Vector.csv']);
        end
        
    case "SDG&E AL-TOU-CP2 (OLD)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_CP2_OLD_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_CP2_OLD_Month_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_NEW_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_NEW_Month_Vector.csv']);
        end
        
    case "SDG&E AL-TOU-CP2 (NEW)"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_CP2_NEW_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_CP2_NEW_Month_Vector.csv']);
        end
        
    case "SDG&E AL-TOU (NEW) with DA CAISO"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Month_Vector.csv']);
        end
        
    case "SDG&E DG-R"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E DG-R/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_DGR_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E DG-R/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_DGR_Month_Vector.csv']);
        end
        
    case "SDG&E DR-SES"
        
        if delta_t == (5/60)
            Month_Data = csvread(['Rates/SDG&E DR-SES/2017/5-Minute Data/Vector Format/'...
                '2017_SDGE_DR_SES_Month_Vector.csv']);
        elseif delta_t == (15/60)
            Month_Data = csvread(['Rates/SDG&E DR-SES/2017/15-Minute Data/Vector Format/'...
                '2017_SDGE_DR_SES_Month_Vector.csv']);
        end
        
end


%% Import Peak and Part-Peak Binary Variable Data

switch Retail_Rate_Name_Input
    
    case "PG&E A-1-STORAGE (NEW)"
        
        % PG&E A-1-STORAGE (NEW) does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E A-6 (OLD)"
        
        % PG&E A-6 (OLD) does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E A-6 PDP (OLD)"
        
        % PG&E A-6 PDP (OLD) does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-1 Tier 1"
        
        % PG&E E-1 Tier 1 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-1 Tier 1 SmartRate"
        
        % PG&E E-1 Tier 1 SmartRate does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-1 Tier 3"
        
        % PG&E E-1 Tier 3 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-1 Tier 3 SmartRate"
        
        % PG&E E-1 Tier 3 SmartRate does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-6 (NEW) Tier 1"
        
        % PG&E E-6 (NEW) Tier 1 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-6 (NEW) Tier 2"
        
        % PG&E E-6 (NEW) Tier 2 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "LADWP R-1B (OLD)"
        
        % LADWP R-1B (OLD) does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-TOU-C (NEW) Tier 1"
        
        % PG&E E-TOU-C (NEW) Tier 1 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "PG&E E-TOU-C (NEW) Tier 2"
        
        % PG&E E-TOU-C (NEW) Tier 2 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "SCE TOU-D-4-9PM (NEW) Tier 1"
        
        % SCE TOU-D-4-9PM (NEW) Tier 1 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "SCE TOU-D-4-9PM (NEW) Tier 2"
        
        % SCE TOU-D-4-9PM (NEW) Tier 2 does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
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
        
        % PG&E E-19S (OLD) does not have a winter peak demand charge.
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        
        
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
        
        % PG&E E-19S PDP (OLD) does not have a winter peak demand charge.
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        
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
        
        % PG&E E-19S-R (OLD) does not have a winter peak demand charge.
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        
        
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
        
        % PG&E E-19S (NEW) does not have a winter part-peak demand charge.
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
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
        
        % PG&E E-19S PDP (NEW) does not have a winter part-peak demand charge.
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
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
        
        % PG&E E-19S-R (NEW) does not have a winter part-peak demand charge.
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "PG&E EV-A (NEW)"
        
        % PG&E EV-A does not have any coincident peak or part-peak demand charges.
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SCE TOU-8-B"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-B/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-B/2017/5-Minute Data/' ...
                'Vector Format/2017_SCE_TOU8B_Summer_Partial_Peak_Binary_Vector.csv']);
            
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-B/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8B_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-B/2017/15-Minute Data/' ...
                'Vector Format/2017_SCE_TOU8B_Summer_Partial_Peak_Binary_Vector.csv']);
        end
        
        % SCE TOU-8-B does not have a winter peak or part-peak demand charge.
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SCE TOU-8-CPP"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-CPP/2017/5-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_CPP_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-CPP/2017/5-Minute Data/' ...
                'Vector Format/2017_SCE_TOU8_CPP_Summer_Partial_Peak_Binary_Vector.csv']);
            
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-CPP/2017/15-Minute Data/'...
                'Vector Format/2017_SCE_TOU8_CPP_Summer_Peak_Binary_Vector.csv']);
            
            Summer_Part_Peak_Binary_Data = csvread(['Rates/SCE TOU-8-CPP/2017/15-Minute Data/' ...
                'Vector Format/2017_SCE_TOU8_CPP_Summer_Partial_Peak_Binary_Vector.csv']);
        end
        
        % SCE TOU-8-CPP does not have a winter peak or part-peak demand charge.
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "SCE TOU-8-R"
        
        % SCE TOU-8-R does not have any coincident peak or part-peak demand charges.
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "SCE TOU-8-RTP"
        
        % SCE TOU-8-RTP does not have any coincident peak or part-peak demand charges.
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SDG&E AL-TOU (OLD)"
        
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_OLD_Winter_Peak_Binary_Vector.csv']);
        end
        
        % SDG&E AL-TOU (OLD) does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SDG&E AL-TOU-CP2 (OLD)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (OLD)/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_CP2_OLD_Winter_Peak_Binary_Vector.csv']);
        end
        
        % SDG&E AL-TOU-CP2 (OLD) does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SDG&E AL-TOU (NEW)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_NEW_Winter_Peak_Binary_Vector.csv']);
        end
        
        % SDG&E AL-TOU (NEW) does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SDG&E AL-TOU-CP2 (NEW)"
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU-CP2 (NEW)/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_CP2_NEW_Winter_Peak_Binary_Vector.csv']);
        end
        
        % SDG&E AL-TOU-CP2 (NEW) does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
    case "SDG&E AL-TOU (NEW) with DA CAISO"
        
        if delta_t == (5/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/5-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/5-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Winter_Peak_Binary_Vector.csv']);
        elseif delta_t == (15/60)
            Summer_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/15-Minute Data/'...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Summer_Peak_Binary_Vector.csv']);
            
            Winter_Peak_Binary_Data = csvread(['Rates/SDG&E AL-TOU (NEW) with DA CAISO/2017/15-Minute Data/' ...
                'Vector Format/2017_SDGE_AL_TOU_NEW_with_DA_CAISO_Winter_Peak_Binary_Vector.csv']);
        end
        
        % SDG&E AL-TOU (NEW) with DA CAISO does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
        
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
        
        % SDG&E DG-R does not have any summer or winter part-peak demand charges.
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
    case "SDG&E DR-SES"
        
        % SDG&E DR-SES does not have any coincident peak or part-peak demand charges.
        
        Summer_Peak_Binary_Data = zeros(size(Month_Data));
        Summer_Part_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Peak_Binary_Data = zeros(size(Month_Data));
        Winter_Part_Peak_Binary_Data = zeros(size(Month_Data));
        
end

%% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)


end