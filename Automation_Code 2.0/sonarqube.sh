#!/bin/bash

directory_name=$1
clone_directory_name=$2

# 토큰 파일에서 토큰 값을 읽어옴
token=$(tail -n 1 token.txt)

# SonarScanner 실행
/home/codevuln/sonarqube/sonarscanner/bin/sonar-scanner -X \
  -Dsonar.projectKey="$directory_name" \
  -Dsonar.sources="/home/codevuln/target-repo/$directory_name/$clone_directory_name" \
  -Dsonar.host.url="http://localhost:9000" \
  -Dsonar.login="$token"

# 분석 결과가 동기화될 때까지 기다림 (예: 60초)
echo "Waiting for SonarQube to process the results..."
sleep 10

# python 코드 내에서 사용할 환경 변수 선언
export directory_name

# 특정 프로젝트의 이슈들 검색 및 CSV 파일 경로 설정
python3 <<END
import csv
import os
from sonarqube import SonarQubeClient

# 환경 변수 호출
directory_name = os.getenv('directory_name')

# SonarQube 서버 설정
url = "http://localhost:9000"
username = "admin"
password = "admin"

# SonarQube 클라이언트 초기화
sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)

# 특정 프로젝트의 이슈들 검색
issues_result = sonar.issues.search_issues(componentKeys=directory_name)

# 'issues' 키에서 실제 이슈 목록 가져오기
issues = issues_result.get('issues', []) if isinstance(issues_result, dict) else []

# Severity 정의 (위험도가 높은 순)
severity_order = ['BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'INFO']

# 이슈를 severity에 따라 정렬
issues.sort(key=lambda x: severity_order.index(x.get('severity')))

# CSV 파일 경로 및 이름 설정
csv_file_path=f"/home/codevuln/target-repo/{directory_name}/sonarqube/sonarqube.csv"

# CSV 파일 열기 및 쓰기
with open(csv_file_path, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    # CSV 헤더 작성
    writer.writerow(['Severity', 'Rule', 'Component', 'Start Line', 'End Line', 'Start Column', 'End Column', 'Message'])

    # 정렬된 이슈들을 순회하며 CSV 파일에 기록
    for issue in issues:
        rule = issue.get('rule', '')
        component = issue.get('component', '')
        line_info = issue.get('textRange', {})
        startLine = line_info.get('startLine', '')
        endLine = line_info.get('endLine', '')
        startColumn = line_info.get('startOffset', '')
        endColumn = line_info.get('endOffset', '')
        message = issue.get('message', '')
        severity = issue.get('severity', '')
        writer.writerow([severity, rule, component, startLine, endLine, startColumn, endColumn, message])
END
