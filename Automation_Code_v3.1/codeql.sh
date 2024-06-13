#!/bin/bash

directory_name=$1
clone_directory_name=$2
language=$3
DATE=$4
TIME=$5

echo -e "\033[32m[+] Create database\033[0m $@"
sleep 2
cd ~

# 기존 데이터베이스 덮어쓰기 플래그 추가
codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" --overwrite

cwe_directories="/home/codevuln/codeql/codeql-repo/$language/ql/src/Security"

# CSV 파일 경로 생성
csv_output_dir="/home/codevuln/scan_result/$DATE"_"$TIME"_"$directory_name"
csv_output_file="$csv_output_dir/codeql.csv"

# 디렉토리가 존재하지 않으면 생성
mkdir -p "$csv_output_dir"

# 파일이 존재하면 삭제
file_to_delete="/home/codevuln/codeql/codeql-repo/javascript/ql/src/Security/CWE-020/ExternalAPIsUsedWithUntrustedData.ql"
if [ -f "$file_to_delete" ]; then
    rm -rf "$file_to_delete"
fi

# IMB 잠금 파일 삭제
lock_file="/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name/db-javascript/default/cache/.lock"
if [ -f "$lock_file" ]; then
    rm -f "$lock_file"
fi

# CodeQL 데이터베이스 분석
codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "$cwe_directories" --format=csv --output="$csv_output_file"

# CSV 파일이 존재하는지 확인
if [ ! -f "$csv_output_file" ]; then
    echo "Error: CSV file not found at $csv_output_file"
    exit 1
fi

# Python 스크립트를 호출하여 CSV 파일에 헤더를 추가하고 파일을 통합
python3 /home/codevuln/codeql/codeql_integrate_csv.py "$directory_name" "$clone_directory_name" "$DATE" "$TIME"

echo "Python script executed successfully."
