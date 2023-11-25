import json
import os
import pandas as pd
from openpyxl import load_workbook

courses = []
columns = ['course', 'description', 'section', 'crn', 'slot',
           'daysOfWeek', 'startTime', 'endTime', 'location']

jason = {}
header = ''
course = ''
description = ''
section = ''
crn = 0
slot = 0
daysOfWeek = ''
startTime = 0
endTime = 0
location = ''

secondary_course = ''
secondary_description = ''



def main():
    # write csv headers
    with open('test_output.txt', 'w') as out:
        out.write('course, description, section, crn, slot, daysOfWeek, startTime, endTime, location\n')
    parse_txt()
    txt_to_json()
    create_excel_sheet()
    reset_global_vars()

def reset_global_vars():
    global header, course, description, section, crn, slot, daysOfWeek, startTime, endTime, location

    course = ''
    description = ''
    section = 0
    crn = 0
    slot = 0
    daysOfWeek = ''
    startTime = 0
    endTime = 0
    location = ''
    
def reset_sec_global_vars():
    global secondary_course, secondary_description

    secondary_course = ''
    secondary_description = ''

def txt_to_json():
    global jason
    
    with open('jsontest.json', 'w', encoding='utf-8') as f:
        json.dump(jason, f, ensure_ascii=False, indent=4)

def parse_txt():
    global jason, header, course, description, section, crn, slot, daysOfWeek, startTime, endTime, location
    global secondary_course, secondary_description
     
    with open('test.txt', 'r') as file:
        lines = file.readlines()
        for line in lines:
            reset_global_vars()
            line.strip()
            item = line.split(" ")
            str_list = list(filter(None, item))
            
            for i in range(len(str_list)):
                if str_list[i].isdigit() : str_list[i] = int(str_list[i])
                if str_list[i] == '\n': str_list.pop(i)
            
            if not str_list: continue    
            
            iterate = True
            iterator = iter(str_list)
            
            while iterate == True:
                first = next(iterator)
                second = next(iterator)
                
                if (isinstance(first, str)):
                    reset_sec_global_vars
                    if 'Subject' in first:
                        header = second
                        jason = {header: {}}
                        iterate = False
                        break
                    elif (len(first) == 4 and isinstance(second, int)):
                        course = first + str(second)
                        nextelem = next(iterator)
                        while isinstance(nextelem, str):   
                            description += nextelem
                            description += " "
                            nextelem = next(iterator)
                            
                        section = str(nextelem).zfill(3)
                        crn = next(iterator)
                    else: 
                        iterate = False
                        break
                elif (isinstance(first, int)):
                    course = secondary_course
                    description = secondary_description
                    section = str(first).zfill(3)
                    crn = second
    
                else:
                    iterate = False
                    break
                
                slot = next(iterator)
                
                nextelem = next(iterator)
                while isinstance(nextelem, str):
                    daysOfWeek += nextelem
                    nextelem = next(iterator)
                    
                startTime = str(nextelem).zfill(4)
                endTime = str(next(iterator)).zfill(4)
                
                location += next(iterator)
                location += str(next(iterator))
        
        
                description = str(description).replace(',', '')
                #print(description)
                secondary_course = course
                secondary_description = description
            
                with open('test_output.txt', 'a') as out:
                    out.write(course + ",")
                    out.write(description + ",")
                    out.write(str(section) + ",")
                    out.write(str(crn) + ",")
                    out.write(str(slot) + ",")
                    out.write(daysOfWeek + ",")
                    out.write(str(startTime) + ",")
                    out.write(str(endTime) + ",")
                    out.write(location + ",")
                    out.write("\n")     
                    
                
                data = {
                    "course": course,
                    "description": description,
                    "section": section,
                    "crn": crn,
                    "slot": slot,
                    "daysOfWeek": daysOfWeek,
                    "startTime": startTime,
                    "endTime": endTime,
                    "location": location
                }
                
                jason[header][course] = data        
            

def create_excel_sheet():
    global header
    df = pd.read_csv('test_output.txt', sep=",", header=0, index_col=False)
    df.columns = columns
    df['section'] = df['section'].apply(str).apply(lambda x: x.zfill(3)) #.str.zfill(3)
    df['startTime'] = df['startTime'].apply(str).apply(lambda x: x.zfill(4)) #.str.zfill(4)
    df['endTime'] = df['endTime'].apply(str).apply(lambda x: x.zfill(4)) #.str.zfill(4)
    #print(df.head(5))
    
    
    with pd.ExcelWriter('course_list.xlsx', engine='openpyxl', mode='a') as writer:  
        df.to_excel(writer, sheet_name=header)


main()
