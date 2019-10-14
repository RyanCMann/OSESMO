function Marginal_Emissions_Rate_Forecast_Data = Import_Marginal_Emissions_Rate_Forecast_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Load_Profile_Data, Emissions_Forecast_Signal_Input)

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)

% Import Marginal Emissions Rate Data Used as Forecast

switch Emissions_Forecast_Signal_Input
    
    case "No Emissions Forecast Signal"
        
        Marginal_Emissions_Rate_Forecast_Data = zeros(size(Load_Profile_Data));
        
    case "NP15 RT5M"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 RT5M"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/' ...
                '15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "NP15 DAM"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '5-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '15-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 DAM"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '5-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/Itron-E3 Methodology/' ...
                '2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/' ...
                '15-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "NP15 DA WattTime"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '5-Minute Data/Vector Format/2017_DA_WattTime_NP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '15-Minute Data/Vector Format/2017_DA_WattTime_NP15_Marginal_Emissions_Rate_Vector.csv']);
        end
        
    case "SP15 DA WattTime"
        
        if delta_t == (5/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '5-Minute Data/Vector Format/2017_DA_WattTime_SP15_Marginal_Emissions_Rate_Vector.csv']);
        elseif delta_t == (15/60)
            Marginal_Emissions_Rate_Forecast_Data = csvread(['Emissions Data/WattTime Public Methodology/' ...
                '15-Minute Data/Vector Format/2017_DA_WattTime_SP15_Marginal_Emissions_Rate_Vector.csv']);
        end
                
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end