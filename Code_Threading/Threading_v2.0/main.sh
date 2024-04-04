#!/bin/bash

# banner
banner() {
    clear
    echo "codevuln 설명 어쩌구 저쩌구 !!! ~~~"
}

# codevuln setting
codevuln_setting() {
    clear
    echo -e "\033[32m[+] codevuln Setting\033[0m $@"
    sleep 2
    apt-get update
    apt-get install git -y
    apt-get install wget -y
    apt-get install vim -y
    apt-get install unzip -y
    apt-get install python3 -y
    apt-get install python3-pip -y
    pip install --upgrade pip
    pip install --upgrade urllib3 chardet
    mkdir /home/codevuln/
    mkdir /home/codevuln/codeql/
    mkdir /home/codevuln/semgrep/
    mkdir /home/codevuln/sonarqube/
    mkdir /home/codevuln/target-repo/
    
    echo -e "\033[32m[+] codeQL Install & Setting\033[0m $@"
    cd /home/codevuln/codeql
    apt install git -y
    git clone https://github.com/github/codeql /home/codevuln/codeql/codeql-repo
    echo -e "\033[32m[+] codeql repo download complete\033[0m $@"
    sleep 2

    LANGUAGES=("java" "javascript" "python" "go")
    for lang in "${LANGUAGES[@]}"; do
        SOURCE_DIR="/home/codevuln/codeql/codeql-repo/${lang}/ql/src/Security"
        TARGET_DIR="/home/codevuln/codeql/${lang}.ql"
        mkdir -p "$TARGET_DIR"
        find "$SOURCE_DIR" -type f -name "*.ql" | while read file; do
            parent_dir=$(basename "$(dirname "$file")")
            filename=$(basename "$file")
            new_file_path="$TARGET_DIR/${parent_dir}_${filename}"
            cp "$file" "$new_file_path"
        done
    done

    wget https://github.com/github/codeql-cli-binaries/releases/download/v2.16.3/codeql-linux64.zip
    unzip codeql-linux64.zip
    mv ./codeql ./codeql-cli
    rm -rf /home/codevuln/codeql/codeql-linux64.zip
    cd ~
    echo 'export PATH=$PATH:/home/codevuln/codeql/codeql-cli/' >> ~/.bashrc
    source ~/.bashrc
    source ./.bashrc
    echo -e "\033[32m[+] codeQL Install & Setting complete\033[0m $@"
    sleep 2

    echo -e "\033[32m[+] Semgrep Install & Setting\033[0m $@"
    cd /home/codevuln/semgrep/
    pip install semgrep
    read -r -d '' python_code << 'EOF'
import json
import csv

with open('results.json') as f:
    data = json.load(f)

with open('result.csv', 'w', newline='') as csvfile:
    fieldnames = ['check_id', 'path', 'start_line', 'end_line', 'message']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()

    for result in data['results']:
        writer.writerow({
            'check_id': result['check_id'],
            'path': result['path'],
            'start_line': result['start']['line'],
            'end_line': result['end']['line'],
            'message': result['extra']['message']
        })
EOF
    echo "$python_code" > /home/codevuln/semgrep/json_csv.py
    chmod +x /home/codevuln/semgrep/json_csv.py
    echo -e "\033[32m[README] Please copy the URL and login from the browser\033[0m $@"
    sleep 3
    semgrep login
    sleep 3
}

# git clone
run_query() {
    clear
    echo ""
    echo -e "\033[32m[+] Directory Setting\033[0m $@"
    read -p "Enter top-level directory to create (repo_name) : " directory_name
    echo -e "\033[32m[+] Make Directory : /home/codevuln/target-repo/$directory_name\033[0m $@"
    sleep 3
    mkdir "/home/codevuln/target-repo/$directory_name"
    mkdir "/home/codevuln/target-repo/$directory_name/codeql"
    mkdir "/home/codevuln/target-repo/$directory_name/semgrep"
    mkdir "/home/codevuln/target-repo/$directory_name/sonarqube"

    echo -e "\033[32m[+] Git clone\033[0m $@"
    read -p "Enter git clone address : " repository_url
    clone_directory_name="$directory_name"-repo
    mkdir -p /home/codevuln/target-repo/$directory_name/$clone_directory_name   
    echo -e "\033[32m[+] git clone : /home/codevuln/target-repo/$directory_name/$clone_directory_name\033[0m $@"
    sleep 3
    git clone --depth=1 "$repository_url" "/home/codevuln/target-repo/$directory_name/$clone_directory_name"

    clear
    echo -e "\033[32m[+] codeQL\033[0m $@"
    echo ""
    echo " -------------------- "
    echo "| 1. python          |"
    echo "| 2. java            |"
    echo "| 3. javascript      |"    
    echo "| 4. go              |"
    echo " --------------------"
    echo ""
    read -p "Input number : " choice

    case $choice in
        1)
            language="python"
            ;;
        2)
            language="java"
            ;;
        3)
            language="javascript"
            ;;
        4)
            language="go"
            ;;
        *)
            exit 0
            ;;
    esac

   (./codeql.sh $directory_name $clone_directory_name $language &)
   (./semgrep.sh $directory_name $clone_directory_name &)

   wait

   echo "all scan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

clear

banner
echo ""
echo " --------------------------------  "
echo "|                                | "
echo "| 1. codevuln Install & Setting  | "
echo "| 2. Run Query                   | "
echo "|                                | "
echo " --------------------------------  "
echo ""
read -p "Selection Process : " process_number

case $process_number in
    1)
        codevuln_setting
        ;;
    2)
        run_query
        ;;
    *)
        exit 0
        ;;
esac
