import os
import json
import subprocess
import sys

directory_name = sys.argv[1]

directory = f"/home/codevuln/target-repo/{directory_name}/semgrep"
output_filename = "semgrep.json"
data = {}

for i, filename in enumerate(os.listdir(directory), start=1):
    if filename.endswith('.json'):
        file_path = os.path.join(directory, filename)
        with open(file_path, 'r') as f:
            data = json.load(f)
            data[f"{filename}"] = data

with open(os.path.join(directory, output_filename), 'w') as f:
    json.dump(data, f, indent=4)

print(f"All JSON files have been merged into {output_filename} in the directory {directory}.")

subprocess.run(['jq', '.', 'semgrep.json'], stdout=open('semgrep.json', 'w'))
