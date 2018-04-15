@mfunction("Solar_PV_Profile_Data")
def Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Solar_Profile_Name_Input, Solar_Size_Input):

    # ryancmann@mac.com
    # Set Directory to Box Sync Folder
    # Note: CSV file is read by specifying the path. Hence, folder is not changed.
    #cd(Input_Output_Data_Directory_Location)

    # Import Solar PV Generation Profile Data.
    # Scale base 10-kW or 100-kW profile to match user-input PV system size.

    if Solar_Profile_Name_Input == "CSI PG&E Residential":
        #logical_and(PG, E)
        #Residential
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 10) * Solar_PV_Profile_Data    # Rescale 10 kW profile to user-input PV system size.

    elif Solar_Profile_Name_Input == "CSI SCE Residential":
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SCE_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SCE_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 10) * Solar_PV_Profile_Data    # Rescale 10 kW profile to user-input PV system size.

    elif Solar_Profile_Name_Input == "CSI SDG&E Residential":
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/10 kW Residential Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Residential.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 10) * Solar_PV_Profile_Data    # Rescale 10 kW profile to user-input PV system size.

    elif Solar_Profile_Name_Input == "CSI PG&E Commercial & Industrial":
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_PG&E_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 100) * Solar_PV_Profile_Data    # Rescale 100 kW profile to user-input PV system size.

    elif Solar_Profile_Name_Input == "CSI SCE Commercial & Industrial":
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SCE_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 100) * Solar_PV_Profile_Data    # Rescale 100 kW profile to user-input PV system size.

    elif Solar_Profile_Name_Input == "CSI SDG&E Commercial & Industrial":
        if delta_t == (5 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/5-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        elif delta_t == (15 / 60):
            csv_file_path = os.path.join('Sample Input and Output Data', 'Solar PV Data/California Solar Initiative/', 'Selected Clean 2017 CSI Generation Profiles/15-Minute Data/100 kW Commercial & Industrial Solar Profiles/Vector Format', 'Clean_Vector_2017_CSI_Solar_Profile_SDG&E_Commercial_&_Industrial.csv')
            Solar_PV_Profile_Data = genfromtxt(csv_file_path, delimiter=',')
        end

        Solar_PV_Profile_Data = (Solar_Size_Input / 100) * Solar_PV_Profile_Data    # Rescale 100 kW profile to user-input PV system size.

    end

    # Return to OSESMO Git Repository Directory
    # Note: CSV file was read by specifying the path. Hence, folder was not changed. Therefore, folder is already where this file is located.
    #cd(OSESMO_Git_Repo_Directory)

    return Solar_PV_Profile_Data

end
