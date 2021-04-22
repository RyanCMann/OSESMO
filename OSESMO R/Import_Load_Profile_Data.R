Import_Load_Profile_Data <- function(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Load_Profile_Name_Input){

  # Set Directory to Input/Output Directory
  setwd(Input_Output_Data_Directory_Location)
  
  # Import Load Profile Data
  
  if(Load_Profile_Name_Input == "PG&E GreenButton Central Valley Residential Non-CARE"){
    
    Load_Profile_Master_Index = "R9"
    
    if(delta_t == (60/60)){
      Load_Profile_Data = read.csv(file.path("Load Profile Data", "PG&E Residential Central Valley 2015",
                                             "2017 Remapped", "60-Minute Data",
                                             "Vector Format", "Clean_Vector_2017_PGE_Central_Valley_Residential_Non_CARE.csv"), header = F)[, 1]
    }
    
    
  }
  
  if(Load_Profile_Name_Input == "EnerNOC GreenButton San Francisco Office"){
    
    Load_Profile_Master_Index = "C13"
    
    if(delta_t == (15/60)){
      Load_Profile_Data = read.csv(file.path("Load Profile Data", "EnerNOC GreenButton",
                                             "Selected Clean 2017 EnerNOC Load Profiles", "15-Minute Data/San Francisco Office",
                                             "Vector Format", "Clean_Vector_2017_San_Francisco_Office.csv"), header = F)[, 1]
    }
    
    
  }
  
  # Return to OSESMO Git Repository Directory
  setwd(OSESMO_Git_Repo_Directory)
  
  
  return(list(Load_Profile_Data, Load_Profile_Master_Index))
  
}