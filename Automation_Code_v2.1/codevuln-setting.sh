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
}

clear
sleep 2
banner
codevuln_setting
