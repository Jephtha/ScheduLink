import json
import pandas as pd
from os import getcwd
from glob import glob

columns = ['course', 'description', 'section', 'crn', 'slot',
           'daysOfWeek', 'startTime', 'endTime', 'location']

jason = {}
courses = []
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
    directory = getcwd()
    # Get all files and directories ending with .txt and that don't begin with a dot
    file_list = glob(directory + "/raw_course_files/*.txt")

    # write csv headers in output file
    with open('parsed_course_list.txt', 'w') as out:
        out.write('course, description, section, crn, slot, daysOfWeek, startTime, endTime, location\n')

    for file in file_list:
        parse_txt(file)
        create_excel_sheet()
        reset_global_vars()

    txt_to_json()

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
    global jason, courses

    jason = {"courses": courses}
    with open('courses.json', 'w', encoding='utf-8') as f:
        json.dump(jason, f, ensure_ascii=False, indent=4)

def parse_txt(path):
    global jason, courses, header, course, description, section, crn, slot, daysOfWeek, startTime, endTime, location
    global secondary_course, secondary_description

    with open('test_output.txt', 'w') as out:
        out.write('course, description, section, crn, slot, daysOfWeek, startTime, endTime, location\n')

    with open(path, 'r') as file:
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
                        header += " "
                        maybe = next(iterator, None)
                        if maybe != None: header += maybe

                        iterate = False
                        break
                    elif (len(first) == 4 and isinstance(second, int)):
                        course = first + str(second)
                        nextelem = next(iterator)
                        while isinstance(nextelem, str):
                            description += nextelem
                            description += " "
                            nextelem = next(iterator)

                        unsure = nextelem
                        if unsure > 10 and unsure != 56 and unsure != 57:
                            unsure = str(unsure)
                            description += unsure
                            section = str(next(iterator)).zfill(3)
                        else:
                            section = str(unsure).zfill(3)
                        crn = next(iterator)
                    else:
                        iterate = False
                        break
                elif (isinstance(first, int)):
                    if first == 16:
                        iterate = False
                        break
                    else:
                        course = secondary_course
                        description = secondary_description
                        section = str(first).zfill(3)
                        crn = second

                else:
                    iterate = False
                    break

                nextelem = next(iterator)
                if isinstance(nextelem, int):
                    slot = nextelem
                    nextelem = next(iterator)
                    while isinstance(nextelem, str):
                        daysOfWeek += nextelem
                        nextelem = next(iterator)
                else:
                    while isinstance(nextelem, str):
                        if "G" in nextelem or "F0" in nextelem:
                            slot = nextelem
                            nextelem = next(iterator)
                        daysOfWeek += nextelem
                        nextelem = next(iterator)

                startTime = str(nextelem).zfill(4)
                endTime = str(next(iterator)).zfill(4)

                first_loc = next(iterator)
                if "CSF" not in first_loc and "IIC" not in first_loc:
                    location += first_loc
                    location += str(next(iterator))
                else:
                    location += first_loc


                description = str(description).replace(',', '')
                secondary_course = course
                secondary_description = description

                with open('parsed_course_list.txt', 'a') as out:
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
                    "subject": header.strip(),
                    "course": course,
                    "description": description.strip(),
                    "section": section,
                    "crn": str(crn),
                    "slot": str(slot),
                    "daysOfWeek": daysOfWeek,
                    "startTime": startTime,
                    "endTime": endTime,
                    "location": location
                }

                courses.append(data)


def create_excel_sheet():
    global header
    df = pd.read_csv('test_output.txt', sep=",", header=0, index_col=False)
    df.columns = columns
    df['section'] = df['section'].apply(str).apply(lambda x: x.zfill(3))
    df['startTime'] = df['startTime'].apply(str).apply(lambda x: x.zfill(4))
    df['endTime'] = df['endTime'].apply(str).apply(lambda x: x.zfill(4))


    with pd.ExcelWriter('course_list.xlsx', engine='openpyxl', mode='a', if_sheet_exists='replace') as writer:
        df.to_excel(writer, sheet_name=header)


main()
