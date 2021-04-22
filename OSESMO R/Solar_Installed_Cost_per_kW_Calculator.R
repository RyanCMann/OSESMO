Solar_Installed_Cost_per_kW_Calculator <- function(Customer_Class_Input,Solar_Size_Input){
    
    # Solar Installed Cost per kW
    # Taken from LBNL"s Tracking the Sun 10 report, Tables B-2 and B-3 (pgs. 50 & 51)
    
    if(Customer_Class_Input == "Residential"){
        
        if(Solar_Size_Input <= 2){
            Solar_Installed_Cost_per_kW = 4400
            
        }else if(Solar_Size_Input > 2 && Solar_Size_Input <= 4){
            Solar_Installed_Cost_per_kW = 4500
            
        }else if(Solar_Size_Input > 4 && Solar_Size_Input <= 6){
            Solar_Installed_Cost_per_kW = 4200
            
        }else if(Solar_Size_Input > 6 && Solar_Size_Input <= 8){
            Solar_Installed_Cost_per_kW = 4000
            
        }else if(Solar_Size_Input > 8 && Solar_Size_Input <= 10){
            Solar_Installed_Cost_per_kW = 3800
            
        }else if(Solar_Size_Input > 10 && Solar_Size_Input <= 12){
            Solar_Installed_Cost_per_kW = 3700
            
        }else if(Solar_Size_Input > 12 && Solar_Size_Input <= 14){
            Solar_Installed_Cost_per_kW = 3600
            
        }else if(Solar_Size_Input > 14 && Solar_Size_Input <= 16){
            Solar_Installed_Cost_per_kW = 3500
            
        }else if(Solar_Size_Input > 16 && Solar_Size_Input <= 18){
            Solar_Installed_Cost_per_kW = 3400
            
        }else if(Solar_Size_Input > 18 && Solar_Size_Input <= 20){
            Solar_Installed_Cost_per_kW = 3500
            
        } else
            Solar_Installed_Cost_per_kW = 3500
        
    }else if(Customer_Class_Input == "Commercial and Industrial"){
        
        if(Solar_Size_Input <= 10){
            Solar_Installed_Cost_per_kW = 4100
            
        }else if(Solar_Size_Input > 10 && Solar_Size_Input <= 20){
            Solar_Installed_Cost_per_kW = 3700
            
        }else if(Solar_Size_Input > 20 && Solar_Size_Input <= 50){
            Solar_Installed_Cost_per_kW = 3400
            
        }else if(Solar_Size_Input > 50 && Solar_Size_Input <= 100){
            Solar_Installed_Cost_per_kW = 3200
            
        }else if(Solar_Size_Input > 100 && Solar_Size_Input <= 250){
            Solar_Installed_Cost_per_kW = 3000
            
        }else if(Solar_Size_Input > 250 && Solar_Size_Input <= 500){
            Solar_Installed_Cost_per_kW = 2600
            
        }else if(Solar_Size_Input > 500 && Solar_Size_Input <= 1000){
            Solar_Installed_Cost_per_kW = 2500
            
        }else
            Solar_Installed_Cost_per_kW = 2200
        
    }
    
    return(Solar_Installed_Cost_per_kW)
    
}