import os
import pandas as pd
import sys
import subprocess
from datetime import datetime

def integrate_csv_files(directory_path, output_file):
    frames = []
    for file in os.listdir(directory_path):
        if file.endswith('.csv'):
            file_path = os.path.join(directory_path, file)
            if os.path.getsize(file_path) > 0:
                df = pd.read_csv(file_path, engine='python')
                frames.append(df)  # Append DataFrame to the list
            else:
                print(f"Skipped empty file: {file_path}")
                
    if frames:
        result = pd.concat(frames, ignore_index=True)
        
        if 'tool' not in result.columns:
            result.insert(0, 'tool', 'Semgrep')
        
        today_date = datetime.now().strftime('%Y-%m-%d')
        if 'date' not in result.columns:
            result.insert(1, 'date', today_date)
        
        current_time = datetime.now().strftime('%H:%M:%S')
        if 'time' not in result.columns:
            result.insert(2, 'time', current_time)
        
        result.to_csv(output_file, index=False)
        print(f"Output saved to {output_file}")

        # Cleanup CSV files
        cleanup_files(directory_path)

def cleanup_files(directory_path):
    try:
        # 제외할 파일 리스트
        exclude_files = ["codeql.csv", "semgrep.csv", "sonarqube.csv"]
        
        for file in os.listdir(directory_path):
            if file.endswith('.csv') and file not in exclude_files:
                file_path = os.path.join(directory_path, file)
                os.remove(file_path)  # 파일 삭제
                print(f"Deleted file: {file_path}")

    except Exception as e:  # 명령 실행 중 오류 발생 시 처리
        print(f"Error cleaning up files: {e}")  # 오류 메시지 출력

if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise ValueError("This script requires exactly two arguments: the directory path and the output file path.")

    directory_path = sys.argv[1]
    output_file = sys.argv[2]

    integrate_csv_files(directory_path, output_file)
