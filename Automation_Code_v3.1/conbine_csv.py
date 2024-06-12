import pandas as pd

def integrate_csv_files(file_paths, output_file, defined_headers):
    frames = []  # 데이터프레임을 저장할 리스트 초기화

    for file_path in file_paths:
        try:
            df = pd.read_csv(file_path)
            df_restructured = df.reindex(columns=defined_headers)
            frames.append(df_restructured)
            print(f"Loaded {file_path} successfully.")
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    if frames:
        result = pd.concat(frames, ignore_index=True)
        result.to_csv(output_file, index=False)
        print(f"All files integrated into {output_file}")
    else:
        print("No CSV files found or all files are empty.")

if __name__ == "__main__":
    # 개별 CSV 파일 경로 리스트 정의
    file_paths = [
        "/home/codevuln/target-repo/gnuboard5/scan_result/codeql.csv",
        "/home/codevuln/target-repo/gnuboard5/scan_result/semgrep.csv",
        #"/home/codevuln/target-repo/gnuboard5/scan_result/sonarqube.csv"
    ]

    # 새로운 헤더 15개 정의
    headers = [
        'tool', 'date', 'time', 'name', 'explanation',
        'severity', 'message', 'path', 'start_line', 'start_col',
        'end_line', 'end_col', 'rule_id', 'lines', 'metadata'
    ]

    # 함수 호출
    output_csv = "test_result.csv"
    integrate_csv_files(file_paths, output_csv, headers)