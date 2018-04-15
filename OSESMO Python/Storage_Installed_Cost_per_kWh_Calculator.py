
# coding: utf-8

# In[10]:

# @mfunction("Storage_Installed_Cost_per_kWh")
def Storage_Installed_Cost_per_kWh_Calculator(Customer_Class_Input=None, Storage_Type_Input=None):
    # Storage_Installed_Cost_per_kWh=0

    # Storage Installed Cost per kWh
    # For lithium-ion batteries, used values from Lazard's Levelized Cost of Storage report (2017), pg. 19.
    # (https://www.lazard.com/media/450338/lazard-levelized-cost-of-storage-version-30.pdf)
    # For lithium-ion batteries, used average of maximum and minimum values from range.

    # Information about commercial and industrial flow batteries was not available in the 2017 version (Version 3.0) of the Lazard report,
    # but was reported in the 2016 version (Version 2.0) of the report, PDF pg. 22 (numbered 18 in the report).
    # (https://www.lazard.com/media/438042/lazard-levelized-cost-of-storage-v20.pdf)

    if Customer_Class_Input == "Residential":

        if Storage_Type_Input == "Lithium-Ion Battery": 
            Storage_Installed_Cost_per_kWh = (831 + 1089) / 2

        elif Storage_Type_Input == "Flow Battery":
            Storage_Installed_Cost_per_kWh = (902 + 1102) / 2

    elif Customer_Class_Input == "Commercial and Industrial":
        if Storage_Type_Input == "Lithium-Ion Battery": 
            Storage_Installed_Cost_per_kWh = (643 + 720) / 2

        elif Storage_Type_Input == "Flow Battery":
            Storage_Installed_Cost_per_kWh = (902 + 1102) / 2           
    return Storage_Installed_Cost_per_kWh


# In[ ]:




# In[ ]:



