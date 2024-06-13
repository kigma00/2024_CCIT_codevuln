import json
import csv

# CSV 모듈의 필드 크기 제한을 늘립니다.
csv.field_size_limit(10000000)

with open('results.json', 'r') as f:
    data = json.load(f)

with open('result.csv', 'w', newline='') as csvfile:
    metadata_fields = set()

    for result in data['results']:
        if 'extra' in result:
            metadata_fields.update(result['extra'].keys())

    fieldnames = ['path', 'start_col', 'start_line',
                  'end_col', 'end_line', 'rule_id']
    fieldnames += sorted(list(metadata_fields))

    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for result in data['results']:
        row = {
            'path': result.get('path', ''),
            'start_col': result.get('start', {}).get('col', ''),
            'start_line': result.get('start', {}).get('line', ''),
            'end_col': result.get('end', {}).get('col', ''),
            'end_line': result.get('end', {}).get('line', ''),
            'rule_id': result.get('check_id', '')
        }

        if 'extra' in result:
            for field in metadata_fields:
                row[field] = result['extra'].get(field, '')

        writer.writerow(row)
