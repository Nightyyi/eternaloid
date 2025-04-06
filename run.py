import subprocess

subprocess.run("odin.exe build main.odin -file -debug -o:speed")
subprocess.run("python converter.py -s")
subprocess.call(["main.exe"])

