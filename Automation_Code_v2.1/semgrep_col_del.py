import pandas as pd

df = pd.read_csv('result.csv')

columns_to_drop = ['dataflow_trace', 'engine_kind', 'fingerprint', 'is_ignored', 'validation_state', 'metavars']

df.drop(columns=columns_to_drop, inplace=True)

df.to_csv('updated_result.csv', index=False)
