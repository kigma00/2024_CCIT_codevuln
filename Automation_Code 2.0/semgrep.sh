#!/bin/bash

directory_name=$1
clone_directory_name=$2

clear
echo -e "\033[32m[RUN] Semgrep default scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep/
cp /home/codevuln/semgrep/json_csv.py ./
sleep 1
semgrep --config=p/default /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 1
python3 ./json_csv.py
mv ./result.csv ./default.csv
rm -rf ./results.json
rm -rf ./json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep cwe-top-25 scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/cwe-top-25 /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./cwe-top-25.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py        
sleep 2

echo -e "\033[32m[RUN] Semgrep owasp-top-ten scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/owasp-top-ten /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./owasp-top-ten.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep r2c-security-audit scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/r2c-security-audit /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./r2c-security-audit.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep command-injection scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/command-injection /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./command-injection.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2       

echo -e "\033[32m[RUN] Semgrep insecure-transport scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/insecure-transport /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./insecure-transport.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2                           

echo -e "\033[32m[RUN] Semgrep jwt scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/jwt /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./jwt.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep secrets scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/secrets /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./secrets.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep sql-injection scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/sql-injection /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./sql-injection.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2

echo -e "\033[32m[RUN] Semgrep xss scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep
cp /home/codevuln/semgrep/json_csv.py ./
sleep 2            
semgrep --config=p/xss /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > ./results.json
sleep 2
python3 ./json_csv.py
mv ./result.csv ./xss.csv
rm -rf ./results.json
rm -rf ./$clone_directory_name/json_csv.py
sleep 2
