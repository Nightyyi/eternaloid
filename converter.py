import subprocess, shutil
from pathlib import Path 

omit_list = ["assets\\cutscene\\first_cutscene.aseprite"]


p = Path('.\\assets\\')
list_of_sprites = list(p.glob('**\\*.aseprite'))

temp_list = []
for sprite in list_of_sprites:
    if not (str(sprite) in omit_list):
        temp_list.append(temp_list)
        
list_of_sprites = temp_list

if len(list_of_sprites) == 0:
    print("No .aseprite files to convert to .png")
    quit()

for sprite in list_of_sprites:
    print(str(sprite))

run = True
while run:
    confirmation = input("Are you sure you want to convert ALL of these .aseprite files to .png\n (Y) or (N)\n")
    confirmation = confirmation.upper()
    if confirmation == 'N':
        quit()
    elif confirmation == 'Y':
        run = False 
    else:
        print("Invalid answer.")

current_directory = Path.cwd()


for sprite in list_of_sprites:
    sliced_sprite = str(sprite).split(".")

    subprocess.call(["aseprite", "-b", str(sprite), "--save-as", sliced_sprite[0]+".png"])
    print(str(sprite),"done being converted")
    
    source = str(current_directory / sprite)
    destination = str(current_directory)+"\\aseprites\\"
    shutil.move(source, destination)
    print(source, "->", destination)
