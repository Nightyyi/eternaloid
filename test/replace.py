import subprocess, shutil, argparse
from pathlib import Path 

parser = argparse.ArgumentParser(
                    prog='ProgramName',
                    description='What the program does',
                    epilog='Text at the bottom of help')
parser.add_argument("-s", "--silent", action="store")

args = parser.parse_args()

file = open(args.silent)
lines = []
for line in file:
    if (len(line) != 0) & (line[0] != "/"):
        index = line.find("rsc.update_resource")
        if index != -1:
            lines.append(line)


for line in lines:
    depth = 0
    arg = 0
    left_half  = ""
    right_half = ""
    for char in line:
        if char == "(":
            depth +=1
        if char == ")":
            depth -=1
        if arg < 2:
            left_half += char
        if (char == ",") & (depth == 1):
            arg +=1
        if arg > 2:
            right_half += char
    print(left_half,right_half)

