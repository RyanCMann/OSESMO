function [Load_Profile_Data, Load_Profile_Master_Index] = Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)

% Import Load Profile Data

switch Load_Profile_Name_Input
    
    case "WattTime GreenButton Residential Berkeley"
        
        Load_Profile_Master_Index = "R1";
        
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
        
        Load_Profile_Master_Index = "R2";
        
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
        
        Load_Profile_Master_Index = "R3";
        
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
        
        Load_Profile_Master_Index = "R4";
        
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
        
        Load_Profile_Master_Index = "R5";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/5-Minute Data/' ...
                'Vector Format/Vector_Residential_Site5_2017_Oakland.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Green Button Data collected by WattTime 2017/15-Minute Data/' ...
                'Vector Format/Vector_Residential_Site5_2017_Oakland.csv']);
        end
        
        
    case "PG&E GreenButton E-6 Residential"
        
        Load_Profile_Master_Index = "R6";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_E-6_Residential_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_E-6_Residential_15_minute_Vector.csv']);
        end
        
        
    case "Custom Power Solar GreenButton PG&E Albany Residential with EV"
        
        Load_Profile_Master_Index = "R7";
        
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
        
        Load_Profile_Master_Index = "R8";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/5-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Crockett_Residential_EV_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Custom Power Solar Load Profiles/15-Minute Data/' ...
                'Vector Format/Custom_Power_Solar_PGE_Crockett_Residential_EV_Vector.csv']);
        end
        
        
    case "PG&E GreenButton Central Valley Residential Non-CARE"
        
        Load_Profile_Master_Index = "R9";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Residential Central Valley 2015/2017 Remapped/5-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_Non_CARE.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Residential Central Valley 2015/2017 Remapped/15-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_Non_CARE.csv']);
        end
        
        
    case "PG&E GreenButton Central Valley Residential CARE"
        
        Load_Profile_Master_Index = "R10";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Residential Central Valley 2015/2017 Remapped/5-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_CARE.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Residential Central Valley 2015/2017 Remapped/15-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_PGE_Central_Valley_Residential_CARE.csv']);
        end
        
        
    case "Avalon GreenButton East Bay Light Industrial"
        
        Load_Profile_Master_Index = "C1";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/5-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_East_Bay_Light_Industrial.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/15-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_East_Bay_Light_Industrial.csv']);
        end
        
        
    case "Stem GreenButton SCE GS-2B Hospitality"
        
        Load_Profile_Master_Index = "C2";
        
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
        
        Load_Profile_Master_Index = "C3";
        
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
        
        Load_Profile_Master_Index = "C4";
        
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
        
        Load_Profile_Master_Index = "C5";
        
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
        
        Load_Profile_Master_Index = "C6";
        
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
        
        Load_Profile_Master_Index = "C7";
        
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
        
        Load_Profile_Master_Index = "C8";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/5-Minute Data/' ...
                'Vector Format/7_PGE_E-19_Industrial_3_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Stem C&I Load Profiles/15-Minute Data/' ...
                'Vector Format/7_PGE_E-19_Industrial_3_Vector.csv']);
        end
        
        
    case "EnerNOC GreenButton Los Angeles Grocery"
        
        Load_Profile_Master_Index = "C9";
        
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
        
        Load_Profile_Master_Index = "C10";
        
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
        
        Load_Profile_Master_Index = "C11";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/San Diego Office/' ...
                'Vector Format/Clean_Vector_2017_San_Diego_Office.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Diego Office/' ...
                'Vector Format/Clean_Vector_2017_San_Diego_Office.csv']);
        end
        
        
    case "EnerNOC GreenButton San Francisco Industrial"
        
        Load_Profile_Master_Index = "C12";
        
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
        
        Load_Profile_Master_Index = "C13";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/5-Minute Data/San Francisco Office/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Office.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/EnerNOC GreenButton/' ...
                'Selected Clean 2017 EnerNOC Load Profiles/15-Minute Data/San Francisco Office/' ...
                'Vector Format/Clean_Vector_2017_San_Francisco_Office.csv']);
        end
        
        
    case "PG&E GreenButton A-1 SMB"
        
        Load_Profile_Master_Index = "C14";
        
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
        
        Load_Profile_Master_Index = "C15";
        
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
        
        Load_Profile_Master_Index = "C16";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/5-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-10S_MLB_5_minute_Vector.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'PG&E Green Button Data 2011-2012/2017/15-Minute Data/' ...
                'Vector Format/PG&E_GreenButton_A-10S_MLB_15_minute_Vector.csv']);
        end
        
        
    case "Avalon GreenButton South Bay Education"
        
        Load_Profile_Master_Index = "C17";
        
        if delta_t == (5/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/5-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_South_Bay_Education.csv']);
        elseif delta_t == (15/60)
            Load_Profile_Data = csvread(['Load Profile Data/' ...
                'Avalon Anonymized Commercial & Industrial/2017 Remapped/15-Minute Data/' ...
                'Vector Format/Clean_Vector_2017_South_Bay_Education.csv']);
        end
        
        
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end