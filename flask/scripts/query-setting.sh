#!/bin/bash

repository_url="$1"
language="$2"
directory_name=$(basename "$repository_url")                                                                                                                                                                                                                                                          
mkdir "/home/codevuln/target-repo/$directory_name"
mkdir "/home/codevuln/target-repo/$directory_name/codeql"
mkdir "/home/codevuln/target-repo/$directory_name/semgrep"
mkdir "/home/codevuln/target-repo/$directory_name/sonarqube"

clone_directory_name="$directory_name"-repo
mkdir -p /home/codevuln/target-repo/$directory_name/$clone_directory_name   
git clone --depth=1 "$repository_url" "/home/codevuln/target-repo/$directory_name/$clone_directory_name"


echo "$directory_name" > /home/codevuln/directory_name.txt

./scripts/codeql.sh $directory_name $clone_directory_name $language & ./scripts/semgrep.sh $directory_name $clone_directory_name &

wait

echo "!!!!!!!! scan ..... !!!!!!!!"

exit 0
