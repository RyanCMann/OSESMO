## Script Description Header

# File Name: OSESMO.py
# File Location: "~/Desktop/OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Simulates operation of energy storage system.
# Calculates customer savings, GHG reduction, and battery cycling.

import os
import math as math
import time as time
import datetime as datetime
import numpy as np
from cvxopt import matrix, sparse, solvers
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt


def OSESMO(Modeling_Team_Input=None, Model_Run_Number_Input=None, Model_Type_Input=None,
           Model_Timestep_Resolution=None, Customer_Class_Input=None, Load_Profile_Name_Input=None,
           Retail_Rate_Name_Input=None, Solar_Profile_Name_Input=None, Solar_Size_Input=None,
           Storage_Type_Input=None, Storage_Power_Rating_Input=None, Usable_Storage_Capacity_Input=None,
           Single_Cycle_RTE_Input=None, Parasitic_Storage_Load_Input=None,
           Storage_Control_Algorithm_Name=None, GHG_Reduction_Solution_Input=None, Equivalent_Cycling_Constraint_Input=None,
           Annual_RTE_Constraint_Input=None, ITC_Constraint_Input=None,
           Carbon_Adder_Incentive_Value_Input=None, Emissions_Forecast_Signal_Input=None,
           OSESMO_Git_Repo_Directory=None, Input_Output_Data_Directory_Location=None, Start_Time_Input=None,
           Show_Plots=None, Export_Plots=None, Export_Data=None,
           Solar_Installed_Cost_per_kW=None, Storage_Installed_Cost_per_kWh=None, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh=None,
           Cycle_Life=None, Storage_Depth_of_Discharge=None, Initial_Final_SOC=None, End_of_Month_Padding_Days=None):


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
            print("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but Model Type set to Storage Only.")

        if Solar_Profile_Name_Input == "No Solar":
            print("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but No Solar Profile Name Input selected.")

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

    from Import_Load_Profile_Data import Import_Load_Profile_Data

    [Load_Profile_Data, Load_Profile_Master_Index] = Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
                                                 delta_t, Load_Profile_Name_Input)

    Annual_Peak_Demand_Baseline = np.max(Load_Profile_Data)
    Annual_Total_Energy_Consumption_Baseline = np.sum(Load_Profile_Data) * delta_t


    # Import Marginal Emissions Rate Data Used as Forecast
    # Call Import_Marginal_Emissions_Rate_Forecast_Data function.

    from Import_Marginal_Emissions_Rate_Forecast_Data import Import_Marginal_Emissions_Rate_Forecast_Data

    Marginal_Emissions_Rate_Forecast_Data = Import_Marginal_Emissions_Rate_Forecast_Data(
        Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
        delta_t, Load_Profile_Data, Emissions_Forecast_Signal_Input)


    # Import Marginal Emissions Rate Data Used for Evaluation
    # Call Import_Marginal_Emissions_Rate_Forecast_Data function.

    from Import_Marginal_Emissions_Rate_Evaluation_Data import Import_Marginal_Emissions_Rate_Evaluation_Data

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

    from Import_Retail_Rate_Data import Import_Retail_Rate_Data

    [Volumetric_Rate_Data, Summer_Peak_DC, Summer_Part_Peak_DC, Summer_Noncoincident_DC,
     Winter_Peak_DC, Winter_Part_Peak_DC, Winter_Noncoincident_DC,
     Fixed_Per_Meter_Day_Charge, Fixed_Per_Meter_Month_Charge,
     First_Summer_Month, Last_Summer_Month, Month_Data,
     Summer_Peak_Binary_Data, Summer_Part_Peak_Binary_Data,
     Winter_Peak_Binary_Data, Winter_Part_Peak_Binary_Data] = Import_Retail_Rate_Data(
        Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
        delta_t, Retail_Rate_Name_Input)

    Month_Data = Month_Data.astype(int)
    Summer_Peak_Binary_Data = Summer_Peak_Binary_Data.astype(int)
    Summer_Part_Peak_Binary_Data = Summer_Part_Peak_Binary_Data.astype(int)
    Winter_Peak_Binary_Data = Winter_Peak_Binary_Data.astype(int)
    Winter_Part_Peak_Binary_Data = Winter_Part_Peak_Binary_Data.astype(int)



    # Import IOU-Proposed Charge and Discharge Hour Flag Vectors

    if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":

        from Import_IOU_Time_Constraint_Binary_Data import Import_IOU_Time_Constraint_Binary_Data

        [IOU_Charge_Hour_Binary_Data, IOU_Discharge_Hour_Binary_Data] = Import_IOU_Time_Constraint_Binary_Data(
            Input_Output_Data_Directory_Location,
            OSESMO_Git_Repo_Directory, delta_t)

    # Import PG&E-Proposed Charge, No-Charge, and Discharge Hour Flag Vectors

    if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" or GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":

        from Import_PGE_Time_Constraint_Binary_Data import Import_PGE_Time_Constraint_Binary_Data

        [PGE_Charge_Hour_Binary_Data, PGE_No_Charge_Hour_Binary_Data, PGE_Discharge_Hour_Binary_Data] = Import_PGE_Time_Constraint_Binary_Data(
            Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t)


    # Import Solar PV Generation Profile Data
    # Scale base 10-kW or 100-kW profile to match user-input PV system size

    if Model_Type_Input == "Solar Plus Storage":

        from Import_Solar_PV_Profile_Data import Import_Solar_PV_Profile_Data

        [Solar_Profile_Master_Index, Solar_Profile_Description, Solar_PV_Profile_Data] = Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location,
                                                             OSESMO_Git_Repo_Directory, delta_t,
                                                             Solar_Profile_Name_Input, Solar_Size_Input)

    elif Model_Type_Input == "Storage Only" or Solar_Profile_Name_Input == "No Solar":

        Solar_PV_Profile_Data = np.zeros(shape=Load_Profile_Data.shape)


    # Import Utility Marginal Cost Data
    # Marginal Costs are mapped to load profile location

    from Import_Utility_Marginal_Cost_Data import Import_Utility_Marginal_Cost_Data

    [Generation_Cost_Data, Representative_Distribution_Cost_Data] = Import_Utility_Marginal_Cost_Data(Input_Output_Data_Directory_Location,
                                                             OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input)


    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)


    ## Iterate Through Months & Filter Data to Selected Month

    # Initialize Blank Variables to store optimal decision variable values for
    # all months

    # Initialize Decision Variable Vectors
    P_ES_in = np.array([])

    P_ES_out = np.array([])

    Ene_Lvl = np.array([])

    P_max_NC = np.array([])

    P_max_peak = np.array([])

    P_max_part_peak = np.array([])


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

        if Month_Iter in range(1, 12):  # 1 through 11

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
            Marginal_Emissions_Rate_Data_Month_Padded = np.concatenate((Marginal_Emissions_Rate_Forecast_Data_Month,
                                                                        Marginal_Emissions_Rate_Forecast_Data_Month[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))

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



        ## Initialize Cost Vector "c"

        # nts = numtsteps = number of timesteps
        numtsteps = len(Load_Profile_Data_Month_Padded)
        all_tsteps = np.array(list(range(0, numtsteps)))


        # x = np.concatenate((P_ES_in_grid(size nts), P_ES_out(size nts), Ene_Lvl(size nts)
        # [P_max_NC (size 1)], [P_max_peak (size 1)], [P_max_part_peak (size 1)]))

        # Even if the system is charging from solar, it still has a relative cost
        # equal to the cost of grid power (Volumetric Rate).
        # This is because every amount of PV power going into the battery is
        # not used to offset load or export to the grid.

        c_Month_Bill_Only = np.concatenate(((Volumetric_Rate_Data_Month_Padded * delta_t),
                             (-Volumetric_Rate_Data_Month_Padded * delta_t),
                             np.zeros((numtsteps,)),
                             [Noncoincident_DC],
                             [Peak_DC],
                             [Part_Peak_DC]))

        # The same is true of carbon emissions. Every amount of PV power going into the battery is
        # not used at that time to offset emissions from the load or from the grid.

        c_Month_Carbon_Only = np.concatenate(((Carbon_Adder_Data_Month_Padded * delta_t),
                               (-Carbon_Adder_Data_Month_Padded * delta_t),
                               np.zeros(numtsteps,),
                               [0.],
                               [0.],
                               [0.]))

        c_Month_Degradation_Only = np.concatenate((
            (((Eff_c * cycle_pen) / (2. * Total_Storage_Capacity)) * delta_t) * np.ones(numtsteps,),
            ((cycle_pen / (Eff_d * 2. * Total_Storage_Capacity)) * delta_t) * np.ones(numtsteps,),
            np.zeros(numtsteps,),
            [0.],
            [0.],
            [0.]))

        # c_Month_Solar_Self_Supply is an additional cost term used in the
        # OSESMO Non-Economic Solar Self-Supply dispatch algorithm. This dispatch mode adds
        #  additional cost terms (P_PV(t) - P_ES_in(t)) to be minimized, which
        #  represent all power produced by the PV system that is not stored in the
        #  battery. Because P_PV is not controllable (not a decision variable),
        #  this can be simplified to adding -P_ES_in(t) cost terms to the cost function.

        if Storage_Control_Algorithm_Name == "OSESMO Economic Dispatch":
            c_Month_Solar_Self_Supply = np.concatenate((np.zeros(numtsteps,),
                                         np.zeros(numtsteps,),
                                         np.zeros(numtsteps,),
                                         [0.],
                                         [0.],
                                         [0.]))

        elif Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply":
            c_Month_Solar_Self_Supply = np.concatenate((-np.ones(numtsteps,),
                                         np.zeros(numtsteps,),
                                         np.zeros(numtsteps,),
                                         [0.],
                                         [0.],
                                         [0.]))

        c_Month = c_Month_Bill_Only + c_Month_Carbon_Only + c_Month_Degradation_Only + c_Month_Solar_Self_Supply

        # This is the length of the vectors c and x, or the total number of decision variables.
        length_x = len(c_Month)

        # Convert from numpy array to cvxopt matrix format
        c_Month = matrix(c_Month, tc = 'd')




        ## Decision Variable Indices

        # P_ES_in = x(1:numtsteps)
        # P_ES_out = x(numtsteps+1:2*numtsteps)
        # Ene_Lvl = x(2*numtsteps+1:3*numtsteps)
        # P_max_NC = x(3*numtsteps+1)
        # P_max_peak = x(3*numtsteps+2)
        # P_max_part_peak = x(3*numsteps+3)


        ## State of Charge Constraint

        # This constraint represents conservation of energy as it flows into and out of the
        # energy storage system, while accounting for efficiency losses.

        # For t in [0, numsteps-1]:

        # E[t+1] = E[t] + [Eff_c * P_ES_in[t] - (1/Eff_d) * P_ES_out[t]] * delta_t

        # E[t] - E[t+1] + Eff_c * P_ES_in[t] * delta_t - (1/Eff_d) * P_ES_out[t] * delta_t = 0

        # An equality constraint can be transformed into two inequality constraints
        # Ax = 0 -> Ax <=0 , -Ax <=0

        # Number of rows in each inequality constraint matrix = (numtsteps - 1)
        # Number of columns in each inequality constraint matrix = number of
        # decision variables = length_x

        A_E = sparse(matrix(0., (numtsteps - 1, length_x), tc = 'd'), tc = 'd')
        b_E = sparse(matrix(0., (numtsteps - 1, 1), tc = 'd'), tc = 'd')

        for n in range(0, numtsteps - 1): # Iterates from Index 0 to Index (numtsteps-2) - equivalent to Timesteps 1 to (numtsteps-1)
            A_E[n, n + (2 * numtsteps)] = 1.  # E[t]
            A_E[n, n + (2 * numtsteps) + 1] = -1.  # -E[t+1]
            A_E[n, n] = Eff_c * delta_t  # Eff_c * P_ES_in[t] * delta_t
            A_E[n, n + numtsteps] = (-1 / Eff_d) * delta_t  # - (1/Eff_d) * P_ES_out[t] * delta_t

        A_Month = sparse([A_E,
                          -A_E], tc = 'd')

        b_Month = sparse([b_E,
                          -b_E], tc = 'd')


        ## Energy Storage Charging Power Constraint

        # This constraint sets maximum and minimum values for P_ES_in.
        # The minimum is 0 kW, and the maximum is Storage_Power_Rating_Input.

        # P_ES_in >= 0 -> -P_ES_in <= 0

        # P_ES_in <= Storage_Power_Rating_Input

        # Number of rows in inequality constraint matrix = numtsteps
        # Number of columns in inequality constraint matrix = length_x
        A_P_ES_in = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')

        for n in range(0, numtsteps): # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
            A_P_ES_in[n, n] = -1.

        A_Month = sparse([A_Month,
                          A_P_ES_in,
                          -A_P_ES_in], tc = 'd')

        b_Month = sparse([b_Month,
                         sparse(matrix(0., (numtsteps, 1), tc = 'd'), tc = 'd'),
                         sparse(matrix(Storage_Power_Rating_Input, (numtsteps, 1), tc = 'd'), tc = 'd')], tc = 'd')


        ## Energy Storage Discharging Power Constraint

        # This constraint sets maximum and minimum values for P_ES_out.
        # The minimum is 0 kW, and the maximum is Storage_Power_Rating_Input.

        # P_ES_out >= 0 -> -P_ES_out <= 0

        # P_ES_out <= Storage_Power_Rating_Input

        A_P_ES_out = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')

        for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
            A_P_ES_out[n, n + numtsteps] = -1.

        A_Month = sparse([A_Month,
                          A_P_ES_out,
                          -A_P_ES_out], tc = 'd')

        b_Month = sparse([b_Month,
                          sparse(matrix(0., (numtsteps, 1), tc = 'd'), tc = 'd'),
                          sparse(matrix(Storage_Power_Rating_Input, (numtsteps, 1), tc = 'd'), tc = 'd')], tc = 'd')


        ## State of Charge Minimum/Minimum Constraints

        # This constraint sets maximum and minimum values on the Energy Level.
        # The minimum value is 0, and the maximum value is Usable_Storage_Capacity, the size of the
        # battery. Note: this optimization defines the range [0, Usable_Storage_Capacity] as the
        # effective storage capacity of the battery, without accounting for
        # depth of discharge.

        # Ene_Lvl(t) >= 0 -> -Ene_Lvl(t) <=0

        A_Ene_Lvl_min = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
        b_Ene_Lvl_min = sparse(matrix(0., (numtsteps, 1), tc = 'd'), tc = 'd')

        for n in range(0, numtsteps): # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
            A_Ene_Lvl_min[n, n + (2 * numtsteps)] = -1.

        A_Month = sparse([A_Month,
                          A_Ene_Lvl_min], tc = 'd')

        b_Month = sparse([b_Month,
                          b_Ene_Lvl_min], tc = 'd')

        # Ene_Lvl(t) <= Size_ES

        A_Ene_Lvl_max = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
        b_Ene_Lvl_max = matrix(Usable_Storage_Capacity * np.ones((numtsteps,1)), tc = 'd')

        for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
            A_Ene_Lvl_max[n, n + (2 * numtsteps)] = 1.

        A_Month = sparse([A_Month,
                          A_Ene_Lvl_max], tc = 'd')

        b_Month = sparse([b_Month,
                          b_Ene_Lvl_max], tc = 'd')


        ## Initial State of Charge Constraint

        # In the first month, this constraint initializes the energy level of the battery at
        # a user-defined percentage of the original battery capacity.
        # In all other month, this constraints initializes the energy level of
        # the battery at the final battery level from the previous month.

        # E(0) = Initial_Final_SOC * Usable_Storage_Capacity_Input
        # E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input

        # E(0) = Previous_Month_Final_Energy_Level
        # E(0) <= Previous_Month_Final_Energy_Level, -E(0) <= Previous_Month_Final_Energy_Level

        A_Ene_Lvl_0 = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

        A_Ene_Lvl_0[0, (2 * numtsteps)] = 1.

        if Month_Iter == 1:

            b_Ene_Lvl_0 = matrix(Initial_Final_SOC * Usable_Storage_Capacity_Input, tc = 'd')

        elif Month_Iter in range(2, (12 + 1)):

            b_Ene_Lvl_0 = matrix(Next_Month_Initial_Energy_Level, tc = 'd')

        A_Month = sparse([A_Month,
                          A_Ene_Lvl_0,
                          -A_Ene_Lvl_0], tc = 'd')

        b_Month = sparse([b_Month,
                          b_Ene_Lvl_0,
                          -b_Ene_Lvl_0], tc = 'd')


        ## Final State of Charge Constraints

        # This constraint fixes the final state of charge of the battery at a user-defined percentage
        # of the original battery capacity,
        # to prevent it from discharging completely in the final timesteps.

        # E(N) = Initial_Final_SOC * Usable_Storage_Capacity_Input
        # E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input

        A_Ene_Lvl_N = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

        A_Ene_Lvl_N[0, (3 * numtsteps) - 1] = 1.

        b_Ene_Lvl_N = matrix(Initial_Final_SOC * Usable_Storage_Capacity_Input, tc = 'd')

        A_Month = sparse([A_Month,
                          A_Ene_Lvl_N,
                          -A_Ene_Lvl_N], tc = 'd')

        b_Month = sparse([b_Month,
                          b_Ene_Lvl_N,
                          -b_Ene_Lvl_N], tc = 'd')


        ## Noncoincident Demand Charge Constraint

        # This constraint linearizes the noncoincident demand charge constraint.
        # Setting the demand charge value as a decision variable incentivizes
        # "demand capping" to reduce the value of max(P_load(t)) to an optimal
        # level without using the nonlinear max() operator.
        # The noncoincident demand charge applies across all 15-minute intervals.

        # P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_NC for all t
        # P_ES_in(t) - P_ES_out(t) - P_max_NC <= - P_load(t) + P_PV(t) for all t

        if Noncoincident_DC > 0:

            A_NC_DC = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
            b_NC_DC = matrix(-Load_Profile_Data_Month_Padded + Solar_PV_Profile_Data_Month_Padded, tc = 'd')

            for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
                A_NC_DC[n, n] = 1.
                A_NC_DC[n, n + numtsteps] = -1.
                A_NC_DC[n, (3 * numtsteps)] = -1.

            A_Month = sparse([A_Month,
                              A_NC_DC], tc = 'd')

            b_Month = sparse([b_Month,
                              b_NC_DC], tc = 'd')

        # Add P_max_NC >=0 Constraint
        # -P_max_NC <= 0
        # Note: this non-negativity constraint is added even if the noncoincident
        # demand charge is $0/kW for this tariff. This ensures that the
        # decision variable P_max_NC goes to zero, and is not negative.

        A_NC_DC_gt0 = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')
        A_NC_DC_gt0[0, (3 * numtsteps)] = -1.
        b_NC_DC_gt0 = matrix(0., tc = 'd')

        A_Month = sparse([A_Month,
                          A_NC_DC_gt0], tc = 'd')

        b_Month = sparse([b_Month,
                          b_NC_DC_gt0], tc = 'd')



        ## Coincident Peak Demand Charge Constraint

        # This constraint linearizes the coincident peak demand charge constraint.
        # This demand charge only applies for peak hours.

        # P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_peak for Peak t only
        # P_ES_in(t) - P_ES_out(t) - P_max_peak <= - P_load(t) + P_PV(t) for Peak t only

        if Peak_DC > 0:

            if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
                Peak_Indices = all_tsteps[Summer_Peak_Binary_Data_Month_Padded == 1]
                A_CPK_DC = sparse(matrix(0., (sum(Summer_Peak_Binary_Data_Month_Padded), length_x), tc = 'd'), tc = 'd')
                b_CPK_DC = matrix(-Load_Profile_Data_Month_Padded[Summer_Peak_Binary_Data_Month_Padded == 1] + \
                    Solar_PV_Profile_Data_Month_Padded[Summer_Peak_Binary_Data_Month_Padded == 1], tc = 'd')
            else:
                Peak_Indices = all_tsteps[Winter_Peak_Binary_Data_Month_Padded == 1]
                A_CPK_DC = sparse(matrix(0., (sum(Winter_Peak_Binary_Data_Month_Padded), length_x), tc = 'd'), tc = 'd')
                b_CPK_DC = matrix(-Load_Profile_Data_Month_Padded[Winter_Peak_Binary_Data_Month_Padded == 1] + \
                    Solar_PV_Profile_Data_Month_Padded[Winter_Peak_Binary_Data_Month_Padded == 1], tc = 'd')


            for n in range(0, len(Peak_Indices)):  # Iterates from Index 0 to Index (len(Peak_Indices)-1) - equivalent to Timesteps 1 to len(Peak_Indices)
                Peak_Index_n = int(Peak_Indices[n])
                A_CPK_DC[n, Peak_Index_n] = 1.
                A_CPK_DC[n, numtsteps + Peak_Index_n] = -1.
                A_CPK_DC[n, (3 * numtsteps) + 1] = -1.

            A_Month = sparse([A_Month,
                              A_CPK_DC], tc = 'd')

            b_Month = sparse([b_Month,
                              b_CPK_DC], tc = 'd')

        # Add P_max_peak >=0 Constraint
        # -P_max_peak <= 0
        # Note: this non-negativity constraint is added even if the coincident peak
        # demand charge is $0/kW for this tariff. This ensures that the
        # decision variable P_max_peak goes to zero, and is not negative.

        A_CPK_DC_gt0 = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')
        A_CPK_DC_gt0[0, (3 * numtsteps) + 1] = -1.
        b_CPK_DC_gt0 = matrix(0., tc = 'd')

        A_Month = sparse([A_Month,
                          A_CPK_DC_gt0], tc = 'd')

        b_Month = sparse([b_Month,
                          b_CPK_DC_gt0], tc = 'd')



        ## Coincident Part-Peak Demand Charge Constraint

        # This constraint linearizes the coincident part-peak demand charge
        # constraint.
        # This demand charge only applies for part-peak hours.

        # P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_part_peak for Part-Peak t only
        # P_ES_in(t) - P_ES_out(t) - P_max_part_peak <= - P_load(t) + P_PV(t) for Part-Peak t only

        if Part_Peak_DC > 0:

            if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
                Part_Peak_Indices = all_tsteps[Summer_Part_Peak_Binary_Data_Month_Padded == 1]
                A_CPP_DC = sparse(matrix(0., (sum(Summer_Part_Peak_Binary_Data_Month_Padded), length_x), tc = 'd'), tc = 'd')
                b_CPP_DC = matrix(-Load_Profile_Data_Month_Padded[Summer_Part_Peak_Binary_Data_Month_Padded == 1] + \
                    Solar_PV_Profile_Data_Month_Padded[Summer_Part_Peak_Binary_Data_Month_Padded == 1], tc = 'd')
            else:
                Part_Peak_Indices = all_tsteps[Winter_Part_Peak_Binary_Data_Month_Padded == 1]
                A_CPP_DC = sparse(matrix(0., (sum(Winter_Part_Peak_Binary_Data_Month_Padded), length_x), tc = 'd'), tc = 'd')
                b_CPP_DC = matrix(-Load_Profile_Data_Month_Padded[Winter_Part_Peak_Binary_Data_Month_Padded == 1] + \
                    Solar_PV_Profile_Data_Month_Padded[Winter_Part_Peak_Binary_Data_Month_Padded == 1], tc = 'd')


            for n in range(0, len(Part_Peak_Indices)):  # Iterates from Index 0 to Index (len(Part_Peak_Indices)-1) - equivalent to Timesteps 1 to len(Part_Peak_Indices)
                Part_Peak_Index_n = int(Part_Peak_Indices[n])
                A_CPP_DC[n, Part_Peak_Index_n] = 1.
                A_CPP_DC[n, numtsteps + Part_Peak_Index_n] = -1.
                A_CPP_DC[n, (3 * numtsteps) + 2] = -1.

            A_Month = sparse([A_Month,
                              A_CPP_DC], tc = 'd')

            b_Month = sparse([b_Month,
                       b_CPP_DC], tc = 'd')

        # Add P_max_part_peak >=0 Constraint
        # -P_max_part_peak <= 0
        # Note: this non-negativity constraint is added even if the coincident part-peak
        # demand charge is $0/kW for this tariff. This ensures that the
        # decision variable P_max_part_peak goes to zero, and is not negative.

        A_CPP_DC_gt0 = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')
        A_CPP_DC_gt0[0, (3 * numtsteps) + 2] = -1.
        b_CPP_DC_gt0 = matrix(0., tc = 'd')

        A_Month = sparse([A_Month,
                          A_CPP_DC_gt0], tc = 'd')

        b_Month = sparse([b_Month,
                          b_CPP_DC_gt0], tc = 'd')



        ## Optional Constraint - Solar ITC Charging Constraint

        # This constraint requires that the storage system be charged 100% from
        # solar. This ensures that the customer receives 100% of the
        # solar Incentive Tax Credit. The ITC amount is prorated by the amount
        # of energy entering into the battery that comes from solar
        # (ex. a storage system charged 90% from solar receives 90% of the ITC).
        # As a result, the optimal amount of solar charging is likely higher
        # than the minimum requirement of 75%, and likely very close to 100%.

        # P_ES_in(t) <= P_PV(t)

        # Note that P_PV(t) can sometimes be negative for some PV profiles, if
        # the solar inverter is consuming energy at night. As a result, P_PV(t)
        # here refers to a modified version of the solar profile where all
        # negative values are set to 0. Otherwise, the model would break
        # because P_ES_in must be >= 0, and can't also be <= P_PV(t) if P_PV(t)
        # <= 0.

        if Model_Type_Input == "Solar Plus Storage" and Solar_Profile_Name_Input != "No Solar" and \
                Solar_Size_Input > 0 and ITC_Constraint_Input == 1:

            Solar_PV_Profile_Data_Month_Padded_Nonnegative = Solar_PV_Profile_Data_Month_Padded
            Solar_PV_Profile_Data_Month_Padded_Nonnegative[Solar_PV_Profile_Data_Month_Padded_Nonnegative < 0] = 0.

            A_ITC = sparse(matrix(0., (numtsteps, length_x)))
            b_ITC = matrix(Solar_PV_Profile_Data_Month_Padded_Nonnegative, tc = 'd')

            for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
                A_ITC[n, n] = 1.

            A_Month = sparse([A_Month,
                              A_ITC])

            b_Month = sparse([b_Month,
                              b_ITC], tc = 'd')


        ## Optional Constraint - No-Charging Time Constraint

        if GHG_Reduction_Solution_Input == "No-Charging Time Constraint":

            # PG&E has suggested a set of time-based constraints on storage charging.
            # One of these constraints is that storage would not be allowed to discharge between 4:00 pm and 9:00 pm.

            # No-Charging Constraint
            # Charging power in each timestep is set equal to 0 between 4:00 pm and 9:00 pm.
            # Because charging power is constrained to be greater than
            # zero, setting the sum of all charging power timesteps to 0 (a
            # single constraint across all timesteps) ensures that all values will be zero
            # without needing to set a constraint for each timestep.

            # Sum of all P_ES_in(t) between 4:00 and 9:00 = 0
            # Because of nonnegative constraint on P_ES_in(t), this is
            # equivalent to a set of numtsteps constraints stating that
            # all P_ES_in(t) between 4:00 and 9:00 = 0 for each timestep.

            A_PGE_No_Charge = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')
            PGE_No_Charge_Hour_Indices = all_tsteps[PGE_No_Charge_Hour_Binary_Data_Month_Padded == 1]

            # Sum of all P_ES_in(t) between 4:00 and 9:00
            A_PGE_No_Charge[0, PGE_No_Charge_Hour_Indices] = 1.

            b_PGE_No_Charge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month,
                              A_PGE_No_Charge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_PGE_No_Charge], tc = 'd')


        ## Optional Constraint - Charging and Discharging Time Constraints

        if GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints":

            # PG&E has suggested a set of time-based constraints on storage charging.
            # At least 50% of total charging would need to occur between 9:00 am and 2:00 pm,
            # and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.
            # In addition, storage would not be allowed to discharge between 4:00 pm and 9:00 pm.

            # Derivation of charging constraint in standard linear form Ax <= 0:
            # Sum of all P_ES_in(t) between 9:00 and 2:00/sum of all P_ES_in(t) >= 0.5
            # Sum of all P_ES_in(t) between 9:00 and 2:00 >= 0.5 * sum of all P_ES_in(t)
            # 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00
            # 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00 <= 0
            # 0.5 * sum of all P_ES_in(t) not between 9:00 and 2:00 - 0.5 * sum of all P_ES_in(t)
            # between 9:00 and 2:00 <= 0.

            # Charging Constraint
            A_PGE_Charge = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

            # 0.5 * sum of all P_ES_in(t)
            A_PGE_Charge[0, range(0, numtsteps)] = 0.5
            PGE_Charge_Hour_Indices = all_tsteps[PGE_Charge_Hour_Binary_Data_Month_Padded == 1]

            # -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
            A_PGE_Charge[0, PGE_Charge_Hour_Indices] = -0.5

            b_PGE_Charge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month, A_PGE_Charge], tc = 'd')
            b_Month = sparse([b_Month, b_PGE_Charge], tc = 'd')


            # No-Charging Constraint
            # Charging power in each timestep is set equal to 0 between 4:00 pm and 9:00 pm.
            # Because charging power is constrained to be greater than
            # zero, setting the sum of all charging power timesteps to 0 (a
            # single constraint across all timesteps) ensures that all values will be zero
            # without needing to set a constraint for each timestep.

            # Sum of all P_ES_in(t) between 4:00 and 9:00 = 0
            # Because of nonnegative constraint on P_ES_in(t), this is
            # equivalent to a set of numtsteps constraints stating that
            # all P_ES_in(t) between 4:00 and 9:00 = 0 for each timestep.

            A_PGE_No_Charge = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')
            PGE_No_Charge_Hour_Indices = all_tsteps[PGE_No_Charge_Hour_Binary_Data_Month_Padded == 1]

            # Sum of all P_ES_in(t) between 4:00 and 9:00
            A_PGE_No_Charge[0, PGE_No_Charge_Hour_Indices] = 1.

            b_PGE_No_Charge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month,
                              A_PGE_No_Charge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_PGE_No_Charge], tc = 'd')

            # Derivation of discharging constraint in standard linear form Ax <= 0:
            # Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
            # Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
            # 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
            # 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
            # 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
            # between 4:00 and 9:00 <= 0.

            # Discharging Constraint
            A_PGE_Discharge = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

            # 0.5 * sum of all P_ES_out(t)
            A_PGE_Discharge[0, range(numtsteps, 2 * numtsteps)] = 0.5
            PGE_Discharge_Hour_Indices = all_tsteps[PGE_Discharge_Hour_Binary_Data_Month_Padded == 1]

            # -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
            A_PGE_Discharge[0, numtsteps + PGE_Discharge_Hour_Indices] = -0.5

            b_PGE_Discharge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month,
                              A_PGE_Discharge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_PGE_Discharge], tc = 'd')

        ## Optional Constraint - Investor-Owned-Utility-Proposed Charge-Discharge Hours

        if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints":

            # The Investor-Owned Utilities have suggested constraints on charging in particular hours
            # as a proposed method for reducing greenhouse gas emissions associated with storage dispatch.
            # Specifically, at least 50% of total charging would need to occur between 12:00 noon and 4:00 pm,
            # and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.

            # Derivation of charging constraint in standard linear form Ax <= 0:
            # Sum of all P_ES_in(t) between 12:00 and 4:00/sum of all P_ES_in(t) >= 0.5
            # Sum of all P_ES_in(t) between 12:00 and 4:00 >= 0.5 * sum of all P_ES_in(t)
            # 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00
            # 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00 <= 0
            # 0.5 * sum of all P_ES_in(t) not between 12:00 and 4:00 - 0.5 * sum of all P_ES_in(t)
            # between 12:00 and 4:00 <= 0.

            # Charging Constraint
            A_IOU_Charge = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

            # 0.5 * sum of all P_ES_in(t)
            A_IOU_Charge[1, range(0, numtsteps)] = 0.5
            IOU_Charge_Hour_Indices = all_tsteps[IOU_Charge_Hour_Binary_Data_Month_Padded == 1]

            # -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
            A_IOU_Charge[0, IOU_Charge_Hour_Indices] = -0.5

            b_IOU_Charge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month,
                              A_IOU_Charge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_IOU_Charge], tc = 'd')

            # Derivation of discharging constraint in standard linear form Ax <= 0:
            # Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
            # Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
            # 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
            # 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
            # 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
            # between 4:00 and 9:00 <= 0.

            # Discharging Constraint
            A_IOU_Discharge = sparse(matrix(0., (1, length_x)))

            # 0.5 * sum of all P_ES_out(t)
            A_IOU_Discharge[0, range(numtsteps, 2 * numtsteps)] = 0.5
            IOU_Discharge_Hour_Indices = all_tsteps[IOU_Discharge_Hour_Binary_Data_Month_Padded == 1]

            # -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
            A_IOU_Discharge[0, numtsteps + IOU_Discharge_Hour_Indices] = -0.5

            b_IOU_Discharge = matrix(0., tc = 'd')

            A_Month = sparse([A_Month,
                              A_IOU_Discharge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_IOU_Discharge], tc = 'd')


        ## Optional Constraint - Non-Positive GHG Emissions Impact

        # Note - the system is following the forecast signal to obey
        # this constraint, not the evaluation signal. It may be necessary
        # to adjust this constraint to aim for a negative GHG impact
        # based on the forecast signal, in order to achieve a non-positive
        # GHG impact as measured by the evaluation signal.

        if GHG_Reduction_Solution_Input == "Non-Positive GHG Constraint":

            # The sum of the net battery charge/discharge load in each
            # timestep, multiplied by the marginal emissions rate in each
            # timestep, must be less than or equal to 0.

            # A_Non_Positive_GHG is similar to c_Month_Carbon_Only,
            # but with Marginal Emissions Rate Data instead of Carbon Adder Data and transposed.
            A_Non_Positive_GHG = matrix(np.concatenate((np.reshape(Marginal_Emissions_Rate_Data_Month_Padded * delta_t, (1, len(Marginal_Emissions_Rate_Data_Month_Padded))), \
                np.reshape(-Marginal_Emissions_Rate_Data_Month_Padded * delta_t, (1, len(Marginal_Emissions_Rate_Data_Month_Padded))), \
                np.zeros((1, numtsteps)), \
                np.reshape(np.array([0., 0., 0.]), (1, 3))), \
                axis = 1))

            b_Non_Positive_GHG = matrix(0., tc = 'd')

            A_Month = sparse([A_Month, A_Non_Positive_GHG], tc = 'd')
            b_Month = sparse([b_Month, b_Non_Positive_GHG], tc = 'd')


        ## Optional Constraint - Equivalent Cycling Constraint

        # Note: due to the OSESMO model structure, the annual cycling requirement
        # must be converted to an equivalent monthly cycling requirement.

        if Equivalent_Cycling_Constraint_Input > 0:

            SGIP_Monthly_Cycling_Requirement = Equivalent_Cycling_Constraint_Input * \
                                               (len(Load_Profile_Data_Month_Padded) / len(Load_Profile_Data))

            # Formula for equivalent cycles is identical to the one used to calculate Cycles_Month:
            # Equivalent Cycles = sum((P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)) + \
            #    (P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)))

            # Equivalent Cycles >= SGIP_Monthly_Cycling Requirement
            # To convert to standard linear program form, multiply both sides by -1.
            # -Equivalent Cycles <= -SGIP_Monthly_Cycling_Requirement

            A_Equivalent_Cycles = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

            # sum of all P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)
            A_Equivalent_Cycles[0, range(0, numtsteps)] = -(((Eff_c) / (2 * Total_Storage_Capacity)) * delta_t)

            # sum of all P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)
            A_Equivalent_Cycles[0, range(numtsteps, 2 * numtsteps)] = -((1 / (Eff_d * 2 * Total_Storage_Capacity)) * delta_t)

            b_Equivalent_Cycles = matrix(-SGIP_Monthly_Cycling_Requirement, tc = 'd')

            A_Month = sparse([A_Month,
                              A_Equivalent_Cycles], tc = 'd')

            b_Month = sparse([b_Month,
                              b_Equivalent_Cycles], tc = 'd')


        ## Optional Constraint - Operational/SGIP Round-Trip Efficiency Constraint

        # Note: due to the OSESMO model structure, the annual RTE requirement
        # must be converted to an equivalent monthly RTE requirement.

        if Annual_RTE_Constraint_Input > 0:

            # If it's impossible for the storage system to achieve the RTE requirement
            # even if it were constantly cycling, stop the model.

            if (Eff_c * Eff_d * Storage_Power_Rating_Input) / (
                    Storage_Power_Rating_Input + Parasitic_Storage_Load) < Annual_RTE_Constraint_Input:

                print(['No solution - could not achieve SGIP RTE requirement' \
                       ' with the provided nameplate efficiency and auxiliary storage load values.'])

            # Formula for Annual Operational/SGIP round-trip efficiency is identical to the one
            # used to calculate Operational_RTE_Percent:
            # Operational_RTE_Percent = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t)
            # Note that Auxiliary_Storage_Load has to be added to P_ES_in here.
            # During the calculation of Operational_RTE_Percent, it has already
            # been added previously, so it does not need to be included in the
            # formula the way it is here.

            # "The Commission concluded that storage devices should demonstrate
            # an average RTE of at least 66.5% over ten years (equivalent to a
            # first-year RTE of 69.6%) in order to qualify for SGIP incentive
            # payments." (Stem, Inc.'s Petition for Modification of Decision 15-11-027, pg. 2)

            # Operational RTE Percent >= 0.696
            # (sum(P_ES_out) * delta_t)/((sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t) >= 0.696
            # (sum(P_ES_out) * delta_t) >= 0.696 * (sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t)
            # To convert to standard linear program form, multiply both sides by -1.
            # -(sum(P_ES_out) * delta_t) <= -0.696 * (sum(P_ES_in) * delta_t) -(sum(Auxiliary_Storage_Load) * delta_t)
            # -(sum(P_ES_out) * delta_t) + 0.696 * (sum(P_ES_in) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)
            # 0.696 * (sum(P_ES_in) * delta_t) -(sum(P_ES_out) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)

            A_SGIP_RTE = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

            # sum of all (P_ES_in(t) * (0.696 * delta_t)
            A_SGIP_RTE[0, range(0, numtsteps)] = (Annual_RTE_Constraint_Input * delta_t)

            # sum of all P_ES_out(t) * -delta_t
            A_SGIP_RTE[0, range(numtsteps, 2 * numtsteps)] = -delta_t

            # (sum(Auxiliary_Storage_Load) * delta_t)
            b_SGIP_RTE = matrix(-((numtsteps * Parasitic_Storage_Load) * delta_t), tc = 'd')

            A_Month = sparse([A_Month,
                              A_SGIP_RTE], tc = 'd')

            b_Month = sparse([b_Month,
                              b_SGIP_RTE], tc = 'd')


        ## Optional Constraint - No-Export Constraint

        # This constraint prevents the standalone energy-storage systems from
        # backfeeding power from the storage system onto the distribution grid.
        # Solar-plus storage systems are allowed to export to the grid.

        if Model_Type_Input == "Storage Only":

            # P_load(t) + P_ES_in(t) - P_ES_out(t) >= 0
            # -P_ES_in(t) + P_ES_out(t) <= P_load(t)

            A_No_Export = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
            b_No_Export = matrix(Load_Profile_Data_Month_Padded, tc = 'd')

            for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
                A_No_Export[n, n] = -1.
                A_No_Export[n, n + numtsteps] = 1.

            A_Month = sparse([A_Month,
                              A_No_Export], tc = 'd')

            b_Month = sparse([b_Month,
                              b_No_Export], tc = 'd')


        ## Optional Constraint - Solar Self-Supply

        # In the Economic Dispatch mode, this constraint is not necessary -
        # the presence of a positive cost on battery charging ensures that
        # simultaneous charging and discharging does not occur.
        # However, in the Non-Economic Solar Self-Consumption, which negative
        # costs on both charging and discharging, the battery charges and
        # discharges simultaneously so as to minimize total cost.
        # This constraint ensures that simultaneous charging and
        # discharging does not occur, and ensures that the storage system
        # only charges when there is excess solar power (net load is negative)
        # and discharges when net load is positive.

        if Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply":

            # P_ES_in <= Non-negative(P_PV - P_Load)

            Excess_Solar_Profile_Data_Month_Padded = Solar_PV_Profile_Data_Month_Padded - Load_Profile_Data_Month_Padded
            Excess_Solar_Profile_Data_Month_Padded[Excess_Solar_Profile_Data_Month_Padded < 0] = 0

            A_Self_Supply_Charge = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
            b_Self_Supply_Charge = matrix(Excess_Solar_Profile_Data_Month_Padded, tc = 'd')

            for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
                A_Self_Supply_Charge[n, n] = 1.

            A_Month = sparse([A_Month,
                              A_Self_Supply_Charge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_Self_Supply_Charge], tc = 'd')

            # P_ES_out <= Non-negative(P_Load - P_PV)

            Non_Negative_Net_Load_Profile_Data_Month_Padded = Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded
            Non_Negative_Net_Load_Profile_Data_Month_Padded[Non_Negative_Net_Load_Profile_Data_Month_Padded < 0] = 0

            A_Self_Supply_Discharge = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
            b_Self_Supply_Discharge = Non_Negative_Net_Load_Profile_Data_Month_Padded

            for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
                A_Self_Supply_Discharge[n, n + numtsteps] = 1.

            A_Month = sparse([A_Month,
                              A_Self_Supply_Discharge], tc = 'd')

            b_Month = sparse([b_Month,
                              b_Self_Supply_Discharge], tc = 'd')


        ## Run LP Optimization Algorithm

        # Check that number of rows in A_Month.size == number of rows in b_Month.size
        # Check that A_Month.typecode, b_Month.typecode, c_Month.typecode == 'd'

        b_Month = matrix(b_Month, tc = 'd') # Convert from sparse to dense matrix

        lp_solution = solvers.lp(c_Month, A_Month, b_Month)

        x_Month = lp_solution['x']

        print("Optimization complete for Month %d." % Month_Iter)


        ## Separate Decision Variable Vectors

        x_Month = np.asarray(x_Month)

        P_ES_in_Month_Padded = x_Month[range(0, numtsteps)]

        P_ES_out_Month_Padded = x_Month[range(numtsteps, 2 * numtsteps)]

        Ene_Lvl_Month_Padded = x_Month[range(2 * numtsteps, 3 * numtsteps)]


        ## Add Auxiliary Load/Parasitic Losses to P_ES_in

        P_ES_in_Month_Padded = P_ES_in_Month_Padded + Parasitic_Storage_Load


        ## Remove "Padding" from Decision Variables

        # Data is padded in Months 1-11, and not in Month 12

        if Month_Iter in range(1, 12):

            P_ES_in_Month_Unpadded = P_ES_in_Month_Padded[range(0, (len(P_ES_in_Month_Padded)-int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

            P_ES_out_Month_Unpadded = P_ES_out_Month_Padded[range(0, (len(P_ES_out_Month_Padded)-int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

            Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded[range(0, (len(Ene_Lvl_Month_Padded)-int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

        elif Month_Iter == 12:

            P_ES_in_Month_Unpadded = P_ES_in_Month_Padded

            P_ES_out_Month_Unpadded = P_ES_out_Month_Padded

            Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded


        # Save Final Energy Level of Battery for use in next month

        Previous_Month_Final_Energy_Level = Ene_Lvl_Month_Unpadded[-1,0]

        Next_Month_Initial_Energy_Level = Previous_Month_Final_Energy_Level + \
                                          ((Eff_c * P_ES_in_Month_Unpadded[-1,0]) - \
                                           ((1 / Eff_d) * P_ES_out_Month_Unpadded[-1,0])) * delta_t


        ## Calculate Monthly Peak Demand Using 15-Minute Intervals

        # Demand Charges are Based on 15-minute interval periods.
        # If the model has 15-minute timestep resolution, the decision
        # variables can be used directly as maximum coincident and noncoincident demand values.
        # Otherwise (such as with 5-minute timestep resolution), maximum
        # demand must be calculated by taking 15-minute averages of the
        # demand values, and then calculating the maximum of these averages.

        if delta_t < (15 / 60):

            # Noncoincident Maximum Demand With and Without Solar and Storage

            # Create Net Load Profile After Solar Only
            Solar_Only_Net_Load_Profile_Data_Month_5_Min = (Load_Profile_Data_Month - Solar_PV_Profile_Data_Month)

            # Create Net Load Profile After Solar and Storage
            Solar_Storage_Net_Load_Profile_Data_Month_5_Min = (Load_Profile_Data_Month - Solar_PV_Profile_Data_Month + \
                                                               P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded)

            # Number of timesteps to average to get 15-minute net load data.
            Reshaped_Rows_Num = int((15 / 60) / delta_t)

            # Reshape load data so that each 15-minute increment's data
            # is in the same column. This creates an array with 3 rows for 5-minute data.
            Load_Profile_Data_Month_Reshaped = np.reshape(Load_Profile_Data_Month, \
                                                          (Reshaped_Rows_Num, len(Load_Profile_Data_Month) / Reshaped_Rows_Num))

            Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(Solar_Only_Net_Load_Profile_Data_Month_5_Min, \
                                                                               (Reshaped_Rows_Num, len(Solar_Only_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

            Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(Solar_Storage_Net_Load_Profile_Data_Month_5_Min, \
                                                                                  (Reshaped_Rows_Num, len(Solar_Storage_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

            # Create 15-minute load profiles by calculating the average of each column.
            Load_Profile_Data_Month_15_Min = np.mean(Load_Profile_Data_Month_Reshaped, 1)
            Solar_Only_Net_Load_Profile_Data_Month_15_Min = np.mean(Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)
            Solar_Storage_Net_Load_Profile_Data_Month_15_Min = np.mean(Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)

            # Calculate Noncoincident Maximum Demand
            P_max_NC_Month_Baseline = np.max(Load_Profile_Data_Month_15_Min)
            P_max_NC_Month_with_Solar_Only = np.max(Solar_Only_Net_Load_Profile_Data_Month_15_Min)
            P_max_NC_Month_with_Solar_and_Storage = np.max(Solar_Storage_Net_Load_Profile_Data_Month_15_Min)

            # Coincident Peak Demand With and Without Storage

            if Peak_DC > 0:

                if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):

                    # Create Coincident Peak Load and Net Load Profiles
                    CPK_Load_Profile_Data_Month = Load_Profile_Data_Month[Summer_Peak_Binary_Data_Month == 1]

                    CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min = Solar_Only_Net_Load_Profile_Data_Month_5_Min[Summer_Peak_Binary_Data_Month == 1]

                    CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = Solar_Storage_Net_Load_Profile_Data_Month_5_Min[Summer_Peak_Binary_Data_Month == 1]

                else:

                    # Create Coincident Peak Load and Net Load Profiles
                    CPK_Load_Profile_Data_Month = Load_Profile_Data_Month[Winter_Peak_Binary_Data_Month == 1]

                    CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min = Solar_Only_Net_Load_Profile_Data_Month_5_Min[Winter_Peak_Binary_Data_Month == 1]

                    CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = Solar_Storage_Net_Load_Profile_Data_Month_5_Min[Winter_Peak_Binary_Data_Month == 1]



                # Reshape load data so that each 15-minute increment's data
                # is in the same column. This creates an array with 3 rows for 5-minute data.
                CPK_Load_Profile_Data_Month_Reshaped = np.reshape(CPK_Load_Profile_Data_Month, \
                                                               (Reshaped_Rows_Num, len(CPK_Load_Profile_Data_Month) / Reshaped_Rows_Num))

                CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min, \
                                                                                       (Reshaped_Rows_Num, len(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

                CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min, \
                                                                                          (Reshaped_Rows_Num, len(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

                # Create 15-minute load profiles by calculating the average of each column.
                CPK_Load_Profile_Data_Month_15_Min = np.mean(CPK_Load_Profile_Data_Month_Reshaped, 1)

                CPK_Solar_Only_Net_Load_Profile_Data_Month_15_Min = np.mean(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)

                CPK_Solar_Storage_Net_Load_Profile_Data_Month_15_Min = np.mean(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)

                # Calculate Coincident Peak Demand
                P_max_CPK_Month_Baseline = np.max(CPK_Load_Profile_Data_Month_15_Min)
                P_max_CPK_Month_with_Solar_Only = np.max(CPK_Solar_Only_Net_Load_Profile_Data_Month_15_Min)
                P_max_CPK_Month_with_Solar_and_Storage = np.max(CPK_Solar_Storage_Net_Load_Profile_Data_Month_15_Min)

            else:

                # If there is no Coincident Peak Demand Period (or if the
                # corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
                P_max_CPK_Month_Baseline = 0
                P_max_CPK_Month_with_Solar_Only = 0
                P_max_CPK_Month_with_Solar_and_Storage = 0

                # Coincident Part-Peak Demand With and Without Storage

            if Part_Peak_DC > 0:

                if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):

                    # Create Coincident Part-Peak Load and Net Load Profiles
                    CPP_Load_Profile_Data_Month = Load_Profile_Data_Month[Summer_Part_Peak_Binary_Data_Month == 1]

                    CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min = Solar_Only_Net_Load_Profile_Data_Month_5_Min[Summer_Part_Peak_Binary_Data_Month == 1]

                    CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = Solar_Storage_Net_Load_Profile_Data_Month_5_Min[Summer_Part_Peak_Binary_Data_Month == 1]

                else:

                    # Create Coincident Part-Peak Load and Net Load Profiles
                    CPP_Load_Profile_Data_Month = Load_Profile_Data_Month[Winter_Part_Peak_Binary_Data_Month == 1]

                    CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min = Solar_Only_Net_Load_Profile_Data_Month_5_Min[Winter_Part_Peak_Binary_Data_Month == 1]

                    CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = Solar_Storage_Net_Load_Profile_Data_Month_5_Min[Winter_Part_Peak_Binary_Data_Month == 1]



                # Reshape load data so that each 15-minute increment's data
                # is in the same column. This creates an array with 3 rows for 5-minute data.
                Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped = np.reshape(CPP_Load_Profile_Data_Month, \
                                                                                   (Reshaped_Rows_Num, len(CPP_Load_Profile_Data_Month) / Reshaped_Rows_Num))

                CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min, \
                                                                                       (Reshaped_Rows_Num, len(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

                CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = np.reshape(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min, \
                                                                                          (Reshaped_Rows_Num, len(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min) / Reshaped_Rows_Num))

                # Create 15-minute load profiles by calculating the average of each column.
                CPP_Load_Profile_Data_Month_15_Min = np.mean(Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped, 1)

                CPP_Solar_Only_Net_Load_Profile_Data_Month_15_Min = np.mean(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)

                CPP_Solar_Storage_Net_Load_Profile_Data_Month_15_Min = np.mean(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1)

                # Calculate Coincident Part-Peak Demand
                P_max_CPP_Month_Baseline = np.max(CPP_Load_Profile_Data_Month_15_Min)
                P_max_CPP_Month_with_Solar_Only = np.max(CPP_Solar_Only_Net_Load_Profile_Data_Month_15_Min)
                P_max_CPP_Month_with_Solar_and_Storage = np.max(CPP_Solar_Storage_Net_Load_Profile_Data_Month_15_Min)

            else:

                # If there is no Coincident Part-Peak Demand Period (or if the
                # corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
                P_max_CPP_Month_Baseline = 0
                P_max_CPP_Month_with_Solar_Only = 0
                P_max_CPP_Month_with_Solar_and_Storage = 0


        elif delta_t == (15 / 60):

            # Noncoincident Maximum Demand With and Without Storage

            P_max_NC_Month_Baseline = np.max(Load_Profile_Data_Month)
            P_max_NC_Month_with_Solar_Only = np.max(Load_Profile_Data_Month - Solar_PV_Profile_Data_Month)
            P_max_NC_Month_with_Solar_and_Storage = x_Month[3 * numtsteps, 0]

            # Coincident Peak Demand With and Without Storage

            if Peak_DC > 0:

                if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
                    P_max_CPK_Month_Baseline = np.max(Load_Profile_Data_Month[Summer_Peak_Binary_Data_Month == 1])

                    P_max_CPK_Month_with_Solar_Only = np.max(Load_Profile_Data_Month[Summer_Peak_Binary_Data_Month == 1] - \
                        Solar_PV_Profile_Data_Month[Summer_Peak_Binary_Data_Month == 1])

                else:
                    P_max_CPK_Month_Baseline = np.max(Load_Profile_Data_Month[Winter_Peak_Binary_Data_Month == 1])

                    P_max_CPK_Month_with_Solar_Only = np.max(Load_Profile_Data_Month[Winter_Peak_Binary_Data_Month == 1] - \
                        Solar_PV_Profile_Data_Month[Winter_Peak_Binary_Data_Month == 1])


                    P_max_CPK_Month_with_Solar_and_Storage = x_Month[3 * numtsteps + 1, 0]

            else:

                # If there is no Coincident Peak Demand Period (or if the
                # corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
                P_max_CPK_Month_Baseline = 0
                P_max_CPK_Month_with_Solar_Only = 0
                P_max_CPK_Month_with_Solar_and_Storage = 0

            # Coincident Part-Peak Demand With and Without Storage

            if Part_Peak_DC > 0:

                if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
                    P_max_CPP_Month_Baseline = np.max(Load_Profile_Data_Month[Summer_Part_Peak_Binary_Data_Month == 1])

                    P_max_CPP_Month_with_Solar_Only = np.max(Load_Profile_Data_Month[Summer_Part_Peak_Binary_Data_Month == 1] - \
                        Solar_PV_Profile_Data_Month[Summer_Part_Peak_Binary_Data_Month == 1])

                else:
                    P_max_CPP_Month_Baseline = np.max(Load_Profile_Data_Month[Winter_Part_Peak_Binary_Data_Month == 1])

                    P_max_CPP_Month_with_Solar_Only = np.max(Load_Profile_Data_Month[Winter_Part_Peak_Binary_Data_Month == 1] - \
                        Solar_PV_Profile_Data_Month[Winter_Part_Peak_Binary_Data_Month == 1])


                    P_max_CPP_Month_with_Solar_and_Storage = x_Month[3 * numtsteps + 2, 0]

            else:

                # If there is no Coincident Part-Peak Demand Period (or if the
                # corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
                P_max_CPP_Month_Baseline = 0
                P_max_CPP_Month_with_Solar_Only = 0
                P_max_CPP_Month_with_Solar_and_Storage = 0

        else:

            print('Timestep is larger than 15 minutes. Cannot properly calculate billing demand.')


        ## Calculate Monthly Bill Cost with and Without Storage

        # Monthly Cost from Daily Fixed Charge
        # This value is not affected by the presence of storage.
        Fixed_Charge_Month = Fixed_Per_Meter_Month_Charge + (
                Fixed_Per_Meter_Day_Charge * len(Load_Profile_Data_Month) / (24 * (1 / delta_t)))

        # Monthly Cost from Noncoincident Demand Charge - Baseline
        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            NC_Demand_Charge_Month_Baseline = Summer_Noncoincident_DC * P_max_NC_Month_Baseline
        else:
            NC_Demand_Charge_Month_Baseline = Winter_Noncoincident_DC * P_max_NC_Month_Baseline

        # Monthly Cost from Noncoincident Demand Charge - With Solar Only
        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            NC_Demand_Charge_Month_with_Solar_Only = Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_Only
        else:
            NC_Demand_Charge_Month_with_Solar_Only = Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_Only

        # Monthly Cost from Noncoincident Demand Charge - With Solar and Storage
        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            NC_Demand_Charge_Month_with_Solar_and_Storage = Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage
        else:
            NC_Demand_Charge_Month_with_Solar_and_Storage = Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage

        # Monthly Cost from Coincident Peak Demand Charge - Baseline
        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPK_Demand_Charge_Month_Baseline = Summer_Peak_DC * P_max_CPK_Month_Baseline
        else:
            CPK_Demand_Charge_Month_Baseline = Winter_Peak_DC * P_max_CPK_Month_Baseline

        # Monthly Cost from Coincident Peak Demand Charge - With Solar Only

        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPK_Demand_Charge_Month_with_Solar_Only = Summer_Peak_DC * P_max_CPK_Month_with_Solar_Only
        else:
            CPK_Demand_Charge_Month_with_Solar_Only = Winter_Peak_DC * P_max_CPK_Month_with_Solar_Only

        # Monthly Cost from Coincident Peak Demand Charge - With Solar and Storage

        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPK_Demand_Charge_Month_with_Solar_and_Storage = Summer_Peak_DC * P_max_CPK_Month_with_Solar_and_Storage
        else:
            CPK_Demand_Charge_Month_with_Solar_and_Storage = Winter_Peak_DC * P_max_CPK_Month_with_Solar_and_Storage

        # Monthly Cost from Coincident Part-Peak Demand Charge - Baseline
        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPP_Demand_Charge_Month_Baseline = Summer_Part_Peak_DC * P_max_CPP_Month_Baseline
        else:
            CPP_Demand_Charge_Month_Baseline = Winter_Part_Peak_DC * P_max_CPP_Month_Baseline

        # Monthly Cost from Coincident Part-Peak Demand Charge - With Solar Only

        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPP_Demand_Charge_Month_with_Solar_Only = Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only
        else:
            CPP_Demand_Charge_Month_with_Solar_Only = Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only

        # Monthly Cost from Coincident Part-Peak Demand Charge - With Solar and Storage

        if Month_Iter in range(First_Summer_Month, (Last_Summer_Month + 1)):
            CPP_Demand_Charge_Month_with_Solar_and_Storage = Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage
        else:
            CPP_Demand_Charge_Month_with_Solar_and_Storage = Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage

        # Monthly Cost from Volumetric Energy Rates - Baseline
        Energy_Charge_Month_Baseline = np.dot(np.transpose(Load_Profile_Data_Month), Volumetric_Rate_Data_Month) * delta_t

        # Monthly Cost from Volumetric Energy Rates - With Solar Only
        Solar_Only_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month
        Energy_Charge_Month_with_Solar_Only = np.dot(np.transpose(Solar_Only_Net_Load_Profile_Month), Volumetric_Rate_Data_Month) * delta_t

        # Monthly Cost from Volumetric Energy Rates - With Solar and Storage
        Solar_Storage_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month + np.transpose(P_ES_in_Month_Unpadded) - np.transpose(P_ES_out_Month_Unpadded)
        Energy_Charge_Month_with_Solar_and_Storage = np.dot(Solar_Storage_Net_Load_Profile_Month, np.reshape(Volumetric_Rate_Data_Month, (len(Volumetric_Rate_Data_Month), 1))) * delta_t
        Energy_Charge_Month_with_Solar_and_Storage = Energy_Charge_Month_with_Solar_and_Storage[0, 0] # Convert from single-value array to double

        # Monthly Cycling Penalty

        Cycles_Month = np.sum((P_ES_in_Month_Unpadded * (((Eff_c) / (2 * Total_Storage_Capacity)) * delta_t)) + \
            (P_ES_out_Month_Unpadded * ((1 / (Eff_d * 2 * Total_Storage_Capacity)) * delta_t)))

        Cycling_Penalty_Month = np.sum((P_ES_in_Month_Unpadded * (((Eff_c * cycle_pen) / (2 * Total_Storage_Capacity)) * delta_t)) + \
            (P_ES_out_Month_Unpadded * ((cycle_pen / (Eff_d * 2 * Total_Storage_Capacity)) * delta_t)))


        ## Update Battery Capacity Based on Monthly Cycling
        # This is to account for capacity fade in lithium-ion batteries.
        # Based on standard definitions of battery cycle life, lithium-ion batteries are
        # defined to have experienced capacity fade to 80% of its original
        # capacity by the  of its cycle life.
        # Flow batteries do not experience capacity fade.

        if Storage_Type_Input == "Lithium-Ion Battery":

            Usable_Storage_Capacity = Usable_Storage_Capacity - (Usable_Storage_Capacity_Input * (Cycles_Month / Cycle_Life) * 0.2)

        elif Storage_Type_Input == "Flow Battery":

            Usable_Storage_Capacity = Usable_Storage_Capacity

        # Update Previous Month Final Energy Level to account for capacity fade, if battery is full at
        # of month. Otherwise, optimization is infeasible.

        if Next_Month_Initial_Energy_Level > Usable_Storage_Capacity:
            Next_Month_Initial_Energy_Level = Usable_Storage_Capacity


        ## Concatenate Decision Variable & Monthly Cost Values from Month Iteration

        # Decision Variable Concatenation
        P_ES_in = np.concatenate((P_ES_in, P_ES_in_Month_Unpadded)) if P_ES_in.size != 0 else P_ES_in_Month_Unpadded

        P_ES_out = np.concatenate((P_ES_out, P_ES_out_Month_Unpadded)) if P_ES_out.size != 0 else P_ES_out_Month_Unpadded

        Ene_Lvl = np.concatenate((Ene_Lvl, Ene_Lvl_Month_Unpadded)) if Ene_Lvl.size != 0 else Ene_Lvl_Month_Unpadded

        P_max_NC = np.concatenate((P_max_NC, np.asarray(P_max_NC_Month_with_Solar_and_Storage).reshape((-1,1)))) if P_max_NC.size != 0 else np.asarray(P_max_NC_Month_with_Solar_and_Storage).reshape((-1,1))

        P_max_peak = np.concatenate((P_max_peak, np.asarray(P_max_CPK_Month_with_Solar_and_Storage).reshape((-1, 1)))) if P_max_peak.size != 0 else np.asarray(P_max_CPK_Month_with_Solar_and_Storage).reshape((-1, 1))

        P_max_part_peak = np.concatenate((P_max_part_peak, np.asarray(P_max_CPP_Month_with_Solar_and_Storage).reshape((-1, 1)))) if P_max_part_peak.size != 0 else np.asarray(P_max_CPP_Month_with_Solar_and_Storage).reshape((-1, 1))


        # Monthly Cost Variable Concatenation
        Fixed_Charge_Vector = np.concatenate((Fixed_Charge_Vector, np.asarray(Fixed_Charge_Month).reshape((-1,1)))) if Fixed_Charge_Vector.size != 0 else  np.asarray(Fixed_Charge_Month).reshape((-1,1))

        NC_DC_Baseline_Vector = np.concatenate((NC_DC_Baseline_Vector,
                                                np.asarray(NC_Demand_Charge_Month_Baseline).reshape((-1, 1)))) if NC_DC_Baseline_Vector.size != 0 else  np.asarray(NC_Demand_Charge_Month_Baseline).reshape((-1,1))

        NC_DC_with_Solar_Only_Vector = np.concatenate((NC_DC_with_Solar_Only_Vector,
                                                       np.asarray(NC_Demand_Charge_Month_with_Solar_Only).reshape((-1, 1)))) if NC_DC_with_Solar_Only_Vector.size != 0 else np.asarray(NC_Demand_Charge_Month_with_Solar_Only).reshape((-1,1))

        NC_DC_with_Solar_and_Storage_Vector = np.concatenate((NC_DC_with_Solar_and_Storage_Vector,
                                                              np.asarray(
                                                                  NC_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1, 1)))) if NC_DC_with_Solar_and_Storage_Vector.size != 0 else \
            np.asarray(NC_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1,1))

        CPK_DC_Baseline_Vector = np.concatenate((CPK_DC_Baseline_Vector,
                                                 np.asarray(CPK_Demand_Charge_Month_Baseline).reshape((-1, 1)))) if CPK_DC_Baseline_Vector.size != 0 else np.asarray(CPK_Demand_Charge_Month_Baseline).reshape((-1,1))

        CPK_DC_with_Solar_Only_Vector = np.concatenate((CPK_DC_with_Solar_Only_Vector,
                                                        np.asarray(CPK_Demand_Charge_Month_with_Solar_Only).reshape((-1, 1)))) if CPK_DC_with_Solar_Only_Vector.size != 0 else np.asarray(CPK_Demand_Charge_Month_with_Solar_Only).reshape((-1,1))

        CPK_DC_with_Solar_and_Storage_Vector = np.concatenate((CPK_DC_with_Solar_and_Storage_Vector,
                                                               np.asarray(
                                                                   CPK_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1, 1)))) if CPK_DC_with_Solar_and_Storage_Vector.size != 0 else \
            np.asarray(CPK_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1,1))

        CPP_DC_Baseline_Vector = np.concatenate((CPP_DC_Baseline_Vector,
                                                 np.asarray(CPP_Demand_Charge_Month_Baseline).reshape((-1, 1)))) if CPP_DC_Baseline_Vector.size != 0 else np.asarray(CPP_Demand_Charge_Month_Baseline).reshape((-1,1))

        CPP_DC_with_Solar_Only_Vector = np.concatenate((CPP_DC_with_Solar_Only_Vector,
                                                        np.asarray(CPP_Demand_Charge_Month_with_Solar_Only).reshape((-1, 1)))) if CPP_DC_with_Solar_Only_Vector.size != 0 else np.asarray(CPP_Demand_Charge_Month_with_Solar_Only).reshape((-1,1))

        CPP_DC_with_Solar_and_Storage_Vector = np.concatenate((CPP_DC_with_Solar_and_Storage_Vector,
                                                               np.asarray(CPP_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1, 1)))) if CPP_DC_with_Solar_and_Storage_Vector.size != 0 else \
            np.asarray(CPP_Demand_Charge_Month_with_Solar_and_Storage).reshape((-1,1))

        Energy_Charge_Baseline_Vector = np.concatenate((Energy_Charge_Baseline_Vector,
                                                        np.asarray(Energy_Charge_Month_Baseline).reshape((-1, 1)))) if Energy_Charge_Baseline_Vector.size != 0 else np.asarray(Energy_Charge_Month_Baseline).reshape((-1,1))

        Energy_Charge_with_Solar_Only_Vector = np.concatenate((Energy_Charge_with_Solar_Only_Vector,
                                                               np.asarray(Energy_Charge_Month_with_Solar_Only).reshape((-1, 1)))) if Energy_Charge_with_Solar_Only_Vector.size != 0 else np.asarray(Energy_Charge_Month_with_Solar_Only).reshape((-1,1))

        Energy_Charge_with_Solar_and_Storage_Vector = np.concatenate((Energy_Charge_with_Solar_and_Storage_Vector,
                                                                      np.asarray(Energy_Charge_Month_with_Solar_and_Storage).reshape((-1, 1)))) if Energy_Charge_with_Solar_and_Storage_Vector.size != 0 else \
            np.asarray(Energy_Charge_Month_with_Solar_and_Storage).reshape((-1,1))

        Cycles_Vector = np.concatenate((Cycles_Vector, np.asarray(Cycles_Month).reshape((-1,1)))) if Cycles_Vector.size != 0 else np.asarray(Cycles_Month).reshape((-1,1))

        Cycling_Penalty_Vector = np.concatenate((Cycling_Penalty_Vector, np.asarray(Cycling_Penalty_Month).reshape((-1,1)))) if Cycling_Penalty_Vector.size != 0 else np.asarray(Cycling_Penalty_Month).reshape((-1,1))


    # Report total script runtime.

    tend = time.time()
    telapsed = tend - tstart

    print('Model Run %0.f complete. Elapsed time to run the optimization model is %0.0f seconds.' % (Model_Run_Number_Input, telapsed))

    ## Calculation of Additional Reported Model Inputs/Outputs

    # Output current system date and time in standard ISO 8601 YYYY-MM-DD HH:MM format.
    Model_Run_Date_Time = datetime.datetime.now().replace(microsecond=0).isoformat()


    # Convert Retail Rate Name Input (which contains both utility name and rate
    # name) into Retail Rate Utility and Retail Rate Name Output

    if "PG&E" in Retail_Rate_Name_Input:
        Retail_Rate_Utility = "PG&E"
    elif "SCE" in Retail_Rate_Name_Input:
        Retail_Rate_Utility = "SCE"
    elif "SDG&E" in Retail_Rate_Name_Input:
        Retail_Rate_Utility = "SDG&E"

    Retail_Rate_Utility_Plus_Space = Retail_Rate_Utility + " "

    Retail_Rate_Name_Output = Retail_Rate_Name_Input.replace(Retail_Rate_Utility_Plus_Space, "")

    # If Solar Profile Name is "No Solar", Solar Profile Name Output is Blank
    if Solar_Profile_Name_Input == "No Solar":
        Solar_Profile_Name_Output = ""
    else:
        Solar_Profile_Name_Output = Solar_Profile_Name_Input

    # Storage Control Algorithm Description (Optional)
    if Storage_Control_Algorithm_Name == "OSESMO Economic Dispatch":
        Storage_Control_Algorithm_Description = "Open Source Energy Storage Model - Economic Dispatch"
    elif Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply":
        Storage_Control_Algorithm_Description = "Open Source Energy Storage Model - Non-Economic Solar Self-Supply"

    # Storage Algorithm Parameters Filename (Optional)
    Storage_Control_Algorithms_Parameters_Filename = ""  # No storage parameters file.

    # Other Incentives or Penalities (Optional)
    Other_Incentives_or_Penalities = ""  # No other incentives or penalties.

    Output_Summary_Filename = "OSESMO Reporting Inputs and Outputs.csv"

    Output_Description_Filename = ""  # No output description file.

    Output_Visualizations_Filename = "Multiple files - in same folder as Output Summary file."  # No single output visualizations file.

    EV_Use = ""  # Model does not calculate or report EV usage information.

    EV_Charge = ""  # Model does not calculate or report EV charge information.

    EV_Gas_Savings = "" # Model does not calculate or report EV gas savings information.

    EV_GHG_Savings = ""  # Model does not calculate or report EV GHG savings information.

    ## Output Directory/Folder Names

    if ITC_Constraint_Input == 0:
        ITC_Constraint_Folder_Name = "No ITC Constraint"
    elif ITC_Constraint_Input == 1:
        ITC_Constraint_Folder_Name = "ITC Constraint"

    # Ensures that folder is called "No Emissions Forecast Signal",
    # and not "No Emissions Forecast Signal Emissions Forecast Signal"

    if Emissions_Forecast_Signal_Input == "No Emissions Forecast Signal":
        Emissions_Forecast_Signal_Input = "No"

    Output_Directory_Filepath = os.path.join(Input_Output_Data_Directory_Location, "Models", "OSESMO", "Model Outputs", \
                                Model_Type_Input, str(Model_Timestep_Resolution) + "-Minute Timestep Resolution", \
                                Customer_Class_Input, Load_Profile_Name_Input, Retail_Rate_Name_Input, \
                                Solar_Profile_Name_Input, str(Solar_Size_Input) + " kW Solar", Storage_Type_Input, \
                                str(Storage_Power_Rating_Input) + " kW " + str(Usable_Storage_Capacity_Input) + " kWh Storage", \
                                str(int(Single_Cycle_RTE_Input * 100)) + " Percent Single-Cycle RTE", \
                                str(Parasitic_Storage_Load_Input * 100) + " Percent Parasitic Load", \
                                Storage_Control_Algorithm_Name, GHG_Reduction_Solution_Input, \
                                str(Equivalent_Cycling_Constraint_Input) + " Equivalent Cycles Constraint", \
                                str(int(Annual_RTE_Constraint_Input * 100)) + " Percent Annual RTE Constraint", \
                                ITC_Constraint_Folder_Name, \
                                str(Carbon_Adder_Incentive_Value_Input) + " Dollar Carbon Adder Incentive", \
                                Emissions_Forecast_Signal_Input + " Emissions Forecast Signal")

    # Correct Emissions Forecast Signal Name back so that it is exported with
    # the correct name in the Outputs model.

    if Emissions_Forecast_Signal_Input == "No":
        Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal"

    # Create folder if one does not exist already

    if os.path.isdir(Output_Directory_Filepath) == False:
        os.mkdir(Output_Directory_Filepath)


    ## Plot Energy Storage Dispatch Schedule

    numtsteps_year = len(Load_Profile_Data)

    t = np.linspace(1, 35040, 35040)
    t = [Start_Time_Input + datetime.timedelta(minutes = int(60 * delta_t) * x) for x in range(0, numtsteps_year)]

    P_ES = np.reshape(P_ES_out - P_ES_in, (numtsteps_year,))


    if Show_Plots == 1 or Export_Plots == 1:
        fig, ax = plt.subplots()
        ax.plot(t, P_ES, 'r-')
        ax.set_xlabel('Date & Time')
        ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax.set_ylabel('Energy Storage Output (kW)')
        ax.set_title('Energy Storage Dispatch Profile')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()

    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Storage Dispatch Plot.png'))

        # Note: The MATLAB version of OSESMO which saves files in .fig format, which allows plots of model runs to be
        # re-opened and then explored interactively (ex. zooming in on specific days).
        # OSESMO Python does not have this functionality currently, as matplotlib does not have any built-in features that make this possible.
        # It may be possible to add this functionality in the future, using the pickle package.
        # https://stackoverflow.com/questions/4348733/saving-interactive-matplotlib-figures


    ## Plot Energy Storage Energy Level

    if Show_Plots == 1 or Export_Plots == 1:
        fig, ax = plt.subplots()
        ax.plot(t, Ene_Lvl, 'r-')
        ax.set_xlabel('Date & Time')
        ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax.set_ylabel('Energy Storage Energy Level (kWh)')
        ax.set_title('Energy Storage Energy Level')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()

    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Energy Level Plot.png'))


    ## Plot Volumetric Electricity Price Schedule and Marginal Carbon Emission Rates

    if Show_Plots == 1 or Export_Plots == 1:
        fig, ax1 = plt.subplots()
        ax1.plot(t, Volumetric_Rate_Data, 'b-')
        ax1.set_xlabel('Date & Time')
        ax1.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax1.set_ylabel('Energy Price ($/kWh)', color='b')
        ax1.tick_params('y', colors='b')
        ax2 = ax1.twinx()
        ax2.plot(t, Marginal_Emissions_Rate_Evaluation_Data, 'r-')
        ax2.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax2.set_ylabel('Marginal Emissions Rate (metric tons/kWh)', color='r')
        ax2.set_title('Electricity Rates and Marginal Emissions Rates')
        ax2.tick_params('y', colors='r')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()


    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Energy Price and Carbon Plot.png'))


    ## Plot Coincident and Non-Coincident Demand Charge Schedule

    # Create Summer/Winter Binary Flag Vector
    Summer_Binary_Data_1 = Month_Data >= First_Summer_Month
    Summer_Binary_Data_2 = Month_Data <= Last_Summer_Month
    Summer_Binary_Data = np.logical_and(Summer_Binary_Data_1, Summer_Binary_Data_2)

    Winter_Binary_Data_1 = Month_Data < First_Summer_Month
    Winter_Binary_Data_2 = Month_Data > Last_Summer_Month
    Winter_Binary_Data = np.logical_or(Winter_Binary_Data_1, Winter_Binary_Data_2)

    # Create Total-Demand-Charge Vector
    # Noncoincident Demand Charge is always included (although it may be 0).
    # Coincident Peak and Part-Peak values are only added if they are non-zero
    # and a binary-flag data input is available.

    Total_DC = (Winter_Noncoincident_DC * Winter_Binary_Data) + \
               (Summer_Noncoincident_DC * Summer_Binary_Data)

    if Winter_Peak_DC > 0:
        Total_DC = Total_DC + (Winter_Peak_DC * Winter_Peak_Binary_Data)

    if Winter_Part_Peak_DC > 0:
        Total_DC = Total_DC + (Winter_Part_Peak_DC * Winter_Part_Peak_Binary_Data)

    if Summer_Peak_DC > 0:
        Total_DC = Total_DC + (Summer_Peak_DC * Summer_Peak_Binary_Data)

    if Summer_Part_Peak_DC > 0:
        Total_DC = Total_DC + (Summer_Part_Peak_DC * Summer_Part_Peak_Binary_Data)

    if Show_Plots == 1 or Export_Plots == 1:
        fig, ax = plt.subplots()
        ax.plot(t, Total_DC, 'g-')
        ax.set_xlabel('Date & Time')
        ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax.set_ylabel('Total Demand Charge ($/kW)')
        ax.set_title('Coincident + Non-Coincident Demand Charge Schedule')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()

    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Demand Charge Plot.png'))


    ## Plot Load, Net Load with Solar Only, Net Load with Solar and Storage

    if Show_Plots == 1 or Export_Plots == 1:
        if Model_Type_Input == "Storage Only":

            fig, ax = plt.subplots()
            ax.plot(t, Load_Profile_Data, 'k-', label = 'Original Load')
            ax.plot(t, Load_Profile_Data - P_ES, 'r-', label = 'Net Load with Storage')
            ax.set_xlabel('Date & Time')
            ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
            ax.set_ylabel('Load (kW)')
            ax.set_title('Original and Net Load Profiles')
            ax.legend()
            fig.autofmt_xdate()
            fig.tight_layout()
            plt.show()

        elif Model_Type_Input == "Solar Plus Storage":

            fig, ax = plt.subplots()
            ax.plot(t, Load_Profile_Data, 'k-', label = 'Original Load')
            ax.plot(t, Load_Profile_Data - Solar_PV_Profile_Data, 'b-', label='Net Load with Solar Only')
            ax.plot(t, Load_Profile_Data - (Solar_PV_Profile_Data + P_ES), 'r-', label = 'Net Load with Solar + Storage')
            ax.set_xlabel('Date & Time')
            ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
            ax.set_ylabel('Load (kW)')
            ax.set_title('Original and Net Load Profiles')
            ax.legend()
            fig.autofmt_xdate()
            fig.tight_layout()
            plt.show()

    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Net Load Plot.png'))


    if Model_Type_Input == "Storage Only":
        Annual_Peak_Demand_with_Solar_Only = ""

        Annual_Total_Energy_Consumption_with_Solar_Only = ""

    elif Model_Type_Input == "Solar Plus Storage":

        Annual_Peak_Demand_with_Solar_Only = np.max(Load_Profile_Data - Solar_PV_Profile_Data)

        Annual_Total_Energy_Consumption_with_Solar_Only = np.sum(Load_Profile_Data - Solar_PV_Profile_Data) * delta_t

        Annual_Peak_Demand_with_Solar_and_Storage = np.max(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES))

        Annual_Total_Energy_Consumption_with_Solar_and_Storage = np.sum(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES)) * delta_t

    if Model_Type_Input == "Storage Only":
        Solar_Only_Peak_Demand_Reduction_Percentage = ""

    elif Model_Type_Input == "Solar Plus Storage":
        Solar_Only_Peak_Demand_Reduction_Percentage = ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_Only) / Annual_Peak_Demand_Baseline) * 100

        Solar_Storage_Peak_Demand_Reduction_Percentage = ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_and_Storage) / Annual_Peak_Demand_Baseline) * 100

    if Model_Type_Input == "Storage Only":
        Solar_Only_Energy_Consumption_Decrease_Percentage = ""

    elif Model_Type_Input == "Solar Plus Storage":
        Solar_Only_Energy_Consumption_Decrease_Percentage = ((Annual_Total_Energy_Consumption_Baseline - Annual_Total_Energy_Consumption_with_Solar_Only) / Annual_Total_Energy_Consumption_Baseline) * 100

        Solar_Storage_Energy_Consumption_Decrease_Percentage = ((Annual_Total_Energy_Consumption_Baseline - Annual_Total_Energy_Consumption_with_Solar_and_Storage) / Annual_Total_Energy_Consumption_Baseline) * 100


    print('Baseline annual peak noncoincident demand is {0} kW.'.format(round(Annual_Peak_Demand_Baseline, 2)))

    if Model_Type_Input == "Storage Only":
        if Solar_Storage_Peak_Demand_Reduction_Percentage >= 0:

            print('Peak demand with storage is {0} kW, representing a DECREASE OF {1}%.'.format(round(Annual_Peak_Demand_with_Solar_and_Storage, 2), round(Solar_Storage_Peak_Demand_Reduction_Percentage, 2)))

        elif Solar_Storage_Peak_Demand_Reduction_Percentage < 0:

            print('Peak demand with storage is {0} kW, representing an INCREASE OF {1}%.'.format(round(Annual_Peak_Demand_with_Solar_and_Storage, 2), round(-Solar_Storage_Peak_Demand_Reduction_Percentage, 2)))

        print('Baseline annual total electricity consumption is {0} kWh.'.format(round(Annual_Total_Energy_Consumption_Baseline, 2)))

        print('Electricity consumption with storage is {0} kWh, representing an INCREASE OF {1}%.'.format(round(Annual_Total_Energy_Consumption_with_Solar_and_Storage, 2),
                                                                                                          round(-Solar_Storage_Energy_Consumption_Decrease_Percentage, 2)))

    elif Model_Type_Input == "Solar Plus Storage":

        print('Peak demand with solar only is {0} kW, representing a DECREASE OF {1}%.'.format(round(Annual_Peak_Demand_with_Solar_Only, 2), round(Solar_Only_Peak_Demand_Reduction_Percentage, 2)))

    if Solar_Storage_Peak_Demand_Reduction_Percentage >= 0:
        print('Peak demand with solar and storage is {0} kW, representing a DECREASE OF {1}%.'.format(round(Annual_Peak_Demand_with_Solar_and_Storage, 2), round(Solar_Storage_Peak_Demand_Reduction_Percentage, 2)))

    elif Solar_Storage_Peak_Demand_Reduction_Percentage < 0:
        print('Peak demand with solar and storage is {0} kW, representing an INCREASE OF {1}%.'.format(round(Annual_Peak_Demand_with_Solar_and_Storage, 2), round(-Solar_Storage_Peak_Demand_Reduction_Percentage, 2)))

    print('Baseline annual total electricity consumption is {0} kWh.'.format(round(Annual_Total_Energy_Consumption_Baseline, 2)))

    print('Electricity consumption with solar only is {0} kWh, representing a DECREASE OF {1}%.'.format(round(Annual_Total_Energy_Consumption_with_Solar_Only, 2),
                                                                                                        round(Solar_Only_Energy_Consumption_Decrease_Percentage, 2)))

    print('Electricity consumption with solar and storage is {0} kWh, representing a DECREASE OF {1}%.'.format(round(Annual_Total_Energy_Consumption_with_Solar_and_Storage, 2),
                                                                                                               round(Solar_Storage_Energy_Consumption_Decrease_Percentage, 2)))


    ## Plot Monthly Costs as Bar Plot

    # Calculate Baseline Monthly Costs

    Monthly_Costs_Matrix_Baseline = np.concatenate((Fixed_Charge_Vector, NC_DC_Baseline_Vector, CPK_DC_Baseline_Vector, CPP_DC_Baseline_Vector, Energy_Charge_Baseline_Vector), axis = 1)

    Annual_Costs_Vector_Baseline = np.concatenate((np.asarray(np.sum(Fixed_Charge_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(NC_DC_Baseline_Vector) + np.sum(CPK_DC_Baseline_Vector) + np.sum(CPP_DC_Baseline_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(Energy_Charge_Baseline_Vector)).reshape(1, -1)), axis = 0)

    Annual_Demand_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline[1, 0]
    Annual_Energy_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline[2, 0]

    # Calculate Monthly Costs With Solar Only

    Monthly_Costs_Matrix_with_Solar_Only = np.concatenate((Fixed_Charge_Vector, NC_DC_with_Solar_Only_Vector, CPK_DC_with_Solar_Only_Vector, CPP_DC_with_Solar_Only_Vector, Energy_Charge_with_Solar_Only_Vector), axis = 1)

    Annual_Costs_Vector_with_Solar_Only = np.concatenate((np.asarray(np.sum(Fixed_Charge_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(NC_DC_with_Solar_Only_Vector) + np.sum(CPK_DC_with_Solar_Only_Vector) + np.sum(CPP_DC_with_Solar_Only_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(Energy_Charge_with_Solar_Only_Vector)).reshape(1, -1)), axis = 0)


    if Model_Type_Input == "Storage Only":
        Annual_Demand_Charge_Cost_with_Solar_Only = ""
        Annual_Energy_Charge_Cost_with_Solar_Only = ""

    elif Model_Type_Input == "Solar Plus Storage":
        Annual_Demand_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only[1, 0]
        Annual_Energy_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only[2, 0]

    # Calculate Monthly Costs with Solar and Storage

    Monthly_Costs_Matrix_with_Solar_and_Storage = np.concatenate((Fixed_Charge_Vector, NC_DC_with_Solar_and_Storage_Vector, CPK_DC_with_Solar_and_Storage_Vector, CPP_DC_with_Solar_and_Storage_Vector, \
                                                                  Energy_Charge_with_Solar_and_Storage_Vector), axis = 1)

    Annual_Costs_Vector_with_Solar_and_Storage = np.concatenate((np.asarray(np.sum(Fixed_Charge_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(NC_DC_with_Solar_and_Storage_Vector) + np.sum(CPK_DC_with_Solar_and_Storage_Vector) + np.sum(CPP_DC_with_Solar_and_Storage_Vector)).reshape(1, -1), \
                                                   np.asarray(np.sum(Energy_Charge_with_Solar_and_Storage_Vector)).reshape(1, -1)), axis = 0)

    Annual_Demand_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage[1, 0]
    Annual_Energy_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage[2, 0]

    # Calculate Maximum and Minimum Monthly Bills - to set y-axis for all plots

    Maximum_Monthly_Bill_Baseline = np.max(np.sum(Monthly_Costs_Matrix_Baseline, axis = 1))
    Minimum_Monthly_Bill_Baseline = np.min(np.sum(Monthly_Costs_Matrix_Baseline, axis = 1))

    Maximum_Monthly_Bill_with_Solar_Only = np.max(np.sum(Monthly_Costs_Matrix_with_Solar_Only, axis = 1))
    Minimum_Monthly_Bill_with_Solar_Only = np.min(np.sum(Monthly_Costs_Matrix_with_Solar_Only, axis = 1))

    Maximum_Monthly_Bill_with_Solar_and_Storage = np.max(np.sum(Monthly_Costs_Matrix_with_Solar_and_Storage, axis = 1))
    Minimum_Monthly_Bill_with_Solar_and_Storage = np.min(np.sum(Monthly_Costs_Matrix_with_Solar_and_Storage, axis = 1))

    Maximum_Monthly_Bill = np.max((Maximum_Monthly_Bill_Baseline, \
                                Maximum_Monthly_Bill_with_Solar_Only, \
                                Maximum_Monthly_Bill_with_Solar_and_Storage))

    Minimum_Monthly_Bill = np.min((Minimum_Monthly_Bill_Baseline, \
                                Minimum_Monthly_Bill_with_Solar_Only, \
                                Minimum_Monthly_Bill_with_Solar_and_Storage))

    Max_Monthly_Bill_ylim = Maximum_Monthly_Bill * 1.1  # Make upper ylim 10% larger than largest monthly bill.

    if Minimum_Monthly_Bill >= 0:
        Min_Monthly_Bill_ylim = 0  # Make lower ylim equal to 0 if the lowest monthly bill is greater than zero.
    elif Minimum_Monthly_Bill < 0:
        Min_Monthly_Bill_ylim = Minimum_Monthly_Bill * 1.1  # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.


    # Define bar-chart-plotting function
    # Created by StackOverflow user Bill: https://stackoverflow.com/questions/44309507/stacked-bar-plot-using-matplotlib

    def stacked_bar(data, series_labels, category_labels=None,
                    show_values=False, value_format="{}", y_label=None,
                    grid=True, reverse=False):
        """Plots a stacked bar chart with the data and labels provided.

        Keyword arguments:
        data            -- 2-dimensional numpy array or nested list
                           containing data for each series in rows
        series_labels   -- list of series labels (these appear in
                           the legend)
        category_labels -- list of category labels (these appear
                           on the x-axis)
        show_values     -- If True then numeric value labels will
                           be shown on each bar
        value_format    -- Format string for numeric value labels
                           (default is "{}")
        y_label         -- Label for y-axis (str)
        grid            -- If True display grid
        reverse         -- If True reverse the order that the
                           series are displayed (left-to-right
                           or right-to-left)
        """

        ny = len(data[0])
        ind = list(range(ny))

        axes = []
        cum_size = np.zeros(ny)

        data = np.array(data)

        if reverse:
            data = np.flip(data, axis=1)
            category_labels = reversed(category_labels)

        for i, row_data in enumerate(data):
            axes.append(plt.bar(ind, row_data, bottom=cum_size,
                                label=series_labels[i]))
            cum_size += row_data

        if category_labels:
            plt.xticks(ind, category_labels)

        if y_label:
            plt.ylabel(y_label)

        plt.legend()

        if grid:
            plt.grid()

        if show_values:
            for axis in axes:
                for bar in axis:
                    w, h = bar.get_width(), bar.get_height()
                    plt.text(bar.get_x() + w / 2, bar.get_y() + h / 2,
                             value_format.format(h), ha="center",
                             va="center")

    # Plot Baseline Monthly Costs

    if Show_Plots == 1 or Export_Plots == 1:

        series_labels = ['Fixed Charges', 'Max DC', 'Peak DC', 'Part-Peak DC', 'Energy Charge']

        category_labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

        plt.figure()

        stacked_bar(np.transpose(Monthly_Costs_Matrix_Baseline),
            series_labels,
            category_labels=category_labels,
            show_values=False,
            value_format="{}",
            y_label="Cost ($/Month)")

        plt.xlabel('Month')
        plt.title('Monthly Costs, Without Storage')
        plt.show()

    if Export_Plots == 1:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Monthly Costs Baseline Plot.png'))

    # Plot Monthly Costs With Solar Only

    if Model_Type_Input == "Solar Plus Storage":
        if Show_Plots == 1 or Export_Plots == 1:

            figure('NumberTitle', 'off')
            bar(Monthly_Costs_Matrix_with_Solar_Only, 'stacked')
            xlim([0.5, 12.5])
            ylim([Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim])
            xlabel('Month', 'FontSize', 15)
            ylabel('Cost ($/Month)', 'FontSize', 15)
            title('Monthly Costs, With Solar Only', 'FontSize', 15)
            leg('Fixed Charges', 'Max DC', 'Peak DC', 'Part-Peak DC', 'Energy Charge', \
                'Location', 'NorthWest')
            set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar Only Plot.png")

        saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar Only Plot")

    # Plot Monthly Costs with Solar and Storage

    if Show_Plots == 1 or Export_Plots == 1:
        figure('NumberTitle', 'off')
        bar(Monthly_Costs_Matrix_with_Solar_and_Storage, 'stacked')
        xlim([0.5, 12.5])
        ylim([Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim])
        xlabel('Month', 'FontSize', 15)
        ylabel('Cost ($/Month)', 'FontSize', 15)
        title('Monthly Costs, With Storage', 'FontSize', 15)
        leg('Fixed Charges', 'Max DC', 'Peak DC', 'Part-Peak DC', 'Energy Charge', \
            'Location', 'NorthWest')
        set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        if Model_Type_Input == "Storage Only":

            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Storage Plot.png")
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Storage Plot")

        elif Model_Type_Input == "Solar Plus Storage":

        saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar and Storage Plot.png")
        saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar and Storage Plot")

    # Plot Monthly Savings From Storage

    if Model_Type_Input == "Storage Only":

        Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_Baseline - \
                                              Monthly_Costs_Matrix_with_Solar_and_Storage

    elif Model_Type_Input == "Solar Plus Storage":

        Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_with_Solar_Only - \
                                              Monthly_Costs_Matrix_with_Solar_and_Storage

    # Remove fixed charges, battery cycling costs.
    Monthly_Savings_Matrix_Plot = Monthly_Savings_Matrix_From_Storage(:, 2: 5)

    if Show_Plots == 1 or Export_Plots == 1:
        figure('NumberTitle', 'off')
        bar(Monthly_Savings_Matrix_Plot, 'stacked')
        xlim([0.5, 12.5])
        xlabel('Month', 'FontSize', 15)
        xticks(linspace(1, 12, 12))
        ylabel('Savings ($/Month)', 'FontSize', 15)
        title('Monthly Savings From Storage', 'FontSize', 15)
        leg('Max DC', 'Peak DC', 'Part-Peak DC', 'Energy Charge', \
            'Location', 'NorthWest')
        set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        saveas(gcf, Output_Directory_Filepath + "Monthly Savings from Storage Plot.png")

        saveas(gcf, Output_Directory_Filepath + "Monthly Savings from Storage Plot")


    ## Report Annual Savings

    # Report Baseline Cost without Solar or Storage
    Annual_Customer_Bill_Baseline = sum(sum(Monthly_Costs_Matrix_Baseline))

    if Model_Type_Input == "Storage Only":
        Annual_Customer_Bill_with_Solar_Only = ""

    elif Model_Type_Input == "Solar Plus Storage":
        Annual_Customer_Bill_with_Solar_Only = sum(Annual_Costs_Vector_with_Solar_Only)

        Annual_Customer_Bill_with_Solar_and_Storage = sum(
            Annual_Costs_Vector_with_Solar_and_Storage)  # Doesn't include degradation cost.

    if Model_Type_Input == "Storage Only":

        Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_and_Storage

    elif Model_Type_Input == "Solar Plus Storage":

        Annual_Customer_Bill_Savings_from_Solar = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_Only

        Annual_Customer_Bill_Savings_from_Solar_Percent = (
                Annual_Customer_Bill_Savings_from_Solar / Annual_Customer_Bill_Baseline)

        Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_with_Solar_Only - Annual_Customer_Bill_with_Solar_and_Storage

        Annual_Customer_Bill_Savings_from_Storage_Percent = (
                Annual_Customer_Bill_Savings_from_Storage / Annual_Customer_Bill_Baseline)

    if Model_Type_Input == "Solar Plus Storage":
        Solar_Installed_Cost = Solar_Size_Input * Solar_Installed_Cost_per_kW
        Solar_Simple_Payback = Solar_Installed_Cost / Annual_Customer_Bill_Savings_from_Solar

        print('Annual cost savings from solar is $%0.0f, representing %0.2f%% of the original $%0.0f bill.', \
                Annual_Customer_Bill_Savings_from_Solar, Annual_Customer_Bill_Savings_from_Solar_Percent * 100,
                Annual_Customer_Bill_Baseline)

        print('The solar PV system has a simple payback of %0.0f years, not including incentives.', \
                Solar_Simple_Payback)

        Storage_Installed_Cost = Total_Storage_Capacity * Storage_Installed_Cost_per_kWh

        Storage_Simple_Payback = Storage_Installed_Cost / Annual_Customer_Bill_Savings_from_Storage

        print('Annual cost savings from storage is $%0.0f, representing %0.2f%% of the original $%0.0f bill.', \
                Annual_Customer_Bill_Savings_from_Storage, Annual_Customer_Bill_Savings_from_Storage_Percent * 100,
                Annual_Customer_Bill_Baseline)

        print('The storage system has a simple payback of %0.0f years, not including incentives.', \
                Storage_Simple_Payback)


    ## Report Cycling/Degradation Penalty

    Annual_Equivalent_Storage_Cycles = np.sum(Cycles_Vector)
    Annual_Cycling_Penalty = sum(Cycling_Penalty_Vector)
    Annual_Capacity_Fade = Usable_Storage_Capacity_Input - Usable_Storage_Capacity
    print(
        'The battery cycles %0.0f times annually, with a degradation cost of $%0.0f, and experiences capacity fade of %0.1f kWh.', \
        Annual_Equivalent_Storage_Cycles, Annual_Cycling_Penalty, Annual_Capacity_Fade)


    ## Report Operational/"SGIP" Round-Trip Efficiency

    Annual_RTE = (sum(P_ES_out) * delta_t) / (sum(P_ES_in) * delta_t)

    print('The battery has an Annual Operational/SGIP Round-Trip Efficiency of %0.2f%%.', \
            Annual_RTE * 100)


    ## Report Operational/"SGIP" Capacity Factor

    # The SGIP Handbook uses the following definition of capacity factor for
    # storage resources, based on the assumption that 60% of hours are
    # available for discharge. The term "hours of data available" is equal to
    # the number of hours in the year here. For actual operational data, it's
    # the number of hours where data is available, which may be less than the
    # number of hours in the year. Here, the number of hours in the year is
    # calculated by multiplying the number of timesteps of original load profile data
    # by the timestep length delta_t. This returns 8760 hours during
    # non-leap years and 8784 during leap years.

    # Capacity Factor = (kWh Discharge)/(Hours of Data Available x Rebated Capacity (kW) x 60%)

    Operational_Capacity_Factor = ((sum(P_ES_out) * delta_t) / (
            (len(Load_Profile_Data) * delta_t) * Storage_Power_Rating_Input * 0.6))

    print('The battery has an Operational/SGIP Capacity Factor of %0.2f%%.', \
            Operational_Capacity_Factor * 100)


    ## Report Grid Costs

    # Calculate Total Annual Grid Costs

    Annual_Grid_Cost_Baseline = (Generation_Cost_Data + Representative_Distribution_Cost_Data)
    # (transpose) * \
    Load_Profile_Data * (1 / 1000) * delta_t

    if Model_Type_Input == "Solar Plus Storage":
        Annual_Grid_Cost_with_Solar_Only = (
                                                   Generation_Cost_Data + Representative_Distribution_Cost_Data)  # (transpose) * \
                                           (Load_Profile_Data - Solar_PV_Profile_Data) * (1 / 1000) * delta_t
    else:
        Annual_Grid_Cost_with_Solar_Only = ""

        Annual_Grid_Cost_with_Solar_and_Storage = (
                                                          Generation_Cost_Data + Representative_Distribution_Cost_Data)  # (transpose) * \
                                                  (Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * (
                                                          1 / 1000) * delta_t

    # Calculate Monthly Grid Costs

    Grid_Cost_Timestep_Baseline = [Generation_Cost_Data. * Load_Profile_Data * (1 / 1000) * delta_t, \
                                   Representative_Distribution_Cost_Data. * Load_Profile_Data * (
                                           1 / 1000) * delta_t]

    Grid_Cost_Month_Baseline = []

    for Month_Iter in range(1, 12 + 1):
        Grid_Cost_Single_Month_Baseline = sum(Grid_Cost_Timestep_Baseline(Month_Data == Month_Iter,:))
        Grid_Cost_Month_Baseline = [Grid_Cost_Month_Baseline, Grid_Cost_Single_Month_Baseline]

        Grid_Cost_Timestep_with_Solar_Only = [
            Generation_Cost_Data. * (Load_Profile_Data - Solar_PV_Profile_Data) * (1 / 1000) * delta_t, \
            Representative_Distribution_Cost_Data. * (Load_Profile_Data - Solar_PV_Profile_Data) * (1 / 1000) * delta_t]

        Grid_Cost_Month_with_Solar_Only = []

    for Month_Iter in range(1, 12 + 1):
        Grid_Cost_Single_Month_with_Solar_Only = sum(Grid_Cost_Timestep_with_Solar_Only(Month_Data == Month_Iter,:))
        Grid_Cost_Month_with_Solar_Only = [Grid_Cost_Month_with_Solar_Only, Grid_Cost_Single_Month_with_Solar_Only]

        Grid_Cost_Timestep_with_Solar_and_Storage = [
            Generation_Cost_Data. * (Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * (
                    1 / 1000) * delta_t, \
            Representative_Distribution_Cost_Data. * (
                    Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * (1 / 1000) * delta_t]

        Grid_Cost_Month_with_Solar_and_Storage = []

    for Month_Iter in range(1, 12 + 1):
        Grid_Cost_Single_Month_with_Solar_and_Storage = sum(
            Grid_Cost_Timestep_with_Solar_and_Storage(Month_Data == Month_Iter,:))
        Grid_Cost_Month_with_Solar_and_Storage = [Grid_Cost_Month_with_Solar_and_Storage,
                                                  Grid_Cost_Single_Month_with_Solar_and_Storage]

    # Calculate Monthly Grid Cost Savings from Storage

    if Model_Type_Input == "Storage Only":

        Grid_Cost_Savings_Month_from_Storage = Grid_Cost_Month_Baseline - Grid_Cost_Month_with_Solar_and_Storage

    elif Model_Type_Input == "Solar Plus Storage":

        Grid_Cost_Savings_Month_from_Storage = Grid_Cost_Month_with_Solar_Only - Grid_Cost_Month_with_Solar_and_Storage

    # Report Grid Cost Savings from Solar

    if Model_Type_Input == "Solar Plus Storage":
        print(
            'Installing solar DECREASES estimated utility grid costs (not including transmission costs, \n and using representative distribution costs) by $%0.2f per year.', \
            Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_Only)

    # Report Grid Cost Impact from Storage

    if Model_Type_Input == "Storage Only":
        if Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage < 0:
            print(
                'Installing energy storage INCREASES estimated utility grid costs (not including transmission costs, \n and using representative distribution costs) by $%0.2f per year.', \
                -(Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage))
        else:
            print(
                'Installing energy storage DECREASES estimated utility grid costs (not including transmission costs, \n and using representative distribution costs) by $%0.2f per year.', \
                Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage)

    elif Model_Type_Input == "Solar Plus Storage":

        if Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage < 0:
            print(
                'Installing energy storage INCREASES estimated utility grid costs (not including transmission costs, \n and using representative distribution costs) by $%0.2f per year.', \
                -(Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage))
        else:
            print(
                'Installing energy storage DECREASES estimated utility grid costs (not including transmission costs, \n and using representative distribution costs) by $%0.2f per year.', \
                Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage)


    ## Report Emissions Impact

    # This approach multiplies net load by marginal emissions factors to
    # calculate total annual emissions. This is consistent with the idea that
    # the customer would pay an adder based on marginal emissions factors.
    # Typically, total annual emissions is calculated using average emissions
    # values, not marginal emissions values.

    # https://www.pge.com/includes/docs/pdfs/shared/environment/calculator/pge_ghg_emission_factor_info_sheet.pdf

    # (tons/kWh) = (tons/MWh) * (MWh/kWh)
    Annual_GHG_Emissions_Baseline = (Marginal_Emissions_Rate_Evaluation_Data  # (transpose) * Load_Profile_Data * \
                                     (1 / 1000) * delta_t)

    if Model_Type_Input == "Storage Only":
        Annual_GHG_Emissions_with_Solar_Only = ""

    elif Model_Type_Input == "Solar Plus Storage":
        Annual_GHG_Emissions_with_Solar_Only = (
                Marginal_Emissions_Rate_Evaluation_Data  # (transpose) * (Load_Profile_Data - Solar_PV_Profile_Data) * \
                (1 / 1000) * delta_t)

    Annual_GHG_Emissions_with_Solar_and_Storage = (
                                                      Marginal_Emissions_Rate_Evaluation_Data  # (transpose) * (Load_Profile_Data - \
                                                      (Solar_PV_Profile_Data + P_ES_out - P_ES_in)) * (
                                                          1 / 1000) * delta_t)

    if Model_Type_Input == "Storage Only":
        Annual_GHG_Emissions_Reduction_from_Solar = ""
    elif Model_Type_Input == "Solar Plus Storage":
        Annual_GHG_Emissions_Reduction_from_Solar = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_Only

    if Model_Type_Input == "Storage Only":
        Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_and_Storage
    elif Model_Type_Input == "Solar Plus Storage":
        Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_with_Solar_Only - Annual_GHG_Emissions_with_Solar_and_Storage

    if Model_Type_Input == "Storage Only":
        Annual_GHG_Emissions_Reduction_from_Solar_Percent = ""
    elif Model_Type_Input == "Solar Plus Storage":
        Annual_GHG_Emissions_Reduction_from_Solar_Percent = \
            (Annual_GHG_Emissions_Reduction_from_Solar / Annual_GHG_Emissions_Baseline)

    Annual_GHG_Emissions_Reduction_from_Storage_Percent = \
        (Annual_GHG_Emissions_Reduction_from_Storage / Annual_GHG_Emissions_Baseline)

    if Model_Type_Input == "Solar Plus Storage":
        print('Installing solar DECREASES marginal carbon emissions \n by %0.2f metric tons per year.', \
                Annual_GHG_Emissions_Reduction_from_Solar)
    print(
        'This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', \
        Annual_GHG_Emissions_Reduction_from_Solar_Percent * 100, Annual_GHG_Emissions_with_Solar_Only)

    if Annual_GHG_Emissions_Reduction_from_Storage < 0:
        print('Installing energy storage INCREASES marginal carbon emissions \n by %0.2f metric tons per year.', \
                -Annual_GHG_Emissions_Reduction_from_Storage)
        print(
            'This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', \
            -Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, Annual_GHG_Emissions_with_Solar_and_Storage)
    else:
        print('Installing energy storage DECREASES marginal carbon emissions \n by %0.2f metric tons per year.', \
                Annual_GHG_Emissions_Reduction_from_Storage)
        print(
            'This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', \
            Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, Annual_GHG_Emissions_with_Solar_and_Storage)


    ## Plot Grid Costs

    # Plot Grid Cost Time-Series

    if Show_Plots == 1 or Export_Plots == 1:
        figure('NumberTitle', 'off')
        plot(t, Generation_Cost_Data * (1 / 1000), \
             t, Representative_Distribution_Cost_Data * (1 / 1000))
        xlim([t(1), t()])
        xlabel('Date & Time', 'FontSize', 15)
        ylim([-max([Generation_Cost_Data, Representative_Distribution_Cost_Data]) * (1 / 1000) * 0.1, \
              max([Generation_Cost_Data, Representative_Distribution_Cost_Data]) * (
                      1 / 1000) * 1.1])  # Make ylim 10% larger than grid cost range.
        ylabel('Grid Costs ($/kWh)', 'FontSize', 15)
        title('Original and Net Load Profiles', 'FontSize', 15)
        leg('Grid Generation Cost', 'Representative Distribution Cost', 'Location', 'NorthOutside')
        set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        saveas(gcf, Output_Directory_Filepath + "Grid Costs Time Series Plot.png")

        saveas(gcf, Output_Directory_Filepath + "Grid Costs Time Series Plot")

    # Calculate Maximum and Minimum Monthly Grid Costs - to set y-axis for all plots

    Maximum_Monthly_Grid_Cost_Baseline = np.max(sum(Grid_Cost_Month_Baseline, 2))
    Minimum_Monthly_Grid_Cost_Baseline = min(sum(Grid_Cost_Month_Baseline, 2))

    Grid_Cost_Month_with_Solar_Only_Neg = Grid_Cost_Month_with_Solar_Only
    Grid_Cost_Month_with_Solar_Only_Neg[Grid_Cost_Month_with_Solar_Only_Neg > 0] = 0
    Grid_Cost_Month_with_Solar_Only_Pos = Grid_Cost_Month_with_Solar_Only
    Grid_Cost_Month_with_Solar_Only_Pos[Grid_Cost_Month_with_Solar_Only_Pos < 0] = 0

    Maximum_Monthly_Grid_Cost_with_Solar_Only = max(sum(Grid_Cost_Month_with_Solar_Only_Pos, 2))
    Minimum_Monthly_Grid_Cost_with_Solar_Only = min(sum(Grid_Cost_Month_with_Solar_Only_Neg, 2))

    Grid_Cost_Month_with_Solar_and_Storage_Neg = Grid_Cost_Month_with_Solar_and_Storage
    Grid_Cost_Month_with_Solar_and_Storage_Neg[Grid_Cost_Month_with_Solar_and_Storage_Neg > 0] = 0
    Grid_Cost_Month_with_Solar_and_Storage_Pos = Grid_Cost_Month_with_Solar_and_Storage
    Grid_Cost_Month_with_Solar_and_Storage_Pos[Grid_Cost_Month_with_Solar_and_Storage_Pos < 0] = 0

    Maximum_Monthly_Grid_Cost_with_Solar_and_Storage = max(sum(Grid_Cost_Month_with_Solar_and_Storage_Pos, 2))
    Minimum_Monthly_Grid_Cost_with_Solar_and_Storage = min(sum(Grid_Cost_Month_with_Solar_and_Storage_Neg, 2))

    Maximum_Monthly_Grid_Cost = max([Maximum_Monthly_Grid_Cost_Baseline, \
                                     Maximum_Monthly_Grid_Cost_with_Solar_Only, \
                                     Maximum_Monthly_Grid_Cost_with_Solar_and_Storage])

    Minimum_Monthly_Grid_Cost = min([Minimum_Monthly_Grid_Cost_Baseline, \
                                     Minimum_Monthly_Grid_Cost_with_Solar_Only, \
                                     Minimum_Monthly_Grid_Cost_with_Solar_and_Storage])

    Max_Monthly_Grid_Cost_ylim = Maximum_Monthly_Grid_Cost * 1.1  # Make upper ylim 10% larger than largest monthly bill.

    if Minimum_Monthly_Grid_Cost >= 0:
        Min_Monthly_Grid_Cost_ylim = 0  # Make lower ylim equal to 0 if the lowest monthly bill is greater than zero.
    elif Minimum_Monthly_Grid_Cost < 0:
        Min_Monthly_Grid_Cost_ylim = Minimum_Monthly_Grid_Cost * 1.1  # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.

    # Plot Baseline Monthly Grid Costs

    if Show_Plots == 1 or Export_Plots == 1:
        figure('NumberTitle', 'off')
        bar(Grid_Cost_Month_Baseline, 'stacked')
        xlim([0.5, 12.5])
        ylim([Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim])
        xlabel('Month', 'FontSize', 15)
        xticks(linspace(1, 12, 12))
        ylabel('Grid Cost ($/month)', 'FontSize', 15)
        title('Monthly Baseline Grid Costs', 'FontSize', 15)
        leg('Generation Cost', 'Representative Distribution Cost', 'Location', 'NorthWest')
        set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs Baseline Plot.png")

        saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs Baseline Plot")

    # Plot Monthly Grid Costs With Solar Only

    if Model_Type_Input == "Solar Plus Storage":
        if Show_Plots == 1 or Export_Plots == 1:

            figure('NumberTitle', 'off')
            hold
            on
            bar(Grid_Cost_Month_with_Solar_Only_Neg, 'stacked')
            ax = gca
            ax.ColorOrderIndex = 1  # Reset Color Order
            bar(Grid_Cost_Month_with_Solar_Only_Pos, 'stacked')
            hold
            off
            xlim([0.5, 12.5])
            ylim([Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim])
            xlabel('Month', 'FontSize', 15)
            xticks(linspace(1, 12, 12))
            ylabel('Grid Cost ($/month)', 'FontSize', 15)
            title('Monthly Grid Costs with Solar Only', 'FontSize', 15)
            leg('Generation Cost', 'Representative Distribution Cost', 'Location', 'NorthWest')
            set(gca, 'FontSize', 15)

        if Export_Plots == 1:
            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Solar Only Plot.png")

            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Solar Only Plot")

    # Plot Monthly Grid Costs with Solar and Storage

    if Show_Plots == 1 or Export_Plots == 1:
        figure('NumberTitle', 'off')
        hold on
        bar(Grid_Cost_Month_with_Solar_and_Storage_Neg, 'stacked')
        ax = gca
        ax.ColorOrderIndex = 1  # Reset Color Order
        bar(Grid_Cost_Month_with_Solar_and_Storage_Pos, 'stacked')
        hold off
        xlim([0.5, 12.5])
        ylim([Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim])
        xlabel('Month', 'FontSize', 15)
        xticks(linspace(1, 12, 12))
        ylabel('Grid Cost ($/month)', 'FontSize', 15)
        title('Monthly Grid Costs with Storage', 'FontSize', 15)
        leg('Generation Cost', 'Representative Distribution Cost', 'Location', 'NorthWest')
        set(gca, 'FontSize', 15)

    if Export_Plots == 1:
        if Model_Type_Input == "Storage Only":

            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Storage Plot.png")
            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Storage Plot")

    elif Model_Type_Input == "Solar Plus Storage"

            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Solar and Storage Plot.png")
            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Costs with Solar and Storage Plot")


    # Plot Monthly Savings from Storage

    if Show_Plots == 1 or Export_Plots == 1:
        # Separate negative and positive values for stacked bar chart
            Grid_Cost_Savings_Month_from_Storage_Neg = Grid_Cost_Savings_Month_from_Storage
        Grid_Cost_Savings_Month_from_Storage_Neg(Grid_Cost_Savings_Month_from_Storage_Neg > 0) = 0

        Grid_Cost_Savings_Month_from_Storage_Pos = Grid_Cost_Savings_Month_from_Storage
        Grid_Cost_Savings_Month_from_Storage_Pos(Grid_Cost_Savings_Month_from_Storage_Pos < 0) = 0

        # Calculate Maximum and Minimum Monthly Grid Savings - to set y-axis for plot

        Maximum_Grid_Cost_Savings_Month_from_Storage = max(sum(Grid_Cost_Savings_Month_from_Storage_Pos, 2))
        Minimum_Grid_Cost_Savings_Month_from_Storage = min(sum(Grid_Cost_Savings_Month_from_Storage_Neg, 2))

        Max_Grid_Cost_Savings_from_Storage_ylim = Maximum_Grid_Cost_Savings_Month_from_Storage * 1.1  # Make upper ylim 10% larger than largest monthly savings.

        if Minimum_Grid_Cost_Savings_Month_from_Storage >= 0:
            Min_Grid_Cost_Savings_from_Storage_ylim = 0  # Make lower ylim equal to 0 if the lowest monthly grid savings.
        elif Minimum_Grid_Cost_Savings_Month_from_Storage < 0:
            Min_Grid_Cost_Savings_from_Storage_ylim = Minimum_Grid_Cost_Savings_Month_from_Storage * 1.1 - Max_Grid_Cost_Savings_from_Storage_ylim * 0.1  # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.

        figure('NumberTitle', 'off')
        hold on
        bar(Grid_Cost_Savings_Month_from_Storage_Neg, 'stacked')
        ax = gca
        ax.ColorOrderIndex = 1  # Reset Color Order
        bar(Grid_Cost_Savings_Month_from_Storage_Pos, 'stacked')
        hold off
        xlim([0.5, 12.5])
        xlabel('Month', 'FontSize', 15)
        xticks(linspace(1, 12, 12))
        ylim([Min_Grid_Cost_Savings_from_Storage_ylim, Max_Grid_Cost_Savings_from_Storage_ylim])
        ylabel('Grid Cost Savings ($/month)', 'FontSize', 15)
        title('Monthly Grid Cost Savings from Storage', 'FontSize', 15)
        leg('Generation Cost', 'Representative Distribution Cost', 'Location', 'NorthWest')
        set(gca, 'FontSize', 15)

        if Export_Plots == 1:
            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Cost Savings from Storage Plot.png")
            saveas(gcf, Output_Directory_Filepath + "Monthly Grid Cost Savings from Storage Plot")


    ## Plot Emissions Impact by Month

    if Show_Plots == 1 or Export_Plots == 1:
        Emissions_Impact_Timestep = Marginal_Emissions_Rate_Evaluation_Data. * -P_ES * (1 / 1000) * delta_t

        Emissions_Impact_Month = []

        for Month_Iter = 1:12:
            Emissions_Impact_Single_Month = sum(Emissions_Impact_Timestep(Month_Data == Month_Iter,:))
            Emissions_Impact_Month = [Emissions_Impact_Month, Emissions_Impact_Single_Month]

        figure('NumberTitle', 'off')
        bar(Emissions_Impact_Month)
        xlim([0.5, 12.5])
        xlabel('Month', 'FontSize', 15)
        xticks(linspace(1, 12, 12))
        ylabel('Emissions Increase (metric tons/month)', 'FontSize', 15)
        title('Monthly Emissions Impact From Storage', 'FontSize', 15)
        set(gca, 'FontSize', 15)
        hold on

        for i = 1:len(Emissions_Impact_Month):
            h = bar(i, Emissions_Impact_Month(i))
            if Emissions_Impact_Month(i) < 0:
                set(h, 'FaceColor', [0 0.5 0])
            elif Emissions_Impact_Month(i) >= 0:
                set(h, 'FaceColor', 'r')

        hold off

        if Export_Plots == 1:
            saveas(gcf, Output_Directory_Filepath + "Monthly Emissions Impact from Storage Plot.png")
            saveas(gcf, Output_Directory_Filepath + "Monthly Emissions Impact from Storage Plot")


    ## Close All Figures

    if Show_Plots == 0:
        close all


    ## Write Outputs to CSV

    Model_Inputs_and_Outputs = np.array([Modeling_Team_Input, Model_Run_Number_Input, Model_Run_Date_Time,
                                     Model_Type_Input, \
                                     Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Master_Index, \
                                     Load_Profile_Name_Input, Retail_Rate_Master_Index, Retail_Rate_Utility, \
                                     Retail_Rate_Name_Output, Retail_Rate_Effective_Date, \
                                     Solar_Profile_Master_Index, Solar_Profile_Name_Output,
                                     Solar_Profile_Description, \
                                     Solar_Size_Input, Storage_Type_Input, Storage_Power_Rating_Input, \
                                     Usable_Storage_Capacity_Input, Single_Cycle_RTE_Input,
                                     Parasitic_Storage_Load_Input, \
                                     Storage_Control_Algorithm_Name, Storage_Control_Algorithm_Description, \
                                     Storage_Control_Algorithms_Parameters_Filename, \
                                     GHG_Reduction_Solution_Input, Equivalent_Cycling_Constraint_Input, \
                                     Annual_RTE_Constraint_Input, ITC_Constraint_Input, \
                                     Carbon_Adder_Incentive_Value_Input, Other_Incentives_or_Penalities, \
                                     Emissions_Forecast_Signal_Input, \
                                     Annual_GHG_Emissions_Baseline, Annual_GHG_Emissions_with_Solar_Only, \
                                     Annual_GHG_Emissions_with_Solar_and_Storage, \
                                     Annual_Customer_Bill_Baseline, Annual_Customer_Bill_with_Solar_Only, \
                                     Annual_Customer_Bill_with_Solar_and_Storage, \
                                     Annual_Grid_Cost_Baseline, Annual_Grid_Cost_with_Solar_Only, \
                                     Annual_Grid_Cost_with_Solar_and_Storage, \
                                     Annual_Equivalent_Storage_Cycles, Annual_RTE, Operational_Capacity_Factor, \
                                     Annual_Demand_Charge_Cost_Baseline, Annual_Demand_Charge_Cost_with_Solar_Only, \
                                     Annual_Demand_Charge_Cost_with_Solar_and_Storage, \
                                     Annual_Energy_Charge_Cost_Baseline, Annual_Energy_Charge_Cost_with_Solar_Only, \
                                     Annual_Energy_Charge_Cost_with_Solar_and_Storage, \
                                     Annual_Peak_Demand_Baseline, Annual_Peak_Demand_with_Solar_Only, \
                                     Annual_Peak_Demand_with_Solar_and_Storage, \
                                     Annual_Total_Energy_Consumption_Baseline,
                                     Annual_Total_Energy_Consumption_with_Solar_Only, \
                                     Annual_Total_Energy_Consumption_with_Solar_and_Storage, \
                                     Output_Summary_Filename, Output_Description_Filename,
                                     Output_Visualizations_Filename, \
                                     EV_Use, EV_Charge, EV_Gas_Savings, EV_GHG_Savings])

    Storage_Dispatch_Outputs = np.array(t, P_ES)
    Storage_Dispatch_Outputs.Properties.VariableNames = {'Date_Time_Pacific_No_DST', 'Storage_Output_kW'}

    if Export_Data == 1:
        writetable(Model_Inputs_and_Outputs, Output_Directory_Filepath + Output_Summary_Filename)

    writetable(Storage_Dispatch_Outputs, Output_Directory_Filepath + "Storage Dispatch Profile Output.csv")


    ## Return to OSESMO Git Repository Directory

    os.chdir(OSESMO_Git_Repo_Directory)