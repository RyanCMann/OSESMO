def Import_Utility_Marginal_Cost_Data(Input_Output_Data_Directory_Location=None, OSESMO_Git_Repo_Directory=None, delta_t=None, Load_Profile_Name_Input=None):

    # Load Python Packages
    import os
    import numpy as np

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)


    if Load_Profile_Name_Input == "WattTime GreenButton Residential Berkeley":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "WattTime GreenButton Residential San Francisco":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "WattTime GreenButton Residential Oakland":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "PG&E GreenButton E-6 Residential":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Albany Residential with EV":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Crockett Residential with EV":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "Stem GreenButton SCE GS-2B Hospitality":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Stem GreenButton PG&E E-19 Office":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "Stem GreenButton SCE GS-3B Food Processing":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "Stem GreenButton SDG&E AL-TOU Education":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "Stem GreenButton PG&E E-19 Industrial":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Grocery":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office":
        Generation_Cost_Region = "SP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "EnerNOC GreenButton San Francisco Industrial":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "EnerNOC GreenButton San Francisco Office":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "PG&E GreenButton A-1 SMB":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "PG&E GreenButton A-6 SMB":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"

    elif Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Sonoma"

    elif Load_Profile_Name_Input == "Avalon GreenButton South Bay Education":
        Generation_Cost_Region = "NP15"
        Representative_Distribution_Cost_Profile = "Mission"



    # Import Generation Cost Data

    if Generation_Cost_Region == "NP15":

        if delta_t == (5 / 60):
            Generation_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/5-Minute Data/Vector Format/NP15_5min_Generation_Cost_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Generation_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/15-Minute Data/Vector Format/NP15_15min_Generation_Cost_Vector.csv', delimiter=',')


    elif Generation_Cost_Region == "SP15":

        if delta_t == (5 / 60):
            Generation_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/5-Minute Data/Vector Format/SP15_5min_Generation_Cost_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Generation_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/15-Minute Data/Vector Format/SP15_15min_Generation_Cost_Vector.csv', delimiter=',')




    # Import Representative Distribution Cost Data

    if Representative_Distribution_Cost_Profile == "Mission":

        if delta_t == (5 / 60):
            Representative_Distribution_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/5-Minute Data/Vector Format/Mission_5min_Distribution_Cost_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Representative_Distribution_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/15-Minute Data/Vector Format/Mission_15min_Distribution_Cost_Vector.csv', delimiter=',')


    elif Representative_Distribution_Cost_Profile == "Sonoma":

        if delta_t == (5 / 60):
            Representative_Distribution_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/5-Minute Data/Vector Format/Sonoma_5min_Distribution_Cost_Vector.csv', delimiter=',')

        elif delta_t == (15 / 60):
            Representative_Distribution_Cost_Data = np.genfromtxt(
                'Utility Marginal Cost Data/Clean Utility Marginal Cost Data/15-Minute Data/Vector Format/Sonoma_15min_Distribution_Cost_Vector.csv', delimiter=',')

    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)

    return Generation_Cost_Data, Representative_Distribution_Cost_Data