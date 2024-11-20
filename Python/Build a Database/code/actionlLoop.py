#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct  6 11:46:53 2024

@author: houderou
"""

import databaseManagement, printActions, statisticActions

def action(patientsdictionary):
    patientsdictionary = databaseManagement.importData()
    patientdic = databaseManagement.patientDic(patientsdictionary)
    
    while True:
        print("Enter 1 to add a patient to the database")
        print("      2 to delete a patient from the database")
        print("      3 to modify a patient's test result")
        print("      4 to print all the patient's records")
        print("      5 to print a single patient's record")
        print("      6 to print a single patient's test result")
        print("      7 to print a statistic")
        print("      8 to exit the program")
        choice = int(input("Enter your choice now: "))
    
        if choice == 1:
            patientdic.add_patient()
        elif choice == 2:
            patientdic.remove_patient()
        elif choice == 3:
            patientdic.modifyResult()
        elif choice == 4:
            printActions.printAllData(patientsdictionary)
        elif choice == 5:
            printActions.printOneData(patientsdictionary)
        elif choice == 6:
            printActions.printOneTest(patientsdictionary)
        elif choice == 7:
            statisticActions.statistic(patientsdictionary)
        else:
            break

    