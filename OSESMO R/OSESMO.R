## Script Description Header

# File Name: OSESMO.m
# File Location: "~/Desktop/OSESMO Git Repository"
# Project: Open-Source Energy Storage Model (OSESMO)
# Description: Simulates operation of energy storage system.
# Calculates customer savings, GHG reduction, and battery cycling.

OSESMO <- function(Modeling_Team_Input, Model_Run_Number_Input, Model_Type_Input,
                   Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Name_Input,
                   Retail_Rate_Name_Input, Export_Compensation_Rate_Name_Input,
                   Solar_Profile_Name_Input, Solar_Size_Input,
                   Storage_Power_Rating_Input, Storage_Energy_Capacity_Input,
                   Single_Cycle_RTE_Input,
                   ITC_Constraint_Input, Site_Export, ESS_Export,
                   Carbon_Adder_Incentive_Value_Input, Emissions_Signal_Input,
                   OSESMO_Git_Repo_Directory, Input_Output_Data_Directory_Location, Start_Time_Input,
                   Show_Plots, Export_Plots, Export_Data,
                   Solar_Installed_Cost_per_kW, Storage_Installed_Cost_per_kWh, Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh,
                   Cycle_Life, Initial_Final_SOC, End_of_Month_Padding_Days){
  
  ## Calculate Model Variable Values from User-Specified Input Values
  
  # Convert model timestep resolution input from minutes to hours.
  # This is a more useful format for the model to use.
  delta_t = (Model_Timestep_Resolution/60); # Model timestep resolution, in hours.
  
  # Convert storage efficiency from round-trip efficiency to charge and discharge efficiency.
  # Charge efficiency and discharge efficiency assumed to be square root of round-trip efficiency (Eff_c = Eff_d).
  # Round-trip efficiency taken from Lazard's Levelized Cost of Storage report (2017), pg. 130
  # https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf
  Eff_c = sqrt(Single_Cycle_RTE_Input);
  Eff_d = sqrt(Single_Cycle_RTE_Input);
  
  # Calculate battery energy capacity in kWh-DC
  # Storage nameplate is in kWh-AC, and represents the amount of usable energy delivered from a fully-charged battery.
  # To calculate the actual storage capacity in kWh-DC, divide by the discharge efficiency.
  Storage_Energy_Capacity_DC <- Storage_Energy_Capacity_Input/Eff_d
  
  # Set Solar Profile Name Input to "No Solar", set Solar Size Input to 0 kW,
  # and set ITC Constraint to 0 if Model Type Input is Storage Only.
  # This serves as error handling.
  
  if(Model_Type_Input == "Storage Only"){
    Solar_Profile_Name_Input = "No Solar";
    Solar_Size_Input = 0;
    ITC_Constraint_Input = 0;
  }
  
  # Throw an error if Model Type Input is set to Solar Plus Storage
  # and Solar Profile Name Input is set to "No Solar",
  # or if Solar Size Input is set to 0 kW.
  
  if(Model_Type_Input == "Solar Plus Storage"){
    if(Solar_Profile_Name_Input == "No Solar"){
      error("Solar Plus Storage Model selected, but No Solar Profile Name Input selected.")
    }
    
    if(Solar_Size_Input == 0){
      error("Solar Plus Storage Model selected, but Solar Size Input set to 0 kW.")
    }
  }
  
  # Cycling Penalty
  # Cycling penalty for lithium-ion battery is equal to estimated replacement cell cost in 10 years divided by expected cycle life.
  # As a result, value is in units of [$/cycle].
  cycle_pen = (Storage_Energy_Capacity_Input * Estimated_Future_Lithium_Ion_Battery_Installed_Cost_per_kWh) / Cycle_Life
  
  ## Import Data from CSV Files
  
  # Begin script runtime timer
  tstart = Sys.time();
  
  # Import Load Profile Data
  # Call Import_Load_Profile_Data function.
  source("Import_Load_Profile_Data.R")
  Load_Profile_Data_List <- Import_Load_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input)
  Load_Profile_Data <- Load_Profile_Data_List[[1]]
  Load_Profile_Master_Index <- Load_Profile_Data_List[[2]]
  rm(Load_Profile_Data_List)
  
  Annual_Peak_Demand_Baseline = max(Load_Profile_Data);
  Annual_Total_Energy_Consumption_Baseline = sum(Load_Profile_Data) * delta_t;
  
  # Import Marginal Emissions Rate Data Used as Forecast
  # Call Import_Marginal_Emissions_Rate_Forecast_Data function.
  source("Import_Marginal_Emissions_Rate_Data.R")
  Marginal_Emissions_Rate_Data = Import_Marginal_Emissions_Rate_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory,
                                                                     delta_t, Emissions_Signal_Input);
  
  
  # Import Carbon Adder Data
  # Carbon Adder ($/kWh) = Marginal Emissions Rate (metric tons CO2/MWh) *
  # Carbon Adder ($/metric ton) * (1 MWh/1000 kWh)
  Carbon_Adder_Data = (Marginal_Emissions_Rate_Data *
                         Carbon_Adder_Incentive_Value_Input)/1000;
  
  
  # Import Retail Rate Data
  # Call Import_Retail_Rate_Data() function.
  source("Import_Retail_Rate_Data.R")
  Retail_Rate_Data_List <- Import_Retail_Rate_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Retail_Rate_Name_Input)
  Retail_Rate_Master_Index <- Retail_Rate_Data_List[[1]]
  Retail_Rate_Effective_Date <- Retail_Rate_Data_List[[2]]
  Volumetric_Rate_Data <- Retail_Rate_Data_List[[3]]
  Summer_Peak_DC <- Retail_Rate_Data_List[[4]]
  Summer_Peak_DC_Period <- Retail_Rate_Data_List[[5]]
  Summer_Part_Peak_DC <- Retail_Rate_Data_List[[6]]
  Summer_Part_Peak_DC_Period <- Retail_Rate_Data_List[[7]] 
  Summer_Special_Maximum_DC <- Retail_Rate_Data_List[[8]] 
  Summer_Special_Maximum_DC_Period <- Retail_Rate_Data_List[[9]] 
  Summer_Noncoincident_DC <- Retail_Rate_Data_List[[10]] 
  Summer_Noncoincident_DC_Period <- Retail_Rate_Data_List[[11]]
  Winter_Peak_DC <- Retail_Rate_Data_List[[12]] 
  Winter_Peak_DC_Period <- Retail_Rate_Data_List[[13]] 
  Winter_Part_Peak_DC <- Retail_Rate_Data_List[[14]] 
  Winter_Part_Peak_DC_Period <- Retail_Rate_Data_List[[15]] 
  Winter_Special_Maximum_DC <- Retail_Rate_Data_List[[16]] 
  Winter_Special_Maximum_DC_Period <- Retail_Rate_Data_List[[17]] 
  Winter_Noncoincident_DC <- Retail_Rate_Data_List[[18]] 
  Winter_Noncoincident_DC_Period <- Retail_Rate_Data_List[[19]] 
  Fixed_Per_Meter_Day_Charge <- Retail_Rate_Data_List[[20]] 
  Fixed_Per_Meter_Month_Charge <- Retail_Rate_Data_List[[21]] 
  First_Summer_Month <- Retail_Rate_Data_List[[22]] 
  Last_Summer_Month <- Retail_Rate_Data_List[[23]] 
  Month_Data <- Retail_Rate_Data_List[[24]]  
  Day_Data <- Retail_Rate_Data_List[[25]] 
  Summer_Peak_Binary_Data <- Retail_Rate_Data_List[[26]]  
  Summer_Part_Peak_Binary_Data <- Retail_Rate_Data_List[[27]] 
  Winter_Peak_Binary_Data <- Retail_Rate_Data_List[[28]] 
  Winter_Part_Peak_Binary_Data <- Retail_Rate_Data_List[[29]] 
  Special_Maximum_Demand_Binary_Data <- Retail_Rate_Data_List[[30]]
  rm(Retail_Rate_Data_List)
  
  # Import Export-Compensation-Rate Data
  # Call Import_Export_Compensation_Rate_Data() function.
  if(Export_Compensation_Rate_Name_Input == "NEM 1"){
    Export_Compensation_Rate_Data = Volumetric_Rate_Data
  }else{
    source("Import_Export_Compensation_Rate_Data.R")
    Export_Compensation_Rate_Data <- Import_Export_Compensation_Rate_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Export_Compensation_Rate_Name_Input)
  }
  
  # Import Solar PV Generation Profile Data
  # Scale base 10-kW or 100-kW profile to match user-input PV system size
  if(Model_Type_Input == "Solar Plus Storage"){
    source("Import_Solar_PV_Profile_Data.R")
    Solar_PV_Profile_Data_List <- Import_Solar_PV_Profile_Data(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t,
                                                               Solar_Profile_Name_Input, Solar_Size_Input)
    Solar_Profile_Master_Index <- Solar_PV_Profile_Data_List[[1]]
    Solar_Profile_Description <- Solar_PV_Profile_Data_List[[2]]
    Solar_PV_Profile_Data <- Solar_PV_Profile_Data_List[[3]]
    rm(Solar_PV_Profile_Data_List)
    
  }else if(Model_Type_Input == "Storage Only" || Solar_Profile_Name_Input == "No Solar"){
    Solar_Profile_Master_Index = "";
    Solar_Profile_Description = "";
    Solar_PV_Profile_Data = rep(0, length(Load_Profile_Data))
  }
  
  
  # Import Utility Marginal Cost Data
  source("Import_Utility_Avoided_Cost_Data.R")
  Utility_Marginal_Cost_Data_List <- Import_Utility_Marginal_Cost_Data(Input_Output_Data_Directory_Location,
                                                                       OSESMO_Git_Repo_Directory, delta_t,
                                                                       Load_Profile_Name_Input)
  Marginal_Energy_Cost_Data <- Utility_Marginal_Cost_Data_List[[1]]
  Marginal_Generation_Capacity_Cost_Data <- Utility_Marginal_Cost_Data_List[[2]]
  rm(Utility_Marginal_Cost_Data_List)
  
  # Set Directory to Box Sync Folder
  setwd(Input_Output_Data_Directory_Location)
  
  
  ## Non-Retail-Rate Export Compensation (NREC) eligibility:
  # 1. Buy rate doesn't equal sell rate, AND
  # 2. Export is physically possible with this load profile and DER sizes: min(Demand - PV - Max_Battery_Power < 0), AND
  # 3. Export is allowed for this site.
  
  nrec <- any(Volumetric_Rate_Data != Export_Compensation_Rate_Data) &&
    min(Load_Profile_Data-Solar_PV_Profile_Data,na.rm=T)-Storage_Power_Rating_Input<0 && 
    Site_Export > 0
  
  ## PV Curtailment eligibility:
  # Curtailment is possible if there is PV, AND
  # 1. Import rate is less than or equal to $0/kWh at any point, OR
  # 2. Export rate is less than or equal to $0/kWh at any point, OR
  # 3. Demand net of the original PV profile (without any curtailment) goes below the allowed site export limits.
  pvAny <- Solar_Size_Input > 0
  pvCurt <- pvAny && (any(Volumetric_Rate_Data < 0) || any(Export_Compensation_Rate_Data < 0) || any(Load_Profile_Data-Solar_PV_Profile_Data < -Site_Export))
  
  ## Iterate Through Months & Filter Data to Selected Month
  
  # Initialize Blank Variables to store optimal decision variable values for
  # all months
  
  # Initialize Decision Variable Vectors
  P_ES_in = c()
  
  P_ES_out = c()
  
  Ene_Lvl = c()
  
  P_max_NC = c()
  
  P_special_max = c()
  
  P_max_peak = c()
  
  P_max_part_peak = c()
  
  
  # Initialize Monthly Cost Variable Vectors
  Fixed_Charge_Vector = c()
  
  SM_DC_Baseline_Vector = c()
  SM_DC_with_Solar_Only_Vector = c()
  SM_DC_with_Solar_and_Storage_Vector = c()
  
  NC_DC_Baseline_Vector = c()
  NC_DC_with_Solar_Only_Vector = c()
  NC_DC_with_Solar_and_Storage_Vector = c()
  
  CPK_DC_Baseline_Vector = c()
  CPK_DC_with_Solar_Only_Vector = c()
  CPK_DC_with_Solar_and_Storage_Vector = c()
  
  CPP_DC_Baseline_Vector = c()
  CPP_DC_with_Solar_Only_Vector = c()
  CPP_DC_with_Solar_and_Storage_Vector = c()
  
  Energy_Charge_Baseline_Vector = c()
  Energy_Charge_with_Solar_Only_Vector = c()
  Energy_Charge_with_Solar_and_Storage_Vector = c()
  
  Cycles_Vector = c()
  Cycling_Penalty_Vector = c()
  
  
  for(Month_Iter in 1:12){ # Iterate through all months
    
    # Filter Load Profile Data to Selected Month
    Load_Profile_Data_Month = Load_Profile_Data[which(Month_Data == Month_Iter)]
    
    # Filter PV Production Profile Data to Selected Month
    Solar_PV_Profile_Data_Month = Solar_PV_Profile_Data[which(Month_Data == Month_Iter)]
    
    # Filter Volumetric Rate Data to Selected Month
    Volumetric_Rate_Data_Month = Volumetric_Rate_Data[which(Month_Data == Month_Iter)]
    
    # Filter Export Compensation Rate Data to Selected Month
    Export_Compensation_Rate_Data_Month = Export_Compensation_Rate_Data[which(Month_Data == Month_Iter)]
    
    # Filter Marginal Emissions Data to Selected Month
    Marginal_Emissions_Rate_Data_Month = Marginal_Emissions_Rate_Data[which(Month_Data == Month_Iter)]
    
    # Filter Carbon Adder Data to Selected Month
    Carbon_Adder_Data_Month = Carbon_Adder_Data[which(Month_Data == Month_Iter)]
    
    # Set Demand Charge Values Based on Month
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){     
      Peak_DC = Summer_Peak_DC;
      Part_Peak_DC = Summer_Part_Peak_DC;
      Special_Maximum_DC = Summer_Special_Maximum_DC;
      Noncoincident_DC = Summer_Noncoincident_DC;
      
      Peak_DC_Period = Summer_Peak_DC_Period;
      Part_Peak_DC_Period = Summer_Part_Peak_DC_Period;
      Special_Maximum_DC_Period = Summer_Special_Maximum_DC_Period;
      Noncoincident_DC_Period = Summer_Noncoincident_DC_Period;
      
    }else{      
      Peak_DC = Winter_Peak_DC;
      Part_Peak_DC = Winter_Part_Peak_DC;
      Special_Maximum_DC = Winter_Special_Maximum_DC;
      Noncoincident_DC = Winter_Noncoincident_DC;
      
      Peak_DC_Period = Winter_Peak_DC_Period;
      Part_Peak_DC_Period = Winter_Part_Peak_DC_Period;
      Special_Maximum_DC_Period = Winter_Special_Maximum_DC_Period;
      Noncoincident_DC_Period = Winter_Noncoincident_DC_Period;       
    }
    
    
    # Filter Peak and Part-Peak Binary Data to Selected Month
    
    if(Summer_Peak_DC > 0){
      Summer_Peak_Binary_Data_Month = Summer_Peak_Binary_Data[which(Month_Data == Month_Iter)]
    }
    
    if(Summer_Part_Peak_DC > 0){
      Summer_Part_Peak_Binary_Data_Month = Summer_Part_Peak_Binary_Data[which(Month_Data == Month_Iter)]
    }
    
    if(Winter_Peak_DC > 0){
      Winter_Peak_Binary_Data_Month = Winter_Peak_Binary_Data[which(Month_Data == Month_Iter)]
    }
    
    if(Winter_Part_Peak_DC > 0){
      Winter_Part_Peak_Binary_Data_Month = Winter_Part_Peak_Binary_Data[which(Month_Data == Month_Iter)]
    }
    
    if(Special_Maximum_DC > 0){
      Special_Maximum_Demand_Binary_Data_Month = Special_Maximum_Demand_Binary_Data[which(Month_Data == Month_Iter)]
    }
    
    # Filter Day Data to Selected Month
    if(length(Day_Data) > 0){
      Day_Data_Month = Day_Data[which(Month_Data == Month_Iter)]
      unpaddedMonthDays <- Day_Data_Month[length(Day_Data_Month)]
    }
    
    ## Add "Padding" to Every Month of Data
    # Don't pad Month 12, because the final state of charge is constrained
    # to equal the original state of charge.
    
    if(Month_Iter %in% 1:11){
      
      Month_End_Index <- length(Load_Profile_Data_Month) # Last interval in the current month iteration.
      
      # Pad Load Profile Data
      Load_Profile_Data_Month_Padded = c(Load_Profile_Data_Month,
                                         Load_Profile_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      # Pad PV Production Profile Data
      Solar_PV_Profile_Data_Month_Padded = c(Solar_PV_Profile_Data_Month,
                                             Solar_PV_Profile_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      # Pad Volumetric Rate Data
      Volumetric_Rate_Data_Month_Padded = c(Volumetric_Rate_Data_Month,
                                            Volumetric_Rate_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      # Pad Export Compensation Rate Data
      Export_Compensation_Rate_Data_Month_Padded = c(Export_Compensation_Rate_Data_Month,
                                                     Export_Compensation_Rate_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      # Pad Marginal Emissions Data
      Marginal_Emissions_Rate_Data_Month_Padded = c(Marginal_Emissions_Rate_Data_Month,
                                                    Marginal_Emissions_Rate_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      # Pad Carbon Adder Data 
      Carbon_Adder_Data_Month_Padded = c(Carbon_Adder_Data_Month,
                                         Carbon_Adder_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      
      
      # Pad Peak and Part-Peak Binary Data
      
      if(Summer_Peak_DC > 0){
        Summer_Peak_Binary_Data_Month_Padded = c(Summer_Peak_Binary_Data_Month,
                                                 Summer_Peak_Binary_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      }
      
      if(Summer_Part_Peak_DC > 0){
        Summer_Part_Peak_Binary_Data_Month_Padded = c(Summer_Part_Peak_Binary_Data_Month,
                                                      Summer_Part_Peak_Binary_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      }
      
      if(Winter_Peak_DC > 0){
        Winter_Peak_Binary_Data_Month_Padded = c(Winter_Peak_Binary_Data_Month,
                                                 Winter_Peak_Binary_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      }
      
      if(Winter_Part_Peak_DC > 0){
        Winter_Part_Peak_Binary_Data_Month_Padded = c(Winter_Part_Peak_Binary_Data_Month,
                                                      Winter_Part_Peak_Binary_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      }
      
      if(Special_Maximum_DC > 0){
        Special_Maximum_Demand_Binary_Data_Month_Padded = c(Special_Maximum_Demand_Binary_Data_Month,
                                                            Special_Maximum_Demand_Binary_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index])
      }
      
      
      # Pad Day Data (ex. add days "32", "33", and "34")
      if(length(Day_Data) > 0){
        Day_Data_Month_Padding = Day_Data_Month[(Month_End_Index-(End_of_Month_Padding_Days * 24 * (1/delta_t) - 1)):Month_End_Index]
        Day_Data_Month_Padding = Day_Data_Month_Padding + 3
        Day_Data_Month_Padded = c(Day_Data_Month, Day_Data_Month_Padding)
      }
      
      
    }else if(Month_Iter == 12){
      
      # Don't Pad Load Profile Data
      Load_Profile_Data_Month_Padded = Load_Profile_Data_Month;
      
      # Don't Pad PV Production Profile Data
      Solar_PV_Profile_Data_Month_Padded = Solar_PV_Profile_Data_Month;
      
      # Don't Pad Volumetric Rate Data
      Volumetric_Rate_Data_Month_Padded = Volumetric_Rate_Data_Month;
      
      # Pad Export Compensation Rate Data
      Export_Compensation_Rate_Data_Month_Padded = Export_Compensation_Rate_Data_Month
      
      # Don't Pad Marginal Emissions Data
      Marginal_Emissions_Rate_Data_Month_Padded = Marginal_Emissions_Rate_Data_Month
      
      # Don't Pad Carbon Adder Data
      Carbon_Adder_Data_Month_Padded = Carbon_Adder_Data_Month;
      
      # Don't Pad Peak and Part-Peak Binary Data
      
      if(Summer_Peak_DC > 0){
        Summer_Peak_Binary_Data_Month_Padded = Summer_Peak_Binary_Data_Month;
      }
      
      if(Summer_Part_Peak_DC > 0){
        Summer_Part_Peak_Binary_Data_Month_Padded = Summer_Part_Peak_Binary_Data_Month;
      }
      
      if(Winter_Peak_DC > 0){
        Winter_Peak_Binary_Data_Month_Padded = Winter_Peak_Binary_Data_Month;
      }
      
      if(Winter_Part_Peak_DC > 0){
        Winter_Part_Peak_Binary_Data_Month_Padded = Winter_Part_Peak_Binary_Data_Month;
      }
      
      if(Special_Maximum_DC > 0){
        Special_Maximum_Demand_Binary_Data_Month_Padded = Special_Maximum_Demand_Binary_Data_Month;
      }
      
    }
    
    
    
    ## Initialize Objective/Cost Function ("c" Vector, or "obj")
    # The total cost to be minimized is (c_1 * x_1 + c_2 * x_2 + . . . c_n * x_n), where x is the vector of decision variables.
    # These decision variables are broken out in "Optimization Solution and Decision Variable Parsing" below.
    # The vector of decision variables is {xGridConsumption, xGridDemand, xStorageIn, xStorageOUt, xStorageSOC, xSolar},
    # and the corresponding vector of costs is {cGridConsumption, cGridDemand, cStorageIn, cStorageOut, cStorageSOC, cSolar}.
    # The lengths of these vectors is saved to {mGridConsumption, mGridDemand, mStorageIn, mStorageOut, mStorageSOC, mSolar}.
    
    n <- length(Load_Profile_Data_Month_Padded) # n is the number of timesteps in the optimization horizon.
    n_unpadded <- length(Load_Profile_Data_Month)
    paddedMonthDays <- Day_Data_Month_Padded[length(Day_Data_Month_Padded)]
    
    # xGridConsumption: Decision variables related to electricity consumption. [kW-AC]
    # Import means that grid is supplying power, export means that grid is accepting power.
    # Length 2*n if non-retail export compensation {xGridConsumptionImport, xGridConsumptionExport}, otherwise length n {xGridConsumption}.
    # Decision variables are located at the customer meter, at the point of utility interconnection.
    
    # cGridConsumption includes volumetric [$/kWh-AC] energy rates, and costs associated with carbon emissions converted to [$/kWh-AC] .
    if(nrec){
      cGridConsumptionImport <- (Volumetric_Rate_Data_Month_Padded * delta_t) + (Carbon_Adder_Data_Month_Padded * delta_t)
      cGridConsumptionExport <- (Export_Compensation_Rate_Data_Month_Padded * delta_t) + (Carbon_Adder_Data_Month_Padded * delta_t)
      cGridConsumption <- c(cGridConsumptionImport, cGridConsumptionExport)
    } else{
      cGridConsumption <- (Volumetric_Rate_Data_Month_Padded * delta_t) + (Carbon_Adder_Data_Month_Padded * delta_t)
    }
    
    mGridConsumption <- ifelse(nrec, 2 * n, 1 * n) # Imports and exports each have separate decision variables for Non-Retail Export Compensation case.
    
    # xGridExportBinary: Binary decision variables related to whether site is exporting to grid.
    # Equal to 0 during timesteps when site is importing; equal to 1 during timesteps when site is exporting.
    # Only needed for timesteps where rateExport is greater than rateImport.
    # These variables serve to constrain xGridConsumptionImport and xGridConsumptionExport,
    # so that the model does not try to do an infinite amount of simultaneous import and export.
    
    # cGridExportBinary represents costs inherent associated with whether the site is exporting (and not the amount of export), which are nonexistent in this model.
    mGridExportBinary <- if(nrec) sum(Export_Compensation_Rate_Data_Month_Padded > Volumetric_Rate_Data_Month_Padded) else 0
    
    if(nrec && mGridExportBinary > 1){
      cGridExportBinary <- rep(0, mGridExportBinary)
    } else{
      cGridExportBinary <- NULL
    }
    
    
    # xGridDemand: Decision variables related to maximum net electricity demand. [kW-AC]
    # Length equal to the number of demand charges.
    # Decision variable is located at the customer meter, at the point of utility interconnection.
    
    # cGridDemand includes demand charges [$/kW-AC].
    cGridDemand <- c()
    if(Noncoincident_DC_Period == "Monthly"){
      cGridDemand <- c(cGridDemand, Noncoincident_DC)
    }else if(Noncoincdient_DC_Period == "Daily"){
      cGridDemand <- c(cGridDemand, rep(Noncoincident_DC, paddedMonthDays))
    }
    
    if(Special_Maximum_DC_Period == "Monthly"){
      cGridDemand <- c(cGridDemand, Special_Maximum_DC)
    }else if(Special_Maximum_DC_Period == "Daily"){
      cGridDemand <- c(cGridDemand, rep(Special_Maximum_DC, paddedMonthDays))
    }
    
    if(Peak_DC_Period == "Monthly"){
      cGridDemand <- c(cGridDemand, Peak_DC)
    }else if(Peak_DC_Period == "Daily"){
      cGridDemand <- c(cGridDemand, rep(Peak_DC, paddedMonthDays))
    }
    
    if(Part_Peak_DC_Period == "Monthly"){
      cGridDemand <- c(cGridDemand, Part_Peak_DC)
    }else if(Part_Peak_DC_Period == "Daily"){
      cGridDemand <- c(cGridDemand, rep(Part_Peak_DC, paddedMonthDays))
    }
    
    mGridDemand <- length(cGridDemand)
    
    
    # xStorage: Decision variables related to energy storage system.
    # xStorageIn describes the charging of the battery,
    # xStorageOut describes the discharging of the battery, and
    # xStorageSOC describes the energy level of the battery (state of charge, but in kWh-DC rather than in %).
    # Length 3 * n: (xStorageIn [kW], xStorageOut [kW], xStorageSOC [kWh-DC]).
    # xStorageIn and xStorageOut are [kW-AC] for AC-coupled solar-plus-storage systems.
    # For AC-coupled systems, decision variable is located on the AC side of the ESS inverter
    # (between the ESS inverter and the AC bus that the customer meter, loads, and PV inverter are connected to).
    
    # cStorage includes cycling/degradation costs associated with charging and discharging, along with a State of Charge cost.
    # Positive cycling cost for both charging and discharging.
    # Zero cost associated with State of charge in this model.
    costCycleIn <- (cycle_pen * delta_t * Eff_c)/(2*Storage_Energy_Capacity_DC) # ([$/cycle] * [h] * [kWh-DC/kWh-AC]) / ([1 charge + 1 discharge/cycle] * [kWh-DC])
    costCycleOut <- (cycle_pen * delta_t)/(Eff_d*2*Storage_Energy_Capacity_DC) # ([$/cycle] * [h]) / ([1 charge + 1 discharge/cycle] * [kWh-DC] * [kWh-AC/kWh-DC])
    
    cStorageIn <- if(Storage_Energy_Capacity_DC > 0) rep(costCycleIn, n) else NULL
    cStorageOut <- if(Storage_Energy_Capacity_DC > 0) rep(costCycleOut, n) else NULL
    cStorageSOC <- if(Storage_Energy_Capacity_DC > 0) rep(0, n) else NULL
    
    cStorage <- c(cStorageIn,
                  cStorageOut,
                  cStorageSOC)
    
    mStorage <- if(Storage_Energy_Capacity_DC > 0) (3 * n) else 0 # n decision variables for storage charging, n for storage discharging, and n for storage energy level.
    
    
    # xSolar: Decision variables related to photovoltaic solar systems.
    # Length n. [kW-AC] for AC-coupled solar-plus-storage systems.
    # For AC-coupled systems, decision variable is located on the AC side of the PV inverter
    # (between the PV inverter and the AC bus that the customer meter, loads, and ESS inverter are connected to).
    
    # cSolar represents costs inherently associated with operating the PV system, which are nonexistent in this model.
    cSolar <- if(pvCurt) rep(0, n) else NULL
    
    mSolar <- ifelse(pvCurt, n, 0) # Solar has its own decision variables if there is a potential need for curtailment.
    
    
    
    # Concatenate costs into an objective-function vector
    obj <- c(cGridConsumption, cGridExportBinary, cGridDemand, cStorage, cSolar)
    
    m <- mGridConsumption + mGridExportBinary + mGridDemand + mStorage + mSolar # m is the total number of decision variables.
    
    ## Calculate Decision Variable Indices
    xGridConsumptionIndices <- 1:mGridConsumption # Length 2 * n if NREC, otherwise length n.
    if(nrec){
      xGridConsumptionImportIndices <- 1:(mGridConsumption/2) # First n indices, corresponding to Imports
      xGridConsumptionExportIndices <- (xGridConsumptionImportIndices[length(xGridConsumptionImportIndices)] + 1):mGridConsumption # Second n indices, corresponding to Exports
    }
    
    # Number of grid export binary indices is length mGridExportBinary (number of intervals where export rate > import rate)
    xGridExportBinaryIndices <- if(mGridExportBinary) mGridConsumption + (1:mGridExportBinary) else NULL
    
    # Number of grid demand indices is based on the number of demand charges, and whether they are monthly or daily.
    xGridDemandIndices <- if(mGridDemand) (mGridConsumption+mGridExportBinary) + (1:mGridDemand) else NULL
    
    if(Noncoincident_DC_Period == "Monthly"){
      P_max_NC_Indices = mGridConsumption+mGridExportBinary+1
    }else if(Noncoincdient_DC_Period == "Daily"){
      P_max_NC_Indices = 3 * n + (1:paddedMonthDays)    
    }
    
    if(Special_Maximum_DC_Period == "Monthly"){
      P_special_max_Indices = P_max_NC_Indices[length(P_max_NC_Indices)] + 1
    }else if(Special_Maximum_DC_Period == "Daily"){
      P_special_max_Indices = P_max_NC_Indices[length(P_max_NC_Indices)] + (1:paddedMonthDays)
    }
    
    if(Peak_DC_Period == "Monthly"){
      P_max_peak_Indices = P_special_max_Indices[length(P_special_max_Indices)] + 1;
    }else if(Peak_DC_Period == "Daily"){
      P_max_peak_Indices = P_special_max_Indices[length(P_special_max_Indices)] + (1:paddedMonthDays);
    }
    
    if(Part_Peak_DC_Period == "Monthly"){
      P_max_part_peak_Indices = P_max_peak_Indices[length(P_max_peak_Indices)] + 1;
    }else if(Part_Peak_DC_Period == "Daily"){
      P_max_part_peak_Indices = P_max_peak_Indices[length(P_max_peak_Indices)] + (1:paddedMonthDays);
    }
    
    
    # Number of storage indices is equal to 3 * n
    xStorageIndices <- if(Storage_Energy_Capacity_DC>0) (mGridConsumption+mGridExportBinary+mGridDemand) + (1:mStorage) else NULL
    xStorageInIndices <- if(Storage_Energy_Capacity_DC>0) xStorageIndices[1]:xStorageIndices[length(cStorage)/3] else NULL # n timesteps' worth of charging decision variables,
    xStorageOutIndices <- if(Storage_Energy_Capacity_DC>0) xStorageIndices[length(cStorage)/3 + 1]:xStorageIndices[length(cStorage)*2/3] else NULL # n timesteps' worth of dicharging decision variables,
    xStorageSOCIndices <- if(Storage_Energy_Capacity_DC>0) xStorageIndices[length(cStorage)*2/3 + 1]:xStorageIndices[length(cStorage)] else NULL # n timesteps' worth of state-of-charge decision variables,
    
    # Number of solar indices is equal to n (number of timesteps' worth of solar-curtailment decision variables).
    xSolarIndices <- if(pvCurt) (mGridConsumption+mGridExportBinary+mGridDemand+mStorage) + (1:mSolar) else NULL
    
    
    ## Construct Optimization Constraints
    
    # Initialize left-hand-side coefficients matric ("A"/"mat"), (in)equality symbol vector ("dir"), and right-hand-side constants vector ("b"/"rhs")
    mat <- NULL
    dir <- NULL
    rhs <- NULL
    
    
    # Energy Balance Constraint
    # This constraint requires that generation and supply must be equal in all timesteps.
    
    # For t in {1:n}:
    # If solar-plus-storage system is AC-coupled:
    # xGridConsumption(t) - Demand(t) + xSolar(t) - xStorageIn(t) + xStorageOut(t) = 0
    # xGridConsumption(t) - xStorageIn(t) + xStorageOut(t) + xSolar(t) = Demand(t)
    
    # If solar is curtailed, xSolar is included in the decision variables, and only Demand(t) appears as a constant in the right-hand-side vector.
    # If solar is not curtailed, xSolar is not included in the decision variables, and Demand(t) - PV(t) appears as a constant in the right-hand-side vector.
    
    # Number of rows in each inequality constraint matrix: n
    # Number of columns in each inequality constraint matrix: m
    
    i <- seq(n)
    A_Balance <- matrix(0, n, m)
    if(nrec){
      A_Balance[cbind(i, xGridConsumptionImportIndices[i])] <- 1 # xGridConsumptionImport(t)
      A_Balance[cbind(i, xGridConsumptionExportIndices[i])] <- -1 # xGridConsumptionExport(t)
    }else{
      A_Balance[cbind(i, xGridConsumptionIndices[i])] <- 1 # xGridConsumption(t)
    }
    
    if(Storage_Energy_Capacity_DC > 0){
      A_Balance[cbind(i, xStorageInIndices[i])] <- -1 # xStorageIn(t)
      A_Balance[cbind(i, xStorageOutIndices[i])] <- 1 # xStorageOut(t)
    }
    
    if(pvCurt){
      A_Balance[cbind(i, xSolarIndices[i])] <- 1 # xSolar(t)
    }
    
    dir_Balance <- rep("==", n)
    
    b_Balance <- if(pvCurt) Load_Profile_Data_Month_Padded else Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded
    
    mat <- rbind(mat, A_Balance)
    dir <- c(dir, dir_Balance)
    rhs <- c(rhs, b_Balance)
    
    
    ## ESS State of Charge Constraints
    
    # This constraint represents conservation of energy as it flows into and out of the
    # energy storage system, while accounting for efficiency losses.
    if(Storage_Energy_Capacity_DC > 0){
      A_SOC <- matrix(0,n+1,m) # Rows 1:(n-1) are used for the first constraint equation; row n is used for the initial SOC, row (n+1) is used for the final SOC.
      
      # For t in {1:(n-1)}:
      # xStorageSOC(t+1) = xStorageSOC(t) + [Eff_c * xStorageIn(t) - (1/Eff_d) * xStorageOut(t)] * hours
      # xStorageSOC(t) - xStorageSOC(t+1) + (Eff_c * xStorageIn(t) * hours) - ((1/Eff_d) * xStorageOut(t) * hours) = 0
      i <- seq(n-1)
      A_SOC[cbind(i, xStorageSOCIndices[i])] <- 1 # xStorageSOC(t)
      A_SOC[cbind(i, xStorageSOCIndices[i+1])] <- -1 # xStorageSOC(t+1)
      A_SOC[cbind(i, xStorageInIndices[i])] <- Eff_c * delta_t # xStorageIn(t)
      A_SOC[cbind(i, xStorageOutIndices[i])] <- (-1/Eff_d) * delta_t # xStorageOut(t)
      b_SOC <- rep(0, n-1)
      
      # Initial State of Charge Constraint
      # In the first month, this constraint initializes the battery state of charge at a user-defined percentage of the original battery capacity.
      # xStorageSOC(1) = Initial_Final_SOC * Storage_Energy_Capacity_DC
      # In all other month, this constraints initializes the battery state of charge based on the final state of charge and power in/out from the previous month.
      # xStorageSOC(1) = Next_Month_Initial_Energy_Level
      A_SOC[cbind(n, xStorageSOCIndices[1])] <- 1 # xStorageSOC(1)
      b_SOC <- if(Month_Iter == 1) c(b_SOC, Initial_Final_SOC * Storage_Energy_Capacity_DC) else c(b_SOC, Next_Month_Initial_Energy_Level)
      
      # Final State of Charge Constraints
      # This constraint fixes the final attery state of charge at a user-defined percentage of the original battery capacity,
      # to prevent it from discharging completely in the final timesteps.
      # xStorageSOC(N) = Initial_Final_SOC * Storage_Energy_Capacity_DC
      A_SOC[cbind(n+1, xStorageSOCIndices[n])] <- 1 # xStorageSOC(N)
      b_SOC <- c(b_SOC, Initial_Final_SOC * Storage_Energy_Capacity_DC)
      
      dir_SOC <- rep("==", n+1)
      
      mat <- rbind(mat, A_SOC)
      dir <- c(dir, dir_SOC)
      rhs <- c(rhs, b_SOC)
    }
    
    
    ## Demand Charge Constraints
    # These constraints are part of the minimax transformation used to linearize the demand charge formulation.
    # Setting the maximum net demand values as decision variables incentivizes
    # "demand capping" to reduce the value of max(xGridConsumption(t)) to an optimal level
    # without using the nonlinear max() operator in the objective function.
    
    # xGridConsumption(t) <= xGridDemand for all t in each demand charge period
    # xGridConsumption(t) - xGridDemand <= 0 for all t in each demand charge period
    
    # Noncoincident Demand Charge Constraint
    # This demand charge applies across all timesteps.
    # Note: this logic only works for monthly demand charges.
    if(Noncoincident_DC > 0){
      i <- seq(n)
      A_NC_DC <- matrix(0,n,m)
      if(nrec){
        A_NC_DC[cbind(i, xGridConsumptionImportIndices[i])] <- 1 # xGridConsumptionImport(t)
        A_NC_DC[cbind(i, xGridConsumptionExportIndices[i])] <- -1 # xGridConsumptionExport(t)
      }else{
        A_NC_DC[cbind(i, xGridConsumptionIndices[i])] <- 1 # xGridConsumption(t)
      }
      A_NC_DC[cbind(i, P_max_NC_Indices)] <- -1 # xGridDemand corresponding to the selected demand charge.
      dir_NC_DC <- rep("<=", n)
      b_NC_DC <- rep(0, n)
      mat <- rbind(mat, A_NC_DC)
      dir <- c(dir, dir_NC_DC)
      rhs <- c(rhs, b_NC_DC)
    }
    
    # Special Maximum Demand Charge Constraint
    # Note: this logic only works for monthly demand charges.
    # This demand charge only applies for the hours where this demand charge is active (all hours except 9:00 am - 2:00 pm for PG&E B-19 Option S).
    if(Special_Maximum_DC > 0){
      i <- seq(n)
      j <- i[which(Special_Maximum_Demand_Binary_Data_Month_Padded == 1)]
      k <- length(j)
      i <- seq(k)
      A_SM_DC <- matrix(0,k,m)
      if(nrec){
        A_SM_DC[cbind(i, xGridConsumptionImportIndices[j])] <- 1 # xGridConsumptionImport(t)
        A_SM_DC[cbind(i, xGridConsumptionExportIndices[j])] <- -1 # xGridConsumptionExport(t)
      }else{
        A_SM_DC[cbind(i, xGridConsumptionIndices[j])] <- 1 # xGridConsumption(t)
      }
      A_SM_DC[cbind(i, P_special_max_Indices)] <- -1 # xGridDemand corresponding to the selected demand charge.
      dir_SM_DC <- rep("<=", k)
      b_SM_DC <- rep(0, k)
      mat <- rbind(mat, A_SM_DC)
      dir <- c(dir, dir_SM_DC)
      rhs <- c(rhs, b_SM_DC)
    }
    
    # Coincident Peak Demand Charge Constraint
    # This demand charge only applies for peak hours.
    if(Peak_DC > 0){
      i <- seq(n)
      if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
        j <- i[which(Summer_Peak_Binary_Data_Month_Padded == 1)]
      }else{
        j <- i[which(Winter_Peak_Binary_Data_Month_Padded == 1)]
      }
      k <- length(j)
      i <- seq(k)
      A_CPK_DC = matrix(0,k,m)
      if(Peak_DC_Period == "Monthly"){
        if(nrec){
          A_CPK_DC[cbind(i, xGridConsumptionImportIndices[j])] <- 1 # xGridConsumptionImport(t)
          A_CPK_DC[cbind(i, xGridConsumptionExportIndices[j])] <- -1 # xGridConsumptionExport(t)
        }else{
          A_CPK_DC[cbind(i, xGridConsumptionIndices[j])] <- 1 # xGridConsumption(t)
        }
        A_CPK_DC[cbind(i, P_max_peak_Indices)] <- -1 # xGridDemand corresponding to the selected demand charge.
      }else if(Peak_DC_Period == "Daily"){
        if(nrec){
          A_CPK_DC[cbind(i, xGridConsumptionImportIndices[j])] <- 1 # xGridConsumptionImport(t)
          A_CPK_DC[cbind(i, xGridConsumptionExportIndices[j])] <- -1 # xGridConsumptionExport(t)
        }else{
          A_CPK_DC[cbind(i, xGridConsumptionIndices[j])] <- 1 # xGridConsumption(t)
        }
        A_CPK_DC[cbind(i, P_max_peak_Indices[Day_Data_Month_Padded[j]])] <- -1 # xGridDemand corresponding to the selected demand charge.
      }
      dir_CPK_DC <- rep("<=", k)
      b_CPK_DC <- rep(0, k)
      mat <- rbind(mat, A_CPK_DC)
      dir <- c(dir, dir_CPK_DC)
      rhs <- c(rhs, b_CPK_DC)
    }
    
    # Coincident Part-Peak Demand Charge Constraint
    # This demand charge only applies for part-peak hours.
    if(Part_Peak_DC > 0){
      i <- seq(n)
      if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
        j <- i[which(Summer_Part_Peak_Binary_Data_Month_Padded == 1)]
      }else{
        j <- i[which(Winter_Part_Peak_Binary_Data_Month_Padded == 1)]
      }
      k <- length(j)
      i <- seq(k)
      A_CPP_DC = matrix(0,k,m)
      if(Part_Peak_DC_Period == "Monthly"){
        if(nrec){
          A_CPP_DC[cbind(i, xGridConsumptionImportIndices[j])] <- 1 # xGridConsumptionImport(t)
          A_CPP_DC[cbind(i, xGridConsumptionExportIndices[j])] <- -1 # xGridConsumptionExport(t)
        }else{
          A_CPP_DC[cbind(i, xGridConsumptionIndices[j])] <- 1 # xGridConsumption(t)
        }
        A_CPP_DC[cbind(i, P_max_peak_Indices)] <- -1 # xGridDemand corresponding to the selected demand charge.
      }else if(Part_Peak_DC_Period == "Daily"){
        if(nrec){
          A_CPP_DC[cbind(i, xGridConsumptionImportIndices[j])] <- 1 # xGridConsumptionImport(t)
          A_CPP_DC[cbind(i, xGridConsumptionExportIndices[j])] <- -1 # xGridConsumptionExport(t)
        }else{
          A_CPP_DC[cbind(i, xGridConsumptionIndices[j])] <- 1 # xGridConsumption(t)
        }
        A_CPP_DC[cbind(i, P_max_peak_Indices[Day_Data_Month_Padded[j]])] <- -1 # xGridDemand corresponding to the selected demand charge.
      }
      dir_CPP_DC <- rep("<=", k)
      b_CPP_DC <- rep(0, k)
      mat <- rbind(mat, A_CPP_DC)
      dir <- c(dir, dir_CPP_DC)
      rhs <- c(rhs, b_CPP_DC)
    }
    
    
    ## Site Export Constraint
    # This constraint adds a lower bound on net site load (xGridConsumption).
    # For instance, a site might only be able to perform limited export to the grid (Site_Export > 0 but not Inf).
    # alternatively, it might not be able to export to the gird at all (Site_Export = 0).
    # Finally, it might be required to be importing power at or above a minimum-import limit (export < 0 but not -Inf).
    
    # For t in {1:n}
    # xGridConsumption(t) >= -Site_Export
    # -xGridConsumption(t) <= Site_Export
    
    if(Site_Export != Inf){
      i <- seq(n)
      A_Site_Export <- matrix(0,n,m)
      if(nrec){
        A_Site_Export[cbind(i, xGridConsumptionImportIndices[i])] <- -1 # xGridConsumptionImport(t)
        A_Site_Export[cbind(i, xGridConsumptionExportIndices[i])] <- 1 # xGridConsumptionExport(t)
      }else{
        A_Site_Export[cbind(i, xGridConsumptionIndices[i])] <- -1 # xGridConsumption(t)
      }
      
      dir_Site_Export <- rep("<=",n)
      b_Site_Export <- rep(Site_Export,n)
      
      mat <- rbind(mat, A_Site_Export)
      dir <- c(dir, dir_Site_Export)
      rhs <- c(rhs, b_Site_Export)
    }
    
    
    ## ESS Export Constraint
    # If this constraint is active, the site is allowed to export (ex. due to excess PV), but the ESS cannot.
    # This means that the net grid consumption profile is lower-bounded at the minimum of net-of-solar-only demand and 0 kW.
    # xGridConsumption(t) >= min(Demand(t) - PV(t), 0)
    if(Storage_Energy_Capacity_DC > 0 && Site_Export > 0 && ESS_Export == FALSE){
      i <- seq(n)
      A_ESS_Export <- matrix(0,n,m)
      if(nrec){
        A_ESS_Export[cbind(i, xGridConsumptionImportIndices[i])] <- 1 # xGridConsumptionImport(t)
        A_ESS_Export[cbind(i, xGridConsumptionExportIndices[i])] <- -1 # xGridConsumptionExport(t)
      }else{
        A_ESS_Export[cbind(i, xGridConsumptionIndices[i])] <- 1 # xGridConsumption(t)
      }
      
      dir_ESS_Export <- rep("<=",n)
      b_ESS_Export <- pmin(Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded, 0)
      
      mat <- rbind(mat, A_ESS_Export)
      dir <- c(dir, dir_ESS_Export)
      rhs <- c(rhs, b_ESS_Export)
    }
    
    
    ## Simultaneous Import & Export Constraint
    # This constraint uses the xGridExportBinary variables to prevent the site from simultaneously importing from and exporting to the grid.
    # To keep the number of binary variables down, this constraint only applies to timesteps where the export rate is higher than the import rate.
    # During all other timesteps, when the import rate is greater than or equal to the export rate,
    # there's no economic incentive to perform simultaneous import and export.
    
    # This constraint leverages the "Big M" technique, where M is traditionally an arbitrarily large number.
    # Here, M is a vector rather than a scalar, and different vectors are used for import and export.
    # The Big M Import vector is equal to the largest possible amount of import at each timestep.
    # The Big M Export vector is equal to the largest possible amount of export at each timestep.
    # See the "Bounds on xGridConsumption" section below to see how these maximum-import and maximum-export values are calculated.
    # When combined with binary variables, Big M constraints can be used to ensure that other variables are either held at 0 or effectively unbounded.
    
    # xGridConsumptionImport(t) <= Big_M_Import * (1 - xGridExportBinary(t)) for all t where Export_Rate(t) > Import_Rate(t)
    # xGridConsumptionImport(t) + Big_M_Import * xGridExportBinary(t) <= Big_M_Import for all t where Export_Rate(t) > Import_Rate(t)
    
    # xGridConsumptionExport(t) <= Big_M_Export * xGridExportBinary(t) for all t where Export_Rate(t) > Import_Rate(t)
    # xGridConsumptionExport(t) - Big_M_Export * xGridExportBinary(t) <= 0 for all t where Export_Rate(t) > Import_Rate(t)
    if(nrec && mGridExportBinary > 0){
      i <- seq(mGridExportBinary)
      exportRateGreaterTimesteps <- which(Export_Compensation_Rate_Data_Month_Padded > Volumetric_Rate_Data_Month_Padded)
      
      # Maximum Possible Import in Each Timestep
      Big_M_Import <- Load_Profile_Data_Month_Padded[exportRateGreaterTimesteps] - min(Solar_PV_Profile_Data_Month_Padded[exportRateGreaterTimesteps]) + Storage_Power_Rating_Input
      
      # Maximum Possible Export in Each Timestep
      Big_M_Export <- -(Load_Profile_Data_Month_Padded[exportRateGreaterTimesteps] - Solar_PV_Profile_Data_Month_Padded[exportRateGreaterTimesteps] - Storage_Power_Rating_Input)
      
      A_Export_Binary <- matrix(0, 2*mGridExportBinary, m) # number of rows = 2x number of binary variables (constraints for both import and export).
      A_Export_Binary[cbind(i, xGridConsumptionImportIndices[exportRateGreaterTimesteps])] <- 1 # xGridConsumptionImport(t)
      A_Export_Binary[cbind(i, xGridExportBinaryIndices[i])] <- Big_M_Import # xGridExportBinary(t)
      A_Export_Binary[cbind(mGridExportBinary+i, xGridConsumptionExportIndices[exportRateGreaterTimesteps])] <- 1 # xGridConsumptionExport(t)
      A_Export_Binary[cbind(mGridExportBinary+i, xGridExportBinaryIndices[i])] <- -Big_M_Export # xGridExportBinary(t)
      
      dir_Export_Binary <- rep("<=", 2*mGridExportBinary)
      b_Export_Binary <- c(Big_M_Import, rep(0, mGridExportBinary))
      
      mat <- rbind(mat, A_Export_Binary)
      dir <- c(dir, dir_Export_Binary)
      rhs <- c(rhs, b_Export_Binary)
    }
    
    
    ## Solar-Only-Charging Constraint for Investment Tax Credit Compliance
    # This constraint requires that the storage system be charged 100% from solar.
    # The most common reason for enabling this constraint is to ensure that the customer receives 100% of the solar Incentive Tax Credit.
    # The ITC amount is prorated by the amount of energy entering into the battery that comes from solar
    # (ex. a storage system charged 90% from solar receives 90% of the ITC). 
    # As a result, the optimal amount of solar charging is likely higher
    # than the minimum requirement of 75%, and likely very close to 100%.
    
    # If solar is being curtailed:
    # xStorageIn(t) <= xSolar(t)
    # xStorageIn(t) - xSolar(t) <= 0
    # If solar is not being curtailed:
    # xStorageIn(t) <= Solar(t)
    
    if(Storage_Energy_Capacity_Input > 0 && Solar_Size_Input > 0 && ITC_Constraint_Input == TRUE){
      i <- seq(n)
      A_ITC <- matrix(0,n,m)
      A_ITC[cbind(i, xStorageInIndices[i])] <- 1 # xStorageIn(t)
      
      if(pvCurt){
        A_ITC[cbind(i, xSolarIndices[i])] <- -1 # xSolar(t)  
        b_ITC <- rep(0,n)
      }else{
        # Sometimes nighttime AC-PV profiles are negative at night due to inverter load. Setting negatives to 0 kW to make optimization feasible.
        b_ITC <- pmax(Solar_PV_Profile_Data_Month_Padded, 0)
      }
      dir_ITC <- rep("<=", n)
      
      mat <- rbind(mat, A_ITC)
      dir <- c(dir, dir_ITC)
      rhs <- c(rhs, b_ITC)
    }
    
    
    ## Optimization Bounds
    
    # Bounds on xGridConsumption
    # For the NREC case, xGridConsumptionImport(t) and xGridConsumptionExport(t) are separate decision variables and must both be positive.
    # Otherwise, xGridConsumption(t) can be positive or negative (positive for import, negative for export).
    # To prevent the problem from becoming unbounded (due to simultaneous grid import and export),
    # bounds are set equal to the minimum/maximum physically possible grid import/export, rather than setting to +/- Inf.
    if(nrec){
      # For NREC case, both xGridConsumptionImport and xGridConsumptionExport have lower bounds at 0 kW, because these variables are defined as non-negative.
      lowerGridConsumption <- rep(0, mGridConsumption)
      
      # For NREC case, the upper bounds on xGridConsumptionImport are based on the gross demand profile,
      # solar PV fully curtailed to 0 kW or even a negative inverter-power-draw value, and the ESS charging at full power in all intervals.
      upperGridConsumptionImport <- pmax(Load_Profile_Data_Month_Padded - min(Solar_PV_Profile_Data_Month_Padded) + Storage_Power_Rating_Input, 0)
      
      # For NREC case, the upper bounds on xGridConsumptionExport are based on the net-of-solar profile plus the ESS discharging at full power in all intervals.
      upperGridConsumptionExport <- pmax(-(Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded - Storage_Power_Rating_Input), 0)
      
      upperGridConsumption <- c(upperGridConsumptionImport, upperGridConsumptionExport)
    }else{
      # For non-NREC case, the lower bounds on xGridConsumption are based on the net-of-solar profile plus the ESS discharging at full power in all intervals.
      lowerGridConsumption <- Load_Profile_Data_Month_Padded - Solar_PV_Profile_Data_Month_Padded - Storage_Power_Rating_Input
      
      # For non-NREC case, the upper bounds on xGridConsumption are based on the gross demand profile,
      # solar PV fully curtailed to 0 kW or even a negative inverter-power-draw value, and the ESS charging at full power in all intervals.
      upperGridConsumption <- Load_Profile_Data_Month_Padded - min(Solar_PV_Profile_Data_Month_Padded) + Storage_Power_Rating_Input
    }
    
    # Bounds on xGridExportBinary
    # Binary variables are bounded between 0 and 1.
    lowerGridExportBinary <- if(mGridExportBinary) rep(0, mGridExportBinary) else NULL
    upperGridExportBinary <- if(mGridExportBinary) rep(1, mGridExportBinary) else NULL
    
    # Bounds on xGridDemand
    # Lower bound on xGridDemand is 0 kW.
    # Upper bound on xGridDemand is based on the maximum possible net demand in the current time horizon.
    # This maximum possible net demand value is based on the maximum gross demand, minimum solar production, and the ESS charging at full power.
    # The alternative would be to have the upper bound be Inf, but having an infinite feasible region (solution space)
    # can result in the solver returning a status of "LP HAS UNBOUNDED PRIMAL SOLUTION" if inputs included negative demand-charge values.
    # Having a finite feasible region helps ensure that the solver finds an optimal solution.
    lowerGridDemand <- if(mGridDemand > 0) rep(0, mGridDemand) else NULL
    maxPossibleNetDemand <- max(max(Load_Profile_Data_Month_Padded) - min(Solar_PV_Profile_Data_Month_Padded) + Storage_Power_Rating_Input, 0) # Floor at 0 kW.
    upperGridDemand <- if(mGridDemand > 0) rep(maxPossibleNetDemand, mGridDemand) else NULL
    
    # Bounds on xStorageIn
    # xStorageIn must be positive, and cannot exceed the nameplate storage power rating.
    if(Storage_Energy_Capacity_Input != 0){
      lowerStorageIn <- rep(0, n)
      upperStorageIn <- rep(Storage_Power_Rating_Input, n)
    }else{
      lowerStorageIn <- NULL
      upperStorageIn <- NULL
    }
    
    # Bounds on xStorageOut
    # xStorageOut must be positive, and cannot exceed the nameplate storage power rating.
    if(Storage_Energy_Capacity_Input != 0){
      lowerStorageOut <- rep(0, n)
      upperStorageOut <- rep(Storage_Power_Rating_Input, n)
    }else{
      lowerStorageOut <- NULL
      upperStorageOut <- NULL
    }
    
    # Bounds on xStorageSOC
    if(Storage_Energy_Capacity_Input != 0){
      lowerStorageSOC <- rep(0, n)
      upperStorageSOC <- rep(Storage_Energy_Capacity_DC, n)
    }else{
      lowerStorageSOC <- NULL
      upperStorageSOC <- NULL
    }
    
    # Bounds on xSolar
    # These bounds ensure that the PV production decision variables are less than or equal to the PV production vector provided as input data.
    # This results in a PV profile that is equal to the maximum PV production vector wherever possible, while still allowing for PV curtailment when needed.
    # Note that PV(t) can sometimes be negative for some AC-PV profiles, if the solar inverter is consuming energy at night.
    # During dispatch simulation, this PV profile is floored at 0 kW to avoid an issue during solar-only charging
    # where xStorageIn(t) <= xSolar(t) and xStorageIn(t) >= 0, and xSolar(t) includes values that are below 0 kW.
    # This minor modification to the solar profile is corrected for during post-simulation calculations before calculating bill savings.
    if(pvCurt){
      lowerSolar <- rep(0, n)
      upperSolar <- pmax(Solar_PV_Profile_Data_Month_Padded, 0)
    }else{
      lowerSolar <- NULL
      upperSolar <- NULL
    }
    
    bounds <- list(lower=list(ind=seq(m),
                              val=c(lowerGridConsumption, lowerGridExportBinary, lowerGridDemand,
                                    lowerStorageIn, lowerStorageOut, lowerStorageSOC,
                                    lowerSolar)),
                   upper=list(ind=seq(m),
                              val=c(upperGridConsumption, upperGridExportBinary, upperGridDemand,
                                    upperStorageIn, upperStorageOut, upperStorageSOC,
                                    upperSolar)))
    
    types <- rep("C", m) # "C" for continuous
    if(mGridExportBinary > 0 && mGridExportBinary <= 12) types[xGridExportBinaryIndices] <- "B" # "B" for binary.
    # Runtime approximately doubles for every binary variable added.
    # Set threshold arbitrarily at 12 binary variables so as to prevent simultaneous import-export in cases where export $/kWh rate exceeds import $/kWh rate in only a few intervals,
    # without creating unreasonably-long runtimes in cases where export rate exceeds import rate in many or all intervals.
    # Even with the xGridExportBinary variables set to continuous rather than binary, the Simultaneous Import & Export constraint combined with the bounds on xGridConsumption
    # should ensure that DERs dispatch in a reasonable way even if the solver output includes simultaneous import and export.
    
    max <- F # This is a minimization problem, not a maximization problem.
    
    
    ## Optimization Solution and Decision Variable Parsing
    lp = Rglpk::Rglpk_solve_LP(obj, mat, dir, rhs,bounds=bounds,types,max) # For more information about what's hapening inside the solver, include "canonicalize_status=F,verbose=T"
    if(lp$status != 0) warning(paste0("GLPK did not successfully return a feasible and optimal result for Month ", Month_Iter, ". Problem may be overconstrained."))
    print(paste("Optimization complete for Month", Month_Iter))
    xMonth <- lp$solution
    
    if(nrec){
      xGridConsumptionImport <- xMonth[xGridConsumptionImportIndices]
      xGridConsumptionExport <- xMonth[xGridConsumptionExportIndices]
      
      # Check for simultaneous import/export, using tolerance of 10^-5 instead of just "!=0"
      # See note about binary variables and simultaneous import/export above. DER dispatch may still be reasonable even if solver output includes simultaneous import and export.
      if(any(abs(xGridConsumptionImport) >= 1e-5 & abs(xGridConsumptionExport) >= 1e-5)){
        warning(paste0("Site is simultaneously importing from the grid and exporting to the grid during Month ", Month_Iter, "."))
      }
      
      xGridConsumption <- xGridConsumptionImport - xGridConsumptionExport
    }else{
      xGridConsumption <- xMonth[xGridConsumptionIndices]
    }
    
    xGridExportBinary <- if(mGridExportBinary) xMonth[xGridExportBinaryIndices] else NULL
    
    if(mGridDemand){
      P_max_NC_Month_Padded = xMonth[P_max_NC_Indices]
      P_special_max_Month_Padded = xMonth[P_special_max_Indices]
      P_max_peak_Month_Padded = xMonth[P_max_peak_Indices]
      P_max_part_peak_Month_Padded = xMonth[P_max_part_peak_Indices]
    }
    
    P_ES_in_Month_Padded <- if(Storage_Energy_Capacity_Input > 0) xMonth[xStorageInIndices] else rep(0, n)
    P_ES_out_Month_Padded <- if(Storage_Energy_Capacity_Input > 0) xMonth[xStorageOutIndices] else rep(0, n)
    Ene_Lvl_Month_Padded <- if(Storage_Energy_Capacity_Input > 0) xMonth[xStorageSOCIndices] else rep(0, n)
    
    # Debugging - check for simultaneous ESS charge/discharge, using tolerance of 10^-5 instead of just "!=0"
    if(any(abs(P_ES_in_Month_Padded) >= 1e-5 & abs(P_ES_out_Month_Padded) >= 1e-5)){
      # warning(paste0("ESS battery is simultaneously charging and discharging during Month ", Month_Iter, "."))
    }
    
    P_PV_Month_Padded <- if(pvCurt) xMonth[xSolarIndices] else NULL
    
    
    ## Remove "Padding" from Decision Variables
    
    # Data is padded in Months 1-11, and not in Month 12
    
    if(Month_Iter %in% 1:11){
      
      P_ES_in_Month_Unpadded = P_ES_in_Month_Padded[1:n_unpadded]
      
      P_ES_out_Month_Unpadded = P_ES_out_Month_Padded[1:n_unpadded]
      
      Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded[1:n_unpadded]
      
      if(Noncoincident_DC_Period == "Monthly"){
        P_max_NC_Month_Unpadded = P_max_NC_Month_Padded;
      }else if(Noncoincident_DC_Period == "Daily"){
        P_max_NC_Month_Unpadded = P_max_NC_Month_Padded[1:(paddedMonthDays-End_of_Month_Padding_Days)]
      }
      
      if(Special_Maximum_DC_Period == "Monthly"){
        P_special_max_Month_Unpadded = P_special_max_Month_Padded;
      }else if(Special_Maximum_DC_Period == "Daily"){
        P_special_max_Month_Unpadded = P_special_max_Month_Padded[1:(paddedMonthDays-End_of_Month_Padding_Days)]
      }
      
      if(Peak_DC_Period == "Monthly"){
        P_max_peak_Month_Unpadded = P_max_peak_Month_Padded;
      }else if(Peak_DC_Period == "Daily"){
        P_max_peak_Month_Unpadded = P_max_peak_Month_Padded[1:(paddedMonthDays-End_of_Month_Padding_Days)]
      }
      
      if(Part_Peak_DC_Period == "Monthly"){
        P_max_part_peak_Month_Unpadded = P_max_part_peak_Month_Padded;
      }else if(Part_Peak_DC_Period == "Daily"){
        P_max_part_peak_Month_Unpadded = P_max_part_peak_Month_Padded[1:(paddedMonthDays-End_of_Month_Padding_Days)]
      }
      
      
    }else if(Month_Iter == 12){
      
      P_ES_in_Month_Unpadded = P_ES_in_Month_Padded
      
      P_ES_out_Month_Unpadded = P_ES_out_Month_Padded
      
      Ene_Lvl_Month_Unpadded = Ene_Lvl_Month_Padded
      
      P_max_NC_Month_Unpadded = P_max_NC_Month_Padded
      P_special_max_Month_Unpadded = P_special_max_Month_Padded
      P_max_peak_Month_Unpadded = P_max_peak_Month_Padded
      P_max_part_peak_Month_Unpadded = P_max_part_peak_Month_Padded
      
    }
    
    # Save Final Energy Level of Battery for use in next month
    
    Previous_Month_Final_Energy_Level = Ene_Lvl_Month_Unpadded[length(Ene_Lvl_Month_Unpadded)]
    
    Next_Month_Initial_Energy_Level = Previous_Month_Final_Energy_Level +
      ((Eff_c * P_ES_in_Month_Unpadded[length(P_ES_in_Month_Unpadded)]) -
         ((1/Eff_d) * P_ES_out_Month_Unpadded[length(P_ES_out_Month_Unpadded)])) * delta_t
    
    
    ## Calculate Peak Demand
    
    # Noncoincident Maximum Demand With and Without Storage
    # Note: this logic only works for monthly demand charges.
    P_max_NC_Month_Baseline = max(Load_Profile_Data_Month)
    P_max_NC_Month_with_Solar_Only = max(Load_Profile_Data_Month - Solar_PV_Profile_Data_Month)
    P_max_NC_Month_with_Solar_and_Storage = P_max_NC_Month_Unpadded
    
    
    # Special Maximum Demand With and Without Storage
    # Note: this logic only works for monthly demand charges.
    if(Special_Maximum_DC > 0){
      P_special_max_Month_Baseline = max(Load_Profile_Data_Month[which(Special_Maximum_Demand_Binary_Data_Month == 1)])
      
      P_special_max_Month_with_Solar_Only = max(Load_Profile_Data_Month[which(Special_Maximum_Demand_Binary_Data_Month == 1)] -
                                                  Solar_PV_Profile_Data_Month[which(Special_Maximum_Demand_Binary_Data_Month == 1)])
      
      P_special_max_Month_with_Solar_and_Storage = P_special_max_Month_Unpadded     
    }else{
      # If there is no Coincident Peak Demand Period (or if the
      # corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
      P_special_max_Month_Baseline = 0;
      P_special_max_Month_with_Solar_Only = 0;
      P_special_max_Month_with_Solar_and_Storage = 0;     
    }
    
    
    # Coincident Peak Demand With and Without Storage
    
    if(Peak_DC > 0){
      
      if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){ # Summer Months
        
        if(Peak_DC_Period == "Monthly"){
          P_max_CPK_Month_Baseline = max(Load_Profile_Data_Month[which(Summer_Peak_Binary_Data_Month == 1)])
          
          P_max_CPK_Month_with_Solar_Only = max(Load_Profile_Data_Month[which(Summer_Peak_Binary_Data_Month == 1)] -
                                                  Solar_PV_Profile_Data_Month[which(Summer_Peak_Binary_Data_Month == 1)])
          
        }else if(Peak_DC_Period == "Daily"){
          P_max_CPK_Month_Baseline = c()
          P_max_CPK_Month_with_Solar_Only = c()
          
          for(n in 1:unpaddedMonthDays){
            Load_Profile_Data_Day = Load_Profile_Data_Month[which(Day_Data_Month == n)]
            Solar_PV_Profile_Data_Day = Solar_PV_Profile_Data_Month[which(Day_Data_Month == n)]
            Summer_Peak_Binary_Data_Day = Summer_Peak_Binary_Data_Month[which(Day_Data_Month == n)]
            P_max_CPK_Month_Baseline = c(P_max_CPK_Month_Baseline, max(Load_Profile_Data_Day[which(Summer_Peak_Binary_Data_Day == 1)]))
            P_max_CPK_Month_with_Solar_Only = c(P_max_CPK_Month_with_Solar_Only, max(Load_Profile_Data_Day[which(Summer_Peak_Binary_Data_Day == 1)] -
                                                                                       Solar_PV_Profile_Data_Day[which(Summer_Peak_Binary_Data_Day == 1)]))
          }
          
        }
        
      }else{ # Winter Months
        
        if(Peak_DC_Period == "Monthly"){
          P_max_CPK_Month_Baseline = max(Load_Profile_Data_Month[which(Winter_Peak_Binary_Data_Month == 1)])
          
          P_max_CPK_Month_with_Solar_Only = max(Load_Profile_Data_Month[which(Winter_Peak_Binary_Data_Month == 1)] -
                                                  Solar_PV_Profile_Data_Month[which(Winter_Peak_Binary_Data_Month == 1)])
          
        }else if(Peak_DC_Period == "Daily"){
          
          P_max_CPK_Month_Baseline = c()
          P_max_CPK_Month_with_Solar_Only = c()
          
          for(n in 1:unpaddedMonthDays){
            Load_Profile_Data_Day = Load_Profile_Data_Month[which(Day_Data_Month == n)]
            Solar_PV_Profile_Data_Day = Solar_PV_Profile_Data_Month[which(Day_Data_Month == n)]
            Winter_Peak_Binary_Data_Day = Winter_Peak_Binary_Data_Month[which(Day_Data_Month == n)]
            P_max_CPK_Month_Baseline = c(P_max_CPK_Month_Baseline, max(Load_Profile_Data_Day[which(Winter_Peak_Binary_Data_Day == 1)]))
            P_max_CPK_Month_with_Solar_Only = c(P_max_CPK_Month_with_Solar_Only, max(Load_Profile_Data_Day[which(Winter_Peak_Binary_Data_Day == 1)] -
                                                                                       Solar_PV_Profile_Data_Day[which(Winter_Peak_Binary_Data_Day == 1)])) 
          }
          
        }
        
        
      }
      
      P_max_CPK_Month_with_Solar_and_Storage = P_max_peak_Month_Unpadded
      
    }else{
      
      # If there is no Coincident Peak Demand Period (or if the
      # corresponding demand charge is $0/kW), set P_max_CPK to 0 kW.
      P_max_CPK_Month_Baseline = 0
      P_max_CPK_Month_with_Solar_Only = 0
      P_max_CPK_Month_with_Solar_and_Storage = 0
      
    }
    
    
    # Coincident Part-Peak Demand With and Without Storage
    
    if(Part_Peak_DC > 0){
      
      if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){ # Summer Months
        
        if(Part_Peak_DC_Period == "Monthly"){
          P_max_CPP_Month_Baseline = max(Load_Profile_Data_Month[which(Summer_Part_Peak_Binary_Data_Month == 1)])
          
          P_max_CPP_Month_with_Solar_Only = max(Load_Profile_Data_Month[which(Summer_Part_Peak_Binary_Data_Month == 1)] -
                                                  Solar_PV_Profile_Data_Month[which(Summer_Part_Peak_Binary_Data_Month == 1)])
          
        }else if(Part_Peak_DC_Period == "Daily"){
          P_max_CPP_Month_Baseline = c()
          P_max_CPP_Month_with_Solar_Only = c()
          
          for(n in 1:unpaddedMonthDays){
            Load_Profile_Data_Day = Load_Profile_Data_Month[which(Day_Data_Month == n)]
            Solar_PV_Profile_Data_Day = Solar_PV_Profile_Data_Month[which(Day_Data_Month == n)]
            Summer_Part_Peak_Binary_Data_Day = Summer_Part_Peak_Binary_Data_Month[which(Day_Data_Month == n)]
            P_max_CPP_Month_Baseline = c(P_max_CPP_Month_Baseline, max(Load_Profile_Data_Day[which(Summer_Part_Peak_Binary_Data_Day == 1)]))
            P_max_CPP_Month_with_Solar_Only = c(P_max_CPP_Month_with_Solar_Only, max(Load_Profile_Data_Day[which(Summer_Part_Peak_Binary_Data_Day == 1)] -
                                                                                       Solar_PV_Profile_Data_Day[which(Summer_Part_Peak_Binary_Data_Day == 1)]))
          }
          
        }
        
      }else{ # Winter Months
        
        if(Part_Peak_DC_Period == "Monthly"){
          P_max_CPP_Month_Baseline = max(Load_Profile_Data_Month[which(Winter_Part_Peak_Binary_Data_Month == 1)])
          
          P_max_CPP_Month_with_Solar_Only = max(Load_Profile_Data_Month[which(Winter_Part_Peak_Binary_Data_Month == 1)] -
                                                  Solar_PV_Profile_Data_Month[which(Winter_Part_Peak_Binary_Data_Month == 1)])
          
        }else if(Part_Peak_DC_Period == "Daily"){
          P_max_CPP_Month_Baseline = c()
          P_max_CPP_Month_with_Solar_Only = c()
          
          for(n in 1:unpaddedMonthDays){
            Load_Profile_Data_Day = Load_Profile_Data_Month[which(Day_Data_Month == n)]
            Solar_PV_Profile_Data_Day = Solar_PV_Profile_Data_Month[which(Day_Data_Month == n)]
            Winter_Part_Peak_Binary_Data_Day = Winter_Part_Peak_Binary_Data_Month[which(Day_Data_Month == n)]
            P_max_CPP_Month_Baseline = c(P_max_CPP_Month_Baseline, max(Load_Profile_Data_Day[which(Winter_Part_Peak_Binary_Data_Day == 1)]))
            P_max_CPP_Month_with_Solar_Only = c(P_max_CPP_Month_with_Solar_Only, max(Load_Profile_Data_Day[which(Winter_Part_Peak_Binary_Data_Day == 1)] -
                                                                                       Solar_PV_Profile_Data_Day[which(Winter_Part_Peak_Binary_Data_Day == 1)]))
          }
          
        }
        
      }
      
      P_max_CPP_Month_with_Solar_and_Storage = P_max_part_peak_Month_Unpadded
      
    }else{
      
      # If there is no Coincident Part-Peak Demand Period (or if the
      # corresponding demand charge is $0/kW), set P_max_CPP to 0 kW.
      P_max_CPP_Month_Baseline = 0
      P_max_CPP_Month_with_Solar_Only = 0
      P_max_CPP_Month_with_Solar_and_Storage = 0
      
    }
    
    
    ## Calculate Monthly Bill Cost with and Without Storage
    
    # Monthly Cost from Daily Fixed Charge
    # This value is not affected by the presence of storage.
    Fixed_Charge_Month = Fixed_Per_Meter_Month_Charge + (Fixed_Per_Meter_Day_Charge * length(Load_Profile_Data_Month)/(24 * (1/delta_t)))
    
    # Monthly Cost from Noncoincident Demand Charge - Baseline
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      NC_Demand_Charge_Month_Baseline = sum(Summer_Noncoincident_DC * P_max_NC_Month_Baseline)
    }else{
      NC_Demand_Charge_Month_Baseline = sum(Winter_Noncoincident_DC * P_max_NC_Month_Baseline)
    }
    
    # Monthly Cost from Noncoincident Demand Charge - With Solar Only
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      NC_Demand_Charge_Month_with_Solar_Only = sum(Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_Only)
    }else{
      NC_Demand_Charge_Month_with_Solar_Only = sum(Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_Only)
    }
    
    # Monthly Cost from Noncoincident Demand Charge - With Solar and Storage
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      NC_Demand_Charge_Month_with_Solar_and_Storage = sum(Summer_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage);
    }else{
      NC_Demand_Charge_Month_with_Solar_and_Storage = sum(Winter_Noncoincident_DC * P_max_NC_Month_with_Solar_and_Storage);
    }
    
    
    # Monthly Cost from Special Maximum Demand Charge - Baseline
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      SM_Demand_Charge_Month_Baseline = sum(Summer_Special_Maximum_DC * P_special_max_Month_Baseline);
    }else{
      SM_Demand_Charge_Month_Baseline = sum(Winter_Special_Maximum_DC * P_special_max_Month_Baseline);
    }
    
    
    # Monthly Cost from Special Maximum Demand Charge - With Solar Only
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      SM_Demand_Charge_Month_with_Solar_Only = sum(Summer_Special_Maximum_DC * P_special_max_Month_with_Solar_Only);
    }else{
      SM_Demand_Charge_Month_with_Solar_Only = sum(Winter_Special_Maximum_DC * P_special_max_Month_with_Solar_Only);
    }
    
    
    # Monthly Cost from Special Maximum Demand Charge - With Solar and Storage
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      SM_Demand_Charge_Month_with_Solar_and_Storage = sum(Summer_Special_Maximum_DC * P_special_max_Month_with_Solar_and_Storage);
    }else{
      SM_Demand_Charge_Month_with_Solar_and_Storage = sum(Winter_Special_Maximum_DC * P_special_max_Month_with_Solar_and_Storage);
    }
    
    
    
    # Monthly Cost from Coincident Peak Demand Charge - Baseline
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPK_Demand_Charge_Month_Baseline = sum(Summer_Peak_DC * P_max_CPK_Month_Baseline);
    }else{
      CPK_Demand_Charge_Month_Baseline = sum(Winter_Peak_DC * P_max_CPK_Month_Baseline);
    }
    
    
    # Monthly Cost from Coincident Peak Demand Charge - With Solar Only
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPK_Demand_Charge_Month_with_Solar_Only = sum(Summer_Peak_DC * P_max_CPK_Month_with_Solar_Only);
    }else{
      CPK_Demand_Charge_Month_with_Solar_Only = sum(Winter_Peak_DC * P_max_CPK_Month_with_Solar_Only);
    }
    
    
    # Monthly Cost from Coincident Peak Demand Charge - With Solar and Storage
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPK_Demand_Charge_Month_with_Solar_and_Storage = sum(Summer_Peak_DC * P_max_CPK_Month_with_Solar_and_Storage);
    }else{
      CPK_Demand_Charge_Month_with_Solar_and_Storage = sum(Winter_Peak_DC * P_max_CPK_Month_with_Solar_and_Storage);
    }
    
    
    # Monthly Cost from Coincident Part-Peak Demand Charge - Baseline
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPP_Demand_Charge_Month_Baseline = sum(Summer_Part_Peak_DC * P_max_CPP_Month_Baseline);
    }else{
      CPP_Demand_Charge_Month_Baseline = sum(Winter_Part_Peak_DC * P_max_CPP_Month_Baseline);
    }
    
    
    # Monthly Cost from Coincident Part-Peak Demand Charge - With Solar Only
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPP_Demand_Charge_Month_with_Solar_Only = sum(Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only);
    }else{
      CPP_Demand_Charge_Month_with_Solar_Only = sum(Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_Only);
    }
    
    
    # Monthly Cost from Coincident Part-Peak Demand Charge - With Solar and Storage
    
    if(Month_Iter %in% First_Summer_Month:Last_Summer_Month){
      CPP_Demand_Charge_Month_with_Solar_and_Storage = sum(Summer_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage);
    }else{
      CPP_Demand_Charge_Month_with_Solar_and_Storage = sum(Winter_Part_Peak_DC * P_max_CPP_Month_with_Solar_and_Storage);
    }
    
    
    # Monthly Cost from Volumetric Energy Rates - Baseline
    if(nrec){
      Energy_Charge_Month_Baseline = sum(pmax(Load_Profile_Data_Month,0) * Volumetric_Rate_Data_Month * delta_t) +
        sum(pmin(Load_Profile_Data_Month,0) * Export_Compensation_Rate_Data_Month * delta_t)
    }else{
      Energy_Charge_Month_Baseline = sum(Load_Profile_Data_Month * Volumetric_Rate_Data_Month * delta_t)
    }
    
    # Monthly Cost from Volumetric Energy Rates - With Solar Only
    Solar_Only_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month
    if(nrec){
      Energy_Charge_Month_with_Solar_Only = sum(pmax(Solar_Only_Net_Load_Profile_Month,0) * Volumetric_Rate_Data_Month * delta_t) +
        sum(pmin(Solar_Only_Net_Load_Profile_Month,0) * Export_Compensation_Rate_Data_Month * delta_t)
    }else{
      Energy_Charge_Month_with_Solar_Only = sum(Solar_Only_Net_Load_Profile_Month * Volumetric_Rate_Data_Month * delta_t)
    }
    
    # Monthly Cost from Volumetric Energy Rates - With Solar and Storage
    Solar_Storage_Net_Load_Profile_Month = Load_Profile_Data_Month - Solar_PV_Profile_Data_Month + P_ES_in_Month_Unpadded - P_ES_out_Month_Unpadded
    if(nrec){
      Energy_Charge_Month_with_Solar_and_Storage = sum(pmax(Solar_Storage_Net_Load_Profile_Month,0) * Volumetric_Rate_Data_Month * delta_t) +
        sum(pmin(Solar_Storage_Net_Load_Profile_Month,0) * Export_Compensation_Rate_Data_Month * delta_t)
    }else{
      Energy_Charge_Month_with_Solar_and_Storage = sum(Solar_Storage_Net_Load_Profile_Month * Volumetric_Rate_Data_Month * delta_t)
    }
    
    
    # Monthly Cycling Penalty
    
    Cycles_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c)/(2 *Storage_Energy_Capacity_DC)) * delta_t)) +
                         (P_ES_out_Month_Unpadded * ((1/(Eff_d * 2 * Storage_Energy_Capacity_DC)) * delta_t)));
    
    Cycling_Penalty_Month = sum((P_ES_in_Month_Unpadded * (((Eff_c * cycle_pen)/(2 * Storage_Energy_Capacity_DC)) * delta_t)) +
                                  (P_ES_out_Month_Unpadded * ((cycle_pen/(Eff_d * 2 * Storage_Energy_Capacity_DC)) * delta_t)));
    
    
    ## Concatenate Decision Variable & Monthly Cost Values from Month Iteration
    
    # Decision Variable Concatenation
    P_ES_in = c(P_ES_in, P_ES_in_Month_Unpadded)
    
    P_ES_out = c(P_ES_out, P_ES_out_Month_Unpadded)
    
    Ene_Lvl = c(Ene_Lvl, Ene_Lvl_Month_Unpadded)
    
    P_max_NC = c(P_max_NC, P_max_NC_Month_with_Solar_and_Storage)
    
    P_special_max = c(P_special_max, P_special_max_Month_with_Solar_and_Storage)
    
    P_max_peak = c(P_max_peak, P_max_CPK_Month_with_Solar_and_Storage)
    
    P_max_part_peak = c(P_max_part_peak, P_max_CPP_Month_with_Solar_and_Storage)
    
    
    # Monthly Cost Variable Concatenation
    Fixed_Charge_Vector = c(Fixed_Charge_Vector, Fixed_Charge_Month)
    
    NC_DC_Baseline_Vector = c(NC_DC_Baseline_Vector, NC_Demand_Charge_Month_Baseline)
    NC_DC_with_Solar_Only_Vector = c(NC_DC_with_Solar_Only_Vector, NC_Demand_Charge_Month_with_Solar_Only)
    NC_DC_with_Solar_and_Storage_Vector = c(NC_DC_with_Solar_and_Storage_Vector, NC_Demand_Charge_Month_with_Solar_and_Storage)
    
    SM_DC_Baseline_Vector = c(SM_DC_Baseline_Vector, SM_Demand_Charge_Month_Baseline)
    SM_DC_with_Solar_Only_Vector = c(SM_DC_with_Solar_Only_Vector, SM_Demand_Charge_Month_with_Solar_Only)
    SM_DC_with_Solar_and_Storage_Vector = c(SM_DC_with_Solar_and_Storage_Vector, SM_Demand_Charge_Month_with_Solar_and_Storage)
    
    CPK_DC_Baseline_Vector = c(CPK_DC_Baseline_Vector, CPK_Demand_Charge_Month_Baseline)
    CPK_DC_with_Solar_Only_Vector = c(CPK_DC_with_Solar_Only_Vector, CPK_Demand_Charge_Month_with_Solar_Only)
    CPK_DC_with_Solar_and_Storage_Vector = c(CPK_DC_with_Solar_and_Storage_Vector, CPK_Demand_Charge_Month_with_Solar_and_Storage)
    
    CPP_DC_Baseline_Vector = c(CPP_DC_Baseline_Vector, CPP_Demand_Charge_Month_Baseline)
    CPP_DC_with_Solar_Only_Vector = c(CPP_DC_with_Solar_Only_Vector, CPP_Demand_Charge_Month_with_Solar_Only)
    CPP_DC_with_Solar_and_Storage_Vector = c(CPP_DC_with_Solar_and_Storage_Vector, CPP_Demand_Charge_Month_with_Solar_and_Storage)
    
    Energy_Charge_Baseline_Vector = c(Energy_Charge_Baseline_Vector, Energy_Charge_Month_Baseline)
    Energy_Charge_with_Solar_Only_Vector = c(Energy_Charge_with_Solar_Only_Vector, Energy_Charge_Month_with_Solar_Only)
    Energy_Charge_with_Solar_and_Storage_Vector = c(Energy_Charge_with_Solar_and_Storage_Vector, Energy_Charge_Month_with_Solar_and_Storage)
    
    Cycles_Vector = c(Cycles_Vector, Cycles_Month)
    
    Cycling_Penalty_Vector = c(Cycling_Penalty_Vector, Cycling_Penalty_Month)
    
    
  }
  
  # Report total script runtime.
  
  telapsed = Sys.time() - tstart
  
  print(paste("Model Run", Model_Run_Number_Input, "complete. Elapsed time to run the optimization model is", 
              round(as.numeric(telapsed)), attr(telapsed, "units")))
  
  
  ## Calculation of Additional Reported Model Inputs/Outputs
  
  # Output current system date and time in standard ISO 8601 YYYY-MM-DD HH:MM format.
  Model_Run_Date_Time = as.character(Sys.time())
  
  
  # Convert Retail Rate Name Input (which contains both utility name and rate
  # name) into Retail Rate Utility and Retail Rate Name Output
  
  if(grepl("PG&E", Retail_Rate_Name_Input)){
    Retail_Rate_Utility = "PG&E";
  }else if(grepl("SCE", Retail_Rate_Name_Input)){
    Retail_Rate_Utility = "SCE";
  }else if(grepl("SDG&E", Retail_Rate_Name_Input)){
    Retail_Rate_Utility = "SDG&E";
  }
  
  Retail_Rate_Utility_Plus_Space = paste0(Retail_Rate_Utility, " ")
  
  Retail_Rate_Name_Output = gsub(pattern = Retail_Rate_Utility_Plus_Space, replacement = "", Retail_Rate_Name_Input);
  
  # If Solar Profile Name is "No Solar", Solar Profile Name Output is Blank
  if(Solar_Profile_Name_Input == "No Solar"){
    Solar_Profile_Name_Output = "";
  }else{
    Solar_Profile_Name_Output = Solar_Profile_Name_Input;
  }
  
  
  ## Output Directory/Folder Names
  
  if(ITC_Constraint_Input == FALSE){
    ITC_Constraint_Folder_Name = "No ITC Constraint";
  }else if(ITC_Constraint_Input == TRUE){
    ITC_Constraint_Folder_Name = "ITC Constraint";   
  }
  
  Output_Directory_Filepath = file.path("Model Outputs", Model_Type_Input, paste0(Model_Timestep_Resolution, "-Minute"),
                                        Customer_Class_Input, Load_Profile_Name_Input, Retail_Rate_Name_Input, Export_Compensation_Rate_Name_Input,
                                        paste(Storage_Power_Rating_Input, "kW", Storage_Energy_Capacity_Input, "kWh Storage"), ITC_Constraint_Folder_Name)
  
  # Create folder if one does not exist already
  
  if(!dir.exists(file.path(Input_Output_Data_Directory_Location, Output_Directory_Filepath))){
    dir.create(file.path(Input_Output_Data_Directory_Location, Output_Directory_Filepath), recursive = TRUE)
  }
  
  
  ## Plot Energy Storage Dispatch Schedule
  
  End_Time_Input <- Start_Time_Input
  lubridate::year(End_Time_Input) <- lubridate::year(Start_Time_Input) + 1
  End_Time_Input <- End_Time_Input - (Model_Timestep_Resolution * 60)
  
  t = seq.POSIXt(Start_Time_Input, End_Time_Input, by = paste(Model_Timestep_Resolution, "min"))
  
  P_ES = P_ES_out - P_ES_in;
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    ggplot() +
      geom_line(aes(x = t, y = P_ES), color = "red") +
      labs(title = 'Energy Storage Dispatch Profile',
           x = 'Date & Time',
           y = 'Energy Storage Output (kW)') +
      ylim(-Storage_Power_Rating_Input * 1.1, Storage_Power_Rating_Input * 1.1) + # Make ylim 10% larger than storage power rating.
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5),
            legend.position = "none")
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Storage Dispatch Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  ## Plot Energy Storage Energy Level
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    ggplot() +
      geom_line(aes(x = t, y = Ene_Lvl), color = "red") +
      labs(title = 'Energy Storage Energy Level',
           x = 'Date & Time',
           y = 'Energy Storage Energy Level (kWh-DC)') +
      ylim(-Storage_Energy_Capacity_DC * 0.1, Storage_Energy_Capacity_DC * 1.1) + # Make ylim 10% larger than energy storage level.
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5),
            legend.position = "none")
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Energy Level Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  ## Plot Volumetric Electricity Price Schedule and Marginal Carbon Emission Rates
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    # Plot Volumetric Rate Data without Marginal Emissions Rate
    ggplot() +
      geom_line(aes(x = t, y = Volumetric_Rate_Data)) +
      labs(title = 'Total Energy Charges',
           x = 'Date & Time',
           y = 'Total Energy Charges ($/kWh)') +
      ylim(-max(Volumetric_Rate_Data) * 0.1, max(Volumetric_Rate_Data) * 1.1) + # Make ylim 10% larger than volumetric rate range.
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5),
            legend.position = "none")
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Energy Price Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  ## Plot Coincident and Non-Coincident Demand Charge Schedule
  
  # Create Summer/Winter Binary Flag Vector
  Summer_Binary_Data = (Month_Data %in% First_Summer_Month:Last_Summer_Month)
  
  Winter_Binary_Data = (Month_Data %in% c(1:(First_Summer_Month-1), (Last_Summer_Month+1):12))
  
  # Create Total-Demand-Charge Vector
  # Noncoincident Demand Charge is always included (although it may be 0).
  # Coincident Peak and Part-Peak values are only added if they are non-zero
  # and a binary-flag data input is available.
  
  Total_DC = (Winter_Noncoincident_DC * Winter_Binary_Data) +
    (Summer_Noncoincident_DC * Summer_Binary_Data);
  
  if(Winter_Special_Maximum_DC > 0){
    Total_DC = Total_DC + (Winter_Special_Maximum_DC * Special_Maximum_Demand_Binary_Data);
  }
  
  if(Winter_Peak_DC > 0){
    Total_DC = Total_DC + (Winter_Peak_DC * Winter_Peak_Binary_Data);
  }
  
  if(Winter_Part_Peak_DC > 0){
    Total_DC = Total_DC + (Winter_Part_Peak_DC * Winter_Part_Peak_Binary_Data);
  }
  
  if(Summer_Special_Maximum_DC > 0){
    Total_DC = Total_DC + (Summer_Special_Maximum_DC * Special_Maximum_Demand_Binary_Data);
  }
  
  if(Summer_Peak_DC > 0){
    Total_DC = Total_DC + (Summer_Peak_DC * Summer_Peak_Binary_Data);
  }
  
  if(Summer_Part_Peak_DC > 0){
    Total_DC = Total_DC + (Summer_Part_Peak_DC * Summer_Part_Peak_Binary_Data);
  }
  
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    ggplot() +
      geom_line(aes(x = t, y = Total_DC), color = "forestgreen") +
      labs(title = 'Total Demand Charges',
           x = 'Date & Time',
           y = 'Total Demand Charges ($/kW)') +
      ylim(-1, max(Total_DC) + 1) +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5),
            legend.position = "none")
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Demand Charge Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  ## Plot Load, Net Load with Solar Only, Net Load with Solar and Storage
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    if(Model_Type_Input == "Storage Only"){
      
      ggplot() +
        geom_line(aes(x = t, y = Load_Profile_Data, color = "1. Original Load")) +
        geom_line(aes(x = t, y = Load_Profile_Data - P_ES, color = "2. Net Load with Storage")) +
        labs(title = 'Original and Net Load Profiles',
             x = 'Date & Time',
             y = 'Load (kW)',
             color = "Legend") +
        scale_color_manual(values = c("black", "red")) +
        theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
      
    }else if(Model_Type_Input == "Solar Plus Storage"){
      
      ggplot() +
        geom_line(aes(x = t, y = Load_Profile_Data, color = "1. Original Load")) +
        geom_line(aes(x = t, y = Load_Profile_Data - Solar_PV_Profile_Data, color = "2. Net Load with Solar Only")) +
        geom_line(aes(x = t, y = Load_Profile_Data - (Solar_PV_Profile_Data + P_ES), color = "3. Net Load with Solar + Storage")) +
        labs(title = 'Original and Net Load Profiles',
             x = 'Date & Time',
             y = 'Load (kW)',
             color = "Legend") +
        scale_color_manual(values = c("black", "blue", "red")) +
        theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
      
    }
    
    
    if(Export_Plots == 1){
      ggsave(filename = file.path(Output_Directory_Filepath, "Net Load Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
    
  }
  
  if(Model_Type_Input == "Storage Only"){
    
    Annual_Peak_Demand_with_Solar_Only = "";
    
    Annual_Total_Energy_Consumption_with_Solar_Only = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    Annual_Peak_Demand_with_Solar_Only = max(Load_Profile_Data - Solar_PV_Profile_Data);
    
    Annual_Total_Energy_Consumption_with_Solar_Only = sum(Load_Profile_Data - Solar_PV_Profile_Data) * delta_t;
    
  }
  
  Annual_Peak_Demand_with_Solar_and_Storage = max(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES));
  
  Annual_Total_Energy_Consumption_with_Solar_and_Storage = sum(Load_Profile_Data - (Solar_PV_Profile_Data + P_ES)) * delta_t;
  
  if(Model_Type_Input == "Storage Only"){
    Solar_Only_Peak_Demand_Reduction_Percentage = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Solar_Only_Peak_Demand_Reduction_Percentage =
      ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_Only)/
         Annual_Peak_Demand_Baseline) * 100;
  }
  
  Solar_Storage_Peak_Demand_Reduction_Percentage =
    ((Annual_Peak_Demand_Baseline - Annual_Peak_Demand_with_Solar_and_Storage)/
       Annual_Peak_Demand_Baseline) * 100;
  
  if(Model_Type_Input == "Storage Only"){
    Solar_Only_Energy_Consumption_Decrease_Percentage = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Solar_Only_Energy_Consumption_Decrease_Percentage =
      ((Annual_Total_Energy_Consumption_Baseline -
          Annual_Total_Energy_Consumption_with_Solar_Only)/
         Annual_Total_Energy_Consumption_Baseline) * 100;
  }
  
  Solar_Storage_Energy_Consumption_Decrease_Percentage =
    ((Annual_Total_Energy_Consumption_Baseline -
        Annual_Total_Energy_Consumption_with_Solar_and_Storage)/
       Annual_Total_Energy_Consumption_Baseline) * 100
  
  print(paste('Baseline annual peak noncoincident demand is', round(Annual_Peak_Demand_Baseline,3), 'kW.'))
  
  if(Model_Type_Input == "Storage Only"){
    
    if(Solar_Storage_Peak_Demand_Reduction_Percentage >= 0){
      
      paste0('Peak demand with storage is ',  round(Annual_Peak_Demand_with_Solar_and_Storage,3),
             ' kW, representing a DECREASE OF ', round(Solar_Storage_Peak_Demand_Reduction_Percentage,2), '%.')
      
    }else if(Solar_Storage_Peak_Demand_Reduction_Percentage < 0){
      
      paste0('Peak demand with storage is ',  round(Annual_Peak_Demand_with_Solar_and_Storage,3),
             ' kW, representing an INCREASE OF ', round(-Solar_Storage_Peak_Demand_Reduction_Percentage,2), '%.')
      
    }        
    
    print(paste('Baseline annual total electricity consumption is', round(Annual_Total_Energy_Consumption_Baseline, 3), 'kWh.'))
    
    paste0('Electricity consumption with storage is ',  round(Annual_Total_Energy_Consumption_with_Solar_and_Storage,3),
           ' kW, representing an INCREASE OF ', round(-Solar_Storage_Energy_Consumption_Decrease_Percentage,2), '%.')
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    paste0('Peak demand with solar only is ',  round(Annual_Peak_Demand_with_Solar_Only,3),
           ' kW, representing a DECREASE OF ', round(Solar_Only_Peak_Demand_Reduction_Percentage,2), '%.')
    
    if(Solar_Storage_Peak_Demand_Reduction_Percentage >= 0){
      paste0('Peak demand with solar and storage is ',  round(Annual_Peak_Demand_with_Solar_and_Storage,3),
             ' kW, representing a DECREASE OF ', round(Solar_Storage_Peak_Demand_Reduction_Percentage,2), '%.')
      
    }else if(Solar_Storage_Peak_Demand_Reduction_Percentage < 0){
      paste0('Peak demand with solar and storage is ',  round(Annual_Peak_Demand_with_Solar_and_Storage,3),
             ' kW, representing an INCREASE OF ', round(-Solar_Storage_Peak_Demand_Reduction_Percentage,2), '%.')
      
    }
    
    print(paste('Baseline annual total electricity consumption is', round(Annual_Total_Energy_Consumption_Baseline, 3), 'kWh.'))
    
    print(paste0('Electricity consumption with solar only is ',  round(Annual_Total_Energy_Consumption_with_Solar_Only,3),
                 ' kW, representing a DECREASE OF ', round(Solar_Only_Energy_Consumption_Decrease_Percentage,2), '%.'))
    
    print(paste0('Electricity consumption with solar and storage is ',  round(Annual_Total_Energy_Consumption_with_Solar_and_Storage,3),
                 ' kW, representing a DECREASE OF ', round(Solar_Storage_Energy_Consumption_Decrease_Percentage,2), '%.'))
    
  }
  
  
  ## Plot Monthly Costs as Bar Plot
  
  # Calculate Baseline Monthly Costs
  
  Monthly_Costs_Matrix_Baseline = cbind(Fixed_Charge_Vector, NC_DC_Baseline_Vector, SM_DC_Baseline_Vector,
                                        CPK_DC_Baseline_Vector, CPP_DC_Baseline_Vector, Energy_Charge_Baseline_Vector)
  
  Annual_Costs_Vector_Baseline = cbind(sum(Fixed_Charge_Vector),
                                       sum(NC_DC_Baseline_Vector) + sum(SM_DC_Baseline_Vector) + sum(CPK_DC_Baseline_Vector) + sum(CPP_DC_Baseline_Vector),
                                       sum(Energy_Charge_Baseline_Vector))
  
  Annual_Demand_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline[,2]
  Annual_Energy_Charge_Cost_Baseline = Annual_Costs_Vector_Baseline[,3]
  
  
  # Calculate Monthly Costs With Solar Only
  
  Monthly_Costs_Matrix_with_Solar_Only = cbind(Fixed_Charge_Vector, NC_DC_with_Solar_Only_Vector, SM_DC_with_Solar_Only_Vector,
                                               CPK_DC_with_Solar_Only_Vector, CPP_DC_with_Solar_Only_Vector, Energy_Charge_with_Solar_Only_Vector)
  
  Annual_Costs_Vector_with_Solar_Only = cbind(sum(Fixed_Charge_Vector),
                                              sum(NC_DC_with_Solar_Only_Vector) + sum(SM_DC_with_Solar_Only_Vector) + sum(CPK_DC_with_Solar_Only_Vector) + sum(CPP_DC_with_Solar_Only_Vector),
                                              sum(Energy_Charge_with_Solar_Only_Vector))
  
  if(Model_Type_Input == "Storage Only"){
    Annual_Demand_Charge_Cost_with_Solar_Only = "";
    Annual_Energy_Charge_Cost_with_Solar_Only = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_Demand_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only[,2]
    Annual_Energy_Charge_Cost_with_Solar_Only = Annual_Costs_Vector_with_Solar_Only[,3]
  }
  
  
  # Calculate Monthly Costs with Solar and Storage
  
  Monthly_Costs_Matrix_with_Solar_and_Storage = cbind(Fixed_Charge_Vector, NC_DC_with_Solar_and_Storage_Vector, SM_DC_with_Solar_and_Storage_Vector,
                                                      CPK_DC_with_Solar_and_Storage_Vector, CPP_DC_with_Solar_and_Storage_Vector, Energy_Charge_with_Solar_and_Storage_Vector)
  
  Annual_Costs_Vector_with_Solar_and_Storage = cbind(sum(Fixed_Charge_Vector),
                                                     sum(NC_DC_with_Solar_and_Storage_Vector) + sum(SM_DC_with_Solar_and_Storage_Vector) + sum(CPK_DC_with_Solar_and_Storage_Vector) + sum(CPP_DC_with_Solar_and_Storage_Vector),
                                                     sum(Energy_Charge_with_Solar_and_Storage_Vector))
  
  Annual_Demand_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage[,2]
  Annual_Energy_Charge_Cost_with_Solar_and_Storage = Annual_Costs_Vector_with_Solar_and_Storage[,3]
  
  
  # Calculate Maximum and Minimum Monthly Bills - to set y-axis for all plots
  
  Maximum_Monthly_Bill_Baseline = max(rowSums(Monthly_Costs_Matrix_Baseline))
  Minimum_Monthly_Bill_Baseline = min(rowSums(Monthly_Costs_Matrix_Baseline));
  
  Maximum_Monthly_Bill_with_Solar_Only = max(rowSums(Monthly_Costs_Matrix_with_Solar_Only));
  Minimum_Monthly_Bill_with_Solar_Only = min(rowSums(Monthly_Costs_Matrix_with_Solar_Only));
  
  Maximum_Monthly_Bill_with_Solar_and_Storage = max(rowSums(Monthly_Costs_Matrix_with_Solar_and_Storage));
  Minimum_Monthly_Bill_with_Solar_and_Storage = min(rowSums(Monthly_Costs_Matrix_with_Solar_and_Storage));
  
  Maximum_Monthly_Bill = max(Maximum_Monthly_Bill_Baseline,
                             Maximum_Monthly_Bill_with_Solar_Only,
                             Maximum_Monthly_Bill_with_Solar_and_Storage)
  
  Minimum_Monthly_Bill = min(Minimum_Monthly_Bill_Baseline,
                             Minimum_Monthly_Bill_with_Solar_Only,
                             Minimum_Monthly_Bill_with_Solar_and_Storage)
  
  Max_Monthly_Bill_ylim = Maximum_Monthly_Bill * 1.1; # Make upper ylim 10% larger than largest monthly bill.
  
  if(Minimum_Monthly_Bill >= 0){
    Min_Monthly_Bill_ylim = 0; # Make lower ylim equal to 0 if the lowest monthly bill is greater than zero.
  }else if(Minimum_Monthly_Bill < 0){
    Min_Monthly_Bill_ylim = Minimum_Monthly_Bill * 1.1; # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.
  }
  
  
  # Plot Baseline Monthly Costs
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    Monthly_Costs_Matrix_Baseline.df <- data.frame(Monthly_Costs_Matrix_Baseline) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", Fixed_Charge_Vector:Energy_Charge_Baseline_Vector) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_Vector", "", Charge_Name)) %>%
      mutate(Charge_Name = gsub("_Baseline", "", Charge_Name)) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = gsub("NC", "Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("SM", "Midday-Exempt Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPK", "Peak", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPP", "Part-Peak", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Max DC", "Midday-Exempt Max DC", "Peak DC", "Part-Peak DC", "Energy Charge", "Fixed Charge")))
    
    ggplot(data = Monthly_Costs_Matrix_Baseline.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      labs(title = 'Monthly Costs, Base Case',
           x = 'Month',
           y = 'Cost ($/Month)',
           fill = "Legend") +
      coord_cartesian(ylim = c(Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim)) +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Monthly_Costs_Matrix_Baseline.df)
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Costs Base Case Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  # Plot Monthly Costs With Solar Only
  
  if(Model_Type_Input == "Solar Plus Storage"){
    
    if(Show_Plots == 1 || Export_Plots ==1){
      
      Monthly_Costs_Matrix_with_Solar_Only.df <- data.frame(Monthly_Costs_Matrix_with_Solar_Only) %>%
        mutate(Month = row_number()) %>%
        group_by(Month) %>%
        gather(key = "Charge_Name", value = "Charge_Value", Fixed_Charge_Vector:Energy_Charge_with_Solar_Only_Vector) %>%
        ungroup() %>%
        mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
        mutate(Charge_Name = gsub("_Vector", "", Charge_Name)) %>%
        mutate(Charge_Name = gsub("_with_Solar_Only", "", Charge_Name)) %>%
        mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
        mutate(Charge_Name = gsub("NC", "Max", Charge_Name)) %>%
        mutate(Charge_Name = gsub("SM", "Midday-Exempt Max", Charge_Name)) %>%
        mutate(Charge_Name = gsub("CPK", "Peak", Charge_Name)) %>%
        mutate(Charge_Name = gsub("CPP", "Part-Peak", Charge_Name)) %>%
        mutate(Charge_Name = factor(Charge_Name, levels = c("Max DC", "Midday-Exempt Max DC", "Peak DC", "Part-Peak DC", "Energy Charge", "Fixed Charge")))
      
      ggplot(data = Monthly_Costs_Matrix_with_Solar_Only.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels=scales::dollar_format()) +
        labs(title = 'Monthly Costs, With Solar Only',
             x = 'Month',
             y = 'Cost ($/Month)',
             fill = "Legend") +
        coord_cartesian(ylim = c(Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim)) +
        theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
      
      rm(Monthly_Costs_Matrix_with_Solar_Only.df)
      
      if(Export_Plots == 1){
        
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Costs with Solar Only Plot.png"), width = 11, height = 8.5, units = "in")
        
      }
      
    }
    
  }
  
  
  # Plot Monthly Costs with Solar and Storage
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    Monthly_Costs_Matrix_with_Solar_and_Storage.df <- data.frame(Monthly_Costs_Matrix_with_Solar_and_Storage) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", Fixed_Charge_Vector:Energy_Charge_with_Solar_and_Storage_Vector) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_Vector", "", Charge_Name)) %>%
      mutate(Charge_Name = gsub("_with_Solar_and_Storage", "", Charge_Name)) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = gsub("NC", "Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("SM", "Midday-Exempt Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPK", "Peak", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPP", "Part-Peak", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Max DC", "Midday-Exempt Max DC", "Peak DC", "Part-Peak DC", "Energy Charge", "Fixed Charge")))
    
    if(Model_Type_Input == "Storage Only"){
      monthlyCostsPlotTitle <- 'Monthly Costs, With Storage'
    }else{
      monthlyCostsPlotTitle <- 'Monthly Costs, With Solar and Storage'
    } 
    
    ggplot(data = Monthly_Costs_Matrix_with_Solar_and_Storage.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      labs(title = monthlyCostsPlotTitle,
           x = 'Month',
           y = 'Cost ($/Month)',
           fill = "Legend") +
      coord_cartesian(ylim = c(Min_Monthly_Bill_ylim, Max_Monthly_Bill_ylim)) +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Monthly_Costs_Matrix_with_Solar_and_Storage.df)
    
    if(Export_Plots == 1){
      
      if(Model_Type_Input == "Storage Only"){
        
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Costs with Storage Plot.png"), width = 11, height = 8.5, units = "in")
        
      }else if(Model_Type_Input == "Solar Plus Storage"){
        
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Costs with Solar and Storage Plot.png"), width = 11, height = 8.5, units = "in")
        
      }
      
    }
    
  }
  
  
  # Plot Monthly Savings From Storage
  
  if(Model_Type_Input == "Storage Only"){
    
    Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_Baseline -
      Monthly_Costs_Matrix_with_Solar_and_Storage;
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    Monthly_Savings_Matrix_From_Storage = Monthly_Costs_Matrix_with_Solar_Only -
      Monthly_Costs_Matrix_with_Solar_and_Storage
    
  }
  
  colnames(Monthly_Savings_Matrix_From_Storage) <- c("Fixed_Charge_Storage_Savings", "NC_DC_Storage_Savings", "SM_DC_Storage_Savings",
                                                     "CPK_DC_Storage_Savings", "CPP_DC_Storage_Savings", "Energy_Charge_Storage_Savings")
  
  # Remove fixed charges, battery cycling costs.
  Monthly_Savings_Matrix_Plot = Monthly_Savings_Matrix_From_Storage[, 2:6]
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    Monthly_Savings_Matrix_Plot.df <- data.frame(Monthly_Savings_Matrix_Plot) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", NC_DC_Storage_Savings:Energy_Charge_Storage_Savings) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_Storage_Savings", "", Charge_Name)) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = gsub("NC", "Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("SM", "Midday-Exempt Max", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPK", "Peak", Charge_Name)) %>%
      mutate(Charge_Name = gsub("CPP", "Part-Peak", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Max DC", "Midday-Exempt Max DC", "Peak DC", "Part-Peak DC", "Energy Charge")))
    
    ggplot(data = Monthly_Savings_Matrix_Plot.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      labs(title = 'Storage Savings ($/Month)',
           x = 'Month',
           y = 'Savings ($/Month)',
           fill = "Legend") +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Monthly_Savings_Matrix_Plot.df)
    
    if(Export_Plots == 1){
      ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Savings from Storage Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
    
  }
  
  
  ## Report Annual Savings
  
  # Report Baseline Cost without Solar or Storage
  Annual_Customer_Bill_Baseline = sum(rowSums(Monthly_Costs_Matrix_Baseline))
  
  if(Model_Type_Input == "Storage Only"){
    Annual_Customer_Bill_with_Solar_Only = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_Customer_Bill_with_Solar_Only = sum(Annual_Costs_Vector_with_Solar_Only);
  }
  
  Annual_Customer_Bill_with_Solar_and_Storage = sum(Annual_Costs_Vector_with_Solar_and_Storage); # Doesn't include degradation cost.
  
  if(Model_Type_Input == "Storage Only"){
    
    Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_and_Storage;
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    Annual_Customer_Bill_Savings_from_Solar = Annual_Customer_Bill_Baseline - Annual_Customer_Bill_with_Solar_Only;
    
    Annual_Customer_Bill_Savings_from_Solar_Percent = (Annual_Customer_Bill_Savings_from_Solar/Annual_Customer_Bill_Baseline);
    
    Annual_Customer_Bill_Savings_from_Storage = Annual_Customer_Bill_with_Solar_Only - Annual_Customer_Bill_with_Solar_and_Storage;
    
  }
  
  Annual_Customer_Bill_Savings_from_Storage_Percent = (Annual_Customer_Bill_Savings_from_Storage/Annual_Customer_Bill_Baseline);
  
  if(Model_Type_Input == "Solar Plus Storage"){
    Solar_Installed_Cost = Solar_Size_Input * Solar_Installed_Cost_per_kW;
    Solar_Simple_Payback = Solar_Installed_Cost/Annual_Customer_Bill_Savings_from_Solar;
    
    print(paste0('Annual cost savings from solar is $', round(Annual_Customer_Bill_Savings_from_Solar, 2),
                 ', representing ', round(Annual_Customer_Bill_Savings_from_Solar_Percent * 100, 2),
                 '% of the original $', round(Annual_Customer_Bill_Baseline, 2), ' bill.'))
    
    print(paste('The solar PV system has a simple payback of', round(Solar_Simple_Payback, 2), 'years, not including incentives.'))
  }
  
  Storage_Installed_Cost = Storage_Energy_Capacity_DC * Storage_Installed_Cost_per_kWh;
  
  Storage_Simple_Payback = Storage_Installed_Cost/Annual_Customer_Bill_Savings_from_Storage;
  
  print(paste0('Annual cost savings from storage is $', round(Annual_Customer_Bill_Savings_from_Storage, 2),
               ', representing ', round(Annual_Customer_Bill_Savings_from_Storage_Percent * 100, 2),
               '% of the original $', round(Annual_Customer_Bill_Baseline, 2), ' bill.'))
  
  print(paste('The storage system has a simple payback of', round(Storage_Simple_Payback, 2), 'years, not including incentives.'))
  
  
  ## Report Cycling/Degradation Penalty
  
  Annual_Equivalent_Storage_Cycles = sum(Cycles_Vector);
  Annual_Cycling_Penalty = sum(Cycling_Penalty_Vector);
  
  print(paste0('The battery cycles ', round(Annual_Equivalent_Storage_Cycles, 2),
               ' times annually, with a degradation cost of $', round(Annual_Cycling_Penalty, 2), '.'))
  
  ## Report Operational/"SGIP" Round-Trip Efficiency
  Annual_RTE = (sum(P_ES_out) * delta_t)/(sum(P_ES_in) * delta_t)
  print(paste0('The battery has an Annual Operational/SGIP Round-Trip Efficiency of ', round(Annual_RTE * 100, 2), "%."))
  
  
  ## Report Grid Costs
  
  # Calculate Total Annual Grid Costs
  
  Annual_Grid_Cost_Baseline = sum((Marginal_Energy_Cost_Data + Marginal_Generation_Capacity_Cost_Data) * 
                                    (Load_Profile_Data * delta_t))
  
  if(Model_Type_Input == "Solar Plus Storage"){
    Annual_Grid_Cost_with_Solar_Only = sum((Marginal_Energy_Cost_Data + Marginal_Generation_Capacity_Cost_Data) * 
                                             ((Load_Profile_Data - Solar_PV_Profile_Data) * delta_t))
  }else{
    Annual_Grid_Cost_with_Solar_Only = "";
  }
  
  Annual_Grid_Cost_with_Solar_and_Storage = sum((Marginal_Energy_Cost_Data + Marginal_Generation_Capacity_Cost_Data) * 
                                                  ((Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * delta_t))
  
  
  # Calculate Monthly Grid Costs
  
  Grid_Cost_Timestep_Baseline = cbind(Marginal_Energy_Cost_Data * Load_Profile_Data * delta_t,
                                      Marginal_Generation_Capacity_Cost_Data * Load_Profile_Data * delta_t)
  
  Grid_Cost_Month_Baseline = c()
  
  for(Month_Iter in 1:12){
    Grid_Cost_Single_Month_Baseline = colSums(Grid_Cost_Timestep_Baseline[which(Month_Data == Month_Iter), ])
    Grid_Cost_Month_Baseline = rbind(Grid_Cost_Month_Baseline, Grid_Cost_Single_Month_Baseline)
  }
  rownames(Grid_Cost_Month_Baseline) = NULL
  
  Grid_Cost_Timestep_with_Solar_Only = cbind(Marginal_Energy_Cost_Data * (Load_Profile_Data - Solar_PV_Profile_Data) * delta_t,
                                             Marginal_Generation_Capacity_Cost_Data * (Load_Profile_Data - Solar_PV_Profile_Data) * delta_t)
  
  Grid_Cost_Month_with_Solar_Only = c()
  
  for(Month_Iter in 1:12){
    Grid_Cost_Single_Month_with_Solar_Only = colSums(Grid_Cost_Timestep_with_Solar_Only[which(Month_Data == Month_Iter), ])
    Grid_Cost_Month_with_Solar_Only = rbind(Grid_Cost_Month_with_Solar_Only, Grid_Cost_Single_Month_with_Solar_Only)
  }
  rownames(Grid_Cost_Month_with_Solar_Only) = NULL
  
  Grid_Cost_Timestep_with_Solar_and_Storage = cbind(Marginal_Energy_Cost_Data * (Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * delta_t,
                                                    Marginal_Generation_Capacity_Cost_Data * (Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * delta_t)
  
  Grid_Cost_Month_with_Solar_and_Storage = c()
  
  for(Month_Iter in 1:12){
    Grid_Cost_Single_Month_with_Solar_and_Storage = colSums(Grid_Cost_Timestep_with_Solar_and_Storage[which(Month_Data == Month_Iter), ])
    Grid_Cost_Month_with_Solar_and_Storage = rbind(Grid_Cost_Month_with_Solar_and_Storage, Grid_Cost_Single_Month_with_Solar_and_Storage)
  }
  rownames(Grid_Cost_Month_with_Solar_and_Storage) = NULL
  
  # Calculate Monthly Grid Cost Savings from Storage
  
  if(Model_Type_Input == "Storage Only"){
    
    Grid_Cost_Savings_Month_from_Storage = Grid_Cost_Month_Baseline - Grid_Cost_Month_with_Solar_and_Storage;
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    Grid_Cost_Savings_Month_from_Storage = Grid_Cost_Month_with_Solar_Only - Grid_Cost_Month_with_Solar_and_Storage;
    
  }
  
  
  # Report Grid Cost Savings from Solar
  
  if(Model_Type_Input == "Solar Plus Storage"){
    
    print(paste0('Installing solar DECREASES estimated utility marginal generation costs (energy and generation capacity) by $',
                 round(Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_Only, 2), ' per year.'))
    
  }
  
  
  # Report Grid Cost Impact from Storage
  
  if(Model_Type_Input == "Storage Only"){
    
    if(Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage < 0){
      print(paste0('Installing energy storage INCREASES estimated utility marginal generation costs (energy and generation capacity) by $',
                   -round(Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage, 2), ' per year.'))
    }else{
      print(paste0('Installing energy storage DECREASES estimated utility marginal generation costs (energy and generation capacity) by $',
                   round(Annual_Grid_Cost_Baseline - Annual_Grid_Cost_with_Solar_and_Storage, 2), ' per year.'))
    }
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    
    if(Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage < 0){
      print(paste0('Installing energy storage INCREASES estimated utility marginal generation costs (energy and generation capacity) by $',
                   -round(Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage, 2), ' per year.'))
    }else{
      print(paste0('Installing energy storage DECREASES estimated utility marginal generation costs (energy and generation capacity) by $',
                   round(Annual_Grid_Cost_with_Solar_Only - Annual_Grid_Cost_with_Solar_and_Storage, 2), ' per year.'))
    }
    
  }
  
  ## Report Emissions Impact
  
  # This approach multiplies net load by marginal emissions factors to
  # calculate total annual emissions. This is consistent with the idea that
  # the customer would pay an adder based on marginal emissions factors.
  # Typically, total annual emissions is calculated using average emissions
  # values, not marginal emissions values.
  
  # https://www.pge.com/includes/docs/pdfs/shared/environment/calculator/pge_ghg_emission_factor_info_sheet.pdf
  
  # (tons/kWh) = (tons/MWh) * (MWh/kWh)
  Annual_GHG_Emissions_Baseline = sum(Marginal_Emissions_Rate_Data * Load_Profile_Data * (1/1000) * delta_t)
  
  if(Model_Type_Input == "Storage Only"){
    Annual_GHG_Emissions_with_Solar_Only = "";
    
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_GHG_Emissions_with_Solar_Only = sum(Marginal_Emissions_Rate_Data * (Load_Profile_Data - Solar_PV_Profile_Data) * (1/1000) * delta_t)
  }
  
  Annual_GHG_Emissions_with_Solar_and_Storage = sum(Marginal_Emissions_Rate_Data * (Load_Profile_Data - Solar_PV_Profile_Data - P_ES_out + P_ES_in) * (1/1000) * delta_t)
  
  if(Model_Type_Input == "Storage Only"){
    Annual_GHG_Emissions_Reduction_from_Solar = "";
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_GHG_Emissions_Reduction_from_Solar = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_Only;
  }
  
  if(Model_Type_Input == "Storage Only"){
    Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_Baseline - Annual_GHG_Emissions_with_Solar_and_Storage;
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_GHG_Emissions_Reduction_from_Storage = Annual_GHG_Emissions_with_Solar_Only - Annual_GHG_Emissions_with_Solar_and_Storage;
  }
  
  if(Model_Type_Input == "Storage Only"){
    Annual_GHG_Emissions_Reduction_from_Solar_Percent = "";
  }else if(Model_Type_Input == "Solar Plus Storage"){
    Annual_GHG_Emissions_Reduction_from_Solar_Percent =
      (Annual_GHG_Emissions_Reduction_from_Solar/Annual_GHG_Emissions_Baseline);
  }
  
  Annual_GHG_Emissions_Reduction_from_Storage_Percent =
    (Annual_GHG_Emissions_Reduction_from_Storage/Annual_GHG_Emissions_Baseline);
  
  
  if(Model_Type_Input == "Solar Plus Storage"){
    
    print(paste0('Installing solar DECREASES marginal carbon emissions by ',
                 round(Annual_GHG_Emissions_Reduction_from_Solar, 2), ' metric tons per year.'))
    print(paste0('This is equivalent to ', round(Annual_GHG_Emissions_Reduction_from_Solar_Percent * 100, 2),
                 '% of baseline emissions, and brings total emissions to ', round(Annual_GHG_Emissions_with_Solar_Only, 2), ' metric tons per year.'))
    
  }
  
  
  if(Annual_GHG_Emissions_Reduction_from_Storage < 0){
    print(paste0('Installing energy storage INCREASES marginal carbon emissions by ',
                 -round(Annual_GHG_Emissions_Reduction_from_Storage, 2), ' metric tons per year.'))
    print(paste0('This is equivalent to ', -round(Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, 2),
                 '% of baseline emissions, and brings total emissions to ', round(Annual_GHG_Emissions_with_Solar_and_Storage, 2), ' metric tons per year.'))
    
  }else{
    print(paste0('Installing energy storage DECREASES marginal carbon emissions by ',
                 round(Annual_GHG_Emissions_Reduction_from_Storage, 2), ' metric tons per year.'))
    print(paste0('This is equivalent to ', round(Annual_GHG_Emissions_Reduction_from_Storage_Percent * 100, 2),
                 '% of baseline emissions, and brings total emissions to ', round(Annual_GHG_Emissions_with_Solar_and_Storage, 2), ' metric tons per year.'))
  }
  
  
  ## Plot Grid Costs
  
  # Plot Grid Cost Time-Series
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    ggplot() +
      geom_line(aes(x = t, y = Marginal_Energy_Cost_Data, color = "Marginal Energy Cost")) +
      geom_line(aes(x = t, y = Marginal_Generation_Capacity_Cost_Data, color = "Marginal Generation Capacity Cost")) +
      labs(title = 'Grid Costs (MEC & MGCC)',
           x = 'Date & Time',
           y = 'Grid Costs ($/kWh)',
           color = "Legend") +
      coord_cartesian(ylim = c(-max(Marginal_Energy_Cost_Data, Marginal_Generation_Capacity_Cost_Data) * 0.1,
                               max(Marginal_Energy_Cost_Data, Marginal_Generation_Capacity_Cost_Data) * 1.1)) + # Make ylim 10% larger than grid cost range.
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    if(Export_Plots == 1){
      
      ggsave(filename = file.path(Output_Directory_Filepath, "Grid Costs Time Series Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  # Calculate Maximum and Minimum Monthly Grid Costs - to set y-axis for all plots
  
  Maximum_Monthly_Grid_Cost_Baseline = max(rowSums(Grid_Cost_Month_Baseline))
  Minimum_Monthly_Grid_Cost_Baseline = min(rowSums(Grid_Cost_Month_Baseline))
  
  Grid_Cost_Month_with_Solar_Only_Neg = Grid_Cost_Month_with_Solar_Only;
  Grid_Cost_Month_with_Solar_Only_Neg[which(Grid_Cost_Month_with_Solar_Only_Neg > 0)] = 0
  Grid_Cost_Month_with_Solar_Only_Pos = Grid_Cost_Month_with_Solar_Only;
  Grid_Cost_Month_with_Solar_Only_Pos[which(Grid_Cost_Month_with_Solar_Only_Pos < 0)] = 0
  
  Maximum_Monthly_Grid_Cost_with_Solar_Only = max(rowSums(Grid_Cost_Month_with_Solar_Only_Pos));
  Minimum_Monthly_Grid_Cost_with_Solar_Only = min(rowSums(Grid_Cost_Month_with_Solar_Only_Neg));
  
  Grid_Cost_Month_with_Solar_and_Storage_Neg = Grid_Cost_Month_with_Solar_and_Storage;
  Grid_Cost_Month_with_Solar_and_Storage_Neg[which(Grid_Cost_Month_with_Solar_and_Storage_Neg > 0)] = 0;
  Grid_Cost_Month_with_Solar_and_Storage_Pos = Grid_Cost_Month_with_Solar_and_Storage;
  Grid_Cost_Month_with_Solar_and_Storage_Pos[which(Grid_Cost_Month_with_Solar_and_Storage_Pos < 0)] = 0;
  
  Maximum_Monthly_Grid_Cost_with_Solar_and_Storage = max(rowSums(Grid_Cost_Month_with_Solar_and_Storage_Pos));
  Minimum_Monthly_Grid_Cost_with_Solar_and_Storage = min(rowSums(Grid_Cost_Month_with_Solar_and_Storage_Neg));
  
  Maximum_Monthly_Grid_Cost = max(Maximum_Monthly_Grid_Cost_Baseline,
                                  Maximum_Monthly_Grid_Cost_with_Solar_Only,
                                  Maximum_Monthly_Grid_Cost_with_Solar_and_Storage)
  
  Minimum_Monthly_Grid_Cost = min(Minimum_Monthly_Grid_Cost_Baseline,
                                  Minimum_Monthly_Grid_Cost_with_Solar_Only,
                                  Minimum_Monthly_Grid_Cost_with_Solar_and_Storage)
  
  Max_Monthly_Grid_Cost_ylim = Maximum_Monthly_Grid_Cost * 1.1; # Make upper ylim 10% larger than largest monthly bill.
  
  if(Minimum_Monthly_Grid_Cost >= 0){
    Min_Monthly_Grid_Cost_ylim = 0; # Make lower ylim equal to 0 if the lowest monthly bill is greater than zero.
  }else if(Minimum_Monthly_Grid_Cost < 0){
    Min_Monthly_Grid_Cost_ylim = Minimum_Monthly_Grid_Cost * 1.1; # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.
  }
  
  
  # Plot Baseline Monthly Grid Costs
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    colnames(Grid_Cost_Month_Baseline) <- c("Marginal_Energy_Cost", "Marginal_Generation_Capacity_Cost")
    
    Grid_Cost_Month_Baseline.df <- data.frame(Grid_Cost_Month_Baseline) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", Marginal_Energy_Cost:Marginal_Generation_Capacity_Cost) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Marginal Energy Cost", "Marginal Generation Capacity Cost")))
    
    ggplot(data = Grid_Cost_Month_Baseline.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      coord_cartesian(ylim = c(Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim)) + # Make ylim 10% larger than grid cost range.
      labs(title = 'Monthly Base Case Grid Costs',
           x = 'Month',
           y = 'Grid Cost ($/month)',
           fill = "Legend") +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Grid_Cost_Month_Baseline.df)
    
    if(Export_Plots == 1){
      ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Grid Costs Base Case Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  # Plot Monthly Grid Costs With Solar Only
  
  if(Model_Type_Input == "Solar Plus Storage"){
    
    if(Show_Plots == 1 || Export_Plots ==1){
      
      colnames(Grid_Cost_Month_with_Solar_Only) <- c("Marginal_Energy_Cost", "Marginal_Generation_Capacity_Cost")
      
      Grid_Cost_Month_with_Solar_Only.df <- data.frame(Grid_Cost_Month_with_Solar_Only) %>%
        mutate(Month = row_number()) %>%
        group_by(Month) %>%
        gather(key = "Charge_Name", value = "Charge_Value", Marginal_Energy_Cost:Marginal_Generation_Capacity_Cost) %>%
        ungroup() %>%
        mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
        mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
        mutate(Charge_Name = factor(Charge_Name, levels = c("Marginal Energy Cost", "Marginal Generation Capacity Cost")))
      
      ggplot(data = Grid_Cost_Month_with_Solar_Only.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels=scales::dollar_format()) +
        coord_cartesian(ylim = c(Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim)) + # Make ylim 10% larger than grid cost range.
        labs(title = 'Monthly Grid Costs with Solar Only',
             x = 'Month',
             y = 'Grid Cost ($/month)',
             fill = "Legend") +
        theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
      
      rm(Grid_Cost_Month_with_Solar_Only.df)
      
      if(Export_Plots == 1){
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Grid Costs with Solar Only Plot.png"), width = 11, height = 8.5, units = "in")
        
      }
      
    }
    
  }
  
  
  # Plot Monthly Grid Costs with Solar and Storage
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    colnames(Grid_Cost_Month_with_Solar_and_Storage) <- c("Marginal_Energy_Cost", "Marginal_Generation_Capacity_Cost")
    
    Grid_Cost_Month_with_Solar_and_Storage.df <- data.frame(Grid_Cost_Month_with_Solar_and_Storage) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", Marginal_Energy_Cost:Marginal_Generation_Capacity_Cost) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Marginal Energy Cost", "Marginal Generation Capacity Cost")))
    
    if(Model_Type_Input == "Solar Plus Storage"){
      gridCostsMonthlyPlotName <- 'Monthly Grid Costs with Solar and Storage'
    }else{
      gridCostsMonthlyPlotName <- 'Monthly Grid Costs with Storage'
    }
    
    ggplot(data = Grid_Cost_Month_with_Solar_and_Storage.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      coord_cartesian(ylim = c(Min_Monthly_Grid_Cost_ylim, Max_Monthly_Grid_Cost_ylim)) + # Make ylim 10% larger than grid cost range.
      labs(title = gridCostsMonthlyPlotName,
           x = 'Month',
           y = 'Grid Cost ($/month)',
           fill = "Legend") +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Grid_Cost_Month_with_Solar_and_Storage.df)
    
    if(Export_Plots == 1){
      
      if(Model_Type_Input == "Storage Only"){
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Grid Costs with Storage Plot.png"), width = 11, height = 8.5, units = "in")
        
      }else if(Model_Type_Input == "Solar Plus Storage"){
        ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Grid Costs with Solar and Storage Plot.png"), width = 11, height = 8.5, units = "in")
        
      }
      
    }
    
  }
  
  
  # Plot Monthly Savings from Storage
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    # Separate negative and positive values for stacked bar chart
    Grid_Cost_Savings_Month_from_Storage_Neg = Grid_Cost_Savings_Month_from_Storage;
    Grid_Cost_Savings_Month_from_Storage_Neg[which(Grid_Cost_Savings_Month_from_Storage_Neg > 0)] = 0;
    
    Grid_Cost_Savings_Month_from_Storage_Pos = Grid_Cost_Savings_Month_from_Storage;
    Grid_Cost_Savings_Month_from_Storage_Pos[which(Grid_Cost_Savings_Month_from_Storage_Pos < 0)] = 0;
    
    
    # Calculate Maximum and Minimum Monthly Grid Savings - to set y-axis for plot
    
    Maximum_Grid_Cost_Savings_Month_from_Storage = max(rowSums(Grid_Cost_Savings_Month_from_Storage_Pos))
    Minimum_Grid_Cost_Savings_Month_from_Storage = min(rowSums(Grid_Cost_Savings_Month_from_Storage_Neg));
    
    Max_Grid_Cost_Savings_from_Storage_ylim = Maximum_Grid_Cost_Savings_Month_from_Storage * 1.1; # Make upper ylim 10% larger than largest monthly savings.
    
    if(Minimum_Grid_Cost_Savings_Month_from_Storage >= 0){
      Min_Grid_Cost_Savings_from_Storage_ylim = 0; # Make lower ylim equal to 0 if(the lowest monthly grid savings.
    }else if(Minimum_Grid_Cost_Savings_Month_from_Storage < 0){
      Min_Grid_Cost_Savings_from_Storage_ylim = Minimum_Grid_Cost_Savings_Month_from_Storage * 1.1 - Max_Grid_Cost_Savings_from_Storage_ylim * 0.1; # Make lower ylim 10% smaller than the smallest monthly bill if less than zero.
    }
    
    
    colnames(Grid_Cost_Savings_Month_from_Storage) <- c("Marginal_Energy_Cost", "Marginal_Generation_Capacity_Cost")
    
    Grid_Cost_Savings_Month_from_Storage.df <- data.frame(Grid_Cost_Savings_Month_from_Storage) %>%
      mutate(Month = row_number()) %>%
      group_by(Month) %>%
      gather(key = "Charge_Name", value = "Charge_Value", Marginal_Energy_Cost:Marginal_Generation_Capacity_Cost) %>%
      ungroup() %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Charge_Name = gsub("_", " ", Charge_Name)) %>%
      mutate(Charge_Name = factor(Charge_Name, levels = c("Marginal Energy Cost", "Marginal Generation Capacity Cost")))
    
    ggplot(data = Grid_Cost_Savings_Month_from_Storage.df, aes(x = Month, y = Charge_Value, fill = Charge_Name)) +
      geom_bar(stat = "identity") +
      scale_y_continuous(labels=scales::dollar_format()) +
      coord_cartesian(ylim = c(Min_Grid_Cost_Savings_from_Storage_ylim, Max_Grid_Cost_Savings_from_Storage_ylim)) + # Make ylim 10% larger than grid cost range.
      labs(title = 'Monthly Grid Cost Savings from Storage',
           x = 'Month',
           y = 'Grid Cost ($/month)',
           fill = "Legend") +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5))
    
    rm(Grid_Cost_Savings_Month_from_Storage.df)
    
    if(Export_Plots == 1){
      ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Grid Cost Savings from Storage Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  
  ## Plot Emissions Impact by Month
  
  if(Show_Plots == 1 || Export_Plots ==1){
    
    Emissions_Impact_Timestep = Marginal_Emissions_Rate_Data * -P_ES * (1/1000) * delta_t;
    
    Emissions_Impact_Month = c()
    
    for(Month_Iter in 1:12){
      Emissions_Impact_Single_Month = sum(Emissions_Impact_Timestep[which(Month_Data == Month_Iter)])
      Emissions_Impact_Month = c(Emissions_Impact_Month, Emissions_Impact_Single_Month)
    }
    
    Emissions_Impact_Month.df <- data.frame(Emissions_Impact = Emissions_Impact_Month) %>%
      mutate(Month = row_number()) %>%
      mutate(Month = factor(month.abb[Month], levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))) %>%
      mutate(Emissions_Increase = factor(ifelse(Emissions_Impact >= 0, "Emissions Increase", "Emissions Decrease"), levels = c("Emissions Increase", "Emissions Decrease")))
    
    ggplot(data = Emissions_Impact_Month.df, aes(x = Month, y = Emissions_Impact, fill = Emissions_Increase)) +
      geom_bar(stat = "identity") +
      labs(title = 'Monthly Emissions Impact From Storage',
           x = 'Month',
           y = 'Emissions Increase (metric tons/month)',
           fill = "Legend") +
      theme(text = element_text(size = 15), plot.title = element_text(hjust = 0.5), legend.position = "none") +
      scale_fill_manual(values = c("Emissions Increase" = "red", "Emissions Decrease" = "forestgreen"))
    
    rm(Emissions_Impact_Month.df)
    
    if(Export_Plots == 1){
      ggsave(filename = file.path(Output_Directory_Filepath, "Monthly Emissions Impact from Storage Plot.png"), width = 11, height = 8.5, units = "in")
      
    }
    
  }
  
  ## Write Outputs to CSV
  
  Model_Inputs_and_Outputs = data.frame(Modeling_Team_Input, Model_Run_Number_Input, Model_Run_Date_Time, Model_Type_Input,
                                        Model_Timestep_Resolution, Customer_Class_Input, Load_Profile_Master_Index,
                                        Load_Profile_Name_Input, Retail_Rate_Master_Index, Retail_Rate_Utility,
                                        Retail_Rate_Name_Output, Retail_Rate_Effective_Date,
                                        Solar_Profile_Master_Index, Solar_Profile_Name_Output, Solar_Profile_Description,
                                        Solar_Size_Input, Storage_Power_Rating_Input,
                                        Storage_Energy_Capacity_Input, Single_Cycle_RTE_Input,
                                        ITC_Constraint_Input,
                                        Carbon_Adder_Incentive_Value_Input,
                                        Emissions_Signal_Input,
                                        Annual_GHG_Emissions_Baseline, Annual_GHG_Emissions_with_Solar_Only,
                                        Annual_GHG_Emissions_with_Solar_and_Storage,
                                        Annual_Customer_Bill_Baseline, Annual_Customer_Bill_with_Solar_Only,
                                        Annual_Customer_Bill_with_Solar_and_Storage,
                                        Annual_Grid_Cost_Baseline, Annual_Grid_Cost_with_Solar_Only,
                                        Annual_Grid_Cost_with_Solar_and_Storage,
                                        Annual_Equivalent_Storage_Cycles, Annual_RTE,
                                        Annual_Demand_Charge_Cost_Baseline, Annual_Demand_Charge_Cost_with_Solar_Only,
                                        Annual_Demand_Charge_Cost_with_Solar_and_Storage,
                                        Annual_Energy_Charge_Cost_Baseline, Annual_Energy_Charge_Cost_with_Solar_Only,
                                        Annual_Energy_Charge_Cost_with_Solar_and_Storage,
                                        Annual_Peak_Demand_Baseline, Annual_Peak_Demand_with_Solar_Only,
                                        Annual_Peak_Demand_with_Solar_and_Storage,
                                        Annual_Total_Energy_Consumption_Baseline, Annual_Total_Energy_Consumption_with_Solar_Only,
                                        Annual_Total_Energy_Consumption_with_Solar_and_Storage)
  
  Storage_Dispatch_Outputs = data.frame(t, P_ES)
  names(Storage_Dispatch_Outputs) <- c('Date_Time_America/Los_Angeles', 'Storage_Output_kW')
  
  if(Export_Data == 1){
    
    write.csv(Model_Inputs_and_Outputs, file.path(Output_Directory_Filepath, "OSESMO Reporting Inputs and Outputs.csv"), row.names = F)
    
    write.csv(Storage_Dispatch_Outputs, file.path(Output_Directory_Filepath, "Storage Dispatch Profile Output.csv"), row.names = F)
    
  }
  
  
  ## Return to OSESMO Git Repository Directory
  
  setwd(OSESMO_Git_Repo_Directory)
  
  
}