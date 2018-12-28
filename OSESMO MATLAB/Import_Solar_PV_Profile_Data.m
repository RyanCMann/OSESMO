function [Solar_Profile_Master_Index, Solar_Profile_Description, Solar_PV_Profile_Data] = ...
    Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, ...
    Solar_Profile_Name_Input, Solar_Size_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)

% Import Solar PV Generation Profile Data.
% Scale base 10-kW or 100-kW profile to match user-input PV system size.

switch Solar_Profile_Name_Input
    
    case "CSI PG&E Residential"
        
        Solar_Profile_Master_Index = "R1";
        Solar_Profile_Description = "CSI Application #PGE-CSI-25632";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Residential.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Residential.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/10) * Solar_PV_Profile_Data; % Rescale 10 kW profile to user-input PV system size.
        
        
    case "CSI SCE Residential"
        
        Solar_Profile_Master_Index = "R2";
        Solar_Profile_Description = "CSI Application #SCE-CSI-07211";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SCE_Residential.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SCE_Residential.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/10) * Solar_PV_Profile_Data; % Rescale 10 kW profile to user-input PV system size.
        
        
    case "CSI SDG&E Residential"
        
        Solar_Profile_Master_Index = "R3";
        Solar_Profile_Description = "CSI Application #SD-CSI-04810";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Residential.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/10 kW Residential Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Residential.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/10) * Solar_PV_Profile_Data; % Rescale 10 kW profile to user-input PV system size.
        
        
    case "CSI PG&E Commercial & Industrial"
        
        Solar_Profile_Master_Index = "C1";
        Solar_Profile_Description = "CSI Application #PGE-CSI-16803";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/100) * Solar_PV_Profile_Data; % Rescale 100 kW profile to user-input PV system size.
        
        
    case "CSI SCE Commercial & Industrial"
        
        Solar_Profile_Master_Index = "C2";
        Solar_Profile_Description = "CSI Application #SCE-CSI-08338";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/100) * Solar_PV_Profile_Data; % Rescale 100 kW profile to user-input PV system size.
        
        
    case "CSI SDG&E Commercial & Industrial"
        
        Solar_Profile_Master_Index = "C3";
        Solar_Profile_Description = "CSI Application #SD-CSI-00087";
        
        if delta_t == (5/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv']);
        elseif delta_t == (15/60)
            Solar_PV_Profile_Data = csvread(['Solar PV Data/California Solar Initiative/' ...
                'Selected Clean 2017 CSI Generation Profiles/'...
                '15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format/' ...
                'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv']);
        end
        
        Solar_PV_Profile_Data = (Solar_Size_Input/100) * Solar_PV_Profile_Data; % Rescale 100 kW profile to user-input PV system size.
        
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end