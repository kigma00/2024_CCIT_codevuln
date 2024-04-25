import json
import csv

with open('results.json', 'r') as f:
    data = json.load(f)

with open('result.csv', 'w', newline='') as csvfile:
    metadata_fields = set()

    for result in data['results']:
        if 'extra' in result:
            metadata_fields.update(result['extra'].keys())

    fieldnames = ['path', 'start_col', 'start_line', 'start_offset',
                  'end_col', 'end_line', 'end_offset', 'message', 'severity', 'rule_id']
    fieldnames += sorted(list(metadata_fields))

    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for result in data['results']:
        row = {
            'path': result.get('path', ''),
            'start_col': result.get('start', {}).get('col', ''),
            'start_line': result.get('start', {}).get('line', ''),
            'start_offset': result.get('start', {}).get('offset', ''),
            'end_col': result.get('end', {}).get('col', ''),
            'end_line': result.get('end', {}).get('line', ''),
            'end_offset': result.get('end', {}).get('offset', ''),
            'message': result.get('message', ''),
            'severity': result.get('severity', ''),
            'rule_id': result.get('check_id', '')
        }

        if 'extra' in result:
            for field in metadata_fields:
                row[field] = result['extra'].get(field, '')

        writer.writerow(row)
