Import_Export_Compensation_Rate_Data <- function(Input_Output_Data_Directory_Location, OSESMO_Git_Repo_Directory, delta_t, Export_Compensation_Rate_Name_Input){
  
  ## Set Directory to Input/Output Directory Folder
  setwd(Input_Output_Data_Directory_Location)
  
  
  ## Import Export Compensation Rate Data

  if(Export_Compensation_Rate_Name_Input == "PG&E EV2 (NEW) NEM 2"){
    
    if(delta_t == (60/60)){
      Export_Compensation_Rate_Data = read.csv(file.path("Export Compensation Rate Data", "PG&E EV2 (NEW) NEM 2", "2017", "60-Minute Data",
                                                         "Vector Format", "2017_PGE_EV2_NEM2_ECR_Vector.csv"), header = F)[, 1]
    }    
    
  }
    
  if(Export_Compensation_Rate_Name_Input == "PG&E B-19S-S NEM 2"){
    
    if(delta_t == (15/60)){
      Export_Compensation_Rate_Data = read.csv(file.path("Export Compensation Rate Data", "PG&E B-19S-S NEM 2", "2017", "15-Minute Data",
                                                "Vector Format", "2017_PGE_B19SS_NEM2_ECR_Vector.csv"), header = F)[, 1]
    }    
    
  }
  
  ## Return to OSESMO Git Repository Directory
  setwd(OSESMO_Git_Repo_Directory)
  
  return(Export_Compensation_Rate_Data)
  
}