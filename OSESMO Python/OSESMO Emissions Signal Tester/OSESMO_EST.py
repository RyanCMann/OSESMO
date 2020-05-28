## Script Description Header

# File Name: OSESMO_EST.py
# File Location: "OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Simulates operation of energy storage system, and calculates GHG impact.

import os
import math as math
import time as time
import datetime as datetime
import numpy as np
import pandas as pd
from cvxopt import matrix, sparse, solvers
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt


def OSESMO_EST(Modeling_Team_Input=None, Model_Run_Number_Input=None,
               Model_Timestep_Resolution=None,
               Storage_Type_Input=None, Storage_Power_Rating_Input=None, Usable_Storage_Capacity_Input=None,
               Single_Cycle_RTE_Input=None, Parasitic_Storage_Load_Input=None,
               Emissions_Forecast_Signal_Name_Input=None, Emissions_Forecast_Signal_Input=None,
               Emissions_Evaluation_Signal_Input=None,
               OSESMO_Git_Repo_Directory=None, Input_Output_Data_Directory_Location=None, Start_Time_Input=None,
               Show_Plots=None, Export_Plots=None, Export_Data=None,
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


    # Usable Storage Capacity
    # Usable storage capacity is equal to the original usable storage capacity
    # input, degraded every month based on the number of cycles performed in
    # that month. Initialized at the usable storage capacity input value.
    Usable_Storage_Capacity = Usable_Storage_Capacity_Input


    ## Import Data from CSV Files

    # Begin script runtime timer
    tstart = time.time()

    # Import Marginal Emissions Rate Data Used as Forecast
    os.chdir(Input_Output_Data_Directory_Location)
    Marginal_Emissions_Rate_Forecast_Data = np.genfromtxt(Emissions_Forecast_Signal_Input,delimiter=',')

    os.chdir(OSESMO_Git_Repo_Directory)

    # Import Marginal Emissions Rate Data Used for Evaluation
    os.chdir(Input_Output_Data_Directory_Location)
    Marginal_Emissions_Rate_Evaluation_Data = np.genfromtxt(Emissions_Evaluation_Signal_Input, delimiter=',')
    os.chdir(OSESMO_Git_Repo_Directory)


    # Import Month Data

    # Set Directory to Box Sync Folder
    os.chdir(Input_Output_Data_Directory_Location)

    if delta_t == (5 / 60):
       Month_Data = np.genfromtxt('Month Data/2017/5-Minute Data/Vector Format/2017_Month_Vector.csv', delimiter=',')

    elif delta_t == (15 / 60):
        Month_Data = np.genfromtxt('Month Data/2017/15-Minute Data/Vector Format/2017_Month_Vector.csv', delimiter=',')

    # Return to OSESMO Git Repository Directory
    os.chdir(OSESMO_Git_Repo_Directory)


    # Set Directory to Input-Output Data Directory
    os.chdir(Input_Output_Data_Directory_Location)


    ## Iterate Through Time Intervals & Filter Data to Selected Time Interval
    # The time interval used in each iteration is 1 (padded) month.

    Time_Intervals_Array = range(1, 12+1)


    # Initialize Blank Variables to store optimal decision variable values for all time intervals.

    # Initialize Decision Variable Vectors
    P_ES_in = np.array([])

    P_ES_out = np.array([])

    Ene_Lvl = np.array([])


    for Time_Interval_Iter in Time_Intervals_Array:  # Iterate through all time intervals

        # Filter Marginal Emissions Forecast Data to Selected Time Interval
        Marginal_Emissions_Rate_Forecast_Data_Interval = Marginal_Emissions_Rate_Forecast_Data[Month_Data == Time_Interval_Iter]


        ## Add "Padding" to Every Month of Data (for Quick Forecasts only)
        # Don't pad Month 12, because the final state of charge is constrained to equal the original state of charge.

        if Time_Interval_Iter in range(1, 12):  # Months 1 through 11

            # Pad Marginal Emissions Data
            Marginal_Emissions_Rate_Forecast_Data_Interval = np.concatenate((Marginal_Emissions_Rate_Forecast_Data_Interval,
                                                                        Marginal_Emissions_Rate_Forecast_Data_Interval[-(End_of_Month_Padding_Days * 24 * int(1 / delta_t)):]))


        ## Initialize Cost Vector "c"

        # nts = numtsteps = number of timesteps
        numtsteps = len(Marginal_Emissions_Rate_Forecast_Data_Interval)
        all_tsteps = np.array(list(range(0, numtsteps)))


        # x = np.concatenate((P_ES_in(size nts), P_ES_out(size nts), Ene_Lvl(size nts)))

        c_Interval_Carbon_Only = np.concatenate(((Marginal_Emissions_Rate_Forecast_Data_Interval * delta_t),
                               (-Marginal_Emissions_Rate_Forecast_Data_Interval * delta_t),
                               np.zeros(numtsteps,)))


        c_Interval = c_Interval_Carbon_Only

        # This is the length of the vectors c and x, or the total number of decision variables.
        length_x = len(c_Interval)

        # Convert from numpy array to cvxopt matrix format
        c_Interval = matrix(c_Interval, tc = 'd')


        ## Decision Variable Indices

        # P_ES_in = x(1:numtsteps)
        # P_ES_out = x(numtsteps+1:2*numtsteps)
        # Ene_Lvl = x(2*numtsteps+1:3*numtsteps)


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

        A_Interval = sparse([A_E,
                          -A_E], tc = 'd')

        b_Interval = sparse([b_E,
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

        A_Interval = sparse([A_Interval,
                          A_P_ES_in,
                          -A_P_ES_in], tc = 'd')

        b_Interval = sparse([b_Interval,
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

        A_Interval = sparse([A_Interval,
                          A_P_ES_out,
                          -A_P_ES_out], tc = 'd')

        b_Interval = sparse([b_Interval,
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

        A_Interval = sparse([A_Interval,
                          A_Ene_Lvl_min], tc = 'd')

        b_Interval = sparse([b_Interval,
                          b_Ene_Lvl_min], tc = 'd')

        # Ene_Lvl(t) <= Size_ES

        A_Ene_Lvl_max = sparse(matrix(0., (numtsteps, length_x), tc = 'd'), tc = 'd')
        b_Ene_Lvl_max = matrix(Usable_Storage_Capacity * np.ones((numtsteps,1)), tc = 'd')

        for n in range(0, numtsteps):  # Iterates from Index 0 to Index (numtsteps-1) - equivalent to Timesteps 1 to (numtsteps)
            A_Ene_Lvl_max[n, n + (2 * numtsteps)] = 1.

        A_Interval = sparse([A_Interval,
                          A_Ene_Lvl_max], tc = 'd')

        b_Interval = sparse([b_Interval,
                          b_Ene_Lvl_max], tc = 'd')


        ## Initial State of Charge Constraint

        # In the first time interval, this constraint initializes the energy level of the battery at
        # a user-defined percentage of the original battery capacity.
        # In all other time intervals, this constraints initializes the energy level of
        # the battery at the final battery level from the previous interval.

        # E(0) = Initial_Final_SOC * Usable_Storage_Capacity_Input
        # E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input

        # E(0) = Previous_Interval_Final_Energy_Level
        # E(0) <= Previous_Interval_Final_Energy_Level, -E(0) <= Previous_Interval_Final_Energy_Level

        A_Ene_Lvl_0 = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

        A_Ene_Lvl_0[0, (2 * numtsteps)] = 1.

        if Time_Interval_Iter == Time_Intervals_Array[0]:

            b_Ene_Lvl_0 = matrix(Initial_Final_SOC * Usable_Storage_Capacity_Input, tc = 'd')

        else:

            b_Ene_Lvl_0 = matrix(Next_Interval_Initial_Energy_Level, tc = 'd')

        A_Interval = sparse([A_Interval,
                          A_Ene_Lvl_0,
                          -A_Ene_Lvl_0], tc = 'd')

        b_Interval = sparse([b_Interval,
                          b_Ene_Lvl_0,
                          -b_Ene_Lvl_0], tc = 'd')


        ## Final State of Charge Constraints (for Quick Forecasts only)

        # This constraint fixes the final state of charge of the battery at a user-defined percentage
        # of the original battery capacity,
        # to prevent it from discharging completely in the final timesteps.

        # E(N) = Initial_Final_SOC * Usable_Storage_Capacity_Input
        # E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input

        A_Ene_Lvl_N = sparse(matrix(0., (1, length_x), tc = 'd'), tc = 'd')

        A_Ene_Lvl_N[0, (3 * numtsteps) - 1] = 1.

        b_Ene_Lvl_N = matrix(Initial_Final_SOC * Usable_Storage_Capacity_Input, tc = 'd')

        A_Interval = sparse([A_Interval,
                             A_Ene_Lvl_N,
                             -A_Ene_Lvl_N], tc = 'd')

        b_Interval = sparse([b_Interval,
                             b_Ene_Lvl_N,
                             -b_Ene_Lvl_N], tc = 'd')


        ## Run LP Optimization Algorithm

        # Check that number of rows in A_Interval.size == number of rows in b_Interval.size
        # Check that A_Interval.typecode, b_Interval.typecode, c_Interval.typecode == 'd'

        b_Interval = matrix(b_Interval, tc = 'd') # Convert from sparse to dense matrix

        lp_solution = solvers.lp(c_Interval, A_Interval, b_Interval)

        x_Interval = lp_solution['x']

        print("Optimization complete for Month %d." % Time_Interval_Iter)


        ## Separate Decision Variable Vectors

        x_Interval = np.asarray(x_Interval)

        P_ES_in_Interval_Padded = x_Interval[range(0, numtsteps)]

        P_ES_out_Interval_Padded = x_Interval[range(numtsteps, 2 * numtsteps)]

        Ene_Lvl_Interval_Padded = x_Interval[range(2 * numtsteps, 3 * numtsteps)]


        ## Add Auxiliary Load/Parasitic Losses to P_ES_in

        P_ES_in_Interval_Padded = P_ES_in_Interval_Padded + Parasitic_Storage_Load


        ## Select Optimal Decision Variable Values Kept from Each Iteration
        # For Quick Forecast, remove 3 days of "Padding" from decision variable vectors. Data is padded in Months 1-11, and not in Month 12
        # For Rolling Forecast, keep only the first interval from each decision variable vector.

        if Time_Interval_Iter in range(1, 12):

            P_ES_in_Interval_Unpadded = P_ES_in_Interval_Padded[
                range(0, (len(P_ES_in_Interval_Padded) - int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

            P_ES_out_Interval_Unpadded = P_ES_out_Interval_Padded[
                range(0, (len(P_ES_out_Interval_Padded) - int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

            Ene_Lvl_Interval_Unpadded = Ene_Lvl_Interval_Padded[
                range(0, (len(Ene_Lvl_Interval_Padded) - int(End_of_Month_Padding_Days * 24 * (1 / delta_t))))]

        elif Time_Interval_Iter == 12:

            P_ES_in_Interval_Unpadded = P_ES_in_Interval_Padded

            P_ES_out_Interval_Unpadded = P_ES_out_Interval_Padded

            Ene_Lvl_Interval_Unpadded = Ene_Lvl_Interval_Padded


        # Save Final Energy Level of Battery for use in next interval

        Previous_Interval_Final_Energy_Level = Ene_Lvl_Interval_Unpadded[-1,0]

        Next_Interval_Initial_Energy_Level = Previous_Interval_Final_Energy_Level + \
                                          ((Eff_c * P_ES_in_Interval_Unpadded[-1,0]) - \
                                           ((1 / Eff_d) * P_ES_out_Interval_Unpadded[-1,0])) * delta_t


        # Correct Next_Interval_Initial_Energy_Level to make sure it's feasible
        Next_Interval_Initial_Energy_Level = np.max((np.min((Next_Interval_Initial_Energy_Level, Usable_Storage_Capacity)), 0))


        ## Concatenate Decision Variable & Cost Values from Each Interval Iteration

        # Decision Variable Concatenation
        P_ES_in = np.concatenate((P_ES_in, P_ES_in_Interval_Unpadded)) if P_ES_in.size != 0 else P_ES_in_Interval_Unpadded

        P_ES_out = np.concatenate((P_ES_out, P_ES_out_Interval_Unpadded)) if P_ES_out.size != 0 else P_ES_out_Interval_Unpadded

        Ene_Lvl = np.concatenate((Ene_Lvl, Ene_Lvl_Interval_Unpadded)) if Ene_Lvl.size != 0 else Ene_Lvl_Interval_Unpadded



    # Report total script runtime.

    tend = time.time()
    telapsed = tend - tstart

    if telapsed <= 60:
        print('Model Run %0.f complete. Elapsed time to run the optimization model is %0.0f seconds.' % (Model_Run_Number_Input, telapsed))
    else:
        print('Model Run %0.f complete. Elapsed time to run the optimization model is %0.0f minutes.' % (Model_Run_Number_Input, telapsed/60))


    ## Calculation of Additional Reported Model Inputs/Outputs

    # Output current system date and time in standard ISO 8601 YYYY-MM-DD HH:MM format.
    Model_Run_Date_Time = datetime.datetime.now().replace(microsecond=0).isoformat()


    Output_Summary_Filename = "OSESMO Reporting Inputs and Outputs.csv"

    Output_Directory_Filepath = os.path.join(Input_Output_Data_Directory_Location, "Model Outputs", \
                                str(Model_Timestep_Resolution) + "-Minute Timestep Resolution", \
                                str(Storage_Power_Rating_Input) + " kW " + str(Usable_Storage_Capacity_Input) + " kWh Storage", \
                                str(int(Single_Cycle_RTE_Input * 100)) + " Percent Single-Cycle RTE", \
                                str(Parasitic_Storage_Load_Input * 100) + " Percent Parasitic Load", \
                                Emissions_Forecast_Signal_Name_Input)


    # Create folder if one does not exist already, if exporting plots or data.
    if (Export_Plots or Export_Data) and os.path.isdir(Output_Directory_Filepath) == False:
        os.makedirs(Output_Directory_Filepath)


    ## Plot Energy Storage Dispatch Schedule and Marginal Emissions

    numtsteps_year = len(Marginal_Emissions_Rate_Evaluation_Data)

    t = np.linspace(1, 35040, 35040)
    t = [Start_Time_Input + datetime.timedelta(minutes = int(60 * delta_t) * x) for x in range(0, numtsteps_year)]

    P_ES = np.reshape(P_ES_out - P_ES_in, (numtsteps_year,))


    if Show_Plots == True or Export_Plots == True:
        fig, ax1 = plt.subplots()
        ax1.plot(t, P_ES, 'b-')
        ax1.set_xlabel('Date & Time')
        ax1.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax1.set_ylabel('Energy Storage Output (kW)', color='b')
        ax1.tick_params('y', colors='b')
        ax2 = ax1.twinx()
        ax2.plot(t, Marginal_Emissions_Rate_Evaluation_Data, 'r-')
        ax2.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax2.set_ylabel('Marginal Emissions Rate (kg/kWh)', color='r')
        ax2.set_title('Energy Storage Dispatch and Marginal Emissions Rates')
        ax2.tick_params('y', colors='r')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()


    if Export_Plots == True:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Storage Dispatch and Marginal Emissions Time-Series Plot.png'))

        # Note: The MATLAB version of OSESMO which saves files in .fig format, which allows plots of model runs to be
        # re-opened and then explored interactively (ex. zooming in on specific days).
        # OSESMO Python does not have this functionality currently, as matplotlib does not have any built-in features that make this possible.
        # It may be possible to add this functionality in the future, using the pickle package.
        # https://stackoverflow.com/questions/4348733/saving-interactive-matplotlib-figures


    ## Plot Energy Storage Dispatch vs. Marginal Emissions

    if Show_Plots == True or Export_Plots == True:
        fig, ax = plt.subplots()
        ax.scatter(Marginal_Emissions_Rate_Evaluation_Data, P_ES, c=np.where(P_ES < 0, 'r', np.where(P_ES > 0, 'b', 'k')))
        ax.set_xlabel('Marginal Emissions Rate (kg/kWh)')
        ax.set_ylabel('Energy Storage Output (kW)')
        ax.set_title('Energy Storage Dispatch vs. Marginal Emissions Rates')
        fig.tight_layout()
        plt.show()

    if Export_Plots == True:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Storage Dispatch vs Marginal Emissions Scatter Plot.png'))


    ## Plot Energy Storage Energy Level

    if Show_Plots == True or Export_Plots == True:
        fig, ax = plt.subplots()
        ax.plot(t, Ene_Lvl, 'r-')
        ax.set_xlabel('Date & Time')
        ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%Y-%m-%d %H:%M'))
        ax.set_ylabel('Energy Storage Energy Level (kWh)')
        ax.set_title('Energy Storage Energy Level')
        fig.autofmt_xdate()
        fig.tight_layout()
        plt.show()

    if Export_Plots == True:
        plt.savefig(os.path.join(Output_Directory_Filepath, 'Energy Level Plot.png'))


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


    ## Report Emissions as Measured by Evaluation Signal

    Annual_GHG_Emissions_Reduction_from_Storage_Evaluation = np.dot(Marginal_Emissions_Rate_Evaluation_Data,
                                                         P_ES_out.reshape((numtsteps_year,)) - P_ES_in.reshape(
                                                             (numtsteps_year,))) * (1 / 1000) * delta_t

    if Annual_GHG_Emissions_Reduction_from_Storage_Evaluation < 0:
        print('Installing energy storage INCREASES marginal carbon emissions by {0} metric tons per year, as measured by the evaluation signal.'.format(
                -round(Annual_GHG_Emissions_Reduction_from_Storage_Evaluation, 2)))
    else:
        print('Installing energy storage DECREASES marginal carbon emissions by {0} metric tons per year, as measured by the evaluation signal.'.format(
                round(Annual_GHG_Emissions_Reduction_from_Storage_Evaluation, 2)))


    ## Plot Emissions Impact by Month

    if Show_Plots == True or Export_Plots == True:
        Emissions_Impact_Timestep = np.multiply(Marginal_Emissions_Rate_Evaluation_Data, -P_ES) * (1 / 1000) * delta_t

        Emissions_Impact_Month = np.array([])

        for Month_Iter in range(1, 12+1):
            Emissions_Impact_Single_Month = np.sum(Emissions_Impact_Timestep[Month_Data == Month_Iter])
            Emissions_Impact_Month = np.concatenate((Emissions_Impact_Month, np.asarray(Emissions_Impact_Single_Month).reshape((-1,1))), axis=0) if \
                Emissions_Impact_Month.size != 0 else np.asarray(Emissions_Impact_Single_Month).reshape((-1,1))


        # Separate Emissions-Increasing Months from Emissions-Decreasing Months
        Emissions_Impact_Month_Positive = Emissions_Impact_Month.copy()
        Emissions_Impact_Month_Positive[Emissions_Impact_Month_Positive < 0] = 0

        Emissions_Impact_Month_Negative = Emissions_Impact_Month.copy()
        Emissions_Impact_Month_Negative[Emissions_Impact_Month_Negative > 0] = 0
        Emissions_Impact_Month_Plot = np.concatenate((Emissions_Impact_Month_Positive, Emissions_Impact_Month_Negative), axis = 1)


        series_labels = ['Emissions Increase', 'Emissions Decrease']

        # category_labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

        category_labels = ['6', '7', '8', '9', '10', '11', '12', '1', '2', '3', '4', '5']

        plt.figure()

        stacked_bar(np.transpose(Emissions_Impact_Month_Plot),
                    series_labels,
                    category_labels=category_labels,
                    show_values=False,
                    value_format="{}",
                    y_label="Emissions Increase (metric tons/month)")

        plt.xlabel('Month')
        plt.title('Monthly Emissions Impact From Storage')
        plt.show()

        if Export_Plots == True:
            plt.savefig(os.path.join(Output_Directory_Filepath, 'Monthly Emissions Impact from Storage Plot.png'))


    ## Close All Figures

    if Show_Plots == 0:
        plt.close('all')


    ## Write Outputs to CSV

    Model_Inputs_and_Outputs = np.array([Modeling_Team_Input, Model_Run_Number_Input, Model_Run_Date_Time, Model_Timestep_Resolution, \
                                         Storage_Type_Input, Storage_Power_Rating_Input, Usable_Storage_Capacity_Input, Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input, \
                                         Emissions_Forecast_Signal_Input, \
                                        Annual_GHG_Emissions_Reduction_from_Storage_Evaluation]).reshape((1, 11))

    Model_Inputs_and_Outputs = pd.DataFrame(Model_Inputs_and_Outputs, columns = ["Modeling_Team_Input", "Model_Run_Number_Input", "Model_Run_Date_Time", "Model_Timestep_Resolution", \
                                         "Storage_Type_Input", "Storage_Power_Rating_Input", "Usable_Storage_Capacity_Input", "Single_Cycle_RTE_Input", "Parasitic_Storage_Load_Input", \
                                         "Emissions_Forecast_Signal_Input", \
                                         "Annual_GHG_Emissions_Reduction from Storage_Evaluation"])

    Storage_Dispatch_Outputs = np.array([t, P_ES]).transpose()
    Storage_Dispatch_Outputs = pd.DataFrame(Storage_Dispatch_Outputs, columns = ["Date_Time_Pacific_No_DST", "Storage_Output_kW"])

    if Export_Data == True:
        Model_Inputs_and_Outputs.to_csv(os.path.join(Output_Directory_Filepath, Output_Summary_Filename), index = False)
        Storage_Dispatch_Outputs.to_csv(os.path.join(Output_Directory_Filepath, "Storage Dispatch Profile Output.csv"), index = False)


    ## Return to OSESMO Git Repository Directory

    os.chdir(OSESMO_Git_Repo_Directory)