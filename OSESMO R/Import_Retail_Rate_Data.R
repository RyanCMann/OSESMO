Import_Retail_Rate_Data <- function(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Retail_Rate_Name_Input){
  
  ## Set Directory to Box Sync Folder
  setwd(Input_Output_Data_Directory_Location)
  
  
  ## Import Volumetric (per kWh) Rate Data

  if(Retail_Rate_Name_Input == "PG&E EV2 (NEW)"){
    
    Retail_Rate_Master_Index = "R1"
    Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II"
    
    if(delta_t == (60/60)){
      Volumetric_Rate_Data = read.csv(file.path("Rates", "PG&E EV2 (NEW)", "2017", "60-Minute Data",
                                                "Vector Format", "2017_PGE_EV2_Energy_Rates_Vector.csv"), header = F)[, 1]
    }    
    
  }
    
  if(Retail_Rate_Name_Input == "PG&E B-19S-S (NEW)"){
    
    Retail_Rate_Master_Index = "C1"
    Retail_Rate_Effective_Date = "Proposed - 2017 GRC Phase II"
    
    if(delta_t == (15/60)){
      Volumetric_Rate_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data",
                                                "Vector Format", "2017_PGE_B19SS_NEW_Energy_Rates_Vector.csv"), header = F)[, 1]
    }    
    
  }
  
  
  ## Select Demand Charge and Fixed-Charge Variable Values
  
  if(Retail_Rate_Name_Input == "PG&E EV2 (NEW)"){
    
    # Demand Charges - PG&E EV2
    Summer_Peak_DC = 0
    Summer_Peak_DC_Period = "Monthly" # $/kW-day
    
    Summer_Part_Peak_DC = 0
    Summer_Part_Peak_DC_Period = "Monthly" # $/kW-day
    
    Summer_Special_Maximum_DC = 0
    Summer_Special_Maximum_DC_Period = "Monthly" # $/kW-month
    
    Summer_Noncoincident_DC = 0
    Summer_Noncoincident_DC_Period = "Monthly" # $/kW-month
    
    Winter_Peak_DC = 0
    Winter_Peak_DC_Period = "Monthly" # $/kW-day
    
    Winter_Part_Peak_DC = 0
    Winter_Part_Peak_DC_Period = "Monthly" # $/kW-day
    
    Winter_Noncoincident_DC = 0
    Winter_Noncoincident_DC_Period = "Monthly" # $/kW-month
    
    Winter_Special_Maximum_DC = 0
    Winter_Special_Maximum_DC_Period = "Monthly" # $/kW-month
    
    # Fixed Per-Meter-Day Charge - PG&E EV2
    Fixed_Per_Meter_Day_Charge = 0  # $ per meter per day
    Fixed_Per_Meter_Month_Charge = 0 # $ per meter per month
    
    # Summer Months
    First_Summer_Month = 6 # June is the first summer month for this rate.
    Last_Summer_Month = 9 # September is the last summer month for this rate.
    
  }
  
  if(Retail_Rate_Name_Input == "PG&E B-19S-S (NEW)"){
    
    # Demand Charges - NEW PG&E B-19 Secondary Voltage - Option S
    Summer_Peak_DC = 0.49
    Summer_Peak_DC_Period = "Daily" # $/kW-day
    
    Summer_Part_Peak_DC = 0.03
    Summer_Part_Peak_DC_Period = "Daily" # $/kW-day
    
    Summer_Special_Maximum_DC = 2.32
    Summer_Special_Maximum_DC_Period = "Monthly" # $/kW-month
    
    Summer_Noncoincident_DC = 8.09
    Summer_Noncoincident_DC_Period = "Monthly" # $/kW-month
    
    Winter_Peak_DC = 0.42
    Winter_Peak_DC_Period = "Daily" # $/kW-day
    
    Winter_Part_Peak_DC = 0 # There is no part-peak demand charge in the winter.
    Winter_Part_Peak_DC_Period = "Daily" # $/kW-day
    
    Winter_Special_Maximum_DC = 2.32
    Winter_Special_Maximum_DC_Period = "Monthly" # $/kW-month
    
    Winter_Noncoincident_DC = 8.09
    Winter_Noncoincident_DC_Period = "Monthly" # $/kW-month
    
    # Fixed Per-Meter-Day Charge - NEW PG&E B-19 Secondary Voltage - Option S
    Fixed_Per_Meter_Day_Charge = 0  # $ per meter per day
    Fixed_Per_Meter_Month_Charge = 720 # $ per meter per month
    
    # Summer Months
    First_Summer_Month = 6 # June is the first summer month for this rate.
    Last_Summer_Month = 9 # September is the last summer month for this rate.
    
  }
  
  
  ## Import Month & Day Data - Used to Filter Other Vectors

  if(Retail_Rate_Name_Input == "PG&E EV2 (NEW)"){
    
    if(delta_t == (60/60)){
      Month_Data = read.csv(file.path("Rates", "PG&E EV2 (NEW)", "2017", "60-Minute Data/Vector Format",
                                      "2017_PGE_EV2_Month_Vector.csv"), header = F)[, 1]
      Day_Data = read.csv(file.path("Rates", "PG&E EV2 (NEW)", "2017", "60-Minute Data/Vector Format",
                                    "2017_PGE_EV2_Day_Vector.csv"), header = F)[, 1] # Used for daily demand charges.
    }
    
  }
    
  if(Retail_Rate_Name_Input == "PG&E B-19S-S (NEW)"){
    
    if(delta_t == (15/60)){
      Month_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data/Vector Format",
                                      "2017_PGE_B19SS_NEW_Month_Vector.csv"), header = F)[, 1]
      Day_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data/Vector Format",
                                    "2017_PGE_B19SS_NEW_Day_Vector.csv"), header = F)[, 1] # Used for daily demand charges.
    }
    
  }
  
  
  ## Import Demand Charge Binary Variable Data
  
  if(Retail_Rate_Name_Input == "PG&E EV2 (NEW)"){
    
    # PG&E EV2 (NEW) does not have any demand charges.
    Summer_Peak_Binary_Data = Month_Data * 0 
    
    Summer_Part_Peak_Binary_Data = Month_Data * 0 
    
    Winter_Peak_Binary_Data = Month_Data * 0 
    
    Special_Maximum_Demand_Binary_Data = Month_Data * 0 
    
    Winter_Part_Peak_Binary_Data = Month_Data * 0    
    
  }
  
  if(Retail_Rate_Name_Input == "PG&E B-19S-S (NEW)"){
    
    if(delta_t == (15/60)){
      Summer_Peak_Binary_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data",
                                                   "Vector Format", "2017_PGE_B19SS_NEW_Summer_Peak_Binary_Vector.csv"), header = F)[, 1]
      
      Summer_Part_Peak_Binary_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data", 
                                                        "Vector Format", "2017_PGE_B19SS_NEW_Summer_Partial_Peak_Binary_Vector.csv"), header = F)[, 1]
      
      Winter_Peak_Binary_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data", 
                                                   "Vector Format", "2017_PGE_B19SS_NEW_Winter_Peak_Binary_Vector.csv"), header = F)[, 1]
      
      Special_Maximum_Demand_Binary_Data = read.csv(file.path("Rates", "PG&E B-19S-S (NEW)", "2017", "15-Minute Data", 
                                                              "Vector Format", "2017_PGE_B19SS_NEW_Special_Maximum_Demand_Charge_Binary_Vector.csv"), header = F)[, 1]
    }
    
    # PG&E B-19S-S (NEW) does not have a winter part-peak demand charge.
    Winter_Part_Peak_Binary_Data = Month_Data * 0    
    
  }
  
  ## Return to OSESMO Git Repository Directory
  setwd(OSESMO_Git_Repo_Directory)
  
  return(list(Retail_Rate_Master_Index, Retail_Rate_Effective_Date, 
              Volumetric_Rate_Data, Summer_Peak_DC, Summer_Peak_DC_Period, 
              Summer_Part_Peak_DC, Summer_Part_Peak_DC_Period, 
              Summer_Special_Maximum_DC, Summer_Special_Maximum_DC_Period, 
              Summer_Noncoincident_DC, Summer_Noncoincident_DC_Period, 
              Winter_Peak_DC, Winter_Peak_DC_Period, 
              Winter_Part_Peak_DC, Winter_Part_Peak_DC_Period, 
              Winter_Special_Maximum_DC, Winter_Special_Maximum_DC_Period, 
              Winter_Noncoincident_DC, Winter_Noncoincident_DC_Period, 
              Fixed_Per_Meter_Day_Charge, Fixed_Per_Meter_Month_Charge, 
              First_Summer_Month, Last_Summer_Month, Month_Data, Day_Data, 
              Summer_Peak_Binary_Data, Summer_Part_Peak_Binary_Data, 
              Winter_Peak_Binary_Data, Winter_Part_Peak_Binary_Data, Special_Maximum_Demand_Binary_Data))
  
}