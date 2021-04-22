Import_Marginal_Emissions_Rate_Data <- function(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Emissions_Signal_Input){
  
  # Set Directory to Box Sync Folder
  setwd(Input_Output_Data_Directory_Location)
  
  # Import Marginal Emissions Rate Data Used for Evaluation
  if(Emissions_Signal_Input == "NP15 RT5M"){
    
    if(delta_t == (15/60)){
      Marginal_Emissions_Rate_Data = read.csv(file.path("Emissions Data/Itron-E3 Methodology",
                                                        "2017", "Clean Emissions Data", "Real Time 5 Minute Emissions Signal",
                                                        "15-Minute Data", "2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv"), header = F)[, 1]
    }
    
    else if(delta_t == (60/60)){
      Marginal_Emissions_Rate_Data = read.csv(file.path("Emissions Data/Itron-E3 Methodology",
                                                        "2017", "Clean Emissions Data", "Real Time 5 Minute Emissions Signal",
                                                        "60-Minute Data", "2017_RT5M_NP15_Marginal_Emissions_Rate_Vector.csv"), header = F)[, 1]
    }
    
  }else if(Emissions_Signal_Input ==  "SP15 RT5M"){
    
    if(delta_t == (15/60)){
      Marginal_Emissions_Rate_Data = read.csv(file.path("Emissions Data/Itron-E3 Methodology",
                                                         "2017", "Clean Emissions Data", "Real Time 5 Minute Emissions Signal",
                                                         "15-Minute Data", "2017_RT5M_SP15_Marginal_Emissions_Rate_Vector.csv"), header = F)[, 1]
    }
    
  }
  
  # Return to OSESMO Git Repository Directory
  setwd(OSESMO_Git_Repo_Directory)
  
  return(Marginal_Emissions_Rate_Data)
  
}