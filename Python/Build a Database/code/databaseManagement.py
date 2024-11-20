#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct  6 08:50:28 2024

@author: houderou
"""

# Create the Tests Class
class Tests():
    def __init__(self, ID, anaemia, diab, hbp, plat, creat, sodium):
        self.ID = int(ID)
        self.anaemia = int(anaemia)
        self.diab = int(diab)
        self.hbp = int(hbp)
        self.plat = int(plat)
        self.creat = float(creat)
        self.sodium = int(sodium)
        
    def get_ID(self):
        return self.ID
    def get_anaemia(self):
        return self.anaemia
    def get_diab(self):
        return self.diab
    def get_hbp(self):
        return self.hbp
    def get_plat(self):
        return self.plat
    def get_creat(self):
        return self.creat
    def get_sodium(self):
        return self.sodium
    
    def printResults(self):
        layout= "{0:>9}{1:>12}{2:>23}{3:>14}{4:>13}{5:>11}"
        print(layout.format("Anemia", "Diabetes", "High Blood Pressure", "Platelets", "Creatinine", "Sodium"))
        print(layout.format(self.anaemia, self.diab, self.hbp, self.plat, self.creat, self.sodium))

# Create the Patient Class
class Patient(Tests):
    def __init__(self, ID, DOB, sex, smok, anaemia, diab, hbp, plat, creat, sodium):
        self.ID = int(ID)
        self.anaemia = int(anaemia)
        self.diab = int(diab)
        self.hbp = int(hbp)
        self.plat = int(plat)
        self.creat = float(creat)
        self.sodium = int(sodium)
        self.ID = int(ID)
        self.characteristics = (int(DOB), int(sex), int(smok))
        self.testResults = Tests(ID, anaemia, diab, hbp, plat, creat, sodium)
        
    def get_ID(self):
        return self.ID
    def get_sex(self):
        return self.characteristics[1]
    def get_anaemia(self):
        return self.anaemia
    def get_diab(self):
        return self.diab
    def get_characteristics(self):
        return self.characteristics
    def get_testResults(self):
        return self.testResults
        
    def printRecord(self):
        print("Patient Record of Patient # ", self.ID)
        sex = "F" if self.characteristics[1] == 0 else "M"
        characteristics = (self.characteristics[0], sex, self.characteristics[2])
        print("DOB, Sex at Birth, Smoker: ", characteristics)

# A function that reads a file and creates a new dictionary of patients based on the contents of the file.
def importData():
    patientsData= open('patients-database-tab.txt', 'r')
    lines = patientsData.readlines()
    patientslist = [] 
    patientsdictionary = {}
    for line in lines[1:]:
        patientslist = line.split()
        patientsdictionary[patientslist[0]] = Patient(patientslist[0], patientslist[1], patientslist[2], patientslist[3], patientslist[4], patientslist[5], patientslist[6], patientslist[7], patientslist[8], patientslist[9])
    return patientsdictionary



class patientDic():
    def __init__(self, patients=None):
        if patients is None:
            self.patients = {}
        else:
            self.patients = patients
            

# A Dictionary method to add a new patient to the dictionary
    def add_patient(self):
        print("Enter the patients year of birth, sex, whether the patient smokes")
        a_DOB = input("DOB: ")
        a_sex = input("Sex at birth (1 for male, 0 for female): ")
        a_smok = input("Smoker (1 for smoker; 0 for non-smoker): ")
        print("Enter Test Results")
        a_anaemia = input("Anemia (1/0): ")
        a_diab = input("Diabetes (1/0): ")
        a_hbp = input("High Blood Pressure (1/0): ")
        a_plat = input("Platelet level: ")
        a_creat = input("Creatinine level: ")
        a_sodium = input("Sodium level: ")
        n=len(self.patients) + 1
        self.patients[n] = Patient(n, a_DOB, a_sex, a_smok, a_anaemia, a_diab, a_hbp, a_plat, a_creat, a_sodium)
        return self.patients

# A Dictionary method to delete a patient from the dictionary
    def remove_patient(self):
        print("Enter the ID of the patient you would like to delete from the Database")
        deleteRoll = int(input("ID Number: "))
        del self.patients[deleteRoll]
        return self.patients  
 
# A Tests method to modify a test result
    def modifyResult(self):
        print("Enter the ID of the patient and the test result you would like to modify")
        modifyID = int(input("Patient ID Number: "))
        if modifyID in self.patients:
            patient = self.patients[modifyID]
            testResults = patient.get_testResults()
            print("Test Selection: Enter 1 for Anemia/2 for Diabetes/3 for High Blood Pressure/4 for Platelets/5 for Creatinine/6 for Sodium")
            modifyType = input("Enter your selection now: ")
            newTest = input("Enter the new test result: ")
            if modifyType == '1':
                testResults.anaemia = int(newTest)
            elif modifyType == '2':
                testResults.diab = int(newTest)
            elif modifyType == '3':
                testResults.hbp = int(newTest)
            elif modifyType == '4':
                testResults.plat = int(newTest)
            elif modifyType == '5':
                testResults.creat = float(newTest)
            else:
                testResults.sodium = int(newTest)
        return self.patients