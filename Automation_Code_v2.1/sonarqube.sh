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
  
# 분석 결과가 동기화될 때까지 기다림
echo "Waiting for SonarQube to process the results..."
sleep 10

# python 코드 내에서 사용할 환경 변수 선언
export directory_name

# 특정 프로젝트의 이슈들 검색 및 CSV 및 JSON 파일 경로 설정
python3 <<END
import csv
import json
import os
from datetime import datetime
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

if issues:
    # Severity 정의 (위험도가 높은 순)
    severity_order = ['BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'INFO']

    # 이슈를 severity에 따라 정렬
    issues.sort(key=lambda x: severity_order.index(x.get('severity')))
    
    # CSV 파일 경로 및 이름 설정
    csv_file_path = f"/home/codevuln/target-repo/{directory_name}/sonarqube/sonarqube.csv"

    # JSON 파일 경로 및 이름 설정
    json_file_path = f"/home/codevuln/target-repo/{directory_name}/sonarqube/sonarqube.json"

    # 현재 시간과 날짜를 가져오기
    current_datetime = datetime.now()
    current_date = current_datetime.strftime("%Y-%m-%d")
    current_time = current_datetime.strftime("%H:%M:%S")

    # CSV 파일 열기 및 쓰기
    with open(csv_file_path, mode='w', newline='', encoding='utf-8') as csv_file:
        csv_writer = csv.writer(csv_file)
        # CSV 헤더 작성
        csv_writer.writerow(['Date', 'Time', 'Severity', 'Rule', 'Component', 'Start Line', 'End Line', 'Start Column', 'End Column', 'Message'])

        # JSON 파일 열기 및 쓰기
        with open(json_file_path, mode='w', encoding='utf-8') as json_file:
            json_data = []
            # 정렬된 이슈들을 순회하며 CSV 파일과 JSON 파일에 기록
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

                # CSV 파일에 기록
                csv_writer.writerow([current_date, current_time, severity, rule, component, startLine, endLine, startColumn, endColumn, message])

                # JSON 데이터 생성 및 기록
                json_data.append({
                    'Date': current_date,
                    'Time': current_time,
                    'Severity': severity,
                    'Rule': rule,
                    'Component': component,
                    'Start Line': startLine,
                    'End Line': endLine,
                    'Start Column': startColumn,
                    'End Column': endColumn,
                    'Message': message
                })

            # JSON 파일에 JSON 데이터 쓰기
            json.dump(json_data, json_file, indent=4)
END
