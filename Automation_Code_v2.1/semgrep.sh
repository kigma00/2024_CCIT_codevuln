#!/bin/bash
directory_name=$1
clone_directory_name=$2

base_dir="/home/codevuln/target-repo/$directory_name/semgrep"
clone_path="/home/codevuln/target-repo/$directory_name/$clone_directory_name"

run_semgrep_scan () {
  local config=$1         
  local output_prefix=$2 
  echo -e "\033[32m[RUN] Semgrep $output_prefix scan\033[0m"
  cd $base_dir || exit  
  cp /home/codevuln/semgrep/json_csv.py ./  
  
  semgrep --config=p/$config $clone_path --json > ./results.json  
  python3 ./json_csv.py 
  mv ./result.csv ./$output_prefix.csv  
  mv ./results.json ./$output_prefix.json  
  rm -f ./json_csv.py  
}

declare -A scans=(
  ["default"]="default"
  ["cwe-top-25"]="cwe-top-25"
  ["owasp-top-ten"]="owasp-top-ten"
  ["r2c-security-audit"]="r2c-security-audit"
  ["command-injection"]="command-injection"
  ["insecure-transport"]="insecure-transport"
  ["jwt"]="jwt"
  ["secrets"]="secrets"
  ["sql-injection"]="sql-injection"
  ["xss"]="xss"
)

for config in "${!scans[@]}"; do
  run_semgrep_scan $config ${scans[$config]}
done

python3 /home/codevuln/semgrep/integrate_csv_files.py "/home/codevuln/target-repo/$directory_name/semgrep" "/home/codevuln/target-repo/$directory_name/semgrep/semgrep.csv"
