def Import_Marginal_Emissions_Rate_Evaluation_Data(Input_Output_Data_Directory_Location=None, OSESMO_Git_Repo_Directory=None, delta_t=None, Emissions_Evaluation_Signal_Input=None):

    # Load Python Packages
    import os
    import numpy as np

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)

    # Import Marginal Emissions Rate Data Used for Evaluation
    if Emissions_Evaluation_Signal_Input == "NP15 RT5M":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

    elif Emissions_Evaluation_Signal_Input == "SP15 RT5M":

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt(
                'Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv', delimiter=',')


    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)

    return Marginal_Emissions_Rate_Evaluation_Data

