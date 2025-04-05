import subprocess, argparse


parser = argparse.ArgumentParser(
                    prog='Quick Git',
                    description='you dont need to git add or git commit seprately..',
                    epilog='qgit.py -m message')
parser.add_argument("-m", "--message", action="store")


args = parser.parse_args()
subprocess.call(["git","add","."])
subprocess.call(["git","commit","-m",args.message])
subprocess.call(["git","push","-u","origin"])
