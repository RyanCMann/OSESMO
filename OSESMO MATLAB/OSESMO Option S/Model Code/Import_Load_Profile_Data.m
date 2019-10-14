function [Load_Profile_Data, Load_Profile_Master_Index] = Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)

% Import Load Profile Data

switch Load_Profile_Name_Input      
        
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
               
        
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end