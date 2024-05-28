import os
import sys
import csv
import json
import glob
import pandas as pd
from datetime import datetime
import shutil

def add_datetime_to_csv_files(directory_path, headers, date, time):
    csv_files = glob.glob(os.path.join(directory_path, '*.csv'))

    for file_path in csv_files:
        try:
            df = pd.read_csv(file_path, header=None)  # CSV 파일 읽기, 파일에 헤더가 없다고 가정

            if not df.empty:
                df.columns = headers  # 헤더 할당
                # 열을 새 데이터프레임에 추가
                new_df = pd.DataFrame({
                    'tool': ['CodeQL'] * len(df),
                    'date': [date] * len(df),
                    'time': [time] * len(df)
                })
                new_df = pd.concat([new_df, df], axis=1)

                # 변경된 파일을 원래 경로에 저장
                new_df.to_csv(file_path, index=False)
                print(f"Updated {file_path} with date and time.")
        except pd.errors.EmptyDataError:
            print(f"Skipping empty or invalid file: {file_path}")
            continue
    if frames:
        combined_df = pd.concat(frames, ignore_index=True)
        combined_df.to_csv(output_file, index=False)
        print(f"All files integrated into {output_file}")
        return combined_df
    else:
        print("No non-empty CSV files found to combine.")
        return pd.DataFrame()

def convert_csv_to_json(csv_file_path, json_file_path):
    # CSV 파일 열기
    with open(csv_file_path, 'r') as csv_file:
        # CSV 파일을 읽어오는데, 첫 번째 행은 헤더로 사용
        reader = csv.DictReader(csv_file)
        
        # 각 행을 JSON 형식으로 변환하여 저장할 배열 초기화
        json_data = []
        
        # CSV 파일의 각 행에 대해 반복하여 JSON 객체로 변환
        for row in reader:
            json_data.append(row)
        
        # JSON 파일에 데이터 저장
        with open(json_file_path, 'w') as json_file:
            # JSON 배열 형식으로 저장
            json.dump(json_data, json_file, indent=4)

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: python3 codeql_integrate_csv.py <directory_name> <clone_directory_name> <date> <time>")
        sys.exit(1)

    directory_name = sys.argv[1]
    clone_directory_name = sys.argv[2]
    date = sys.argv[3]
    time = sys.argv[4]

    base_directory = f"/home/codevuln/scan_result/{date}_{time}_{directory_name}"
    output_directory = f"/home/codevuln/scan_result/{date}_{time}_{directory_name}"
    os.makedirs(output_directory, exist_ok=True)  # output 디렉토리를 생성

    # Define headers to add to each CSV file
    headers = ['name', 'explanation', 'severity', 'message', 'path', 'start_line', 'start_col', 'end_line', 'end_col']

    # Process CSV files by adding date/time
    add_datetime_to_csv_files(base_directory, headers, date, time)

    # Convert each updated CSV to JSON
    csv_files = glob.glob(os.path.join(base_directory, '*.csv'))
    for csv_file in csv_files:
        output_json_file = os.path.join(output_directory, os.path.basename(csv_file).replace('.csv', '.json'))
        convert_csv_to_json(csv_file, output_json_file)

    # 디렉토리 삭제
    try:
        shutil.rmtree(f"/home/codevuln/target-repo/{directory_name}/codeql")
    except Exception as e:
        print(f"Error removing directory: {e}")
