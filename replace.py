import subprocess, shutil, argparse
from pathlib import Path 

parser = argparse.ArgumentParser(
                    prog='idkbro',
                    description='a utility that replaces the 4th arguement\nin rsc.update_resource() calls automatically',
                    epilog='meow')
parser.add_argument("-f", "--file", action="store")
parser.add_argument("-w", "--write", action="store_true")
parser.add_argument("-o", "--overwrite", action="store_true")

args = parser.parse_args()

file = open(args.file)
lines = []
keyword = "rsc.update_resource"
counter = 0
file_contents = file.read()
file.close()
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
    depthn = 0
    arg = 0
    first_arg = ""
    third_arg = ""
    left_half  = ""
    right_half = ""
    for char in call:
        if char == ")":
            depth -=1
            if depth == 0:
                right_half += char
        if arg < 3:
            left_half += char
        if (char == ",") & (depth == 1) & (depthn == 0):
            arg +=1
        if (depth == 1) & (arg == 0) & (char != " ") & (char != "\n") & (char != "\t"):
            first_arg += char                                                         
        if (depth == 1) & (arg == 2) & (char != " ") & (char != "\n") & (char != "\t"):
            third_arg += char
        if char == "(":
            depth +=1
        if char == "}":
            depthn -=1
        if char == "{":
            depthn +=1
        if char == "]":
            depthn -=1
        if char == "[":
            depthn +=1
        if arg > 3:
            right_half += char
    key = first_arg+"-"+(third_arg.split(".")[2])
    if key in managers:
        val = managers.get(key)+1
        list_of_rsc[index] = left_half+str(val)+right_half
        managers.update({key : val})
    else:
        print("New Key: ", key,"\n---------------------------")
        list_of_rsc[index] = left_half+"0"+right_half
        managers.update({key : 0})


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
for call in list_of_rsc:
    print(call)
if args.write:
    new_file_name = "generated_"+args.file 
    if args.overwrite:
        new_file_name = args.file
    new_file = open(new_file_name,"w")
    new_file.write(full)
    new_file.close()
