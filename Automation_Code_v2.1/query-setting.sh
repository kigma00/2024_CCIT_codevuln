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
mkdir "/home/codevuln/target-repo/$directory_name/scan_result"

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

# python 코드 내에서 사용할 환경 변수 선언
export directory_name

python3 <<END
import requests
import os
from sonarqube import SonarQubeClient

# 환경 변수 호출
directory_name = os.getenv('directory_name')

# SonarQube 서버 URL 및 인증 정보 설정
url = "http://localhost:9000"
username = "admin"
password = "admin"

sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)

# 프로젝트 생성 요청을 위한 데이터 설정
data = {
    "name": directory_name,
    "project": directory_name,
    "visibility": "private"
}

# 프로젝트 생성 요청 보내기
response = requests.post(f"{url}/api/projects/create", auth=(username, password), data=data)

# 응답 확인
if response.status_code == 200:
    print(f"Project '{directory_name}' created successfully.")

    # 프로젝트 토큰 생성 요청을 위한 데이터 설정
    token_data = {
        "name": directory_name
    }

    # 프로젝트 토큰 생성 요청 보내기
    token_response = requests.post(f"{url}/api/user_tokens/generate", auth=(username, password), data=token_data)

    # 응답 확인
    if token_response.status_code == 200:
        token = token_response.json()["token"]
        print(token)

        # token 값을 token.txt 파일에 저장
        with open("token.txt", "w") as file:
            file.write(f"{token}\n")
        print("token saved to token.txt")

    else:
        print(f"Failed to generate token for project '{directory_name}'.")
        print(f"Reason: {token_response.text}")
else:
    print(f"Failed to create project '{directory_name}'.")
    print(f"Reason: {response.text}")

END


./codeql.sh $directory_name $clone_directory_name $language & ./semgrep.sh $directory_name $clone_directory_name & ./sonarqube.sh $directory_name $clone_directory_name &
