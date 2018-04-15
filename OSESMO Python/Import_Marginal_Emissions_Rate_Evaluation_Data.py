
# coding: utf-8

# In[ ]:

#@mfunction("Marginal_Emissions_Rate_Evaluation_Data")
def Import_Marginal_Emissions_Rate_Evaluation_Data(Box_Sync_Directory_Location=None, OSESMO_Git_Repo_Directory=None, delta_t=None, Emissions_Evaluation_Signal_Input=None):

    # Set Directory to Box Sync Folder
    #cd(Box_Sync_Directory_Location)
    import os
    os.chdir(Box_Sync_Directory_Location)

    # Import Marginal Emissions Rate Data Used for Evaluation
    import numpy as np

    if Emissions_Evaluation_Signal_Input == “NP15 RT5M”:

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt('Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv',delimiter=',')
        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt('Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv',delimiter=',')

    elif Emissions_Evaluation_Signal_Input == “SP15 RT5M”:

        if delta_t == (5 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt('Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/5-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv',delimiter=',')
        elif delta_t == (15 / 60):
            Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt('Emissions Data/Itron-E3 Methodology/2017/Clean Emissions Data/Real Time 5 Minute Emissions Signal/15-Minute Data/2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv',delimiter=',')

    return Marginal_Emissions_Rate_Evaluation_Data

    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)

