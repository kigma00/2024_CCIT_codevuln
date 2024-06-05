#!/bin/bash

# banner
clear
echo " ________  ________  ________  _______   ___      ___ ___  ___  ___       ________      "
echo "|\\   ____\\|\\   __  \\|\\   ___ \\|\\  ___ \\ |\\  \\    /  /|\\  \\|\\  \\|\\  \\     |\\   ___  \\    "
echo "\\ \\  \\___|\\ \\  \\|\\  \\ \\  \\_|\\ \\ \\   __/|\\ \\  \\  /  / | \\  \\\\\\  \\ \\  \\    \\ \\  \\\\ \\  \\   "
echo " \\ \\  \\    \\ \\  \\\\\\  \\ \\  \\ \\\\ \\ \\  \\_|/_\\ \\  \\/  / / \\ \\  \\\\\\  \\ \\  \\    \\ \\  \\\\ \\  \\  "
echo "  \\ \\  \\____\\ \\  \\\\\\  \\ \\  \\_\\\\ \\ \\  \\_|\ \\ \\    / /   \\ \\  \\\\\\  \\ \\  \\____\\ \\  \\\\ \\  \\ "
echo "   \\ \\_______\\ \\_______\\ \\_______\\ \\_______\\ \\__/ /     \\ \\_______\\ \\_______\\ \\__\\\\ \\__\\"
echo "    \\|_______|\\|_______|\\|_______|\\|_______|\\|__|/       \\|_______|\\|_______|\\|__| \\|__|"
echo""




# query setting
echo -e "\033[32m[+] Git clone\033[0m $@"
read -p "Enter git clone address : " repository_url
directory_name=$(basename "$repository_url")
clone_directory_name="$directory_name"-repo

mkdir -p /home/codevuln/target-repo/$directory_name/$clone_directory_name

echo -e "\033[32m[+] git clone : /home/codevuln/target-repo/$directory_name/$clone_directory_name\033[0m $@"
git clone --depth=1 "$repository_url" "/home/codevuln/target-repo/$directory_name/$clone_directory_name"

mkdir "/home/codevuln/target-repo/$directory_name"
mkdir "/home/codevuln/target-repo/$directory_name/codeql"
mkdir "/home/codevuln/target-repo/$directory_name/semgrep"
mkdir "/home/codevuln/target-repo/$directory_name/sonarqube"
#scan_result
mkdir "/home/codevuln/scan_result"

clear
echo -e "\033[32m[+] codeQL\033[0m $@"
echo ""
echo " -------------------- "
echo "| 1. python          |"
echo "| 2. java            |"
echo "| 3. javascript      |"
echo "| 4. go              |"
echo " --------------------"
echo ""
read -p "Input number : " choice

case $choice in
    1)
        language="python"
        ;;
    2)
        language="java"
        ;;
    3)
        language="javascript"
        ;;
    4)
        language="go"
        ;;
    *)
        exit 0
        ;;
esac

python3 <<END
from sonarqube import SonarQubeClient

url = "http://localhost:9000"
username = "admin"
password = "admin"

sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)
END

python3 /home/codevuln/sonarqube/sonarqube-query-action.py $directory_name $clone_directory_name &
./codeql.sh $directory_name $clone_directory_name $language & ./semgrep.sh $directory_name $clone_directory_name &
