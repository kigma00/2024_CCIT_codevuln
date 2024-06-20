import pandas as pd

df = pd.read_csv('semgrep.csv')

columns_to_drop = ['dataflow_trace', 'engine_kind', 'fingerprint', 'is_ignored', 'validation_state', 'metavars']

df.drop(columns=columns_to_drop, inplace=True)

df.to_csv('semgrep.csv', index=False)
