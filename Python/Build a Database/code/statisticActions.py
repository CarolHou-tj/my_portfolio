#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct  6 11:46:23 2024

@author: houderou
"""

import databaseManagement

patientsdictionary = databaseManagement.importData()

# A function that calculates the percentage of men and women who have anemia or diabetes.
def statistic(patientsdictionary):
    womenGroup = {key: value for key, value in patientsdictionary.items() if value.get_sex() == 0}
    menGroup = {key: value for key, value in patientsdictionary.items() if value.get_sex() == 1}
    
    def anemia(subDictionary):
        anemiaGroup = {key: value for key, value in subDictionary.items() if value.get_anaemia() == 1}
        anemiaStats = int(round((len(anemiaGroup) / len(subDictionary))*100,0))
        return anemiaStats
    
    def diabetes(subDictionary):
        diabetesGroup = {key: value for key, value in subDictionary.items() if value.get_diab() == 1}
        diabetesStats = int(round((len(diabetesGroup) / len(subDictionary))*100,0))
        return diabetesStats
    
    print("The percentage of women who have anemia is ", anemia(womenGroup),"%")
    print("The percentage of men who have anemia is ", anemia(menGroup),"%")
    print("The percentage of women who have diabetes is ", diabetes(womenGroup),"%")
    print("The percentage of men who have diabetes is ", diabetes(menGroup),"%")