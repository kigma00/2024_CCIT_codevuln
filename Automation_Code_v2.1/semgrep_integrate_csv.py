import os
import pandas as pd
import sys
import subprocess
from datetime import datetime

def integrate_csv_files(directory_path, output_file):
    frames = []
    for file in os.listdir(directory_path):
        if file.endswith('.csv') and file != "semgrep.csv":
            file_path = os.path.join(directory_path, file)
            if os.path.getsize(file_path) > 0:
                df = pd.read_csv(file_path, engine='python')
                frames.append(df)  # Append DataFrame to the list
            else:
                print(f"Skipped empty file: {file_path}")
                
    if frames:
        result = pd.concat(frames, ignore_index=True)
        
        today_date = datetime.now().strftime('%Y-%m-%d')
        result.insert(0, 'date', today_date)
        
        current_time = datetime.now().strftime('%H:%M:%S')
        result.insert(1, 'time', current_time)
        
        result.to_csv(output_file, index=False)
        print(f"Output saved to {output_file}")

        # Cleanup CSV files
        cleanup_files(directory_path)

def cleanup_files(directory_path):
    try:
        delete_command = f"mv {directory_path}/semgrep.csv /home/codevuln/ && rm -rf {directory_path}/*.csv && mv /home/codevuln/semgrep.csv {directory_path}"
        subprocess.run(delete_command, shell=True, check=True, cwd=directory_path)
    except subprocess.CalledProcessError as e:
        print(f"Error cleaning up files: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise ValueError("This script requires exactly two arguments: the directory path and the output file path.")

    directory_path = sys.argv[1]
    output_file = sys.argv[2]

    integrate_csv_files(directory_path, output_file)
