#!/bin/bash
directory_name=$1
clone_directory_name=$2
DATE=$4
TIME=$3

base_dir="/home/codevuln/scan_result/${DATE}_${TIME}_${directory_name}"
clone_path="/home/codevuln/target-repo/$directory_name/$clone_directory_name"

mkdir -p $base_dir

run_semgrep_scan () {
  local config=$1
  local output_prefix=$2
  echo -e "\033[32m[RUN] Semgrep $output_prefix scan\033[0m"
  cd $base_dir || exit
  cp /home/codevuln/semgrep/semgrep_json_csv.py ./

  semgrep --config=p/$config $clone_path --json > ./results.json
  python3 ./semgrep_json_csv.py
  mv ./result.csv ./${output_prefix}.csv
  mv ./results.json ./${output_prefix}.json
  rm -f ./semgrep_json_csv.py
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

python3 /home/codevuln/semgrep/semgrep_integrate_csv.py "$base_dir" "$base_dir/semgrep.csv"

cp /home/codevuln/semgrep/semgrep_column_delete.py $base_dir
cd $base_dir
python3 semgrep_column_delete.py
rm -rf ./semgrep_column_delete.py

cp /home/codevuln/semgrep/semgrep_column_order.py $base_dir
python3 semgrep_column_order.py
rm -rf ./semgrep_column_order.py

jq -s '[.[][]]' $base_dir/default.json $base_dir/owasp-top-ten.json $base_dir/r2c-security-audit.json $base_dir/cwe-top-25.json $base_dir/command-injection.json $base_dir/insecure-transport.json $base_dir/jwt.json $base_dir/secrets.json $base_dir/sql-injection.json $base_dir/xss.json > $base_dir/semgrep.json
#rm -f $base_dir/*.json

# JSON 파일 삭제 (semgrep.json 제외)
cd $base_dir
for file in *.json; do
  if [ "$file" != "semgrep.json" ]; then
    rm -f "$file"
  fi
done

exit 0
