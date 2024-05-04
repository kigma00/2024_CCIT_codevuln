import os
import sys
import csv
import json
import glob
import pandas as pd
from datetime import datetime
import shutil

def add_datetime_and_combine_csv(directory_path, output_file, headers):
    """
    지정된 디렉토리의 모든 CSV 파일에서 데이터를 확인하고,
    비어있지 않은 파일에 헤더와 현재 날짜와 시각을 추가한 후 모든 파일을 하나로 통합한다.
    """
    current_date = datetime.now().strftime('%Y-%m-%d')
    current_time = datetime.now().strftime('%H:%M:%S')
    frames = []

    csv_files = glob.glob(os.path.join(directory_path, '*.csv'))
    for file_path in csv_files:
        try:
            df = pd.read_csv(file_path, header=None)  # CSV 파일 읽기, 파일에 헤더가 없다고 가정
            if not df.empty:
                df.columns = headers  # 헤더 할당
                df.insert(1, 'Time', current_time)  # 두 번째 열에 시각 추가
                df.insert(0, 'Date', current_date)  # 첫 번째 열에 날짜 추가
                
                frames.append(df)
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

def delete_original_csv_files(directory_path):
    csv_files = [file for file in os.listdir(directory_path) if file.endswith('.csv')]
    for file in csv_files:
        if file != 'codeql.csv':  # codeql.csv 파일을 제외하고 삭제
            file_path = os.path.join(directory_path, file)
            os.remove(file_path)
            print(f"Deleted original CSV file: {file_path}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 process_csv_files.py <directory_name> <output_file>")
        sys.exit(1)

    directory_name = sys.argv[1]
    base_directory = f"/home/codevuln/target-repo/{directory_name}/codeql"
    output_csv_file = f"{base_directory}/codeql.csv"
    output_json_file = f"{base_directory}/codeql.json"  # JSON 파일 경로 설정
    
    # Define headers to add to each CSV file
    headers = ['Name', 'Explanation', 'Severity', 'Message', 'Path', 'Start_Line', 'Start_Column', 'End_Line', 'End_Column']

    # Process CSV files by adding date/time and combining them
    combined_df = add_datetime_and_combine_csv(base_directory, output_csv_file, headers)

    # Convert the combined CSV to JSON
    if not combined_df.empty:
        convert_csv_to_json(output_csv_file, output_json_file)

    # Delete original CSV files
    delete_original_csv_files(base_directory)
    
    # 파일 이동
    try:
        # codeql.csv 파일 이동
        shutil.move(f"{base_directory}/codeql.csv", f"/home/codevuln/target-repo/{directory_name}/scan_result")
        # codeql.json 파일 이동
        shutil.move(f"{base_directory}/codeql.json", f"/home/codevuln/target-repo/{directory_name}/scan_result")
    except Exception as e:
        print(f"Error moving files: {e}")

    # 디렉토리 삭제
    try:
        shutil.rmtree(f"/home/codevuln/target-repo/{directory_name}/codeql")
    except Exception as e:
        print(f"Error removing directory: {e}")
