import subprocess
from pathlib import Path 

p = Path('.')
list_of_sprites = list(p.glob('**/*.aseprite'))
for sprite in list_of_sprites:
    print(str(sprite))

run = True
while run:
    confirmation = input("Are you sure you want to convert ALL of these .aseprite files to .png/n (Y) or (N)\n")
    confirmation = confirmation.upper()
    if confirmation == 'N':
        quit()
    elif confirmation == 'Y':
        run = False 
    else:
        print("Invalid answer.")

omit_list = ["assets\\cutscene\\first_cutscene.aseprite"]

for sprite in list_of_sprites:
    sliced_sprite = str(sprite).split(".")
    if not (str(sprite) in omit_list):

        subprocess.call(["aseprite", "-b", str(sprite), "--save-as", sliced_sprite[0]+".png"])
        print(str(sprite),"done")
    else:
        print(str(sprite), "has been omitted")
