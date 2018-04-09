%% Script Description Header

% File Name: OSESMO.m
% File Location: "~/Desktop/OSESMO Git Repository"
% Project: Open-Source Energy Storage Model (OSESMO)
% Description: Simulates operation of energy storage system.
% Calculates customer savings, GHG reduction, and battery cycling.

function OSESMO(Modeling_Team_Input, Model_Run_Number_Input, Model_Type_Input, ...
    Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Name_Input, ...
    Retail_Rate_Name_Input, Solar_Profile_Name_Input, Solar_Size_Input, ...
    Storage_Type_Input, Storage_Power_Rating_Input, Usable_Storage_Capacity_Input, ...
    Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input, ...
    Storage_Control_Algorithm_Name, GHG_Reduction_Solution_Input, Equivalent_Cycling_Constraint_Input, ...
    Annual_RTE_Constraint_Input, ITC_Constraint_Input, ...
    Carbon_Adder_Incentive_Value_Input, Emissions_Forecast_Signal_Input, ...
    OSESMO_Git_Repo_Directory, Input_Output_Data_Directory_Location, Start_Time_Input, ...
    Show_Plots, Export_Plots, Export_Data, ...
    Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh, ...
    Cycle_Life, Storage_Depth_of_Discharge, Initial_Final_SOC, End_of_Month_Padding_Days)

%% Calculate Model Variable Values from User-Specified Input Values

% Convert model timestep resolution input from minutes to hours.
% This is a more useful format for the model to use.
delta_t = (Model_Timestep_Resolution/60); % Model timestep resolution, in hours.

% Convert storage efficiency from round-trip efficiency to charge and discharge efficiency.
% Charge efficiency and discharge efficiency assumed to be square root of round-trip efficiency (Eff_c = Eff_d).
% Round-trip efficiency taken from Lazard's Levelized Cost of Storage report (2017), pg. 130
% https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
Eff_c = sqrt(Single_Cycle_RTE_Input);
Eff_d = sqrt(Single_Cycle_RTE_Input);

% Parasitic storage load (kW) calculated based on input value, which is
% given as a percentage of Storage Power Rating.
Parasitic_Storage_Load = Storage_Power_Rating_Input * Parasitic_Storage_Load_Input;

% Set Carbon Adder to $0/metric ton if GHG Reduction Solution is not GHG Signal Co-Optimization.
% This serves as error-handling in case the user sets the Carbon Adder to a
% non-zero value, and sets the GHG Reduction Solution to something other
% than GHG Signal Co-Optimization.

if GHG_Reduction_Solution_Input ~= "GHG Signal Co-Optimization"
    
    Carbon_Adder_Incentive_Value_Input = 0; % Value of carbon adder, in $ per metric ton.
    
    Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal"; % Ensures consistent outputs.
    
end

% Set Solar Profile Name Input to "No Solar", set Solar Size Input to 0 kW,
% and set ITC Constraint to 0 if Model Type Input is Storage Only.
% This serves as error handling.

if Model_Type_Input == "Storage Only"
    
    Solar_Profile_Name_Input = "No Solar";
    Solar_Size_Input = 0;
    ITC_Constraint_Input = 0;
end

% Throw an error if Model Type Input is set to Solar Plus Storage
% and Solar Profile Name Input is set to "No Solar",
% or if Solar Size Input is set to 0 kW.

if Model_Type_Input == "Solar Plus Storage"
    
    if Solar_Profile_Name_Input == "No Solar"
        error("Solar Plus Storage Model selected, but No Solar Profile Name Input selected.")
    end
    
    if Solar_Size_Input == 0
        error("Solar Plus Storage Model selected, but Solar Size Input set to 0 kW.")
    end
end

% Throw an error if Storage Control Algorithm set to OSESMO Non-Economic
% Solar Self-Supply, and Model Type Input is set to Storage Only,
% or if Solar Profile Name Input is set to "No Solar",
% or if Solar Size Input is set to 0 kW.

if Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply"
    if Model_Type_Input == "Storage Only"
        error("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but Model Type set to Storage Only.")
    end
    
    if Solar_Profile_Name_Input == "No Solar"
        error("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but No Solar Profile Name Input selected.")
    end
    
    if Solar_Size_Input == 0
        error("OSESMO Non-Economic Solar Self-Supply control algorithm selected, but Solar Size Input set to 0 kW.")
    end  
end

% Emissions Evaluation Signal
% Real-time five-minute marginal emissions signal used to evaluate emission impacts.
% Available for both NP15 (Northern California congestion zone)
% and SP15 (Southern California congestion zone).
% Mapped based on load profile site location (Northern or Southern CA).

if Load_Profile_Name_Input == "WattTime GreenButton Residential Berkeley" || ...
        Load_Profile_Name_Input == "WattTime GreenButton Residential Coulterville" || ...
        Load_Profile_Name_Input ==  "PG&E GreenButton E-6 Residential" || ...
        Load_Profile_Name_Input ==  "PG&E GreenButton Central Valley Residential CARE" || ...
        Load_Profile_Name_Input ==  "PG&E GreenButton Central Valley Residential Non-CARE" || ...
        Load_Profile_Name_Input ==  "Custom Power Solar GreenButton PG&E Albany Residential with EV" || ...
        Load_Profile_Name_Input ==  "Custom Power Solar GreenButton PG&E Crockett Residential with EV" || ...
        Load_Profile_Name_Input == "Avalon GreenButton East Bay Light Industrial" || ...
        Load_Profile_Name_Input == "Avalon GreenButton South Bay Education" || ...
        Load_Profile_Name_Input ==  "EnerNOC GreenButton San Francisco Office" || ...
        Load_Profile_Name_Input ==  "EnerNOC GreenButton San Francisco Industrial" || ...
        Load_Profile_Name_Input ==  "PG&E GreenButton A-6 SMB" || ...
        Load_Profile_Name_Input == "PG&E GreenButton A-10S MLB" || ...
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE" || ...
        Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential CARE"
        
    
    Emissions_Evaluation_Signal_Input = "NP15 RT5M";
    
elseif Load_Profile_Name_Input == "WattTime GreenButton Residential Long Beach" || ...
        Load_Profile_Name_Input == "Stem GreenButton SCE TOU-8B Office" || ...
        Load_Profile_Name_Input ==  "Stem GreenButton SDG&E G-16 Manufacturing" || ...
        Load_Profile_Name_Input ==  "Stem GreenButton SCE GS-3B Food Processing" || ...
        Load_Profile_Name_Input ==  "EnerNOC GreenButton Los Angeles Grocery" || ...
        Load_Profile_Name_Input ==  "EnerNOC GreenButton Los Angeles Industrial" || ...
        Load_Profile_Name_Input == "EnerNOC GreenButton San Diego Office"
    
    Emissions_Evaluation_Signal_Input = "SP15 RT5M";
    
else
    
    error("This load profile name input has not been mapped to an emissions evaluation signal (NP15 or SP15).")
    
end


% Total Storage Capacity
% Total storage capacity is the total chemical capacity of the battery.
% The usable storage capacity is equal to the total storage capacity 
% multiplied by storage depth of discharge. This means that the total
% storage capacity is equal to the usable storage capacity divided by
% storage depth of discharge. Total storage capacity is used to 
% calculate battery cost, whereas usable battery capacity is used 
% as an input to operational simulation portion of model.
Total_Storage_Capacity = Usable_Storage_Capacity_Input/Storage_Depth_of_Discharge;

% Usable Storage Capacity
% Usable storage capacity is equal to the original usable storage capacity
% input, degraded every month based on the number of cycles performed in
% that month. Initialized at the usable storage capacity input value.

Usable_Storage_Capacity = Usable_Storage_Capacity_Input;


% Cycling Penalty
% Cycling penalty for lithium-ion battery is equal to estimated replacement cell cost
% in 10 years divided by expected cycle life. Cycling penalty for flow batteries is $0/cycle.

if Storage_Type_Input == "Lithium-Ion Battery"
    
    cycle_pen = (Total_Storage_Capacity * Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh) / Cycle_Life;
    
elseif Storage_Type_Input == "Flow Battery"
    cycle_pen = 0;
    
end


%% Import Data from CSV Files

% Begin script runtime timer
tstart = tic;

% Import Load Profile Data
% Call Import_Load_Profile_Data function.
Load_Profile_Data = Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input);

Annual_Peak_Demand_Baseline = max(Load_Profile_Data);
Annual_Total_Energy_Consumption_Baseline = sum(Load_Profile_Data) * delta_t;

% Import Marginal Emissions Rate Data Used as Forecast
% Call Import_Marginal_Emissions_Rate_Forecast_Data function.
Marginal_Emissions_Rate_Forecast_Data = Import_Marginal_Emissions_Rate_Forecast_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Load_Profile_Data, Emissions_Forecast_Signal_Input);


% Import Marginal Emissions Rate Data Used for Evaluation
% Call Import_Marginal_Emissions_Rate_Forecast_Data function.
Marginal_Emissions_Rate_Evaluation_Data = Import_Marginal_Emissions_Rate_Evaluation_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Emissions_Evaluation_Signal_Input);


% Import Carbon Adder Data
   
% Carbon Adder ($/kWh) = Marginal Emissions Rate (metric tons CO2/MWh) * ...
% Carbon Adder ($/metric ton) * (1 MWh/1000 kWh)
Carbon_Adder_Data = (Marginal_Emissions_Rate_Forecast_Data * ...
    Carbon_Adder_Incentive_Value_Input)/1000;


% Import Retail Rate Data
% Call Import_Retail_Rate_Data function.
[Volumetric_Rate_Data, Summer_Peak_DC, Summer_Part_Peak_DC, Summer_Noncoincident_DC, ...
    Winter_Peak_DC, Winter_Part_Peak_DC, Winter_Noncoincident_DC, ...
    Fixed_Per_Meter_Day_Charge, Fixed_Per_Meter_Month_Charge, ...
    First_Summer_Month, Last_Summer_Month, Month_Data, ...
    Summer_Peak_Binary_Data, Summer_Part_Peak_Binary_Data, ...
    Winter_Peak_Binary_Data, Winter_Part_Peak_Binary_Data] = Import_Retail_Rate_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, ...
    delta_t, Retail_Rate_Name_Input);

% Import IOU-Proposed Charge and Discharge Hour Flag Vectors

if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints"
    
    [IOU_Charge_Hour_Binary_Data, IOU_Discharge_Hour_Binary_Data] = Import_IOU_Time_Constraint_Binary_Data(Input_Output_Data_Directory_Location, ...
        OSESMO_Git_Repo_Directory, delta_t);
    
end

% Import PG&E-Proposed Charge, No-Charge, and Discharge Hour Flag Vectors

if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" || ...
            GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints"
    
 [PGE_Charge_Hour_Binary_Data, PGE_No_Charge_Hour_Binary_Data, PGE_Discharge_Hour_Binary_Data] = ...
     Import_PGE_Time_Constraint_Binary_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t);
    
end


% Import Solar PV Generation Profile Data
% Scale base 10-kW or 100-kW profile to match user-input PV system size

if Model_Type_Input == "Solar Plus Storage"
    
    Solar_PV_Profile_Data = Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, ...
    Solar_Profile_Name_Input, Solar_Size_Input);    
    
elseif Model_Type_Input == "Storage Only" || Solar_Profile_Name_Input == "No Solar"
    
    Solar_PV_Profile_Data = zeros(size(Load_Profile_Data));
    
end

% Set Directory to Box Sync Folder
cd(Input_Output_Data_Directory_Location)


%% Iterate Through Months & Filter Data to Selected Month

% Initialize Blank Variables to store optimal decision variable values for
% all months

% Initialize Decision Variable Vectors
P_ES_in = [];

P_ES_out = [];

Ene_Lvl = [];

P_max_NC = [];
    
P_max_peak = [];
    
P_max_part_peak = [];
    

% Initialize Monthly Cost Variable Vectors

Fixed_Charge_Vector = [];

NC_DC_Baseline_Vector = [];
NC_DC_with_Solar_Only_Vector = [];
NC_DC_with_Solar_and_Storage_Vector = [];

CPK_DC_Baseline_Vector = [];
CPK_DC_with_Solar_Only_Vector = [];
CPK_DC_with_Solar_and_Storage_Vector = [];

CPP_DC_Baseline_Vector = [];
CPP_DC_with_Solar_Only_Vector = [];
CPP_DC_with_Solar_and_Storage_Vector = [];

Energy_Charge_Baseline_Vector = [];
Energy_Charge_with_Solar_Only_Vector = [];
Energy_Charge_with_Solar_and_Storage_Vector = [];

Cycles_Vector = [];
Cycling_Penalty_Vector = [];


