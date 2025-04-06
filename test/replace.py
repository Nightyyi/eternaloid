import subprocess, shutil, argparse
from pathlib import Path 

parser = argparse.ArgumentParser(
                    prog='ProgramName',
                    description='What the program does',
                    epilog='Text at the bottom of help')
parser.add_argument("-f", "--file", action="store")

args = parser.parse_args()

file = open(args.file)
lines = []
keyword = "rsc.update_resource"
counter = 0
file_contents = file.read()
depth = 0
buffer = ""

list_misc = [""]
list_of_rsc = []
for char in file_contents:
    if len(keyword) > len(buffer):
        if char == keyword[counter]:
            buffer = buffer + char 
            counter += 1
        else:
            list_misc[len(list_misc)-1]+=buffer + char
            buffer = ""
            counter = 0
    else:
        if char == "(":
            buffer = buffer + char 
            depth +=1
        elif char == ")":
            buffer = buffer + char 
            depth -=1
        else:
            buffer = buffer + char
        if depth == 0:
            list_of_rsc.append(buffer)
            buffer = "" 
            counter = 0
            list_misc.append("")

managers = {}

for index, call in enumerate(list_of_rsc):
    depth = 0
    arg = 0
    first_arg = ""
    left_half  = ""
    right_half = ""
    for char in call:
        if char == ")":
            depth -=1
            if depth == 0:
                right_half += char
        if arg < 3:
            left_half += char
        if (char == ",") & (depth == 1):
            arg +=1
        if (depth == 1) & (arg == 0):
            first_arg += char
        if char == "(":
            depth +=1
        if arg > 3:
            right_half += char
    print("First Arguement == ", first_arg,"\n---------------------------\n")
    if first_arg in managers:
        val = managers.get(first_arg)+1
        list_of_rsc[index] = left_half+str(val)+right_half
        managers.update({first_arg : val})
    else:
        list_of_rsc[index] = left_half+"0"+right_half
        managers.update({first_arg : 0})


rsc_counter  = 0
misc_counter = 0
full = ""
for main_counter in range(0,len(list_misc)+len(list_of_rsc)):
    if main_counter % 2 == 0:
        full += list_misc[misc_counter]
        misc_counter+=1
    else:
        full += list_of_rsc[rsc_counter]
        rsc_counter+=1

print(full)

