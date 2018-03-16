function [IOU_Charge_Hour_Binary_Data, IOU_Discharge_Hour_Binary_Data] = ...
    Import_IOU_Time_Constraint_Binary_Data(Box_Sync_Directory_Location, OSESMO_Git_Repo_Directory, delta_t)

% Set Directory to Box Sync Folder
cd(Box_Sync_Directory_Location)

if delta_t == (5/60)
    IOU_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
        'Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/'...
        'Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv']);
    IOU_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
        'Joint-IOU-Proposed Charge-Discharge Constraint/2017/5-Minute Data/' ...
        'Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv']);
elseif delta_t == (15/60)
    IOU_Charge_Hour_Binary_Data = csvread(['Emissions Data/' ...
        'Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/'...
        'Vector Format/2017_IOU_Charge_Hour_Flag_Vector.csv']);
    IOU_Discharge_Hour_Binary_Data = csvread(['Emissions Data/' ...
        'Joint-IOU-Proposed Charge-Discharge Constraint/2017/15-Minute Data/' ...
        'Vector Format/2017_IOU_Discharge_Hour_Flag_Vector.csv']);
end

% Return to OSESMO Git Repository Directory
cd(OSESMO_Git_Repo_Directory)

end