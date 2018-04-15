
# coding: utf-8

# In[6]:

# @mfunction("Solar_Installed_Cost_per_kW")
def Solar_Installed_Cost_per_kW_Calculator(Customer_Class_Input=None, Solar_Size_Input=None):

    # Solar Installed Cost per kW
    # Taken from LBNL"s Tracking the Sun 10 report, Tables B-2 and B-3 (pgs. 50 & 51)

    if Customer_Class_Input == "Residential":

        if Solar_Size_Input <= 2:
            Solar_Installed_Cost_per_kW = 4400

        elif Solar_Size_Input > 2 and Solar_Size_Input <= 4:
            Solar_Installed_Cost_per_kW = 4500

        elif Solar_Size_Input > 4 and Solar_Size_Input <= 6:
            Solar_Installed_Cost_per_kW = 4200

        elif Solar_Size_Input > 6 and Solar_Size_Input <= 8:
            Solar_Installed_Cost_per_kW = 4000

        elif Solar_Size_Input > 8 and Solar_Size_Input <= 10:
            Solar_Installed_Cost_per_kW = 3800

        elif Solar_Size_Input > 10 and Solar_Size_Input <= 12:
            Solar_Installed_Cost_per_kW = 3700

        elif Solar_Size_Input > 12 and Solar_Size_Input <= 14:
            Solar_Installed_Cost_per_kW = 3600

        elif Solar_Size_Input > 14 and Solar_Size_Input <= 16:
            Solar_Installed_Cost_per_kW = 3500

        elif Solar_Size_Input > 16 and Solar_Size_Input <= 18:
            Solar_Installed_Cost_per_kW = 3400

        elif Solar_Size_Input > 18 and Solar_Size_Input <= 20:
            Solar_Installed_Cost_per_kW = 3500

        else:
            Solar_Installed_Cost_per_kW = 3500
        

    elif Customer_Class_Input == "Commercial and Industrial":

        if Solar_Size_Input <= 10:
            Solar_Installed_Cost_per_kW = 4100

        elif Solar_Size_Input > 10 and Solar_Size_Input <= 20:
            Solar_Installed_Cost_per_kW = 3700

        elif Solar_Size_Input > 20 and Solar_Size_Input <= 50:
            Solar_Installed_Cost_per_kW = 3400

        elif Solar_Size_Input > 50 and Solar_Size_Input <= 100:
            Solar_Installed_Cost_per_kW = 3200

        elif Solar_Size_Input > 100 and Solar_Size_Input <= 250:
            Solar_Installed_Cost_per_kW = 3000

        elif Solar_Size_Input > 250 and Solar_Size_Input <= 500:
            Solar_Installed_Cost_per_kW = 2600

        elif Solar_Size_Input > 500 and Solar_Size_Input <= 1000:
            Solar_Installed_Cost_per_kW = 2500

        else:
            Solar_Installed_Cost_per_kW = 2200

    return Solar_Installed_Cost_per_kW

    


# In[ ]:




# In[ ]:




# In[ ]:



