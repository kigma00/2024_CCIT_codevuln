#!/bin/bash

directory_name=$1
clone_directory_name=$2
language=$3

echo -e "\033[32m[+] Create database\033[0m $@"
sleep 2
source ~/.bashrc
codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name"

cwe_directories=$(find /home/codevuln/codeql/codeql-repo/$language/ql/src/Security/ -type d -name "CWE*")

for dir in $cwe_directories; do
    ql_files=$(find "$dir" -type f -name "*.ql")
    for ql_file in $ql_files; do
        echo "Analyzing $ql_file..."
        
        # CSV 파일 경로 생성
        csv_output_file="/home/codevuln/target-repo/$directory_name/codeql/$(basename ${ql_file%.ql}).csv"
        
        # 환경 설정 소스
        source ~/.bashrc
        
        # CodeQL 분석을 CSV로 실행
        codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "$ql_file" --format=csv --output="$csv_output_file"
        echo "CSV output saved to $csv_output_file"
        
        # CodeQL 분석을 JSON으로 실행
         echo "JSON output saved to $json_output_file"
    done
done

# Python 스크립트를 호출하여 CSV 파일에 헤더를 추가하고 파일을 통합
python3 "$(dirname "$0")/process_csv_files.py" "$directory_name" "$clone_directory_name"
echo "Python script executed successfully."
