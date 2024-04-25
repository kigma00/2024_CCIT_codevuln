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

    read -r -d '' python_code << 'EOF'
import os
import sys
import csv
import json
import glob
import pandas as pd
from datetime import datetime

def add_datetime_and_combine_csv(directory_path, output_file, headers):
    """
    지정된 디렉토리의 모든 CSV 파일에서 데이터를 확인하고,
    비어있지 않은 파일에 헤더와 현재 날짜와 시각을 추가한 후 모든 파일을 하나로 통합한다.
    """
    current_date = datetime.now().strftime('%Y-%m-%d')
    current_time = datetime.now().strftime('%H:%M:%S')
    frames = []

    csv_files = glob.glob(os.path.join(directory_path, '*.csv'))
    for file_path in csv_files:
        try:
            df = pd.read_csv(file_path, header=None)  # CSV 파일 읽기, 파일에 헤더가 없다고 가정
            if not df.empty:
                df.columns = headers  # 헤더 할당
                df.insert(0, 'Time', current_time)  # 두 번째 열에 시각 추가
                df.insert(0, 'Date', current_date)  # 첫 번째 열에 날짜 추가
                frames.append(df)
        except pd.errors.EmptyDataError:
            print(f"Skipping empty or invalid file: {file_path}")
            continue

    if frames:
        combined_df = pd.concat(frames, ignore_index=True)
        combined_df.to_csv(output_file, index=False)
        print(f"All files integrated into {output_file}")
        return combined_df
    else:
        print("No non-empty CSV files found to combine.")
        return pd.DataFrame()

def convert_csv_to_json(csv_file_path, json_file_path):
    # CSV 파일 열기
    with open(csv_file_path, 'r') as csv_file:
        # CSV 파일을 읽어오는데, 첫 번째 행은 헤더로 사용
        reader = csv.DictReader(csv_file)
        
        # 각 행을 JSON 형식으로 변환하여 저장할 배열 초기화
        json_data = []
        
        # CSV 파일의 각 행에 대해 반복하여 JSON 객체로 변환
        for row in reader:
            json_data.append(row)
        
        # JSON 파일에 데이터 저장
        with open(json_file_path, 'w') as json_file:
            # JSON 배열 형식으로 저장
            json.dump(json_data, json_file, indent=4)

def delete_original_csv_files(directory_path):
    csv_files = [file for file in os.listdir(directory_path) if file.endswith('.csv')]
    for file in csv_files:
        file_path = os.path.join(directory_path, file)
        os.remove(file_path)
        print(f"Deleted original CSV file: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 process_csv_files.py <directory_name> <output_file>")
        sys.exit(1)

    directory_name = sys.argv[1]
    base_directory = f"/home/codevuln/target-repo/{directory_name}/codeql"
    output_csv_file = f"{base_directory}.csv"
    output_json_file = f"{base_directory}.json"  # JSON 파일 경로 설정
    
    # Define headers to add to each CSV file
    headers = ['Name', 'Explanation', 'Severity', 'Message', 'Path', 'Start_Line', 'Start_Column', 'End_Line', 'End_Column']

    # Process CSV files by adding date/time and combining them
    combined_df = add_datetime_and_combine_csv(base_directory, output_csv_file, headers)

    # Convert the combined CSV to JSON
    if not combined_df.empty:
        convert_csv_to_json(output_csv_file, output_json_file)

    # Delete original CSV files
    delete_original_csv_files(base_directory)
EOF

    echo "$python_code" > /home/codevuln/codeql/json_csv.py
    chmod +x /home/codevuln/codeql/json_csv.py
    
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
