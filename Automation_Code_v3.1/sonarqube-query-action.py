import time
import requests
import os
import subprocess
import sys
from sonarqube import SonarQubeClient

def create_project():
    # SonarQube 서버 URL 및 인증 정보 설정
    url = "http://localhost:9000"
    username = "admin"
    password = "admin"

    # 사용자 인증
    sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)
    print("Login . . .")
    time.sleep(3)  # 5초 대기

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

            with open("token.txt", "w") as file:
                file.write(f"{token}\n")
            print(f"Token saved to token.txt")
            return True  # 프로젝트 생성 및 토큰 발급 성공

        else:
            print(f"Failed to generate token for project '{directory_name}'.")
            print(f"Reason: {token_response.text}")
    else:
        print(f"Failed to create project '{directory_name}'.")
        print(f"Reason: {response.text}")

    return False  # 프로젝트 생성 또는 토큰 발급 실패

if len(sys.argv) > 2:  # 적어도 세 개의 명령줄 인수가 전달되었는지 확인
    directory_name = sys.argv[1]
    clone_directory_name = sys.argv[2]
    print("Received directory_name:", directory_name)
    print("Received clone_directory_name:", clone_directory_name)
else:
    print("Not enough arguments provided.")

# 프로젝트 생성 및 토큰 발급을 시도하고 성공할 때까지 반복
while not create_project():
    print("Retrying project creation and token generation...")
    time.sleep(3)  # 5초 대기 후 재시도

# 성공한 후에는 sonarqube.sh 스크립트 실행
command = f"./sonarqube.sh {directory_name} {clone_directory_name}"
process = subprocess.Popen(command, shell=True)
process.wait()
