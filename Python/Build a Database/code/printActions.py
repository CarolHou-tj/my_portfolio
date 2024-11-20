#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct  6 11:45:25 2024

@author: houderou
"""

import databaseManagement

patientsdictionary = databaseManagement.importData()

# A function to print all the records in the Dictionnary
def printAllData(patientsdictionary):
    for ID, patient in patientsdictionary.items():
        patient.printRecord()
        patient.testResults.printResults()

# A function that asks the user to enter a patient’s ID and calls the method that that prints that patient’s full record                
def printOneData(patientsdictionary):
    dataNum = int(input("Please enter the id of the patient whose record you would like to see: "))
    if dataNum in patientsdictionary:
        patient = patientsdictionary[dataNum]
        patient.printRecord()
        patient.testResults.printResults()        

# A function that asks the user to enter a patient’s ID and a test and that prints the patient’s specific test results.
def printOneTest(patientsdictionary):
    dataNum = int(input("Please enter the id of the patient you are treating: "))
    print("What test results you would like to view?")
    print("Enter 1 for Anemia/2 for Diabetes/3 for High Blood Pressure/4 for Platelets/5 for Creatinine/6 for Sodium")
    testNum = int(input("Enter your selection now: "))
    
    patient = patientsdictionary.get(dataNum)
    if testNum == 1:
        if patient.anaemia ==1:
            print("Patient # ", dataNum,"has anemia")
        else:
            print("Patient # ", dataNum,"does't have anemia")
    elif testNum == 2:
        if patient.diab ==1:
            print("Patient # ", dataNum,"has diabetes")
        else:
            print("Patient # ", dataNum,"does't have diabetes")
    elif testNum == 3:
        if patient.hbp ==1:
            print("Patient # ", dataNum,"has high blood pressure")
        else:
            print("Patient # ", dataNum,"does't have high blood pressure")
    elif testNum == 4:
        print("Patient # ", dataNum,"'s platelets level is ", patient.plat)
    elif testNum == 5:
        print("Patient # ", dataNum,"'s creatinine level is ", patient.creat)
    else:
        print("Patient # ", dataNum,"'s sodium level is ", patient.sodium)
    