#!/bin/bash

#24.04.20 kgh add code [codeql error]
source ~/.bashrc

directory_name=$1
clone_directory_name=$2
language=$3

echo -e "\033[32m[+] create database\033[0m $@"
sleep 2
codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name"

cwe_directories=$(find /home/codevuln/codeql/codeql-repo/$language/ql/src/Security/ -type d -name "CWE*")

for dir in $cwe_directories; do
    ql_files=$(find "$dir" -type f -name "*.ql")
    for ql_file in $ql_files; do
        echo "Analyzing $ql_file..."
        output_file="/home/codevuln/target-repo/$directory_name/codeql/$(basename ${ql_file%.ql}).csv"
        codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "$ql_file" --format=csv --output="$output_file"
        echo "Output saved to $output_file"
    done
done
