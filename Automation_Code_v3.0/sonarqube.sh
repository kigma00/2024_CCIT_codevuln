#!/bin/bash

directory_name=$1
clone_directory_name=$2
DATE=$(date +"%y%m%d")
TIME=$(date +"%H%M%S")

# 토큰 파일에서 토큰 값을 읽어옴
token=$(tail -n 1 token.txt)
rm -r ./token.txt

# SonarScanner 실행
/home/codevuln/sonarqube/sonarscanner/bin/sonar-scanner -X \
    -Dsonar.projectKey="$directory_name" \
    -Dsonar.sources="/home/codevuln/target-repo/$directory_name/$clone_directory_name" \
    -Dsonar.java.binaries=/home/codevuln/sonarqube/sonarscanner/jre/bin \
    -Dsonar.host.url="http://localhost:9000" \
    -Dsonar.login="$token"

echo "SonarScanner has finished scanning."
echo "Waiting for SonarQube to process the results..."
sleep 180  # 3분 대기

export directory_name
echo "Checking project key: $directory_name"

# 특정 프로젝트의 이슈들 검색 및 CSV 및 JSON 파일 경로 설정
python3 <<END
import time
import csv
import json
import os
from datetime import datetime
from sonarqube import SonarQubeClient

directory_name = os.getenv('directory_name')
print("Start checking SonarQube issues...")
print("Project key:", directory_name)

url = "http://localhost:9000"
username = "admin"
password = "admin"

sonar = SonarQubeClient(sonarqube_url=url, username=username, password=password)
time.sleep(10)  # 추가 대기 시간

try:
    issues_result = sonar.issues.search_issues(componentKeys=directory_name)
    print("API Call Successful.")

    if issues_result['total'] > 0:
        issues = issues_result['issues']  # 받아온 이슈들을 변수에 할당

        # Severity 정의 (위험도가 높은 순)
        severity_order = ['BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'INFO']

        # 이슈를 severity에 따라 정렬
        issues.sort(key=lambda x: severity_order.index(x.get('severity')))

        # CSV 파일 경로 및 이름 설정
        csv_file_path = f"/home/codevuln/scan_result/{DATE}_{TIME}_{directory_name}/sonarqube.csv"

        # JSON 파일 경로 및 이름 설정
        json_file_path = f"/home/codevuln/scan_result/{DATE}_{TIME}_{directory_name}/sonarqube.json"

        # 현재 시간과 날짜를 가져오기
        current_datetime = datetime.now()
        date = current_datetime.strftime("%Y-%m-%d")
        time = current_datetime.strftime("%H:%M:%S")

        # CSV 파일 열기 및 쓰기
        with open(csv_file_path, mode='w', newline='', encoding='utf-8') as csv_file:
            csv_writer = csv.writer(csv_file)
            # CSV 헤더 작성 (변경된 순서로 업데이트)
            csv_writer.writerow(['tool', 'date', 'time', 'rule', 'severity', 'message', 'path', 'start_line', 'start_column', 'end_line', 'end_column'])

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

                    # CSV 파일에 기록 (변경된 순서로 업데이트)
                    csv_writer.writerow(['SonarQube', date, time, rule, severity, message, component, startLine, startColumn, endLine, endColumn])

                    # JSON 데이터 생성 및 기록
                    json_data.append({
                        'Date': date,
                        'Time': time,
                        'Severity': severity,
                        'Rule': rule,
                        'Component': component,
                        'Start Line': startLine,
                        'End Line': endLine,
                        'Start Column': startColumn,
                        'End Column': endColumn,
                        'Message': message
                    })

                # JSON 파일에 데이터 쓰기
                json.dump(json_data, json_file, indent=4)

    else:
        print("No issues found. Check project key and SonarQube server status.")

except Exception as e:
    print("Error during API call:", str(e))
END
