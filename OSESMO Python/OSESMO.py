## Script Description Header

# File Name: OSESMO.py
# File Location: "~/Desktop/OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Simulates operation of energy storage system.
# Calculates customer savings, GHG reduction, and battery cycling.

import os
import math as math
import time as time
import numpy as np


def OSESMO(Modeling_Team_Input=None, Model_Run_Number_Input=None, Model_Type_Input=None, Model_Timestep_Resolution=None,
           Customer_Class_Input=None, Load_Profile_Name_Input=None, Retail_Rate_Name_Input=None, Solar_Profile_Name_Input=None,
           Solar_Size_Input=None, Storage_Type_Input=None, Storage_Power_Rating_Input=None, Usable_Storage_Capacity_Input=None,
           Single_Cycle_RTE_Input=None, Parasitic_Storage_Load_Input=None, Storage_Control_Algorithm_Name=None,
           GHG_Reduction_Solution_Input=None, Equivalent_Cycling_Constraint_Input=None, Annual_RTE_Constraint_Input=None,
           ITC_Constraint_Input=None, Carbon_Adder_Incentive_Value_Input=None, Emissions_Forecast_Signal_Input=None,
           OSESMO_Git_Repo_Directory=None, Input_Output_Data_Directory_Location=None, Start_Time_Input=None, Show_Plots=None,
           Export_Plots=None, Export_Data=None, Solar_Installed_Cost_per_kW=None, Storage_Installed_Cost_per_kWh=None,
           Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh=None, Cycle_Life=None, Storage_Depth_of_Discharge=None,
           Initial_Final_SOC=None, End_of_Month_Padding_Days=None):


    ## Calculate Model Variable Values from User-Specified Input Values

    # Convert model timestep resolution input from minutes to hours.
    # This is a more useful format for the model to use.
    delta_t = (Model_Timestep_Resolution / 60)  # Model timestep resolution, in hours.

    # Convert storage efficiency from round-trip efficiency to charge and discharge efficiency.
    # Charge efficiency and discharge efficiency assumed to be square root of round-trip efficiency (Eff_c = Eff_d).
    # Round-trip efficiency taken from Lazard's Levelized Cost of Storage report (2017), pg. 130
    # https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
    Eff_c = math.sqrt(Single_Cycle_RTE_Input)
    Eff_d = math.sqrt(Single_Cycle_RTE_Input)

    # Parasitic storage load (kW) calculated based on input value, which is
    # given as a percentage of Storage Power Rating.
    Parasitic_Storage_Load = Storage_Power_Rating_Input * Parasitic_Storage_Load_Input

    # Set Carbon Adder to $0/metric ton if GHG Reduction Solution is not GHG Signal Co-Optimization.
    # This serves as error-handling in case the user sets the Carbon Adder to a
    # non-zero value, and sets the GHG Reduction Solution to something other
    # than GHG Signal Co-Optimization.

    if GHG_Reduction_Solution_Input != "GHG Signal Co-Optimization":

        Carbon_Adder_Incentive_Value_Input = 0  # Value of carbon adder, in $ per metric ton.

        Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal"  # Ensures consistent outputs.


    # Set Solar Profile Name Input to "No Solar", set Solar Size Input to 0 kW,
    # and set ITC Constraint to 0 if Model Type Input is Storage Only.
    # This serves as error handling.

    if Model_Type_Input == "Storage Only":

    Solar_Profile_Name_Input = "No Solar"
    Solar_Size_Input = 0
    ITC_Constraint_Input = 0

    # Throw an error if Model Type Input is set to Solar Plus Storage
    # and Solar Profile Name Input is set to "No Solar",
    # or if Solar Size Input is set to 0 kW.

    if Model_Type_Input == "Solar Plus Storage":

        if Solar_Profile_Name_Input == "No Solar":
            print("Solar Plus Storage Model selected, but No Solar Profile Name Input selected.")

        if Solar_Size_Input == 0:
            print("Solar Plus Storage Model selected, but Solar Size Input set to 0 kW.")

    # Throw an error if Storage Control Algorithm set to OSESMO Non-Economic
    # Solar Self-Supply, and Model Type Input is set to Storage Only,
    # or if Solar Profile Name Input is set to "No Solar",
    # or if Solar Size Input is set to 0 kW.

    if Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply":
        if Model_Type_Input == "Storage Only":
            print(
                "OSESMO Non-Economic Solar Self-Supply control algorithm selected, but Model Type set to Storage Only.")

        if Solar_Profile_Name_Input == "No Solar":
            print(
                "OSESMO Non-Economic Solar Self-Supply control algorithm selected, but No Solar Profile Name Input selected.")

        if Solar_Size_Input == 0:
            print("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but Solar Size Input set to 0 kW.")


    # Emissions Evaluation Signal
    # Real-time five-minute marginal emissions signal used to evaluate emission impacts.
    # Available for both NP15 (Northern California congestion zone)
    # and SP15 (Southern California congestion zone).
    # Mapped based on load profile site location (Northern or Southern CA).

    if Load_Profile_Name_Input == "WattTime GreenButton Residential Berkeley" or \
        Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville" or \
        Load_Profile_Name_Input == "PG&E GreenButton E-6 Residential" or \
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE" or \
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE" or \
        Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Albany Residential with EV" or \
        Load_Profile_Name_Input == "Custom Power Solar GreenButton PG&E Crockett Residential with EV" or \
        Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" or \
        Load_Profile_Name_Input == "Avalon GreenButton South Bay Education" or \
        Load_Profile_Name_Input == "EnerNOC GreenButton San Francisco Office" or \
        Load_Profile_Name_Input == "EnerNOC GreenButton San Francisco Industrial" or \
        Load_Profile_Name_Input == "PG&E GreenButton A-6 SMB" or \
        Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" or \
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE" or \
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE":

        Emissions_Evaluation_Signal_Input = "NP15 RT5M"

    elif Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach" or\
        Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office" or\
        Load_Profile_Name_Input == "Stem GreenButton SDG&E G-16 Manufacturing" or\
        Load_Profile_Name_Input == "Stem GreenButton SCE GS-3B Food Processing" or\
        Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Grocery" or\
        Load_Profile_Name_Input == "EnerNOC GreenButton Los Angeles Industrial" or\
        Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office":

        Emissions_Evaluation_Signal_Input = "SP15 RT5M"

    else:

        print("This load profile name input has not been mapped to an emissions evaluation signal (NP15 or SP15).")


    # Total Storage Capacity
    # Total storage capacity is the total chemical capacity of the battery.
    # The usable storage capacity is equal to the total storage capacity
    # multiplied by storage depth of discharge. This means that the total
    # storage capacity is equal to the usable storage capacity divided by
    # storage depth of discharge. Total storage capacity is used to
    # calculate battery cost, whereas usable battery capacity is used
    # as an input to operational simulation portion of model.
    Total_Storage_Capacity = Usable_Storage_Capacity_Input / Storage_Depth_of_Discharge

    # Usable Storage Capacity
    # Usable storage capacity is equal to the original usable storage capacity
    # input, degraded every month based on the number of cycles performed in
    # that month. Initialized at the usable storage capacity input value.

    Usable_Storage_Capacity = Usable_Storage_Capacity_Input

    # Cycling Penalty
    # Cycling penalty for lithium-ion battery is equal to estimated replacement cell cost
    # in 10 years divided by expected cycle life. Cycling penalty for flow batteries is $0/cycle.

    if Storage_Type_Input == "Lithium-Ion Battery":

        cycle_pen = (Total_Storage_Capacity * Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh) / Cycle_Life

    elif Storage_Type_Input == "Flow Battery":
        cycle_pen = 0



    ## Import Data from CSV Files

    # Begin script runtime timer
    tstart = time.time()

    # Import Load Profile Data
    # Call Import_Load_Profile_Data function.
    # Load_Profile_Data = np.genfromtxt('Clean_Vector_2017_San_Francisco_Office.csv', delimiter = ",")
    Load_Profile_Data = Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
                                                 delta_t, Load_Profile_Name_Input)

    Annual_Peak_Demand_Baseline = np.max(Load_Profile_Data)
    Annual_Total_Energy_Consumption_Baseline = np.sum(Load_Profile_Data) * delta_t

    # Import Marginal Emissions Rate Data Used as Forecast
    # Call Import_Marginal_Emissions_Rate_Forecast_Data function.
    Marginal_Emissions_Rate_Forecast_Data = Import_Marginal_Emissions_Rate_Forecast_Data(
        Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
        delta_t, Load_Profile_Data, Emissions_Forecast_Signal_Input)

    # Import Marginal Emissions Rate Data Used for Evaluation
    # Call Import_Marginal_Emissions_Rate_Forecast_Data function.
    Marginal_Emissions_Rate_Evaluation_Data = Import_Marginal_Emissions_Rate_Evaluation_Data(
        Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
        delta_t, Emissions_Evaluation_Signal_Input)


    # Import Carbon Adder Data

    # Carbon Adder ($/kWh) = Marginal Emissions Rate (metric tons CO2/MWh) *
    # Carbon Adder ($/metric ton) * (1 MWh/1000 kWh)
    Carbon_Adder_Data = (Marginal_Emissions_Rate_Forecast_Data *
                         Carbon_Adder_Incentive_Value_Input) / 1000

    # Import Retail Rate Data
    # Call Import_Retail_Rate_Data function.
    [Volumetric_Rate_Data, Summer_Peak_DC, Summer_Part_Peak_DC, Summer_Noncoincident_DC,
     Winter_Peak_DC, Winter_Part_Peak_DC, Winter_Noncoincident_DC,
     Fixed_Per_Meter_Day_Charge, Fixed_Per_Meter_Month_Charge,
     First_Summer_Month, Last_Summer_Month, Month_Data,
     Summer_Peak_Binary_Data, Summer_Part_Peak_Binary_Data,
     Winter_Peak_Binary_Data, Winter_Part_Peak_Binary_Data] = Import_Retail_Rate_Data(
        Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
        delta_t, Retail_Rate_Name_Input)

    # Month_Data = np.genfromtxt('2017_PGE_E19S_OLD_Month_Vector.csv', delimiter = ",")

    # Import IOU-Proposed Charge and Discharge Hour Flag Vectors

    if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":

        [IOU_Charge_Hour_Binary_Data, IOU_Discharge_Hour_Binary_Data] = Import_IOU_Time_Constraint_Binary_Data(
            Input_Output_Data_Directory_Location,
            OSESMO_Git_Repo_Directory, delta_t)

    # Import PG&E-Proposed Charge, No-Charge, and Discharge Hour Flag Vectors

    if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" or \
        GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":

        [PGE_Charge_Hour_Binary_Data, PGE_No_Charge_Hour_Binary_Data, PGE_Discharge_Hour_Binary_Data] =
        Import_PGE_Time_Constraint_Binary_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t)

    # Import Solar PV Generation Profile Data
    # Scale base 10-kW or 100-kW profile to match user-input PV system size

    if Model_Type_Input == "Solar Plus Storage":

        Solar_PV_Profile_Data = Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location,
                                                             OSESMO_Git_Repo_Directory, delta_t,
                                                             Solar_Profile_Name_Input, Solar_Size_Input)

    elif Model_Type_Input == "Storage Only" or Solar_Profile_Name_Input == "No Solar":

        Solar_PV_Profile_Data = np.zeros(shape = Load_Profile_Data.shape)

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)

    ## Iterate Through Months & Filter Data to Selected Month

    # Initialize Blank Variables to store optimal decision variable values for
    # all months

    # Initialize Decision Variable Vectors
    P_ES_in = np.empty([])

    P_ES_out = np.empty([])

    Ene_Lvl = np.empty([])

    P_max_NC = np.empty([])

    P_max_peak = np.empty([])

    P_max_part_peak = np.empty([])

    # Initialize Monthly Cost Variable Vectors

    Fixed_Charge_Vector = np.array([])

    NC_DC_Baseline_Vector = np.array([])
    NC_DC_with_Solar_Only_Vector = np.array([])
    NC_DC_with_Solar_and_Storage_Vector = np.array([])

    CPK_DC_Baseline_Vector = np.array([])
    CPK_DC_with_Solar_Only_Vector = np.array([])
    CPK_DC_with_Solar_and_Storage_Vector = np.array([])

    CPP_DC_Baseline_Vector = np.array([])
    CPP_DC_with_Solar_Only_Vector = np.array([])
    CPP_DC_with_Solar_and_Storage_Vector = np.array([])

    Energy_Charge_Baseline_Vector = np.array([])
    Energy_Charge_with_Solar_Only_Vector = np.array([])
    Energy_Charge_with_Solar_and_Storage_Vector = np.array([])

    Cycles_Vector = np.array([])
    Cycling_Penalty_Vector = np.array([])

    for Month_Iter in range(1,13):  # Iterate through all months

        # Filter Load Profile Data to Selected Month
        Load_Profile_Data_Month = Load_Profile_Data[Month_Data == Month_Iter]

        # Filter PV Production Profile Data to Selected Month
        Solar_PV_Profile_Data_Month = Solar_PV_Profile_Data[Month_Data == Month_Iter]

        # Filter Volumetric Rate Data to Selected Month
        Volumetric_Rate_Data_Month = Volumetric_Rate_Data[Month_Data == Month_Iter]

        # Filter Marginal Emissions Data to Selected Month

        Marginal_Emissions_Rate_Forecast_Data_Month = Marginal_Emissions_Rate_Forecast_Data[Month_Data == Month_Iter]

        # Filter Carbon Adder Data to Selected Month

        Carbon_Adder_Data_Month = Carbon_Adder_Data[Month_Data == Month_Iter]



        # Set Demand Charge Values Based on Month

        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            Peak_DC = Summer_Peak_DC
            Part_Peak_DC = Summer_Part_Peak_DC
            Noncoincident_DC = Summer_Noncoincident_DC

        else:
            Peak_DC = Winter_Peak_DC
            Part_Peak_DC = Winter_Part_Peak_DC
            Noncoincident_DC = Winter_Noncoincident_DC


        # Filter Peak and Part-Peak Binary Data to Selected Month

        if Summer_Peak_DC > 0:
            Summer_Peak_Binary_Data_Month = Summer_Peak_Binary_Data[Month_Data == Month_Iter]

        if Summer_Part_Peak_DC > 0:
            Summer_Part_Peak_Binary_Data_Month = Summer_Part_Peak_Binary_Data[Month_Data == Month_Iter]

        if Winter_Peak_DC > 0:
            Winter_Peak_Binary_Data_Month = Winter_Peak_Binary_Data[Month_Data == Month_Iter]

        if Winter_Part_Peak_DC > 0:
            Winter_Part_Peak_Binary_Data_Month = Winter_Part_Peak_Binary_Data[Month_Data == Month_Iter]

        # Filter PG&E-Proposed Charge and Discharge Hour Binary Data to Selected Month
        if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" or \
                GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":
            PGE_Charge_Hour_Binary_Data_Month = PGE_Charge_Hour_Binary_Data[Month_Data == Month_Iter]
            PGE_No_Charge_Hour_Binary_Data_Month = PGE_No_Charge_Hour_Binary_Data[Month_Data == Month_Iter]
            PGE_Discharge_Hour_Binary_Data_Month = PGE_Discharge_Hour_Binary_Data[Month_Data == Month_Iter]

        # Filter IOU-Proposed Charge and Discharge Hour Binary Data to Selected Month
        if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":
            IOU_Charge_Hour_Binary_Data_Month = IOU_Charge_Hour_Binary_Data[Month_Data == Month_Iter]
            IOU_Discharge_Hour_Binary_Data_Month = IOU_Discharge_Hour_Binary_Data[Month_Data == Month_Iter]

        ## Add "Padding" to Every Month of Data
        # Don't pad Month 12, because the final state of charge is constrained
        # to equal the original state of charge.

        if Month_Iter in range(1, 12):

            # Pad Load Profile Data
            Load_Profile_Data_Month_Padded = np.concatenate((Load_Profile_Data_Month,
                                                             Load_Profile_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            # Pad PV Production Profile Data
            Solar_PV_Profile_Data_Month_Padded = np.concatenate((Solar_PV_Profile_Data_Month,
                                                                 Solar_PV_Profile_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            # Pad Volumetric Energy Rate Data
            Volumetric_Rate_Data_Month_Padded = np.concatenate((Volumetric_Rate_Data_Month,
                                                                Volumetric_Rate_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            # Pad Marginal Emissions Data
            Marginal_Emissions_Rate_Data_Month_Padded = np.concatenate((Marginal_Emissions_Rate_Data_Month,
                                                                        Marginal_Emissions_Rate_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            # Pad Carbon Adder Data
            Carbon_Adder_Data_Month_Padded = np.concatenate((Carbon_Adder_Data_Month,
                                                             Carbon_Adder_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            # Pad Peak and Part-Peak Binary Data

            if Summer_Peak_DC > 0:
                Summer_Peak_Binary_Data_Month_Padded = np.concatenate((Summer_Peak_Binary_Data_Month,
                                                                       Summer_Peak_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            if Summer_Part_Peak_DC > 0:
                Summer_Part_Peak_Binary_Data_Month_Padded = np.concatenate((Summer_Part_Peak_Binary_Data_Month,
                                                                       Summer_Part_Peak_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            if Winter_Peak_DC > 0:
                Winter_Peak_Binary_Data_Month_Padded = np.concatenate((Winter_Peak_Binary_Data_Month,
                                                                       Winter_Peak_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

            if Winter_Part_Peak_DC > 0:
                Winter_Part_Peak_Binary_Data_Month_Padded = np.concatenate((Winter_Part_Peak_Binary_Data_Month,
                                                                            Winter_Part_Peak_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))


            # Pad PG&E-Proposed Charge and Discharge Hour Binary Data
            if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" or \
                GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":

                PGE_Charge_Hour_Binary_Data_Month_Padded = np.concatenate((PGE_Charge_Hour_Binary_Data_Month,
                                                                           PGE_Charge_Hour_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

                PGE_No_Charge_Hour_Binary_Data_Month_Padded = np.concatenate((PGE_No_Charge_Hour_Binary_Data_Month,
                                                                              PGE_No_Charge_Hour_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

                PGE_Discharge_Hour_Binary_Data_Month_Padded = np.concatenate((PGE_Discharge_Hour_Binary_Data_Month,
                                                                              PGE_Discharge_Hour_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))


            # Pad IOU-Proposed Charge and Discharge Hour Binary Data
            if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":
                IOU_Charge_Hour_Binary_Data_Month_Padded = np.concatenate((IOU_Charge_Hour_Binary_Data_Month,
                                                                           IOU_Charge_Hour_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

                IOU_Discharge_Hour_Binary_Data_Month_Padded = np.concatenate((IOU_Discharge_Hour_Binary_Data_Month,
                                                                              IOU_Discharge_Hour_Binary_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

        elif Month_Iter == 12:

            # Don't Pad Load Profile Data
            Load_Profile_Data_Month_Padded = Load_Profile_Data_Month

            # Don't Pad PV Production Profile Data
            Solar_PV_Profile_Data_Month_Padded = Solar_PV_Profile_Data_Month

            # Don't Pad Volumetric Rate Data
            Volumetric_Rate_Data_Month_Padded = Volumetric_Rate_Data_Month

            # Don't Pad Marginal Emissions Data

            Marginal_Emissions_Rate_Data_Month_Padded = Marginal_Emissions_Rate_Forecast_Data_Month

            # Don't Pad Carbon Adder Data

            Carbon_Adder_Data_Month_Padded = Carbon_Adder_Data_Month

            # Don't Pad Peak and Part-Peak Binary Data

            if Summer_Peak_DC > 0:
                Summer_Peak_Binary_Data_Month_Padded = Summer_Peak_Binary_Data_Month

            if Summer_Part_Peak_DC > 0:
                Summer_Part_Peak_Binary_Data_Month_Padded = Summer_Part_Peak_Binary_Data_Month

            if Winter_Peak_DC > 0:
                Winter_Peak_Binary_Data_Month_Padded = Winter_Peak_Binary_Data_Month

            if Winter_Part_Peak_DC > 0:
                Winter_Part_Peak_Binary_Data_Month_Padded = Winter_Part_Peak_Binary_Data_Month

            # Don't Pad PG&E-Proposed Charge and Discharge Hour Binary Data
            if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" or \
                GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":
                PGE_Charge_Hour_Binary_Data_Month_Padded = PGE_Charge_Hour_Binary_Data_Month

                PGE_No_Charge_Hour_Binary_Data_Month_Padded = PGE_No_Charge_Hour_Binary_Data_Month

                PGE_Discharge_Hour_Binary_Data_Month_Padded = PGE_Discharge_Hour_Binary_Data_Month

            # Don't Pad IOU-Proposed Charge and Discharge Hour Binary Data
            if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":
                IOU_Charge_Hour_Binary_Data_Month_Padded = IOU_Charge_Hour_Binary_Data_Month

                IOU_Discharge_Hour_Binary_Data_Month_Padded = IOU_Discharge_Hour_Binary_Data_Month