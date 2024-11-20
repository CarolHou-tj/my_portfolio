#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  7 23:57:37 2024

@author: houderou
"""

# All the code in this assignment was written by myself with reference to the lecture notes. 
# However, I ask ChatGPT for help in the following three situations:
    # 1.When I have written functions in a module and I want ChatGPT to check for possible errors.
    # 2.When the output is different from what I expected.
    # 3.When error messages appear.
    
import databaseManagement, actionlLoop

patientsdictionary = databaseManagement.importData()
actionlLoop.action(patientsdictionary)