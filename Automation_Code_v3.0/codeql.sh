#!/bin/bash

# 환경 설정 소스
#source ~/.bashrc

directory_name=$1
clone_directory_name=$2
language=$3

echo -e "\033[32m[+] Create database\033[0m $@"
sleep 2
cd ~

codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name"

cwe_directories="/home/codevuln/codeql/codeql-repo/$language/ql/src/Security"

#test
#codeql database finalize /home/codevuln/target-repo/mongo/codeql/codeql-db-mongo

# CSV 파일 경로 생성
csv_output_file="/home/codevuln/target-repo/$directory_name/codeql/codeql.csv"

codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "$cwe_directories" --format=csv --output="$csv_output_file"

# Python 스크립트를 호출하여 CSV 파일에 헤더를 추가하고 파일을 통합
# python3 /home/codevuln/codeql/codeql_integrate_csv.py "$directory_name" "$clone_directory_name"

echo "Python script executed successfully."
