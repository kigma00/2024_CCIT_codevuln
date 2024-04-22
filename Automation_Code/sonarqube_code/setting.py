import requests
from sonarqube import SonarQubeClient

# SonarQube 서버 URL 및 인증 정보 설정
url = "http://localhost:9000"
username = "admin"
password = "admin"

sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)

# 사용자로부터 프로젝트 이름 입력 받기
project_name = input("Enter repository name : ")

# 프로젝트 생성 요청을 위한 데이터 설정
data = {
    "name": project_name,
    "project": project_name,
    "visibility": "private"
}

# 프로젝트 생성 요청 보내기
response = requests.post(f"{url}/api/projects/create", auth=(username, password), data=data)

# 응답 확인
if response.status_code == 200:
    print(f"Project '{project_name}' created successfully.")

    # 프로젝트 토큰 생성 요청을 위한 데이터 설정
    token_data = {
        "name": project_name
    }

    # 프로젝트 토큰 생성 요청 보내기
    token_response = requests.post(f"{url}/api/user_tokens/generate", auth=(username, password), data=token_data)

    # 응답 확인
    if token_response.status_code == 200:
        token = token_response.json()["token"]
        print(token)

        # project_name과 token 값을 token.txt 파일에 저장
        with open("token.txt", "w") as file:
            file.write(f"{project_name}\n")
            file.write(f"{token}\n")
        print("project_name and token saved to token.txt")
    else:
        print(f"Failed to generate token for project '{project_name}'.")
        print(f"Reason: {token_response.text}")
else:
    print(f"Failed to create project '{project_name}'.")
    print(f"Reason: {response.text}")

