#!/bin/bash

directory_name="$1"
clone_directory_name="$2"

echo -e "\033[32m[RUN] Semgrep default scan\033[0m $@"
cd /home/codevuln/target-repo/$directory_name/semgrep/
cp /home/codevuln/semgrep/json_csv.py ./
semgrep --config=p/owasp-top-ten /home/codevuln/target-repo/$directory_name/$clone_directory_name --json > /home/codevuln/target-repo/$directory_name/semgrep/results.json
python3 ./json_csv.py
mv ./result.csv ./owasp-top-ten.csv
rm -rf ./results.json
rm -rf ./json_csv.py     

echo "semgrep scans complete."

echo "Scan completed for $directory_name" > "/home/codevuln/semgrep_complete.txt"

exit 0
