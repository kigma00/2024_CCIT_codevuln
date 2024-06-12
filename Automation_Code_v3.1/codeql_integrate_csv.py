import os
import sys
import csv
import json
import pandas as pd
from datetime import datetime

def add_datetime_to_csv_file(file_path, headers, date, time):
    try:
        # CSV 파일 읽기, 파일에 헤더가 없다고 가정
        df = pd.read_csv(file_path, header=None)

        if not df.empty:
            # 데이터프레임의 열 이름을 지정한 헤더로 설정
            df.columns = headers

            # 새로운 데이터프레임을 생성하여 tool, date, time 열을 추가
            new_df = pd.DataFrame({
                'tool': ['CodeQL'] * len(df),
                'date': [date] * len(df),
                'time': [time] * len(df)
            })

            # 원래 데이터프레임과 새 데이터프레임을 결합
            new_df = pd.concat([new_df, df], axis=1)

            # 변경된 내용을 원래 경로에 저장
            new_df.to_csv(file_path, index=False)
            print(f"Updated {file_path} with date and time.")
            return new_df
        else:
            print(f"The file {file_path} is empty.")
            return pd.DataFrame()
    except pd.errors.EmptyDataError:
        print(f"Skipping empty or invalid file: {file_path}")
        return pd.DataFrame()
    except ValueError as ve:
        print(f"Error processing file {file_path}: {ve}")
        return pd.DataFrame()

def convert_csv_to_json(csv_file_path, json_file_path):
    try:
        # CSV 파일 열기
        with open(csv_file_path, 'r', encoding='utf-8') as csv_file:
            # CSV 파일을 읽어오는데, 첫 번째 행은 헤더로 사용
            reader = csv.DictReader(csv_file)

            # 각 행을 JSON 형식으로 변환하여 저장할 배열 초기화
            json_data = []

            # CSV 파일의 각 행에 대해 반복하여 JSON 객체로 변환
            for row in reader:
                json_data.append(row)

            # JSON 파일에 데이터 저장
            with open(json_file_path, 'w', encoding='utf-8') as json_file:
                # JSON 배열 형식으로 저장
                json.dump(json_data, json_file, indent=4)
                
            print(f"Converted {csv_file_path} to {json_file_path}")
    except FileNotFoundError as fnf_error:
        print(f"File not found: {fnf_error}")
    except Exception as e:
        print(f"Error converting file {csv_file_path} to JSON: {e}")

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

    # CSV 파일 경로 설정
    csv_file_path = os.path.join(base_directory, 'codeql.csv')
    if not os.path.isfile(csv_file_path):
        print(f"CSV file not found: {csv_file_path}")
        sys.exit(1)

    # Define headers to add to the CSV file
    headers = ['name', 'explanation', 'severity', 'message', 'path', 'start_line', 'start_col', 'end_line', 'end_col']

    # Process the CSV file by adding date/time
    updated_df = add_datetime_to_csv_file(csv_file_path, headers, date, time)

    # Convert the updated CSV to JSON if the file is not empty
    if not updated_df.empty:
        output_json_file = os.path.join(output_directory, 'codeql.json')
        convert_csv_to_json(csv_file_path, output_json_file)

    # 디렉토리 삭제 (주석 처리된 부분, 필요 시 사용)
    # try:
    #     shutil.rmtree(f"/home/codevuln/target-repo/{directory_name}/codeql")
    # except Exception as e:
    #     print(f"Error removing directory: {e}")
