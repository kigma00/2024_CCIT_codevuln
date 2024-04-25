#!/bin/bash

directory_name="$1"
clone_directory_name="$2"
language="$3"

codeql database create --language="$language" --source-root="/home/codevuln/target-repo/$directory_name/$clone_directory_name" "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name"

codeql database analyze "/home/codevuln/target-repo/$directory_name/codeql/codeql-db-$directory_name" "/home/codevuln/codeql/codeql-repo/javascript/ql/src/Security/CWE-918/RequestForgery.ql" --format=csv --output="/home/codevuln/target-repo/$directory_name/codeql/RequestForgery.csv"

echo "codeql scans complete."

echo "Scan completed for $directory_name" > "/home/codevuln/codeql_complete.txt"

exit 0

