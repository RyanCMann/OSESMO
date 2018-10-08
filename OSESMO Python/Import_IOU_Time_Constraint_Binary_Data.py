def Import_IOU_Time_Constraint_Binary_Data(Input_Output_Data_Directory_Location=None, OSESMO_Git_Repo_Directory=None, delta_t=None):

    # Load Python Packages
    import os
    import numpy as np

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)

    # Import IOU Charge/Discharge Binary Data
    if delta_t == (5 / 60):

        IOU_Charge_Hour_Binary_Data = np.genfromtxt(
            'Emissions Data/Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv', delimiter=',')

        IOU_Discharge_Hour_Binary_Data = np.genfromtxt(
            'Emissions Data/Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv', delimiter=',')

    elif delta_t == (15 / 60):

        IOU_Charge_Hour_Binary_Data = np.genfromtxt(
            'Emissions Data/Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv', delimiter=',')

        IOU_Discharge_Hour_Binary_Data = np.genfromtxt(
            'Emissions Data/Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv', delimiter=',')

    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)

    return IOU_Charge_Hour_Binary_Data, IOU_Discharge_Hour_Binary_Data


