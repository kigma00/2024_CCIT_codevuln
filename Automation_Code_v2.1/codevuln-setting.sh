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
}

# codevuln setting
codevuln_setting() {
    clear
    echo -e "\033[32m[+] codevuln Setting\033[0m $@"
    apt-get update
    apt-get install sudo

    # 필요한 패키지 및 라이브러리 설치 확인 및 설치
    packages=("openjdk-17-jre-headless" "python3-pip" "wget" "unzip" "curl" "git" "vim")
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q $package; then
            sudo apt install -y $package
        else
            echo "$package is already installed."
        fi
    done

    # pip 업그레이드
    pip install --upgrade pip

    # 필요한 Python 패키지 설치 확인 및 설치
    python_packages=("requests" "python-sonarqube-api" "urllib3" "chardet" "pandas")
    for python_package in "${python_packages[@]}"; do
        if ! python3 -c "import $python_package" &>/dev/null; then
            sudo pip install $python_package
        else
            echo "$python_package is already installed."
        fi
    done

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

    wget https://github.com/github/codeql-cli-binaries/releases/download/v2.17.0/codeql-linux64.zip
    unzip codeql-linux64.zip
    mv ./codeql ./codeql-cli
    rm -rf /home/codevuln/codeql/codeql-linux64.zip
    cd ~
    echo 'export PATH=$PATH:/home/codevuln/codeql/codeql-cli/' >> ~/.bashrc
    source ~/.bashrc
    source ./.bashrc
    echo -e "\033[32m[+] codeQL Install & Setting complete\033[0m $@"

    echo -e "\033[32m[+] Semgrep Install & Setting\033[0m $@"
    cd /home/codevuln/semgrep/
    pip install semgrep
    read -r -d '' python_code_01 << 'EOF'
import json
import csv
import sys

def convert_json_to_csv(json_file_path, csv_file_path):
    with open(json_file_path, 'r') as f:
        data = json.load(f)

    with open(csv_file_path, 'w', newline='') as csvfile:
        metadata_fields = set()

        for result in data['results']:
            if 'extra' in result:
                metadata_fields.update(result['extra'].keys())

        fieldnames = ['path', 'start_col', 'start_line', 'start_offset',
                      'end_col', 'end_line', 'end_offset', 'message', 'severity', 'rule_id']
        fieldnames += sorted(list(metadata_fields))

        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for result in data['results']:
            row = {
                'path': result.get('path', ''),
                'start_col': result.get('start', {}).get('col', ''),
                'start_line': result.get('start', {}).get('line', ''),
                'start_offset': result.get('start', {}).get('offset', ''),
                'end_col': result.get('end', {}).get('col', ''),
                'end_line': result.get('end', {}).get('line', ''),
                'end_offset': result.get('end', {}).get('offset', ''),
                'message': result.get('message', ''),
                'severity': result.get('severity', ''),
                'rule_id': result.get('check_id', '')
            }

            if 'extra' in result:
                for field in metadata_fields:
                    row[field] = result['extra'].get(field, '')

            writer.writerow(row)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise ValueError("This script requires exactly two arguments: the JSON file path and the CSV file path.")

    json_file_path = sys.argv[1]
    csv_file_path = sys.argv[2]

    convert_json_to_csv(json_file_path, csv_file_path)

EOF
    echo "$python_code_01" > /home/codevuln/semgrep/json_csv.py
    chmod +x /home/codevuln/semgrep/json_csv.py

    read -r -d '' python_code_02 << 'EOF'
import os
import pandas as pd
import sys
import subprocess
from datetime import datetime

def integrate_csv_files(directory_path, output_file):
    frames = []
    for file in os.listdir(directory_path):
        if file.endswith('.csv') and file != "semgrep.csv":  
            file_path = os.path.join(directory_path, file)
            if os.path.getsize(file_path) > 0:  
                df = pd.read_csv(file_path, engine='python')  
            else:
                print(f"Skipped empty file: {file_path}")
    if frames:  
        result = pd.concat(frames, ignore_index=True)  
        
        today_date = datetime.now().strftime('%Y-%m-%d')
        result.insert(0, 'date', today_date)
        
        current_time = datetime.now().strftime('%H:%M:%S')
        result.insert(1, 'time', current_time)
        
        result.to_csv(output_file, index=False) 
        print(f"Output saved to {output_file}")
    else:
        print("No data to process.")

    delete_command = f"mv {directory_path}/semgrep.csv /home/codevuln/ && rm -rf {directory_path}/*.csv && mv /home/codevuln/semgrep.csv {directory_path} && exit"
    subprocess.run(delete_command, shell=True, check=True, cwd=directory_path)  


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise ValueError("This script requires exactly two arguments: the directory path and the output file path.")

    directory_path = sys.argv[1]  
    output_file = sys.argv[2]  

    integrate_csv_files(directory_path, output_file)
EOF
    echo "$python_code_02" > /home/codevuln/semgrep/integrate_csv_files.py
    chmod +x /home/codevuln/semgrep/integrate_csv_files.py
    echo -e "\033[32m[+] Semgrep Install & Setting complete\033[0m $@"

    echo -e "\033[32m[+] SonarQube Install & Setting\033[0m $@"
    cd /home/codevuln/sonarqube
    # SonarQube 및 SonarScanner가 설치되어 있는지 확인
    if ! [ -d "/home/codevuln/sonarqube/sonarqube" ]; then
        # SonarQube 설치
        cd /home/codevuln/sonarqube
        sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
        sudo unzip sonarqube-10.4.1.88267.zip
        sudo mv /home/codevuln/sonarqube/sonarqube-10.4.1.88267 /home/codevuln/sonarqube/sonarqube
        sudo chmod 777 /home/codevuln/sonarqube/sonarqube
        sudo rm -r sonarqube-10.4.1.88267.zip

        # 'sonar' 사용자 추가 및 권한 설정
        sudo adduser --system --no-create-home --group sonar
        sudo chown -R sonar:sonar /home/codevuln/sonarqube/sonarqube
    else
        echo "SonarQube is already installed."
    fi

    # SonarQube 시작
    sudo -u sonar /home/codevuln/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh start
    sudo -u sonar /home/codevuln/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh status
    sleep 3

    if ! [ -d "/home/codevuln/sonarqube/sonarscanner" ]; then
        # SonarScanner 설치
        cd /home/codevuln/sonarqube
        sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
        sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
        sudo mv /home/codevuln/sonarqube/sonar-scanner-5.0.1.3006-linux /home/codevuln/sonarqube/sonarscanner
        sudo chmod 777 /home/codevuln/sonarqube/sonarscanner
        sudo rm -r sonar-scanner-cli-5.0.1.3006-linux.zip
    else
        echo "SonarScanner is already installed."
    fi
    echo -e "\033[32m[+] SonarQube Install & Setting complete\033[0m $@"

    echo -e "\033[32m[README] Please copy the URL and login from the browser\033[0m $@"
    semgrep login
}

clear
banner
sleep 2
codevuln_setting
