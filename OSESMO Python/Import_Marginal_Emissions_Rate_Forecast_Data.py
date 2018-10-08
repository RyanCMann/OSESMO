def Import_Marginal_Emissions_Rate_Forecast_Data(Input_Output_Data_Directory_Location=None, OSESMO_Git_Repo_Directory=None, delta_t=None, Load_Profile_Data=None, Emissions_Forecast_Signal_Input=None):

    # Load Python Packages
    import os
    import numpy as np

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)

    # Import Marginal Emissions Rate Data Used as Forecast
    if Emissions_Forecast_Signal_Input == "No Emissions Forecast Signal":

        Marginal_Emissions_Rate_Forecast_Data = np.zeros(np.shape(Load_Profile_Data))

    elif Emissions_Forecast_Signal_Input == "NP15 RT5M":
        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    elif Emissions_Forecast_Signal_Input == "SP15 RT5M":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    elif Emissions_Forecast_Signal_Input == "NP15 DAM":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/5-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/15-Minute Data/2017_DA_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    elif Emissions_Forecast_Signal_Input == "SP15 DAM":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/5-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Day Ahead Market Forecasted Emissions Signal/15-Minute Data/2017_DA_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    elif Emissions_Forecast_Signal_Input == "NP15 DA WattTime":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/WattTime Public Methodology/5-Minute Data/Vector Format/2017_DA_WattTime_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/WattTime Public Methodology/15-Minute Data/Vector Format/2017_DA_WattTime_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    elif Emissions_Forecast_Signal_Input == "SP15 DA WattTime":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/WattTime Public Methodology/5-Minute Data/Vector Format/2017_DA_WattTime_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(
                'Emissions Data/WattTime Public Methodology/15-Minute Data/Vector Format/2017_DA_WattTime_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')
        

    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)

    return Marginal_Emissions_Rate_Forecast_Data