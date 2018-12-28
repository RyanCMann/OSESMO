function [Generation_Cost_Data, Representative_Distribution_Cost_Data] = ...
Import_Utility_Marginal_Cost_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)


% Map Load Profile Name to Representative Utility Marginal Cost Profiles 

switch Load_Profile_Name_Input
    
    case "WattTime GreenButton Residential Berkeley"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "WattTime GreenButton Residential Long Beach"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Sonoma";
        
    case "WattTime GreenButton Residential Coulterville"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "WattTime GreenButton Residential San Francisco"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "WattTime GreenButton Residential Oakland"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "PG&E GreenButton E-6 Residential"
        Generation_Cost_Region =  "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma";
        
    case "Custom Power Solar GreenButton PG&E Albany Residential with EV"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "Custom Power Solar GreenButton PG&E Crockett Residential with EV"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "PG&E GreenButton Central Valley Residential Non-CARE"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "PG&E GreenButton Central Valley Residential CARE"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "Avalon GreenButton East Bay Light Industrial"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "Stem GreenButton SCE GS-2B Hospitality"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "Stem GreenButton SCE TOU-8B Office"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "Stem GreenButton PG&E E-19 Office"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "Stem GreenButton SCE GS-3B Food Processing"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Sonoma";
        
    case "Stem GreenButton SDG&E G-16 Manufacturing"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "Stem GreenButton SDG&E AL-TOU Education"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "Stem GreenButton PG&E E-19 Industrial"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "EnerNOC GreenButton Los Angeles Grocery"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "EnerNOC GreenButton Los Angeles Industrial"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "EnerNOC GreenButton San Diego Office"
        Generation_Cost_Region = "SP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "EnerNOC GreenButton San Francisco Industrial"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma"; 
        
    case "EnerNOC GreenButton San Francisco Office"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma";
        
    case "PG&E GreenButton A-1 SMB"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "PG&E GreenButton A-6 SMB"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
    case "PG&E GreenButton A-10S MLB"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Sonoma";
        
    case "Avalon GreenButton South Bay Education"
        Generation_Cost_Region = "NP15";
        Representative_Distribution_Cost_Profile = "Mission";
        
end

        
% Import Generation Cost Data

switch Generation_Cost_Region
    
    case "NP15"
        
        if delta_t == (5/60)
            Generation_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/5-Minute Data/' ...
                'Vector Format/NP15_5min_Generation_Cost_Vector.csv']);
        elseif delta_t == (15/60)
            Generation_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/15-Minute Data/' ...
                'Vector Format/NP15_15min_Generation_Cost_Vector.csv']);
        end
        
    case "SP15"
        
        if delta_t == (5/60)
            Generation_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/5-Minute Data/' ...
                'Vector Format/SP15_5min_Generation_Cost_Vector.csv']);
        elseif delta_t == (15/60)
            Generation_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/15-Minute Data/' ...
                'Vector Format/SP15_15min_Generation_Cost_Vector.csv']);
        end
        
end


% Import Representative Distribution Cost Data

switch Representative_Distribution_Cost_Profile
    
    case "Mission"
        
        if delta_t == (5/60)
            Representative_Distribution_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/5-Minute Data/' ...
                'Vector Format/Mission_5min_Distribution_Cost_Vector.csv']);
        elseif delta_t == (15/60)
            Representative_Distribution_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/15-Minute Data/' ...
                'Vector Format/Mission_15min_Distribution_Cost_Vector.csv']);
        end
        
    case "Sonoma"
        
        if delta_t == (5/60)
            Representative_Distribution_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/5-Minute Data/' ...
                'Vector Format/Sonoma_5min_Distribution_Cost_Vector.csv']);
        elseif delta_t == (15/60)
            Representative_Distribution_Cost_Data = csvread(['Utility Marginal Cost Data/' ...
                'Clean Utility Marginal Cost Data/15-Minute Data/' ...
                'Vector Format/Sonoma_15min_Distribution_Cost_Vector.csv']);
        end
        
end


% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end