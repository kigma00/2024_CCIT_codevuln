import pandas as pd

csv_file_path = "./semgrep.csv"

df = pd.read_csv(csv_file_path)

df = df[['tool', 'date', 'time', 'severity', 'path', 'start_line', 'end_line', 'start_col', 'end_col', 'message', 'rule_id', 'lines', 'metadata']]

output_csv_file_path = "semgrep.csv"
df.to_csv(output_csv_file_path, index=False)
