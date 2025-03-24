print_text = True
import subprocess, shutil, argparse
from pathlib import Path 

omit_list = ["assets\\cutscene\\first_cutscene.aseprite"]


p = Path('.\\assets\\')
list_of_sprites = list(p.glob('**\\*.aseprite'))

def mprint(string):
    if print_text:
        print(string)

mprint(list_of_sprites)

parser = argparse.ArgumentParser(
                    prog='ProgramName',
                    description='What the program does',
                    epilog='Text at the bottom of help')
parser.add_argument("-s", "--silent", action="store_true")

args = parser.parse_args()


if args.silent:
    print_text = False

temp_list = []
for sprite in list_of_sprites:
    if not (str(sprite) in omit_list):
        temp_list.append(sprite)
        
list_of_sprites = temp_list

if len(list_of_sprites) == 0:
    mprint("No .aseprite files to convert to .png")
    quit()

for sprite in list_of_sprites:
    mprint(str(sprite))
if not args.silent:
    run = True
    while run:
        confirmation = input("Are you sure you want to convert ALL of these .aseprite files to .png\n (Y) or (N)\n")
        confirmation = confirmation.upper()
        if confirmation == 'N':
            quit()
        elif confirmation == 'Y':
            run = False 
        else:
            mprint("Invalid answer.")

current_directory = Path.cwd()


for sprite in list_of_sprites:
    sliced_sprite = str(sprite).split(".")

    subprocess.call(["aseprite", "-b", str(sprite), "--save-as", sliced_sprite[0]+".png"])
    mprint(str(sprite) +" done being converted")
    
    source = str(current_directory / sprite)
    destination = str(current_directory)+"\\aseprites\\"
    shutil.move(source, destination)
    mprint(source + " -> " + destination)
