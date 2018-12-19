function Marginal_Emissions_Rate_Evaluation_Data = Import_Marginal_Emissions_Rate_Evaluation_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Emissions_Evaluation_Signal_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)

% Import Marginal Emissions Rate Data Used for Evaluation
switch Emissions_Evaluation_Signal_Input
    
    case "NP15 RT5M"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 RT5M"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "LADWP RT5M"
        
        if delta_t == (15/60)
            Marginal_Emissions_Rate_Evaluation_Data = csvread(['Emissions Data/WattTime LADWP/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_LADWP_Marginal_Emissions_Rate_Vector.csv']);
        end
        
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end