for Month_Iter = 1:12 % Iterate through all months
    
    % Filter Load Profile Data to Selected Month
    Load_Profile_Data_Month = Load_Profile_Data(Month_Data == Month_Iter, :);
    
    % Filter PV Production Profile Data to Selected Month
    Solar_PV_Profile_Data_Month = Solar_PV_Profile_Data(Month_Data == Month_Iter, :);
    
    % Filter Volumetric Rate Data to Selected Month
    Volumetric_Rate_Data_Month = Volumetric_Rate_Data(Month_Data == Month_Iter, :);
    
    % Filter Marginal Emissions Data to Selected Month
    
    Marginal_Emissions_Rate_Forecast_Data_Month = ...
        Marginal_Emissions_Rate_Forecast_Data(Month_Data == Month_Iter, :);
    
    % Filter Carbon Adder Data to Selected Month
    
    Carbon_Adder_Data_Month = Carbon_Adder_Data(Month_Data == Month_Iter, :);
    
    % Set Demand Charge Values Based on Month
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        
        Peak_DC = Summer_Peak_DC;
        Part_Peak_DC = Summer_Part_Peak_DC;
        Noncoincident_DC = Summer_Noncoincident_DC;
        
    else
        
        Peak_DC = Winter_Peak_DC;
        Part_Peak_DC = Winter_Part_Peak_DC;
        Noncoincident_DC = Winter_Noncoincident_DC;
        
    end
    
    
    % Filter Peak and Part-Peak Binary Data to Selected Month
    
    if Summer_Peak_DC > 0
        Summer_Peak_Binary_Data_Month = Summer_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Summer_Part_Peak_DC > 0
        Summer_Part_Peak_Binary_Data_Month = Summer_Part_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Winter_Peak_DC > 0
        Winter_Peak_Binary_Data_Month = Winter_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    if Winter_Part_Peak_DC > 0
        Winter_Part_Peak_Binary_Data_Month = Winter_Part_Peak_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    % Filter PG&E-Proposed Charge and Discharge Hour Binary Data to Selected Month
    if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" || ...
            GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints"
        PGE_Charge_Hour_Binary_Data_Month = PGE_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        PGE_No_Charge_Hour_Binary_Data_Month = PGE_No_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        PGE_Discharge_Hour_Binary_Data_Month = PGE_Discharge_Hour_Binary_Data(Month_Data == Month_Iter, :);
    end
    
    % Filter IOU-Proposed Charge and Discharge Hour Binary Data to Selected Month
    if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints"
        IOU_Charge_Hour_Binary_Data_Month = IOU_Charge_Hour_Binary_Data(Month_Data == Month_Iter, :);
        IOU_Discharge_Hour_Binary_Data_Month = IOU_Discharge_Hour_Binary_Data(Month_Data == Month_Iter, :);
    end
    
       
    %% Add "Padding" to Every Month of Data
    % Don't pad Month 12, because the final state of charge is constrained
    % to equal the original state of charge.
    
    if any(Month_Iter == 1:11)
    
        % Pad Load Profile Data
        Load_Profile_Data_Month_Padded = [Load_Profile_Data_Month;
            Load_Profile_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        % Pad PV Production Profile Data
        Solar_PV_Profile_Data_Month_Padded = [Solar_PV_Profile_Data_Month;
            Solar_PV_Profile_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        % Pad Volumetric Rate Data
        Volumetric_Rate_Data_Month_Padded = [Volumetric_Rate_Data_Month;
            Volumetric_Rate_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        % Pad Marginal Emissions Data
        
        Marginal_Emissions_Rate_Data_Month_Padded = [Marginal_Emissions_Rate_Forecast_Data_Month;
            Marginal_Emissions_Rate_Forecast_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        % Pad Carbon Adder Data
        
        Carbon_Adder_Data_Month_Padded = [Carbon_Adder_Data_Month;
            Carbon_Adder_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        
        
        % Pad Peak and Part-Peak Binary Data
        
        if Summer_Peak_DC > 0
            Summer_Peak_Binary_Data_Month_Padded = [Summer_Peak_Binary_Data_Month;
                Summer_Peak_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
        
        if Summer_Part_Peak_DC > 0
            Summer_Part_Peak_Binary_Data_Month_Padded = [Summer_Part_Peak_Binary_Data_Month;
                Summer_Part_Peak_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
        
        if Winter_Peak_DC > 0
            Winter_Peak_Binary_Data_Month_Padded = [Winter_Peak_Binary_Data_Month;
                Winter_Peak_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
        
        if Winter_Part_Peak_DC > 0
            Winter_Part_Peak_Binary_Data_Month_Padded = [Winter_Part_Peak_Binary_Data_Month;
                Winter_Part_Peak_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
        
        % Pad PG&E-Proposed Charge and Discharge Hour Binary Data
        if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" || ...
                GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints"
            PGE_Charge_Hour_Binary_Data_Month_Padded = [PGE_Charge_Hour_Binary_Data_Month;
                PGE_Charge_Hour_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
            
            PGE_No_Charge_Hour_Binary_Data_Month_Padded = [PGE_No_Charge_Hour_Binary_Data_Month;
                PGE_No_Charge_Hour_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
            
            PGE_Discharge_Hour_Binary_Data_Month_Padded = [PGE_Discharge_Hour_Binary_Data_Month;
                PGE_Discharge_Hour_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
        
        
        % Pad IOU-Proposed Charge and Discharge Hour Binary Data
        if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints"
            IOU_Charge_Hour_Binary_Data_Month_Padded = [IOU_Charge_Hour_Binary_Data_Month;
                IOU_Charge_Hour_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
            
            IOU_Discharge_Hour_Binary_Data_Month_Padded = [IOU_Discharge_Hour_Binary_Data_Month;
                IOU_Discharge_Hour_Binary_Data_Month(end-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1):end)];
        end
    
    elseif Month_Iter == 12
        
        % Don't Pad Load Profile Data
        Load_Profile_Data_Month_Padded = Load_Profile_Data_Month;
        
        % Don't Pad PV Production Profile Data
        Solar_PV_Profile_Data_Month_Padded = Solar_PV_Profile_Data_Month;
        
        % Don't Pad Volumetric Rate Data
        Volumetric_Rate_Data_Month_Padded = Volumetric_Rate_Data_Month;
        
        % Don't Pad Marginal Emissions Data
        
        Marginal_Emissions_Rate_Data_Month_Padded = Marginal_Emissions_Rate_Forecast_Data_Month;
        
        % Don't Pad Carbon Adder Data
        
        Carbon_Adder_Data_Month_Padded = Carbon_Adder_Data_Month;
        
        % Don't Pad Peak and Part-Peak Binary Data
        
        if Summer_Peak_DC > 0
            Summer_Peak_Binary_Data_Month_Padded = Summer_Peak_Binary_Data_Month;
        end
        
        if Summer_Part_Peak_DC > 0
            Summer_Part_Peak_Binary_Data_Month_Padded = Summer_Part_Peak_Binary_Data_Month;
        end
        
        if Winter_Peak_DC > 0
            Winter_Peak_Binary_Data_Month_Padded = Winter_Peak_Binary_Data_Month;
        end
        
        if Winter_Part_Peak_DC > 0
            Winter_Part_Peak_Binary_Data_Month_Padded = Winter_Part_Peak_Binary_Data_Month;
        end
        
        % Don't Pad PG&E-Proposed Charge and Discharge Hour Binary Data
        if GHG_Reduction_Solution_Input == "No-Charging Time Constraint" || ...
                GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints"
            PGE_Charge_Hour_Binary_Data_Month_Padded = PGE_Charge_Hour_Binary_Data_Month;
            
            PGE_No_Charge_Hour_Binary_Data_Month_Padded = PGE_No_Charge_Hour_Binary_Data_Month;
            
            PGE_Discharge_Hour_Binary_Data_Month_Padded = PGE_Discharge_Hour_Binary_Data_Month;
        end
        
        
        % Don't Pad IOU-Proposed Charge and Discharge Hour Binary Data
        if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints"
            IOU_Charge_Hour_Binary_Data_Month_Padded = IOU_Charge_Hour_Binary_Data_Month;
            
            IOU_Discharge_Hour_Binary_Data_Month_Padded = IOU_Discharge_Hour_Binary_Data_Month;
        end
        
    end
    
  
    
    %% Initialize Cost Vector "c"
    
    % nts = numtsteps = number of timesteps
    numtsteps = length(Load_Profile_Data_Month_Padded);
    all_tsteps = linspace(1,numtsteps, numtsteps)';
    
    % x = [P_ES_in_grid(size nts); P_ES_out(size nts); Ene_Lvl(size nts);...
    % P_max_NC (size 1); P_max_peak (size 1); P_max_part_peak (size 1)];
    
    % Even if the system is charging from solar, it still has a relative cost
    % equal to the cost of grid power (Volumetric Rate).
    % This is because every amount of PV power going into the battery is
    % not used to offset load or export to the grid.
    
    c_Month_Bill_Only = [(Volumetric_Rate_Data_Month_Padded * delta_t); ...
        (-Volumetric_Rate_Data_Month_Padded * delta_t); ...
        zeros(numtsteps, 1);
        Noncoincident_DC
        Peak_DC;
        Part_Peak_DC];    
    
    % The same is true of carbon emissions. Every amount of PV power going into the battery is
    % not used at that time to offset emissions from the load or from the grid.
        
    c_Month_Carbon_Only = [(Carbon_Adder_Data_Month_Padded * delta_t); ...
        (-Carbon_Adder_Data_Month_Padded * delta_t); ...
        zeros(numtsteps, 1);
        0
        0;
        0];
    
    c_Month_Degradation_Only = [(((Eff_c * cycle_pen)/(2 * Total_Storage_Capacity)) * delta_t) * ones(numtsteps,1); ...
        ((cycle_pen/(Eff_d * 2 * Total_Storage_Capacity)) * delta_t) * ones(numtsteps,1); ...
        zeros(numtsteps, 1);
        0
        0;
        0];
    
    % c_Month_Solar_Self_Supply is an additional cost term used in the
    % OSESMO Non-Economic Solar Self-Supply dispatch algorithm. This dispatch mode adds
    %  additional cost terms (P_PV(t) - P_ES_in(t)) to be minimized, which
    %  represent all power produced by the PV system that is not stored in the
    %  battery. Because P_PV is not controllable (not a decision variable),
    %  this can be simplified to adding -P_ES_in(t) cost terms to the cost function.
    
    if Storage_Control_Algorithm_Name == "OSESMO Economic Dispatch"
        c_Month_Solar_Self_Supply = [zeros(numtsteps, 1);
            zeros(numtsteps, 1);
            zeros(numtsteps, 1);
            0
            0;
            0];
    
    elseif Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply"
        c_Month_Solar_Self_Supply = [-ones(numtsteps, 1);
            zeros(numtsteps, 1);
            zeros(numtsteps, 1);
            0
            0;
            0];
    
    end
    
    c_Month = c_Month_Bill_Only + c_Month_Carbon_Only + c_Month_Degradation_Only + c_Month_Solar_Self_Supply;
    
    % This is the length of the vectors c and x, or the total number of decision variables.
    length_x = length(c_Month);
    
    
    %% State Variable Indices
    
    % P_ES_in = x(1:numtsteps);
    % P_ES_out = x(numtsteps+1:2*numtsteps);
    % Ene_Lvl = x(2*numtsteps+1:3*numtsteps);
    % P_max_NC = x(3*numtsteps+1);
    % P_max_peak = x(3*numtsteps+2);
    % P_max_part_peak = x(3*numsteps+3);
    
    %% State of Charge Constraint
    
    % This constraint represents conservation of energy as it flows into and out of the
    % energy storage system, while accounting for efficiency losses.
    
    %For t in [0, numsteps-1]:
    
    % E(t+1) = E(t) + [Eff_c*P_ES_in(t) - (1/Eff_d)*P_ES_out(t)] * delta_t
    
    % E(t) - E(t+1) + Eff_c*P_ES_in(t) * delta_t - (1/Eff_d)*P_ES_out(t) * delta_t = 0
    
    % An equality constraint can be transformed into two inequality constraints
    % Ax = 0 -> Ax <=0 , -Ax <=0
    
    % Number of rows in each inequality constraint matrix = (numtsteps - 1)
    % Number of columns in each inequality constraint matrix = number of
    % decision variables = length_x
    
    A_E = sparse(numtsteps-1,length_x);
    b_E = sparse(numtsteps-1,1);
    
    for n = 1:(numtsteps-1)
        A_E(n, n + (2 * numtsteps)) = 1;
        A_E(n, n + (2 * numtsteps) + 1) = -1;
        A_E(n, n) = Eff_c * delta_t;
        A_E(n, n + numtsteps) = (-1/Eff_d) * delta_t;
    end
    
    A_Month = [A_E;-A_E];
    
    b_Month = [b_E;-b_E];
    
    
    
    %% Energy Storage Charging Power Constraint
    
    % This constraint sets maximum and minimum values for P_ES_in.
    % The minimum is 0 kW, and the maximum is Storage_Power_Rating_Input.
    
    % P_ES_in >= 0 -> -P_ES_in <= 0
    
    % P_ES_in <= Storage_Power_Rating_Input
    
    % Number of rows in inequality constraint matrix = numtsteps
    % Number of columns in inequality constraint matrix = length_x
    A_P_ES_in = sparse(numtsteps, length_x);
    
    
    for n = 1:numtsteps
        A_P_ES_in(n, n) = -1;
    end
    
    A_Month = [A_Month; A_P_ES_in; -A_P_ES_in];
    
    b_Month = [b_Month; sparse(numtsteps,1); Storage_Power_Rating_Input * ones(numtsteps,1)];
    
    %% Energy Storage Discharging Power Constraint
    
    % This constraint sets maximum and minimum values for P_ES_out.
    % The minimum is 0 kW, and the maximum is Storage_Power_Rating_Input.
    
    % P_ES_out >= 0 -> -P_ES_out <= 0
    
    % P_ES_out <= Storage_Power_Rating_Input
    
    A_P_ES_out = sparse(numtsteps, length_x);
    
    for n = 1:numtsteps
        A_P_ES_out(n, n + numtsteps) = -1;
    end
    
    A_Month = [A_Month; A_P_ES_out; -A_P_ES_out];
    
    b_Month = [b_Month; sparse(numtsteps,1); Storage_Power_Rating_Input * ones(numtsteps,1)];
    
    %% State of Charge Minimum/Minimum Constraints
    
    % This constraint sets maximum and minimum values on the Energy Level.
    % The minimum value is 0, and the maximum value is Usable_Storage_Capacity, the size of the
    % battery. Note: this optimization defines the range [0, Usable_Storage_Capacity] as the
    % effective storage capacity of the battery, without accounting for
    % depth of discharge.
    
    % Ene_Lvl(t) >= 0 -> -Ene_Lvl(t) <=0
    
    A_Ene_Lvl_min = sparse(numtsteps, length_x);
    b_Ene_Lvl_min = sparse(numtsteps, 1);
    
    for n = 1:numtsteps
        A_Ene_Lvl_min(n, n + (2 * numtsteps)) = -1;
    end
    
    A_Month = [A_Month;A_Ene_Lvl_min];
    b_Month = [b_Month;b_Ene_Lvl_min];
    
    
    % Ene_Lvl(t) <= Size_ES
    
    A_Ene_Lvl_max = sparse(numtsteps, length_x);
    b_Ene_Lvl_max = Usable_Storage_Capacity * ones(numtsteps,1);
    
    for n = 1:numtsteps
        A_Ene_Lvl_max(n, n + (2 * numtsteps)) = 1;
    end
    
    A_Month = [A_Month; A_Ene_Lvl_max];
    
    b_Month = [b_Month; b_Ene_Lvl_max];
    
    %% Initial State of Charge Constraint
    
    % In the first month, this constraint initializes the energy level of the battery at
    % a user-defined percentage of the original battery capacity.
    % In all other month, this constraints initializes the energy level of
    % the battery at the final battery level from the previous month.
    
    % E(0) = Initial_Final_SOC * Usable_Storage_Capacity_Input
    % E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(0) <= Initial_Final_SOC * Usable_Storage_Capacity_Input
    
    % E(0) = Previous_Month_Final_Energy_Level
    % E(0) <= Previous_Month_Final_Energy_Level, -E(0) <= Previous_Month_Final_Energy_Level  
    
    
    A_Ene_Lvl_0 = sparse(1, length_x);
    
    A_Ene_Lvl_0(1, (2*numtsteps) + 1) = 1;
    
    if Month_Iter == 1
        
        b_Ene_Lvl_0 = Initial_Final_SOC * Usable_Storage_Capacity_Input;
        
    elseif any(Month_Iter == 2:12)
        
        b_Ene_Lvl_0 = Previous_Month_Final_Energy_Level;
        
    end
    
    A_Month = [A_Month; A_Ene_Lvl_0; -A_Ene_Lvl_0];
    
    b_Month = [b_Month; b_Ene_Lvl_0; -b_Ene_Lvl_0];
    
    %% Final State of Charge Constraints
    
    % This constraint fixes the final state of charge of the battery at a user-defined percentage
    % of the original battery capacity,
    % to prevent it from discharging completely in the final timesteps.
    
    % E(N) = Initial_Final_SOC * Usable_Storage_Capacity_Input
    % E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input, -E(N) <= Initial_Final_SOC * Usable_Storage_Capacity_Input
    
    A_Ene_Lvl_N = sparse(1, length_x);
    
    A_Ene_Lvl_N(1, 3 * numtsteps) = 1;
    
    b_Ene_Lvl_N = Initial_Final_SOC * Usable_Storage_Capacity_Input;
    
    A_Month = [A_Month; A_Ene_Lvl_N; -A_Ene_Lvl_N];
    
    b_Month = [b_Month; b_Ene_Lvl_N; -b_Ene_Lvl_N];
    
    
    %% Noncoincident Demand Charge Constraint
    
    % This constraint linearizes the noncoincident demand charge constraint.
    % Setting the demand charge value as a decision variable incentivizes
    % "demand capping" to reduce the value of max(P_load(t)) to an optimal
    % level without using the nonlinear max() operator.
    % The noncoincident demand charge applies across all 15-minute intervals.
    
    % P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_NC for all t
    % P_ES_in(t) - P_ES_out(t) - P_max_NC <= - P_load(t) + P_PV(t) for all t
    
    if Noncoincident_DC > 0
        
        A_NC_DC = sparse(numtsteps, length_x);
        b_NC_DC = -Load_Profile_Data_Month_Padded + Solar_PV_Profile_Data_Month_Padded;
        
        for n = 1:numtsteps
            A_NC_DC(n, n) = 1;
            A_NC_DC(n, n + numtsteps) = -1;
            A_NC_DC(n, (3*numtsteps) + 1) = -1;
            
        end
        
        A_Month = [A_Month; A_NC_DC];
        b_Month = [b_Month; b_NC_DC];
        
    end
    
    % Add P_max_NC >=0 Constraint
    % -P_max_NC <= 0
    % Note: this non-negativity constraint is added even if the noncoincident
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_NC goes to zero, and is not negative.
    
    A_NC_DC_gt0 = sparse(1, length_x);
    A_NC_DC_gt0(1, (3 * numtsteps) + 1) = -1;
    b_NC_DC_gt0 = 0;
    
    A_Month = [A_Month; A_NC_DC_gt0];
    b_Month = [b_Month; b_NC_DC_gt0];
    
    
    %% Coincident Peak Demand Charge Constraint
    
    % This constraint linearizes the coincident peak demand charge constraint.
    % This demand charge only applies for peak hours.
    
    % P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_peak for Peak t only
    % P_ES_in(t) - P_ES_out(t) - P_max_peak <= - P_load(t) + P_PV(t) for Peak t only
    
    if Peak_DC > 0
        
        if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
            Peak_Indices = all_tsteps(Summer_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPK_DC = sparse(sum(Summer_Peak_Binary_Data_Month_Padded), length_x);
            b_CPK_DC = -Load_Profile_Data_Month_Padded(Summer_Peak_Binary_Data_Month_Padded == 1, :) + ...
                Solar_PV_Profile_Data_Month_Padded(Summer_Peak_Binary_Data_Month_Padded == 1, :);
        else
            Peak_Indices = all_tsteps(Winter_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPK_DC = sparse(sum(Winter_Peak_Binary_Data_Month_Padded), length_x);
            b_CPK_DC = -Load_Profile_Data_Month_Padded(Winter_Peak_Binary_Data_Month_Padded == 1, :) + ...
                Solar_PV_Profile_Data_Month_Padded(Winter_Peak_Binary_Data_Month_Padded == 1, :);
        end
        
        for n = 1:length(Peak_Indices)
            A_CPK_DC(n, Peak_Indices(n)) = 1;
            A_CPK_DC(n, numtsteps + Peak_Indices(n)) = -1;
            A_CPK_DC(n, (3*numtsteps) + 2) = -1;
        end
        
        A_Month = [A_Month; A_CPK_DC];
        b_Month = [b_Month; b_CPK_DC];
        
    end
    
    
    % Add P_max_peak >=0 Constraint
    % -P_max_peak <= 0
    % Note: this non-negativity constraint is added even if the coincident peak
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_peak goes to zero, and is not negative.
    
    A_CPK_DC_gt0 = sparse(1, length_x);
    A_CPK_DC_gt0(1, (3 * numtsteps) + 2) = -1;
    b_CPK_DC_gt0 = 0;
    
    A_Month = [A_Month; A_CPK_DC_gt0];
    b_Month = [b_Month; b_CPK_DC_gt0];
    
    
    %% Coincident Part-Peak Demand Charge Constraint
    
    % This constraint linearizes the coincident part-peak demand charge
    % constraint.
    % This demand charge only applies for part-peak hours.
    
    % P_load(t) - P_PV(t) + P_ES_in(t) - P_ES_out(t) <= P_max_part_peak for Part-Peak t only
    % P_ES_in(t) - P_ES_out(t) - P_max_part_peak <= - P_load(t) + P_PV(t) for Part-Peak t only
    
    if Part_Peak_DC > 0
        
        if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
            Part_Peak_Indices = all_tsteps(Summer_Part_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPP_DC = sparse(sum(Summer_Part_Peak_Binary_Data_Month_Padded), length_x);
            b_CPP_DC = -Load_Profile_Data_Month_Padded(Summer_Part_Peak_Binary_Data_Month_Padded == 1, :) + ...
                Solar_PV_Profile_Data_Month_Padded(Summer_Part_Peak_Binary_Data_Month_Padded == 1, :);      
        else
            Part_Peak_Indices = all_tsteps(Winter_Part_Peak_Binary_Data_Month_Padded == 1, :);
            A_CPP_DC = sparse(sum(Winter_Part_Peak_Binary_Data_Month_Padded), length_x);
            b_CPP_DC = -Load_Profile_Data_Month_Padded(Winter_Part_Peak_Binary_Data_Month_Padded == 1, :) + ...
                Solar_PV_Profile_Data_Month_Padded(Winter_Part_Peak_Binary_Data_Month_Padded == 1, :);
        end
        
        for n = 1:length(Part_Peak_Indices)
            A_CPP_DC(n, Part_Peak_Indices(n)) = 1;
            A_CPP_DC(n, numtsteps + Part_Peak_Indices(n)) = -1;
            A_CPP_DC(n, (3*numtsteps) + 3) = -1;
        end
        
        A_Month = [A_Month; A_CPP_DC];
        b_Month = [b_Month; b_CPP_DC];
        
        
    end
    
    % Add P_max_part_peak >=0 Constraint
    % -P_max_part_peak <= 0
    % Note: this non-negativity constraint is added even if the coincident part-peak
    % demand charge is $0/kW for this tariff. This ensures that the
    % decision variable P_max_part_peak goes to zero, and is not negative.
    
    A_CPP_DC_gt0 = sparse(1, length_x);
    A_CPP_DC_gt0(1, (3 * numtsteps) + 3) = -1;
    b_CPP_DC_gt0 = 0;
    
    A_Month = [A_Month; A_CPP_DC_gt0];
    b_Month = [b_Month; b_CPP_DC_gt0];
    
    
%% Optional Constraint - Solar ITC Charging Constraint
    
    % This constraint requires that the storage system be charged 100% from
    % solar. This ensures that the customer receives 100% of the 
    % solar Incentive Tax Credit. The ITC amount is prorated by the amount 
    % of energy entering into the battery that comes from solar 
    % (ex. a storage system charged 90% from solar receives 90% of the ITC). 
    % As a result, the optimal amount of solar charging is likely higher
    % than the minimum requirement of 75%, and likely very close to 100%.

    % P_ES_in(t) <= P_PV(t)
    
    % Note that P_PV(t) can sometimes be negative for some PV profiles, if
    % the solar inverter is consuming energy at night. As a result, P_PV(t)
    % here refers to a modified version of the solar profile where all
    % negative values are set to 0. Otherwise, the model would break
    % because P_ES_in must be >= 0, and can't also be <= P_PV(t) if P_PV(t)
    % <= 0.
       
    
    if Model_Type_Input == "Solar Plus Storage" && Solar_Profile_Name_Input ~= "No Solar" && ...
            Solar_Size_Input > 0 && ITC_Constraint_Input == 1
        
        Solar_PV_Profile_Data_Month_Padded_Nonnegative = Solar_PV_Profile_Data_Month_Padded;
        Solar_PV_Profile_Data_Month_Padded_Nonnegative(Solar_PV_Profile_Data_Month_Padded_Nonnegative<0) = 0;
        
        A_ITC = sparse(numtsteps, length_x);
        b_ITC = Solar_PV_Profile_Data_Month_Padded_Nonnegative;
        
        for n = 1:numtsteps
            A_ITC(n, n) = 1;
        end
        
        A_Month = [A_Month; A_ITC];
        b_Month = [b_Month; b_ITC];
        
    end
    
    
    %% Optional Constraint - No-Charging Time Constraint
    
    if GHG_Reduction_Solution_Input == "No-Charging Time Constraint"
        
        % PG&E has suggested a set of time-based constraints on storage charging.
        % One of these constraints is that storage would not be allowed to discharge between 4:00 pm and 9:00 pm.
        
        % No-Charging Constraint
        % Charging power in each timestep is set equal to 0 between 4:00 pm and 9:00 pm.
        % Because charging power is constrained to be greater than
        % zero, setting the sum of all charging power timesteps to 0 (a
        % single constraint across all timesteps) ensures that all values will be zero
        % without needing to set a constraint for each timestep.
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00 = 0
        % Because of nonnegative constraint on P_ES_in(t), this is
        % equivalent to a set of numtsteps constraints stating that
        % all P_ES_in(t) between 4:00 and 9:00 = 0 for each timestep.
        
        A_PGE_No_Charge = sparse(1, length_x);
        PGE_No_Charge_Hour_Indices = all_tsteps(PGE_No_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00
        A_PGE_No_Charge(1, PGE_No_Charge_Hour_Indices) = 1;
        
        b_PGE_No_Charge = 0;
        
        A_Month = [A_Month; A_PGE_No_Charge];
        b_Month = [b_Month; b_PGE_No_Charge];       
        
    end  
    
    %% Optional Constraint - Charging and Discharging Time Constraints
    
    if GHG_Reduction_Solution_Input == "Charging and Discharging Time Constraints"
        
        % PG&E has suggested a set of time-based constraints on storage charging.
        % At least 50% of total charging would need to occur between 9:00 am and 2:00 pm,
        % and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.
        % In addition, storage would not be allowed to discharge between 4:00 pm and 9:00 pm.
        
        % Derivation of charging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_in(t) between 9:00 and 2:00/sum of all P_ES_in(t) >= 0.5
        % Sum of all P_ES_in(t) between 9:00 and 2:00 >= 0.5 * sum of all P_ES_in(t)
        % 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00
        % 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 9:00 and 2:00 <= 0
        % 0.5 * sum of all P_ES_in(t) not between 9:00 and 2:00 - 0.5 * sum of all P_ES_in(t)
        % between 9:00 and 2:00 <= 0.
        
        % Charging Constraint
        A_PGE_Charge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_in(t)
        A_PGE_Charge(1, 1:numtsteps) = 0.5;
        PGE_Charge_Hour_Indices = all_tsteps(PGE_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
        A_PGE_Charge(1, PGE_Charge_Hour_Indices) = -0.5;
        
        b_PGE_Charge = 0;
        
        A_Month = [A_Month; A_PGE_Charge];
        b_Month = [b_Month; b_PGE_Charge];
        
        
        % No-Charging Constraint
        % Charging power in each timestep is set equal to 0 between 4:00 pm and 9:00 pm.
        % Because charging power is constrained to be greater than
        % zero, setting the sum of all charging power timesteps to 0 (a
        % single constraint across all timesteps) ensures that all values will be zero
        % without needing to set a constraint for each timestep.
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00 = 0
        % Because of nonnegative constraint on P_ES_in(t), this is
        % equivalent to a set of numtsteps constraints stating that
        % all P_ES_in(t) between 4:00 and 9:00 = 0 for each timestep.
        
        A_PGE_No_Charge = sparse(1, length_x);
        PGE_No_Charge_Hour_Indices = all_tsteps(PGE_No_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % Sum of all P_ES_in(t) between 4:00 and 9:00
        A_PGE_No_Charge(1, PGE_No_Charge_Hour_Indices) = 1;
        
        b_PGE_No_Charge = 0;
        
        A_Month = [A_Month; A_PGE_No_Charge];
        b_Month = [b_Month; b_PGE_No_Charge];
        
        
        % Derivation of discharging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
        % Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
        % 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
        % 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
        % 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
        % between 4:00 and 9:00 <= 0.
        
        % Discharging Constraint
        A_PGE_Discharge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_out(t)
        A_PGE_Discharge(1, numtsteps+1:2*numtsteps) = 0.5;
        PGE_Discharge_Hour_Indices = all_tsteps(PGE_Discharge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
        A_PGE_Discharge(1, numtsteps + PGE_Discharge_Hour_Indices) = -0.5;
        
        b_PGE_Discharge = 0;
        
        A_Month = [A_Month; A_PGE_Discharge];
        b_Month = [b_Month; b_PGE_Discharge];
        
    end
    
    
    %% Optional Constraint - Investor-Owned-Utility-Proposed Charge-Discharge Hours
    
    if GHG_Reduction_Solution_Input == "IOU-Proposed Charge-Discharge Time Constraints"
        
        % The Investor-Owned Utilities have suggested constraints on charging in particular hours
        % as a proposed method for reducing greenhouse gas emissions associated with storage dispatch.
        % Specifically, at least 50% of total charging would need to occur between 12:00 noon and 4:00 pm,
        % and at least 50% of total discharging would need to occur between 4:00 pm and 9:00 pm.
        
        % Derivation of charging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_in(t) between 12:00 and 4:00/sum of all P_ES_in(t) >= 0.5
        % Sum of all P_ES_in(t) between 12:00 and 4:00 >= 0.5 * sum of all P_ES_in(t)
        % 0 >= 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00
        % 0.5 * sum of all P_ES_in(t) - sum of all P_ES_in(t) between 12:00 and 4:00 <= 0
        % 0.5 * sum of all P_ES_in(t) not between 12:00 and 4:00 - 0.5 * sum of all P_ES_in(t)
        % between 12:00 and 4:00 <= 0.
        
        % Charging Constraint
        A_IOU_Charge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_in(t)
        A_IOU_Charge(1, 1:numtsteps) = 0.5;
        IOU_Charge_Hour_Indices = all_tsteps(IOU_Charge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_in(t) between 12:00 and 4:00
        A_IOU_Charge(1, IOU_Charge_Hour_Indices) = -0.5;
        
        b_IOU_Charge = 0;
        
        A_Month = [A_Month; A_IOU_Charge];
        b_Month = [b_Month; b_IOU_Charge];
        
        % Derivation of discharging constraint in standard linear form Ax <= 0:
        % Sum of all P_ES_out(t) between 4:00 and 9:00/sum of all P_ES_out(t) >= 0.5
        % Sum of all P_ES_out(t) between 4:00 and 9:00 >= 0.5 * sum of all P_ES_out(t)
        % 0 >= 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00
        % 0.5 * sum of all P_ES_out(t) - sum of all P_ES_out(t) between 4:00 and 9:00 <= 0
        % 0.5 * sum of all P_ES_out(t) not between 4:00 and 9:00 - 0.5 * sum of all P_ES_out(t)
        % between 4:00 and 9:00 <= 0.
        
        % Discharging Constraint
        A_IOU_Discharge = sparse(1, length_x);
        
        % 0.5 * sum of all P_ES_out(t)
        A_IOU_Discharge(1, numtsteps+1:2*numtsteps) = 0.5;
        IOU_Discharge_Hour_Indices = all_tsteps(IOU_Discharge_Hour_Binary_Data_Month_Padded == 1, :);
        
        % -0.5 * sum of all P_ES_out(t) between 12:00 and 4:00
        A_IOU_Discharge(1, numtsteps + IOU_Discharge_Hour_Indices) = -0.5;
        
        b_IOU_Discharge = 0;
        
        A_Month = [A_Month; A_IOU_Discharge];
        b_Month = [b_Month; b_IOU_Discharge];
        
    end
       
    
    %% Optional Constraint - Non-Positive GHG Emissions Impact
    
    % Note - the system is following the forecast signal to obey
    % this constraint, not the evaluation signal. It may be necessary
    % to adjust this constraint to aim for a negative GHG impact
    % based on the forecast signal, in order to achieve a non-positive
    % GHG impact as measured by the evaluation signal.
    
    if GHG_Reduction_Solution_Input == "Non-Positive GHG Constraint"
        
        % The sum of the net battery charge/discharge load in each
        % timestep, multiplied by the marginal emissions rate in each
        % timestep, must be less than or equal to 0.
        
        % A_Non_Positive_GHG is similar to c_Month_Carbon_Only,
        % but with Marginal Emissions Rate Data instead of Carbon Adder Data and transposed.
        A_Non_Positive_GHG = [(Marginal_Emissions_Rate_Data_Month_Padded * delta_t); ...
            (-Marginal_Emissions_Rate_Data_Month_Padded * delta_t); ...
            zeros(numtsteps, 1);
            0
            0;
            0]';
        
        b_Non_Positive_GHG = 0;
        
        A_Month = [A_Month; A_Non_Positive_GHG];
        b_Month = [b_Month; b_Non_Positive_GHG];
        
        
    end
    
    
    %% Optional Constraint - Equivalent Cycling Constraint
    
    % Note: due to the OSESMO model structure, the annual cycling requirement 
    % must be converted to an equivalent monthly cycling requirement.
    
    if Equivalent_Cycling_Constraint_Input > 0
           
        SGIP_Monthly_Cycling_Requirement = Equivalent_Cycling_Constraint_Input * ...
            (length(Load_Profile_Data_Month_Padded)/length(Load_Profile_Data));
        
        % Formula for equivalent cycles is identical to the one used to calculate Cycles_Month:
        % Equivalent Cycles = sum((P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)) + ...
        %    (P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)));
        
        % Equivalent Cycles >= SGIP_Monthly_Cycling Requirement
        % To convert to standard linear program form, multiply both sides by -1.
        % -Equivalent Cycles <= -SGIP_Monthly_Cycling_Requirement
        
        A_Equivalent_Cycles = sparse(1, length_x);
        
        % sum of all P_ES_in(t) * (((Eff_c)/(2 * Size_ES)) * delta_t)
        A_Equivalent_Cycles(1, 1:numtsteps) = -(((Eff_c)/(2 * Total_Storage_Capacity)) * delta_t);
        
        % sum of all P_ES_out(t) * ((1/(Eff_d * 2 * Size_ES)) * delta_t)
        A_Equivalent_Cycles(1, numtsteps+1:2*numtsteps) = -((1/(Eff_d * 2 * Total_Storage_Capacity)) * delta_t);
        
        b_Equivalent_Cycles = -SGIP_Monthly_Cycling_Requirement;
        
        A_Month = [A_Month; A_Equivalent_Cycles];
        b_Month = [b_Month; b_Equivalent_Cycles];
    
    end
    
    
    %% Optional Constraint - Operational/SGIP Round-Trip Efficiency Constraint
    
    % Note: due to the OSESMO model structure, the annual RTE requirement 
    % must be converted to an equivalent monthly RTE requirement.
    
    if Annual_RTE_Constraint_Input > 0
        
        % If it's impossible for the storage system to achieve the RTE requirement
        % even if it were constantly cycling, stop the model.
        
        if (Eff_c * Eff_d * Storage_Power_Rating_Input)/(Storage_Power_Rating_Input + Parasitic_Storage_Load) < Annual_RTE_Constraint_Input
            
            error(['No solution - could not achieve SGIP RTE requirement' ...
                ' with the provided nameplate efficiency and auxiliary storage load values.'])
        end
        
       % Formula for Annual Operational/SGIP round-trip efficiency is identical to the one
       % used to calculate Operational_RTE_Percent:
       % Operational_RTE_Percent = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t);
       % Note that Auxiliary_Storage_Load has to be added to P_ES_in here.
       % During the calculation of Operational_RTE_Percent, it has already
       % been added previously, so it does not need to be included in the
       % formula the way it is here.
       
       % "The Commission concluded that storage devices should demonstrate
       % an average RTE of at least 66.5% over ten years (equivalent to a
       % first-year RTE of 69.6%) in order to qualify for SGIP incentive
       % payments." (Stem, Inc.'s Petition for Modification of Decision 15-11-027, pg. 2)
       
       % Operational RTE Percent >= 0.696
       % (sum(P_ES_out) * delta_t)/((sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t) >= 0.696
       % (sum(P_ES_out) * delta_t) >= 0.696 * (sum(P_ES_in) * delta_t) + (sum(Auxiliary_Storage_Load) * delta_t)
       % To convert to standard linear program form, multiply both sides by -1.
       % -(sum(P_ES_out) * delta_t) <= -0.696 * (sum(P_ES_in) * delta_t) -(sum(Auxiliary_Storage_Load) * delta_t)
       % -(sum(P_ES_out) * delta_t) + 0.696 * (sum(P_ES_in) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)
       % 0.696 * (sum(P_ES_in) * delta_t) -(sum(P_ES_out) * delta_t) <= -(sum(Auxiliary_Storage_Load) * delta_t)
                    
       A_SGIP_RTE = sparse(1, length_x);
       
       % sum of all (P_ES_in(t) * (0.696 * delta_t)
       A_SGIP_RTE(1, 1:numtsteps) = (Annual_RTE_Constraint_Input * delta_t);
       
       % sum of all P_ES_out(t) * -delta_t
       A_SGIP_RTE(1, numtsteps+1:2*numtsteps) = -delta_t;
       
       % (sum(Auxiliary_Storage_Load) * delta_t)
       b_SGIP_RTE = -((numtsteps * Parasitic_Storage_Load) * delta_t);
       
       A_Month = [A_Month; A_SGIP_RTE];
       b_Month = [b_Month; b_SGIP_RTE];
       
    end
    
    %% Optional Constraint - No-Export Constraint
    
    % This constraint prevents the standalone energy-storage systems from
    % backfeeding power from the storage system onto the distribution grid.
    % Solar-plus storage systems are allowed to export to the grid.
    
    if Model_Type_Input == "Storage Only"
        
        % P_load(t) + P_ES_in(t) - P_ES_out(t) >= 0
        % -P_ES_in(t) + P_ES_out(t) <= P_load(t)
        
        A_No_Export = sparse(numtsteps, length_x);
        b_No_Export = Load_Profile_Data_Month_Padded;
        
        for n = 1:numtsteps
            A_No_Export(n, n) = -1;
            A_No_Export(n, n + numtsteps) = 1;
        end
        
        A_Month = [A_Month; A_No_Export];
        b_Month = [b_Month; b_No_Export];
        
    end
       
    
    %% Optional Constraint - Solar Self-Supply
    
    % In the Economic Dispatch mode, this constraint is not necessary -
    % the presence of a positive cost on battery charging ensures that
    % simultaneous charging and discharging does not occur.
    % However, in the Non-Economic Solar Self-Consumption, which negative
    % costs on both charging and discharging, the battery charges and
    % discharges simultaneously so as to minimize total cost.
    % This constraint ensures that simultaneous charging and
    % discharging does not occur, and ensures that the storage system
    % only charges when there is excess solar power (net load is negative)
    % and discharges when net load is positive.
    
    if Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply"

        % P_ES_in <= Non-negative(P_PV - P_Load)
        
        Excess_Solar_Profile_Data_Month_Padded = Solar_PV_Profile_Data_Month_Padded - Load_Profile_Data_Month_Padded;
        Excess_Solar_Profile_Data_Month_Padded(Excess_Solar_Profile_Data_Month_Padded < 0) = 0;
        
        A_Self_Supply_Charge = sparse(numtsteps, length_x);
        b_Self_Supply_Charge = Excess_Solar_Profile_Data_Month_Padded;
        
        for n = 1:numtsteps
            A_Self_Supply_Charge(n, n) = 1;
        end
        
        A_Month = [A_Month; A_Self_Supply_Charge];
        b_Month = [b_Month; b_Self_Supply_Charge];
        
        
        % P_ES_out <= Non-negative(P_Load - P_PV)
        
        Non_Negative_Net_Load_Profile_Data_Month_Padded = Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded;
        Non_Negative_Net_Load_Profile_Data_Month_Padded(Non_Negative_Net_Load_Profile_Data_Month_Padded < 0) = 0;
        
        A_Self_Supply_Discharge = sparse(numtsteps, length_x);
        b_Self_Supply_Discharge = Non_Negative_Net_Load_Profile_Data_Month_Padded;
        
        for n = 1:numtsteps
            A_Self_Supply_Discharge(n, n + numtsteps) = 1;
        end
        
        A_Month = [A_Month; A_Self_Supply_Discharge];
        b_Month = [b_Month; b_Self_Supply_Discharge];
        
    end
    
    
    %% Run LP Optimization Algorithm
    
    options = optimset('Display','none'); % Suppress "Optimal solution found" message.
    
    x_Month = linprog(c_Month,A_Month,b_Month, [], [], [], [], options); % Set Aeq, beq, LB, UB to []
    
    sprintf('Optimization complete for Month %d.', Month_Iter)
    
    %% Separate Decision Variable Vectors
    
    P_ES_in_Month_Padded = x_Month(1:numtsteps);
    
    P_ES_out_Month_Padded = x_Month(numtsteps+1:2*numtsteps);
    
    Ene_Lvl_Month_Padded = x_Month(2*numtsteps+1:3*numtsteps);
    
    
    %% Add Auxiliary Load/Parasitic Losses to P_ES_in
    
    P_ES_in_Month_Padded = P_ES_in_Month_Padded + Parasitic_Storage_Load;
    
    
    %% Remove "Padding" from Decision Variables
    
    % Data is padded in Months 1-11, and not in Month 12
    
    if any(Month_Iter == 1:11)
    
    P_ES_in_Month_Unpadded = P_ES_in_Month_Padded(1:(end-(End_of_Month_Padding_Days * 24 * (1/delta_t))));
    
    P_ES_out_Month_Unpadded = P_ES_out_Month_Padded(1:(end-(End_of_Month_Padding_Days * 24 * (1/delta_t))));
    
    Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded(1:(end-(End_of_Month_Padding_Days * 24 * (1/delta_t))));
    
    elseif Month_Iter == 12
        
        P_ES_in_Month_Unpadded = P_ES_in_Month_Padded;
        
        P_ES_out_Month_Unpadded = P_ES_out_Month_Padded;
        
        Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded;
        
    end
    
    % Save Final Energy Level of Battery for use in next month
    
    Previous_Month_Final_Energy_Level = Ene_Lvl_Month_Unpadded(length(Ene_Lvl_Month_Unpadded));
    
    
    %% Calculate Monthly Peak Demand Using 15-Minute Intervals
    
    % Demand Charges are Based on 15-minute interval periods.
    % If the model has 15-minute timestep resolution, the decision
    % variables can be used directly as maximum coincident and noncoincident demand values.
    % Otherwise (such as with 5-minute timestep resolution), maximum
    % demand must be calculated by taking 15-minute averages of the
    % demand values, and then calculating the maximum of these averages.
    
    if delta_t < (15/60)
        
        % Noncoincident Maximum Demand With and Without Solar and Storage
             
        % Create Net Load Profile After Solar Only
        Solar_Only_Net_Load_Profile_Data_Month_5_Min = (Load_Profile_Data_Month - Solar_PV_Profile_Data_Month);
                
        % Create Net Load Profile After Solar and Storage
        Solar_Storage_Net_Load_Profile_Data_Month_5_Min = (Load_Profile_Data_Month - Solar_PV_Profile_Data_Month + ...
            P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded);
        
        % Number of timesteps to average to get 15-minute net load data.
        Reshaped_Rows_Num = (15/60)/delta_t;
        
        % Reshape load data so that each 15-minute increment's data
        % is in the same column. This creates an array with 3 rows for 5-minute data.
        Load_Profile_Data_Month_Reshaped = reshape(Load_Profile_Data_Month, Reshaped_Rows_Num, ...
            length(Load_Profile_Data_Month)/Reshaped_Rows_Num);
        
        Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = reshape(Solar_Only_Net_Load_Profile_Data_Month_5_Min, ...
            Reshaped_Rows_Num, length(Solar_Only_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);        
        
        Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = reshape(Solar_Storage_Net_Load_Profile_Data_Month_5_Min, ...
            Reshaped_Rows_Num, length(Solar_Storage_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
        
        % Create 15-minute load profiles by calculating the average of each column.
        Load_Profile_Data_Month_15_Min = mean(Load_Profile_Data_Month_Reshaped, 1);
        Solar_Only_Net_Load_Profile_Data_Month_15_Min = mean(Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);        
        Solar_Storage_Net_Load_Profile_Data_Month_15_Min = mean(Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
        
        % Calculate Noncoincident Maximum Demand
        P_max_NC_Month_Baseline = max(Load_Profile_Data_Month_15_Min);
        P_max_NC_Month_with_Solar_Only = max(Solar_Only_Net_Load_Profile_Data_Month_15_Min);
        P_max_NC_Month_with_Solar_and_Storage = max(Solar_Storage_Net_Load_Profile_Data_Month_15_Min);
               
        
        % Coincident Peak Demand With and Without Storage
        
        if Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                
                % Create Coincident Peak Load and Net Load Profiles
                CPK_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :);

                CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Only_Net_Load_Profile_Data_Month_5_Min(Summer_Peak_Binary_Data_Month == 1, :);
                
                CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Storage_Net_Load_Profile_Data_Month_5_Min(Summer_Peak_Binary_Data_Month == 1, :);
                
            else
                
                % Create Coincident Peak Load and Net Load Profiles
                CPK_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :);

                CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Only_Net_Load_Profile_Data_Month_5_Min(Winter_Peak_Binary_Data_Month == 1, :);
                
                CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Storage_Net_Load_Profile_Data_Month_5_Min(Winter_Peak_Binary_Data_Month == 1, :);
                
            end
            
            % Reshape load data so that each 15-minute increment's data
            % is in the same column. This creates an array with 3 rows for 5-minute data.
            CPK_Load_Profile_Data_Month_Reshaped = ...
                reshape(CPK_Load_Profile_Data_Month, Reshaped_Rows_Num, ...
                length(CPK_Load_Profile_Data_Month)/Reshaped_Rows_Num);

            CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            % Create 15-minute load profiles by calculating the average of each column.
            CPK_Load_Profile_Data_Month_15_Min = ...
                mean(CPK_Load_Profile_Data_Month_Reshaped, 1);

            CPK_Solar_Only_Net_Load_Profile_Data_Month_15_Min = ...
                mean(CPK_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            CPK_Solar_Storage_Net_Load_Profile_Data_Month_15_Min = ...
                mean(CPK_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            % Calculate Coincident Peak Demand
            P_max_CPK_Month_Baseline = max(CPK_Load_Profile_Data_Month_15_Min);
            P_max_CPK_Month_with_Solar_Only = max(CPK_Solar_Only_Net_Load_Profile_Data_Month_15_Min);
            P_max_CPK_Month_with_Solar_and_Storage = max(CPK_Solar_Storage_Net_Load_Profile_Data_Month_15_Min);
            
        else
            
            % If there is no Coincident Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
            P_max_CPK_Month_Baseline = 0;
            P_max_CPK_Month_with_Solar_Only = 0;
            P_max_CPK_Month_with_Solar_and_Storage = 0;
            
        end
        
        
        % Coincident Part-Peak Demand With and Without Storage
        
        if Part_Peak_DC > 0
        
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                
                % Create Coincident Part-Peak Load and Net Load Profiles
                CPP_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :);

                CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Only_Net_Load_Profile_Data_Month_5_Min(Summer_Part_Peak_Binary_Data_Month == 1, :);
                
                CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Storage_Net_Load_Profile_Data_Month_5_Min(Summer_Part_Peak_Binary_Data_Month == 1, :);
                
            else
                
                % Create Coincident Part-Peak Load and Net Load Profiles
                CPP_Load_Profile_Data_Month = ...
                    Load_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :);

                CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Only_Net_Load_Profile_Data_Month_5_Min(Winter_Part_Peak_Binary_Data_Month == 1, :);
                
                CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min = ...
                    Solar_Storage_Net_Load_Profile_Data_Month_5_Min(Winter_Part_Peak_Binary_Data_Month == 1, :);
                
            end
            
            % Reshape load data so that each 15-minute increment's data
            % is in the same column. This creates an array with 3 rows for 5-minute data.
            Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped = ...
                reshape(CPP_Load_Profile_Data_Month, Reshaped_Rows_Num, ...
                length(CPP_Load_Profile_Data_Month)/Reshaped_Rows_Num);

            CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped = ...
                reshape(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min, Reshaped_Rows_Num, ...
                length(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min)/Reshaped_Rows_Num);
            
            % Create 15-minute load profiles by calculating the average of each column.
            CPP_Load_Profile_Data_Month_15_Min = ...
                mean(Coincident_Part_Peak_Load_Profile_Data_Month_Reshaped, 1);

            CPP_Solar_Only_Net_Load_Profile_Data_Month_15_Min = ...
                mean(CPP_Solar_Only_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            CPP_Solar_Storage_Net_Load_Profile_Data_Month_15_Min = ...
                mean(CPP_Solar_Storage_Net_Load_Profile_Data_Month_5_Min_Reshaped, 1);
            
            % Calculate Coincident Part-Peak Demand
            P_max_CPP_Month_Baseline = max(CPP_Load_Profile_Data_Month_15_Min);
            P_max_CPP_Month_with_Solar_Only = max(CPP_Solar_Only_Net_Load_Profile_Data_Month_15_Min);
            P_max_CPP_Month_with_Solar_and_Storage = max(CPP_Solar_Storage_Net_Load_Profile_Data_Month_15_Min);
        
        else
            
            % If there is no Coincident Part-Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
            P_max_CPP_Month_Baseline = 0;
            P_max_CPP_Month_with_Solar_Only = 0;
            P_max_CPP_Month_with_Solar_and_Storage = 0;
            
        end
        
        
    elseif delta_t == (15/60)
        
        % Noncoincident Maximum Demand With and Without Storage
        
        P_max_NC_Month_Baseline = max(Load_Profile_Data_Month);
        P_max_NC_Month_with_Solar_Only = max(Load_Profile_Data_Month - Solar_PV_Profile_Data_Month);
        P_max_NC_Month_with_Solar_and_Storage = x_Month(3*numtsteps+1);
        
        
        % Coincident Peak Demand With and Without Storage
        
        if Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                P_max_CPK_Month_Baseline = max(Load_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :));
                
                P_max_CPK_Month_with_Solar_Only = max(Load_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :) - ...
                                                      Solar_PV_Profile_Data_Month(Summer_Peak_Binary_Data_Month == 1, :));
                
            else
                P_max_CPK_Month_Baseline = max(Load_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :));
                
                P_max_CPK_Month_with_Solar_Only = max(Load_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :) - ...
                                                      Solar_PV_Profile_Data_Month(Winter_Peak_Binary_Data_Month == 1, :));
            end
            
            P_max_CPK_Month_with_Solar_and_Storage = x_Month(3*numtsteps+2);
            
        else
            
            % If there is no Coincident Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
            P_max_CPK_Month_Baseline = 0;
            P_max_CPK_Month_with_Solar_Only = 0;
            P_max_CPK_Month_with_Solar_and_Storage = 0;
            
        end
        
        
        % Coincident Part-Peak Demand With and Without Storage
        
        if Part_Peak_DC > 0
            
            if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
                P_max_CPP_Month_Baseline = max(Load_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :));
                
                P_max_CPP_Month_with_Solar_Only = max(Load_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :) - ...
                                                      Solar_PV_Profile_Data_Month(Summer_Part_Peak_Binary_Data_Month == 1, :));
                
            else
                P_max_CPP_Month_Baseline = max(Load_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :));
                
                P_max_CPP_Month_with_Solar_Only = max(Load_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :) - ...
                                                      Solar_PV_Profile_Data_Month(Winter_Part_Peak_Binary_Data_Month == 1, :));
            end
            
            P_max_CPP_Month_with_Solar_and_Storage = x_Month(3*numtsteps+3);
            
        else
            
            % If there is no Coincident Part-Peak Demand Period (or if the
            % corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
            P_max_CPP_Month_Baseline = 0;
            P_max_CPP_Month_with_Solar_Only = 0;
            P_max_CPP_Month_with_Solar_and_Storage = 0;
            
        end
        
        
    else
        
        error('Timestep is larger than 15 minutes. Cannot properly calculate billing demand.')
        
    end
    
    
    %% Calculate Monthly Bill Cost with and Without Storage
    
    % Monthly Cost from Daily Fixed Charge
    % This value is not affected by the presence of storage.
    Fixed_Charge_Month = Fixed_Per_Meter_Month_Charge + (Fixed_Per_Meter_Day_Charge * length(Load_Profile_Data_Month)/(24 * (1/delta_t)));
    
    % Monthly Cost from Noncoincident Demand Charge - Baseline
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        NC_Demand_Charge_Month_Baseline = Summer_Noncoincident_DC * P_max_NC_Month_Baseline;
    else
        NC_Demand_Charge_Month_Baseline = Winter_Noncoincident_DC * P_max_NC_Month_Baseline;
    end

    % Monthly Cost from Noncoincident Demand Charge - With Solar Only
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        NC_Demand_Charge_Month_with_Solar_Only = Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_Only;
    else
        NC_Demand_Charge_Month_with_Solar_Only = Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_Only;
    end
    
    % Monthly Cost from Noncoincident Demand Charge - With Solar and Storage
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        NC_Demand_Charge_Month_with_Solar_and_Storage = Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage;
    else
        NC_Demand_Charge_Month_with_Solar_and_Storage = Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage;
    end
    
    
    % Monthly Cost from Coincident Peak Demand Charge - Baseline
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPK_Demand_Charge_Month_Baseline = Summer_Peak_DC * P_max_CPK_Month_Baseline;
    else
        % There is no coincident peak demand charge in the winter.
        CPK_Demand_Charge_Month_Baseline = 0;
    end
    
    
    % Monthly Cost from Coincident Peak Demand Charge - With Solar Only
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPK_Demand_Charge_Month_with_Solar_Only = Summer_Peak_DC * P_max_CPK_Month_with_Solar_Only;
    else
        % There is no coincident peak demand charge in the winter.
        CPK_Demand_Charge_Month_with_Solar_Only = 0;
    end
    
    
    % Monthly Cost from Coincident Peak Demand Charge - With Solar and Storage
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPK_Demand_Charge_Month_with_Solar_and_Storage = Summer_Peak_DC * P_max_CPK_Month_with_Solar_and_Storage;
    else
        % There is no coincident peak demand charge in the winter.
        CPK_Demand_Charge_Month_with_Solar_and_Storage = 0;
    end
    
    
    % Monthly Cost from Coincident Part-Peak Demand Charge - Baseline
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPP_Demand_Charge_Month_Baseline = Summer_Part_Peak_DC * P_max_CPP_Month_Baseline;
    else
        CPP_Demand_Charge_Month_Baseline = Winter_Part_Peak_DC * P_max_CPP_Month_Baseline;
    end
    

    % Monthly Cost from Coincident Part-Peak Demand Charge - With Solar Only
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPP_Demand_Charge_Month_with_Solar_Only = Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only;
    else
        CPP_Demand_Charge_Month_with_Solar_Only = Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only;
    end
    
    
    % Monthly Cost from Coincident Part-Peak Demand Charge - With Solar and Storage
    
    if any(Month_Iter == First_Summer_Month:Last_Summer_Month)
        CPP_Demand_Charge_Month_with_Solar_and_Storage = Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage;
    else
        CPP_Demand_Charge_Month_with_Solar_and_Storage = Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage;
    end
    
    
    % Monthly Cost from Volumetric Energy Rates - Baseline
    Energy_Charge_Month_Baseline = (Load_Profile_Data_Month' * Volumetric_Rate_Data_Month) * delta_t;
    
    % Monthly Cost from Volumetric Energy Rates - With Solar Only
    Solar_Only_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month;
    Energy_Charge_Month_with_Solar_Only = (Solar_Only_Net_Load_Profile_Month' * Volumetric_Rate_Data_Month) * delta_t;
    
    % Monthly Cost from Volumetric Energy Rates - With Solar and Storage
    Solar_Storage_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month + ...
                                           P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded;
    Energy_Charge_Month_with_Solar_and_Storage = (Solar_Storage_Net_Load_Profile_Month' * Volumetric_Rate_Data_Month) * delta_t;
    
    
    % Monthly Cycling Penalty
    
    Cycles_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c)/(2 * Total_Storage_Capacity)) * delta_t)) + ...
        (P_ES_out_Month_Unpadded * ((1/(Eff_d * 2 * Total_Storage_Capacity)) * delta_t)));
    
    Cycling_Penalty_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c * cycle_pen)/(2 * Total_Storage_Capacity)) * delta_t)) + ...
        (P_ES_out_Month_Unpadded * ((cycle_pen/(Eff_d * 2 * Total_Storage_Capacity)) * delta_t)));
    
    
    %% Update Battery Capacity Based on Monthly Cycling
    % This is to account for capacity fade in lithium-ion batteries.
    % Based on standard definitions of battery cycle life, lithium-ion batteries are
    % defined to have experienced capacity fade to 80% of its original
    % capacity by the end of its cycle life.
    % Flow batteries do not experience capacity fade.
    
    if Storage_Type_Input == "Lithium-Ion Battery"
        
        Usable_Storage_Capacity = Usable_Storage_Capacity - (Usable_Storage_Capacity_Input * (Cycles_Month/Cycle_Life) * 0.2);
        
    elseif Storage_Type_Input == "Flow Battery"
        
        Usable_Storage_Capacity = Usable_Storage_Capacity;
        
    end
    
    % Update Previous Month Final Energy Level to account for capacity fade, if battery is full at end
    % of month. Otherwise, optimization is infeasible.
    
    if Previous_Month_Final_Energy_Level > Usable_Storage_Capacity
        
        Previous_Month_Final_Energy_Level = Usable_Storage_Capacity;
        
    end
    
    
    %% Concatenate Decision Variable & Monthly Cost Values from Month Iteration
    
    % Decision Variable Concatenation
    P_ES_in = [P_ES_in; P_ES_in_Month_Unpadded];
    
    P_ES_out = [P_ES_out; P_ES_out_Month_Unpadded];
    
    Ene_Lvl = [Ene_Lvl; Ene_Lvl_Month_Unpadded];
    
    P_max_NC = [P_max_NC; P_max_NC_Month_with_Solar_and_Storage];
    
    P_max_peak = [P_max_peak; P_max_CPK_Month_with_Solar_and_Storage];
    
    P_max_part_peak = [P_max_part_peak; P_max_CPP_Month_with_Solar_and_Storage];
    
    
    % Monthly Cost Variable Concatenation
    Fixed_Charge_Vector = [Fixed_Charge_Vector; Fixed_Charge_Month];
    
    NC_DC_Baseline_Vector = [NC_DC_Baseline_Vector; NC_Demand_Charge_Month_Baseline];
    NC_DC_with_Solar_Only_Vector = [NC_DC_with_Solar_Only_Vector; NC_Demand_Charge_Month_with_Solar_Only];
    NC_DC_with_Solar_and_Storage_Vector = [NC_DC_with_Solar_and_Storage_Vector; NC_Demand_Charge_Month_with_Solar_and_Storage];
    
    CPK_DC_Baseline_Vector = [CPK_DC_Baseline_Vector; CPK_Demand_Charge_Month_Baseline];
    CPK_DC_with_Solar_Only_Vector = [CPK_DC_with_Solar_Only_Vector; CPK_Demand_Charge_Month_with_Solar_Only];
    CPK_DC_with_Solar_and_Storage_Vector = [CPK_DC_with_Solar_and_Storage_Vector; CPK_Demand_Charge_Month_with_Solar_and_Storage];
    
    CPP_DC_Baseline_Vector = [CPP_DC_Baseline_Vector; CPP_Demand_Charge_Month_Baseline];
    CPP_DC_with_Solar_Only_Vector = [CPP_DC_with_Solar_Only_Vector; CPP_Demand_Charge_Month_with_Solar_Only];
    CPP_DC_with_Solar_and_Storage_Vector = [CPP_DC_with_Solar_and_Storage_Vector; CPP_Demand_Charge_Month_with_Solar_and_Storage];
    
    Energy_Charge_Baseline_Vector = [Energy_Charge_Baseline_Vector; Energy_Charge_Month_Baseline];
    Energy_Charge_with_Solar_Only_Vector = [Energy_Charge_with_Solar_Only_Vector; Energy_Charge_Month_with_Solar_Only];
    Energy_Charge_with_Solar_and_Storage_Vector = [Energy_Charge_with_Solar_and_Storage_Vector; Energy_Charge_Month_with_Solar_and_Storage];
    
    Cycles_Vector = [Cycles_Vector; Cycles_Month];
    
    Cycling_Penalty_Vector = [Cycling_Penalty_Vector; Cycling_Penalty_Month];
    
    
end

% Report total script runtime.

telapsed = toc(tstart);

sprintf('Model Run %0.f complete. Elapsed time to run the optimization model is %0.0f seconds.', Model_Run_Number_Input, telapsed)


%% Calculation of Additional Reported Model Inputs/Outputs

% Output current system date and time in standard ISO 8601 YYYY-MM-DD HH:MM format.
format shortg
Model_Run_Date_Time_Raw = clock;
Model_Run_Date_Time_Components = Model_Run_Date_Time_Raw(1:5); % Remove seconds column

Model_Run_Date_Time = "";

for Model_Run_Date_Time_Component_Iter = 1:length(Model_Run_Date_Time_Components)
   
    Model_Run_Date_Time_Component_Num = Model_Run_Date_Time_Components(Model_Run_Date_Time_Component_Iter);
    
    if Model_Run_Date_Time_Component_Num > 10
        Model_Run_Date_Time_Component_String = num2str(Model_Run_Date_Time_Component_Num);
    else
        Model_Run_Date_Time_Component_String = ['0', num2str(Model_Run_Date_Time_Component_Num)];
    end
    
    if Model_Run_Date_Time_Component_Iter == 1 || Model_Run_Date_Time_Component_Iter == 2
       Model_Run_Date_Time = [Model_Run_Date_Time, Model_Run_Date_Time_Component_String, '-'];
    elseif Model_Run_Date_Time_Component_Iter == 3
        Model_Run_Date_Time = [Model_Run_Date_Time, Model_Run_Date_Time_Component_String, ' '];
    elseif Model_Run_Date_Time_Component_Iter == 4
        Model_Run_Date_Time = [Model_Run_Date_Time, Model_Run_Date_Time_Component_String, ':'];
    elseif Model_Run_Date_Time_Component_Iter == 5
        Model_Run_Date_Time = [Model_Run_Date_Time, Model_Run_Date_Time_Component_String];
    end
    
end

Model_Run_Date_Time = join(Model_Run_Date_Time, "");


% Find Load Profile Master Index Corresponding to Load Profile Name Input
Load_Profile_Master_Index = ""; % Placeholder


% Find Retail Rate Master Index Corresponding to Retail Rate Name
Retail_Rate_Master_Index = ""; % Placeholder

% Convert Retail Rate Name Input (which contains both utility name and rate
% name) into Retail Rate Utility and Retail Rate Name Output

if contains(Retail_Rate_Name_Input, "PG&E")
    Retail_Rate_Utility = "PG&E";
elseif contains(Retail_Rate_Name_Input, "SCE")
    Retail_Rate_Utility = "SCE";
elseif contains(Retail_Rate_Name_Input, "SDG&E")
    Retail_Rate_Utility = "SDG&E";
end

Retail_Rate_Utility_Plus_Space = join([Retail_Rate_Utility, " "], "");

Retail_Rate_Name_Output = erase(Retail_Rate_Name_Input, Retail_Rate_Utility_Plus_Space);

% Find Retail Rate Effective Date Corresponding to Retail Rate Name
Retail_Rate_Effective_Date = ""; % Placeholder

% If Solar Profile Name is "No Solar", Solar Profile Name Output is Blank
if Solar_Profile_Name_Input == "No Solar"
    Solar_Profile_Name_Output = "";
else
    Solar_Profile_Name_Output = Solar_Profile_Name_Input;
end

% Find Solar Profile Master Index Corresponding to Solar Profile Name
Solar_Profile_Master_Index = ""; % Placeholder

% Find Solar Profile Description Corresponding to Solar Profile Name (Optional)
Solar_Profile_Description = ""; % Placeholder

% Storage Control Algorithm Description (Optional)
if Storage_Control_Algorithm_Name == "OSESMO Economic Dispatch"
    Storage_Control_Algorithm_Description = "Open Source Energy Storage Model - Economic Dispatch";
elseif Storage_Control_Algorithm_Name == "OSESMO Non-Economic Solar Self-Supply"
    Storage_Control_Algorithm_Description = "Open Source Energy Storage Model - Non-Economic Solar Self-Supply";
end

% Storage Algorithm Parameters Filename (Optional)
Storage_Control_Algorithms_Parameters_Filename = ""; % No storage parameters file.

% Other Incentives or Penalities (Optional)
Other_Incentives_or_Penalities = ""; % No other incentives or penalties.

Output_Summary_Filename = "OSESMO Reporting Inputs and Outputs.csv";

Output_Description_Filename = ""; % No output description file.

Output_Visualizations_Filename = "Multiple files - in same folder as Output Summary file."; % No single output visualizations file.

EV_Use = ""; % Model does not calculate or report EV usage information.

EV_Charge = ""; % Model does not calculate or report EV charge information.

EV_Gas_Savings = ""; % Model does not calculate or report EV gas savings information.

EV_GHG_Savings = ""; % Model does not calculate or report EV GHg savings information.




%% Output Directory/Folder Names

if ITC_Constraint_Input == 0
    ITC_Constraint_Folder_Name = "No ITC Constraint";
elseif ITC_Constraint_Input == 1
    ITC_Constraint_Folder_Name = "ITC Constraint";   
end

% Ensures that folder is called "No Emissions Forecast Signal",
% and not "No Emissions Forecast Signal Emissions Forecast Signal"

if Emissions_Forecast_Signal_Input == "No Emissions Forecast Signal"
    Emissions_Forecast_Signal_Input = "No";
end

Output_Directory_Filepath = "Models/OSESMO/Model Outputs/" + ...
    Model_Type_Input + "/" + Model_Timestep_Resolution + "-Minute Timestep Resolution" + "/" + ...
    Customer_Class_Input + "/" + Load_Profile_Name_Input + "/" + Retail_Rate_Name_Input + "/" + ...
    Solar_Profile_Name_Input + "/" + Solar_Size_Input + " kW Solar/" + Storage_Type_Input + "/" + ...
    Storage_Power_Rating_Input + " kW " + Usable_Storage_Capacity_Input + " kWh Storage/" + ...
    (Single_Cycle_RTE_Input * 100) + " Percent Single-Cycle RTE/" + ...
    (Parasitic_Storage_Load_Input * 100) + " Percent Parasitic Load/" + ...
    Storage_Control_Algorithm_Name + "/" + GHG_Reduction_Solution_Input + "/" + ...
    Equivalent_Cycling_Constraint_Input + " Equivalent Cycles Constraint/" + ...
    (Annual_RTE_Constraint_Input * 100) + " Percent Annual RTE Constraint/" + ...
    ITC_Constraint_Folder_Name + "/" + ...
    Carbon_Adder_Incentive_Value_Input + " Dollar Carbon Adder Incentive/" + ...
    Emissions_Forecast_Signal_Input + " Emissions Forecast Signal/";

% Correct Emissions Forecast Signal Name back so that it is exported with
% the correct name in the Outputs model.

if Emissions_Forecast_Signal_Input == "No"
    Emissions_Forecast_Signal_Input = "No Emissions Forecast Signal";
end


% Create folder if one does not exist already

if ~exist(Output_Directory_Filepath, 'dir')
    Output_Directory_Filepath_Single_Quotes = char(Output_Directory_Filepath);
    mkdir(Output_Directory_Filepath_Single_Quotes); % mkdir only works with single-quote filepath
end


%% Plot Energy Storage Dispatch Schedule

numtsteps_year = length(Load_Profile_Data);

t = Start_Time_Input + linspace(0, ((numtsteps_year-1) * delta_t)/(24), numtsteps_year)';

P_ES = P_ES_out - P_ES_in;

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    plot(t, P_ES,'r')
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Energy Storage Output (kW)','FontSize',15);
    title('Energy Storage Dispatch Profile','FontSize',15)     
  
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Storage Dispatch Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Storage Dispatch Plot");
        
    end
    
end


%% Plot Energy Storage Energy Level

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    plot(t, Ene_Lvl,'r')
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Energy Storage Energy Level (kWh)','FontSize',15);
    title('Energy Storage Energy Level','FontSize',15) 
    
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Energy Level Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Energy Level Plot");
        
    end
    
end


%% Plot Volumetric Electricity Price Schedule and Marginal Carbon Emission Rates

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    yyaxis left
    plot(t, Volumetric_Rate_Data)
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Energy Price ($/kWh)', 'FontSize', 15);
    yyaxis right
    plot(t, Marginal_Emissions_Rate_Evaluation_Data)
    ylabel('Marginal Emissions Rate (metric tons/kWh)','FontSize',15);
    title('Electricity Rates and Marginal Emissions Rates','FontSize',15)
    legend('Electricity Rates ($/kWh)','Marginal Carbon Emissions Rate (metric tons/kWh)', ...
        'Location','NorthOutside')
    set(gca,'FontSize',15);

    
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Energy Price and Carbon Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Energy Price and Carbon Plot");
        
    end
    
end

%% Plot Coincident and Non-Coincident Demand Charge Schedule

% Create Summer/Winter Binary Flag Vector
Summer_Binary_Data = sum(Month_Data == First_Summer_Month:Last_Summer_Month, 2);

Winter_Binary_Data = sum(Month_Data == [1:(First_Summer_Month-1), (Last_Summer_Month+1):12], 2);

% Create Total-Demand-Charge Vector
% Noncoincident Demand Charge is always included (although it may be 0).
% Coincident Peak and Part-Peak values are only added if they are non-zero
% and a binary-flag data input is available.

Total_DC = (Winter_Noncoincident_DC * Winter_Binary_Data) + ...
    (Summer_Noncoincident_DC * Summer_Binary_Data);

if Winter_Peak_DC > 0
    Total_DC = Total_DC + (Winter_Peak_DC * Winter_Peak_Binary_Data);
end

if Winter_Part_Peak_DC > 0
    Total_DC = Total_DC + (Winter_Part_Peak_DC * Winter_Part_Peak_Binary_Data);
end

if Summer_Peak_DC > 0
    Total_DC = Total_DC + (Summer_Peak_DC * Summer_Peak_Binary_Data);
end

if Summer_Part_Peak_DC > 0
    Total_DC = Total_DC + (Summer_Part_Peak_DC * Summer_Part_Peak_Binary_Data);
end


if Show_Plots == 1 || Export_Plots ==1

    figure('NumberTitle', 'off')
    plot(t, Total_DC,'Color',[0,0.5,0])
    xlim([t(1), t(end)])
    xlabel('Date & Time','FontSize',15);
    ylabel('Total Demand Charge ($/kW)','FontSize',15);
    title('Coincident + Non-Coincident Demand Charge Schedule','FontSize',15)
        
    
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Demand Charge Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Demand Charge Plot");
        
    end
    
end


%% Plot Load, Net Load with Solar Only, Net Load with Solar and Storage

if Show_Plots == 1 || Export_Plots ==1
    
    if Model_Type_Input == "Storage Only"
        
        figure('NumberTitle', 'off')
        plot(t, Load_Profile_Data,'k', ...
            t, Load_Profile_Data - P_ES,'r')
        xlim([t(1), t(end)])
        xlabel('Date & Time','FontSize',15);
        ylabel('Load (kW)','FontSize',15);
        title('Original and Net Load Profiles','FontSize',15)
        legend('Original Load', 'Net Load with Storage', 'Location','NorthOutside')
        set(gca,'FontSize',15);
        
    elseif Model_Type_Input == "Solar Plus Storage"
        
        figure('NumberTitle', 'off')
        plot(t, Load_Profile_Data,'k', ...
            t, Load_Profile_Data - Solar_PV_Profile_Data,'b', ...
            t, Load_Profile_Data - (Solar_PV_Profile_Data + P_ES),'r')
        xlim([t(1), t(end)])
        xlabel('Date & Time','FontSize',15);
        ylabel('Load (kW)','FontSize',15);
        title('Original and Net Load Profiles','FontSize',15)
        legend('Original Load','Net Load with Solar Only', 'Net Load with Solar + Storage', 'Location','NorthOutside')
        set(gca,'FontSize',15);
        
    end
        
    
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Net Load Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Net Load Plot");
        
    end
    
    
end

if Model_Type_Input == "Storage Only"
    
    Annual_Peak_Demand_with_Solar_Only = "";
    
    Annual_Total_Energy_Consumption_with_Solar_Only = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    
    Annual_Peak_Demand_with_Solar_Only = max(Load_Profile_Data - Solar_PV_Profile_Data);
    
    Annual_Total_Energy_Consumption_with_Solar_Only = sum(Load_Profile_Data - Solar_PV_Profile_Data) * delta_t;
    
end

Annual_Peak_Demand_with_Solar_and_Storage = max(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES));

Annual_Total_Energy_Consumption_with_Solar_and_Storage = sum(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES)) * delta_t;

if Model_Type_Input == "Storage Only"
    Solar_Only_Peak_Demand_Reduction_Percentage = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    Solar_Only_Peak_Demand_Reduction_Percentage = ...
        ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_Only)/...
        Annual_Peak_Demand_Baseline) * 100;
end

Solar_Storage_Peak_Demand_Reduction_Percentage = ...
    ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_and_Storage)/...
    Annual_Peak_Demand_Baseline) * 100;

if Model_Type_Input == "Storage Only"
    Solar_Only_Energy_Consumption_Decrease_Percentage = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    Solar_Only_Energy_Consumption_Decrease_Percentage = ...
        ((Annual_Total_Energy_Consumption_Baseline - ...
        Annual_Total_Energy_Consumption_with_Solar_Only)/...
        Annual_Total_Energy_Consumption_Baseline) * 100;
end

Solar_Storage_Energy_Consumption_Decrease_Percentage = ...
    ((Annual_Total_Energy_Consumption_Baseline - ...
    Annual_Total_Energy_Consumption_with_Solar_and_Storage)/...
    Annual_Total_Energy_Consumption_Baseline) * 100;

sprintf('Baseline annual peak noncoincident demand is %0.00f kW', ...
    Annual_Peak_Demand_Baseline)

if Model_Type_Input == "Storage Only"
    
    if Solar_Storage_Peak_Demand_Reduction_Percentage >= 0
        
        sprintf('Peak demand with storage is %0.00f kW, representing a DECREASE OF %0.02f%%.', ...
            Annual_Peak_Demand_with_Solar_and_Storage, Solar_Storage_Peak_Demand_Reduction_Percentage)
        
    elseif Solar_Storage_Peak_Demand_Reduction_Percentage < 0
        
        sprintf('Peak demand with storage is %0.00f kW, representing an INCREASE OF %0.02f%%.', ...
            Annual_Peak_Demand_with_Solar_and_Storage, -Solar_Storage_Peak_Demand_Reduction_Percentage)
        
    end        
    
    sprintf('Baseline annual total electricity consumption is %0.00f kWh.', ...
    Annual_Total_Energy_Consumption_Baseline)
    
    sprintf('Electricity consumption with storage is %0.00f kWh, representing an INCREASE OF %0.02f%%.', ...
        Annual_Total_Energy_Consumption_with_Solar_and_Storage, -Solar_Storage_Energy_Consumption_Decrease_Percentage)
    
elseif Model_Type_Input == "Solar Plus Storage"
    
    sprintf('Peak demand with solar only is %0.00f kW, representing a DECREASE OF %0.02f%%.', ...
        Annual_Peak_Demand_with_Solar_Only, Solar_Only_Peak_Demand_Reduction_Percentage)
    
    if Solar_Storage_Peak_Demand_Reduction_Percentage >= 0
        sprintf('Peak demand with solar and storage is %0.00f kW, representing a DECREASE OF %0.02f%%.', ...
            Annual_Peak_Demand_with_Solar_and_Storage, Solar_Storage_Peak_Demand_Reduction_Percentage)
        
    elseif Solar_Storage_Peak_Demand_Reduction_Percentage < 0
        sprintf('Peak demand with solar and storage is %0.00f kW, representing an INCREASE OF %0.02f%%.', ...
            Annual_Peak_Demand_with_Solar_and_Storage, -Solar_Storage_Peak_Demand_Reduction_Percentage)
        
    end
    
    sprintf('Baseline annual total electricity consumption is %0.00f kWh.', ...
    Annual_Total_Energy_Consumption_Baseline)
    
    sprintf('Electricity consumption with solar only is %0.00f kWh, representing a DECREASE OF %0.02f%%.', ...
        Annual_Total_Energy_Consumption_with_Solar_Only, Solar_Only_Energy_Consumption_Decrease_Percentage)
    
    sprintf('Electricity consumption with solar and storage is %0.00f kWh, representing a DECREASE OF %0.02f%%.', ...
        Annual_Total_Energy_Consumption_with_Solar_and_Storage, Solar_Storage_Energy_Consumption_Decrease_Percentage)
    
end


%% Plot Monthly Costs as Bar Plot

% Calculate Baseline Monthly Costs

Monthly_Costs_Matrix_Baseline = [Fixed_Charge_Vector, NC_DC_Baseline_Vector, ...
    CPK_DC_Baseline_Vector, CPP_DC_Baseline_Vector, Energy_Charge_Baseline_Vector, ...
    zeros(size(Fixed_Charge_Vector))];

Annual_Costs_Vector_Baseline = [sum(Fixed_Charge_Vector); ...
    sum(NC_DC_Baseline_Vector) + sum(CPK_DC_Baseline_Vector) + sum(CPP_DC_Baseline_Vector);...
    sum(Energy_Charge_Baseline_Vector)];

Annual_Demand_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline(2);
Annual_Energy_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline(3);


% Calculate Monthly Costs With Solar Only

Monthly_Costs_Matrix_with_Solar_Only = [Fixed_Charge_Vector, NC_DC_with_Solar_Only_Vector, CPK_DC_with_Solar_Only_Vector,...
    CPP_DC_with_Solar_Only_Vector, Energy_Charge_with_Solar_Only_Vector, zeros(size(Fixed_Charge_Vector))];

Annual_Costs_Vector_with_Solar_Only = [sum(Fixed_Charge_Vector); ...
    sum(NC_DC_with_Solar_Only_Vector) + sum(CPK_DC_with_Solar_Only_Vector) + sum(CPP_DC_with_Solar_Only_Vector);...
    sum(Energy_Charge_with_Solar_Only_Vector)];

if Model_Type_Input == "Storage Only"
    Annual_Demand_Charge_Cost_with_Solar_Only = "";
    Annual_Energy_Charge_Cost_with_Solar_Only = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_Demand_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only(2);
    Annual_Energy_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only(3);
end


% Calculate Monthly Costs with Solar and Storage

Monthly_Costs_Matrix_with_Solar_and_Storage = [Fixed_Charge_Vector, NC_DC_with_Solar_and_Storage_Vector, ...
    CPK_DC_with_Solar_and_Storage_Vector, CPP_DC_with_Solar_and_Storage_Vector, Energy_Charge_with_Solar_and_Storage_Vector, ...
    Cycling_Penalty_Vector];

Annual_Costs_Vector_with_Solar_and_Storage = [sum(Fixed_Charge_Vector); ...
    sum(NC_DC_with_Solar_and_Storage_Vector) + sum(CPK_DC_with_Solar_and_Storage_Vector) + sum(CPP_DC_with_Solar_and_Storage_Vector);...
    sum(Energy_Charge_with_Solar_and_Storage_Vector)];

Annual_Demand_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage(2);
Annual_Energy_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage(3);


% Calculate Maximum and Minimum Monthly Bills - to set y-axis for all plots

Maximum_Monthly_Bill_Baseline = max(sum(Monthly_Costs_Matrix_Baseline, 2));
Minimum_Monthly_Bill_Baseline = min(sum(Monthly_Costs_Matrix_Baseline, 2));

Maximum_Monthly_Bill_with_Solar_Only = max(sum(Monthly_Costs_Matrix_with_Solar_Only, 2));
Minimum_Monthly_Bill_with_Solar_Only = min(sum(Monthly_Costs_Matrix_with_Solar_Only, 2));

Maximum_Monthly_Bill_with_Solar_and_Storage = max(sum(Monthly_Costs_Matrix_with_Solar_and_Storage, 2));
Minimum_Monthly_Bill_with_Solar_and_Storage = min(sum(Monthly_Costs_Matrix_with_Solar_and_Storage, 2));

Maximum_Monthly_Bill = max([Maximum_Monthly_Bill_Baseline, ...
    Maximum_Monthly_Bill_with_Solar_Only, ...
    Maximum_Monthly_Bill_with_Solar_and_Storage]);

Minimum_Monthly_Bill = min([Minimum_Monthly_Bill_Baseline, ...
    Minimum_Monthly_Bill_with_Solar_Only, ...
    Minimum_Monthly_Bill_with_Solar_and_Storage]);

Max_Monthly_Bill_ylim = Maximum_Monthly_Bill * 1.1; % Make upper ylim 10% larger than largest monthly bill.

if Minimum_Monthly_Bill >= 0
    Min_Monthly_Bill_ylim = 0; % Make lower ylim equal to 0 if the lowest monthly bill is greater than zero.
elseif Minimum_Monthly_Bill < 0
    Min_Monthly_Bill_ylim = Minimum_Monthly_Bill * 1.1; % Make lower ylim 10% smaller than the smallest monthly bill if less than zero.
end


% Plot Baseline Monthly Costs

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    bar(Monthly_Costs_Matrix_Baseline, 'stacked')
    xlim([0.5, 12.5])
    ylim([Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim])
    xlabel('Month','FontSize',15);
    ylabel('Cost ($/Month)','FontSize',15);
    title('Monthly Costs, Without Storage','FontSize',15)
    legend('Fixed Charges','Max DC', 'Peak DC','Part-Peak DC', 'Energy Charge', 'Cycling Penalty', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
        
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Monthly Costs Baseline Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Monthly Costs Baseline Plot");
        
    end
    
end


% Plot Monthly Costs With Solar Only

if Model_Type_Input == "Solar Plus Storage"
   
    if Show_Plots == 1 || Export_Plots ==1
        
        figure('NumberTitle', 'off')
        bar(Monthly_Costs_Matrix_with_Solar_Only, 'stacked')
        xlim([0.5, 12.5])
        ylim([Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim])
        xlabel('Month','FontSize',15);
        ylabel('Cost ($/Month)','FontSize',15);
        title('Monthly Costs, With Solar Only','FontSize',15)
        legend('Fixed Charges','Max DC', 'Peak DC','Part-Peak DC', 'Energy Charge', 'Cycling Penalty', ...
            'Location', 'NorthWest')
        set(gca,'FontSize',15);

        
        if Export_Plots == 1
            
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar Only Plot.png");
            
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar Only Plot");
            
        end
        
    end

end


% Plot Monthly Costs with Solar and Storage

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    bar(Monthly_Costs_Matrix_with_Solar_and_Storage, 'stacked')
    xlim([0.5, 12.5])
    ylim([Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim])
    xlabel('Month','FontSize',15);
    ylabel('Cost ($/Month)','FontSize',15);
    title('Monthly Costs, With Storage','FontSize',15)
    legend('Fixed Charges','Max DC', 'Peak DC','Part-Peak DC', 'Energy Charge', 'Cycling Penalty', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
        
    
    if Export_Plots == 1
        
        if Model_Type_Input == "Storage Only"
            
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Storage Plot.png");
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Storage Plot");
            
        elseif Model_Type_Input == "Solar Plus Storage"
            
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar and Storage Plot.png");
            saveas(gcf, Output_Directory_Filepath + "Monthly Costs with Solar and Storage Plot");
            
        end
        
    end
    
end


% Plot Monthly Savings From Storage

if Model_Type_Input == "Storage Only"
    
    Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_Baseline - ...
        Monthly_Costs_Matrix_with_Solar_and_Storage;
    
elseif Model_Type_Input == "Solar Plus Storage"
    
    Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_with_Solar_Only - ...
        Monthly_Costs_Matrix_with_Solar_and_Storage;
    
end


% Remove fixed charges, battery cycling costs.
Monthly_Savings_Matrix_Plot = Monthly_Savings_Matrix_From_Storage(:, 2:5);

if Show_Plots == 1 || Export_Plots ==1
    
    figure('NumberTitle', 'off')
    bar(Monthly_Savings_Matrix_Plot, 'stacked')
    xlim([0.5, 12.5])
    xlabel('Month','FontSize',15);
    xticks(linspace(1,12,12));
    ylabel('Savings ($/Month)','FontSize',15);
    title('Monthly Savings From Storage','FontSize',15)
    legend('Max DC', 'Peak DC','Part-Peak DC', 'Energy Charge', ...
        'Location', 'NorthWest')
    set(gca,'FontSize',15);
        
    
    if Export_Plots == 1
        
        saveas(gcf, Output_Directory_Filepath + "Monthly Savings from Storage Plot.png");
        
        saveas(gcf, Output_Directory_Filepath + "Monthly Savings from Storage Plot");
        
    end
    
    
end

%% Close All Figures

if Show_Plots == 0
    
    close all;
    
end


%% Report Annual Savings

% Report Baseline Cost without Solar or Storage
Annual_Customer_Bill_Baseline = sum(sum(Monthly_Costs_Matrix_Baseline));

if Model_Type_Input == "Storage Only"
    Annual_Customer_Bill_with_Solar_Only = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_Customer_Bill_with_Solar_Only = sum(Annual_Costs_Vector_with_Solar_Only);
end

Annual_Customer_Bill_with_Solar_and_Storage = sum(Annual_Costs_Vector_with_Solar_and_Storage); % Doesn't include degradation cost.

if Model_Type_Input == "Storage Only"
    
    Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_and_Storage;
    
elseif Model_Type_Input == "Solar Plus Storage"
    
    Annual_Customer_Bill_Savings_from_Solar = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_Only;
    
    Annual_Customer_Bill_Savings_from_Solar_Percent = (Annual_Customer_Bill_Savings_from_Solar/Annual_Customer_Bill_Baseline);
    
    Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_with_Solar_Only - Annual_Customer_Bill_with_Solar_and_Storage;
    
end

Annual_Customer_Bill_Savings_from_Storage_Percent = (Annual_Customer_Bill_Savings_from_Storage/Annual_Customer_Bill_Baseline);

if Model_Type_Input == "Solar Plus Storage"
    Solar_Installed_Cost = Solar_Size_Input * Solar_Installed_Cost_per_kW;
    Solar_Simple_Payback = Solar_Installed_Cost/Annual_Customer_Bill_Savings_from_Solar;
    
    sprintf('Annual cost savings from solar is $%0.0f, representing %0.2f %% of the original $%0.0f bill.', ...
        Annual_Customer_Bill_Savings_from_Solar, Annual_Customer_Bill_Savings_from_Solar_Percent * 100, Annual_Customer_Bill_Baseline)
    
    sprintf('The solar PV system has a simple payback of %0.0f years, not including incentives.', ...
        Solar_Simple_Payback)
end

Storage_Installed_Cost = Total_Storage_Capacity * Storage_Installed_Cost_per_kWh;

Storage_Simple_Payback = Storage_Installed_Cost/Annual_Customer_Bill_Savings_from_Storage;

sprintf('Annual cost savings from storage is $%0.0f, representing %0.2f%% of the original $%0.0f bill.', ...
    Annual_Customer_Bill_Savings_from_Storage, Annual_Customer_Bill_Savings_from_Storage_Percent * 100, Annual_Customer_Bill_Baseline)

sprintf('The storage system has a simple payback of %0.0f years, not including incentives.', ...
    Storage_Simple_Payback)


%% Report Cycling/Degradation Penalty

Annual_Equivalent_Storage_Cycles = sum(Cycles_Vector);
Annual_Cycling_Penalty = sum(Cycling_Penalty_Vector);
Annual_Capacity_Fade = Usable_Storage_Capacity_Input - Usable_Storage_Capacity;
sprintf('The battery cycles %0.0f times annually, with a degradation cost of $%0.0f, and experiences capacity fade of %0.1f kWh.', ...
    Annual_Equivalent_Storage_Cycles, Annual_Cycling_Penalty, Annual_Capacity_Fade)

%% Report Operational/"SGIP" Round-Trip Efficiency

Annual_RTE = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t);

sprintf('The battery has an Annual Operational/SGIP Round-Trip Efficiency of %0.2f%%.', ...
    Annual_RTE * 100)


%% Report Operational/"SGIP" Capacity Factor

% The SGIP Handbook uses the following definition of capacity factor for
% storage resources, based on the assumption that 60% of hours are
% available for discharge. The term "hours of data available" is equal to
% the number of hours in the year here. For actual operational data, it's
% the number of hours where data is available, which may be less than the
% number of hours in the year. Here, the number of hours in the year is
% calculated by multiplying the number of timesteps of original load profile data
% by the timestep length delta_t. This returns 8760 hours during
% non-leap years and 8784 during leap years.

% Capacity Factor = (kWh Discharge)/(Hours of Data Available x Rebated Capacity (kW) x 60%)

Operational_Capacity_Factor = ((sum(P_ES_out) * delta_t)/((length(Load_Profile_Data) * delta_t) * Storage_Power_Rating_Input * 0.6));

sprintf('The battery has an Operational/SGIP Capacity Factor of %0.2f%%.', ...
    Operational_Capacity_Factor * 100)

%% Report Emissions Impact

% This approach multiplies net load by marginal emissions factors to
% calculate total annual emissions. This is consistent with the idea that
% the customer would pay an adder based on marginal emissions factors.
% Typically, total annual emissions is calculated using average emissions
% values, not marginal emissions values.

% https://www.pge.com/includes/docs/pdfs/shared/environment/calculator/pge_ghg_emission_factor_info_sheet.pdf

% (tons/kWh) = (tons/MWh) * (MWh/kWh)
Annual_GHG_Emissions_Baseline = (Marginal_Emissions_Rate_Evaluation_Data' * Load_Profile_Data * ...
    (1/1000) * delta_t);

if Model_Type_Input == "Storage Only"
    Annual_GHG_Emissions_with_Solar_Only = "";
    
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_GHG_Emissions_with_Solar_Only = (Marginal_Emissions_Rate_Evaluation_Data' * (Load_Profile_Data - Solar_PV_Profile_Data) * ...
        (1/1000) * delta_t);
end

Annual_GHG_Emissions_with_Solar_and_Storage = (Marginal_Emissions_Rate_Evaluation_Data' * (Load_Profile_Data - ...
    (Solar_PV_Profile_Data + P_ES_out - P_ES_in)) * (1/1000) * delta_t);

if Model_Type_Input == "Storage Only"
    Annual_GHG_Emissions_Reduction_from_Solar = "";
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_GHG_Emissions_Reduction_from_Solar = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_Only;
end

if Model_Type_Input == "Storage Only"
    Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_and_Storage;
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_with_Solar_Only - Annual_GHG_Emissions_with_Solar_and_Storage;
end

if Model_Type_Input == "Storage Only"
    Annual_GHG_Emissions_Reduction_from_Solar_Percent = "";
elseif Model_Type_Input == "Solar Plus Storage"
    Annual_GHG_Emissions_Reduction_from_Solar_Percent = ...
        (Annual_GHG_Emissions_Reduction_from_Solar/Annual_GHG_Emissions_Baseline);
end

Annual_GHG_Emissions_Reduction_from_Storage_Percent = ...
    (Annual_GHG_Emissions_Reduction_from_Storage/Annual_GHG_Emissions_Baseline);


if Model_Type_Input == "Solar Plus Storage"
    
    sprintf('Installing solar DECREASES marginal carbon emissions \n by %0.2f metric tons per year.', ...
        Annual_GHG_Emissions_Reduction_from_Solar)
    sprintf('This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', ...
        Annual_GHG_Emissions_Reduction_from_Solar_Percent * 100, Annual_GHG_Emissions_with_Solar_Only)
    
end


if Annual_GHG_Emissions_Reduction_from_Storage < 0
    sprintf('Installing energy storage INCREASES marginal carbon emissions \n by %0.2f metric tons per year.', ...
        -Annual_GHG_Emissions_Reduction_from_Storage)
    sprintf('This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', ...
        -Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, Annual_GHG_Emissions_with_Solar_and_Storage)
else
    sprintf('Installing energy storage DECREASES marginal carbon emissions \n by %0.2f metric tons per year.', ...
        Annual_GHG_Emissions_Reduction_from_Storage)
    sprintf('This is equivalent to %0.2f%% of baseline emissions, and brings total emissions to %0.2f metric tons per year.', ...
        Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, Annual_GHG_Emissions_with_Solar_and_Storage)
end


%% Report Grid Cost/Grid Impact

 Annual_Grid_Cost_Baseline = ""; % Placeholder
 
 Annual_Grid_Cost_with_Solar_Only = ""; % Placeholder
 
 Annual_Grid_Cost_with_Solar_and_Storage = ""; % Placeholder



%% Write Outputs to CSV

Model_Inputs_and_Outputs = table(Modeling_Team_Input, Model_Run_Number_Input, Model_Run_Date_Time, Model_Type_Input, ...
    Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Master_Index, ...
    Load_Profile_Name_Input, Retail_Rate_Master_Index, Retail_Rate_Utility, ...
    Retail_Rate_Name_Output, Retail_Rate_Effective_Date, ...
    Solar_Profile_Master_Index, Solar_Profile_Name_Output, Solar_Profile_Description, ...
    Solar_Size_Input, Storage_Type_Input, Storage_Power_Rating_Input, ...
    Usable_Storage_Capacity_Input, Single_Cycle_RTE_Input, Parasitic_Storage_Load_Input, ...
    Storage_Control_Algorithm_Name, Storage_Control_Algorithm_Description, ...
    Storage_Control_Algorithms_Parameters_Filename, ...  
    GHG_Reduction_Solution_Input, Equivalent_Cycling_Constraint_Input, ...
    Annual_RTE_Constraint_Input, ITC_Constraint_Input, ...
    Carbon_Adder_Incentive_Value_Input, Other_Incentives_or_Penalities, ...
    Emissions_Forecast_Signal_Input, ...
    Annual_GHG_Emissions_Baseline, Annual_GHG_Emissions_with_Solar_Only, ...
    Annual_GHG_Emissions_with_Solar_and_Storage, ...
    Annual_Customer_Bill_Baseline, Annual_Customer_Bill_with_Solar_Only, ...
    Annual_Customer_Bill_with_Solar_and_Storage, ...
    Annual_Grid_Cost_Baseline, Annual_Grid_Cost_with_Solar_Only, ...
    Annual_Grid_Cost_with_Solar_and_Storage, ...
    Annual_Equivalent_Storage_Cycles, Annual_RTE, Operational_Capacity_Factor, ...
    Annual_Demand_Charge_Cost_Baseline, Annual_Demand_Charge_Cost_with_Solar_Only, ...
    Annual_Demand_Charge_Cost_with_Solar_and_Storage, ...
    Annual_Energy_Charge_Cost_Baseline, Annual_Energy_Charge_Cost_with_Solar_Only, ...
    Annual_Energy_Charge_Cost_with_Solar_and_Storage, ...
    Annual_Peak_Demand_Baseline, Annual_Peak_Demand_with_Solar_Only, ...
    Annual_Peak_Demand_with_Solar_and_Storage, ...
    Annual_Total_Energy_Consumption_Baseline, Annual_Total_Energy_Consumption_with_Solar_Only, ...
    Annual_Total_Energy_Consumption_with_Solar_and_Storage, ...
    Output_Summary_Filename, Output_Description_Filename, Output_Visualizations_Filename, ...
    EV_Use, EV_Charge, EV_Gas_Savings, EV_GHG_Savings);

Storage_Dispatch_Outputs = table(t, P_ES);
Storage_Dispatch_Outputs.Properties.VariableNames = {'Date_Time_Pacific_No_DST', 'Storage_Output_kW'};

if Export_Data == 1
    
    writetable(Model_Inputs_and_Outputs, Output_Directory_Filepath + Output_Summary_Filename);
    
    writetable(Storage_Dispatch_Outputs, Output_Directory_Filepath + "Storage Dispatch Profile Output.csv");
    
end


%% Return to OSESMO Git Repository Directory

cd(OSESMO_Git_Repo_Directory)


end