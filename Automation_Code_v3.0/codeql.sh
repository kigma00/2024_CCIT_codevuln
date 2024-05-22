#!/bin/bash

directory_name=$1
clone_directory_name=$2
language=$3
date=$(date +"%y%m%d")
time=$(date +"%H%M%S")

echo -e "\033[32m[+] Create database\033[0m $@"
sleep 2
cd ~

codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name"

cwe_directories="/home/codevuln/codeql/codeql-repo/$language/ql/src/Security"

# CSV 파일 경로 생성
csv_output_file="/home/codevuln/scan_result/$date"_"$time"_"$directory_name/$d:irectory_name.csv"

codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "$cwe_directories" --format=csv --output="$csv_output_file"

# Python 스크립트를 호출하여 CSV 파일에 헤더를 추가하고 파일을 통합
# python3 /home/codevuln/codeql/codeql_integrate_csv.py "$directory_name" "$clone_directory_name"

echo "Python script executed successfully."
