#!/bin/bash

# banner
banner() {
    clear
    echo " ________  ________  ________  _______   ___      ___ ___  ___  ___       ________      "
    echo "|\\   ____\\|\\   __  \\|\\   ___ \\|\\  ___ \\ |\\  \\    /  /|\\  \\|\\  \\|\\  \\     |\\   ___  \\    "
    echo "\\ \\  \\___|\\ \\  \\|\\  \\ \\  \\_|\\ \\ \\   __/|\\ \\  \\  /  / | \\  \\\\\\  \\ \\  \\    \\ \\  \\\\ \\  \\   "
    echo " \\ \\  \\    \\ \\  \\\\\\  \\ \\  \\ \\\\ \\ \\  \\_|/_\\ \\  \\/  / / \\ \\  \\\\\\  \\ \\  \\    \\ \\  \\\\ \\  \\  "
    echo "  \\ \\  \\____\\ \\  \\\\\\  \\ \\  \\_\\\\ \\ \\  \\_|\ \\ \\    / /   \\ \\  \\\\\\  \\ \\  \\____\\ \\  \\\\ \\  \\ "
    echo "   \\ \\_______\\ \\_______\\ \\_______\\ \\_______\\ \\__/ /     \\ \\_______\\ \\_______\\ \\__\\\\ \\__\\"
    echo "    \\|_______|\\|_______|\\|_______|\\|_______|\\|__|/       \\|_______|\\|_______|\\|__| \\|__|"
    echo""                                                                                                                                                                                                                                                             
}

# codevuln setting
codevuln_setting() {
    clear
    echo -e "\033[32m[+] codevuln Setting\033[0m $@"
    apt-get update
    apt-get install git -y
    apt-get install wget -y
    apt-get install vim -y
    apt-get install unzip -y
    apt-get install python3 -y
    apt-get install python3-pip -y
    pip install --upgrade pip
    pip install --upgrade urllib3 chardet
    mkdir /home/codevuln/
    mkdir /home/codevuln/codeql/
    mkdir /home/codevuln/semgrep/
    mkdir /home/codevuln/sonarqube/
    mkdir /home/codevuln/target-repo/
    
    echo -e "\033[32m[+] codeQL Install & Setting\033[0m $@"
    cd /home/codevuln/codeql
    apt install git -y
    git clone https://github.com/github/codeql /home/codevuln/codeql/codeql-repo
    echo -e "\033[32m[+] codeql repo download complete\033[0m $@"

    wget https://github.com/github/codeql-cli-binaries/releases/download/v2.16.3/codeql-linux64.zip
    unzip codeql-linux64.zip
    mv ./codeql ./codeql-cli
    rm -rf /home/codevuln/codeql/codeql-linux64.zip
    cd ~
    echo 'export PATH=$PATH:/home/codevuln/codeql/codeql-cli/' >> ~/.bashrc
    echo 'export SEMGREP_APP_TOKEN="0814691bdb1deaf325766b1e553a31626e75b234c6f3ddfc55612b16b46621d0"' >> ~/.bashrc
    source ~/.bashrc
    source ./.bashrc
    echo -e "\033[32m[+] codeQL Install & Setting complete\033[0m $@"

    echo -e "\033[32m[+] Semgrep Install & Setting\033[0m $@"
    cd /home/codevuln/semgrep/
    pip install semgrep
    read -r -d '' python_code << 'EOF'
import json
import csv

with open('results.json') as f:
    data = json.load(f)

with open('result.csv', 'w', newline='') as csvfile:
    fieldnames = ['check_id', 'path', 'start_line', 'end_line', 'message']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()

    for result in data['results']:
        writer.writerow({
            'check_id': result['check_id'],
            'path': result['path'],
            'start_line': result['start']['line'],
            'end_line': result['end']['line'],
            'message': result['extra']['message']
        })
EOF
    echo "$python_code" > /home/codevuln/semgrep/json_csv.py
    chmod +x /home/codevuln/semgrep/json_csv.py
    echo -e "\033[32m[README] Please copy the URL and login from the browser\033[0m $@"
    semgrep login
}

clear
banner
sleep 2
codevuln_setting
