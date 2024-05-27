from flask import Flask, render_template, g, request, jsonify
import sqlite3
import pandas as pd
import json
import csv
import os

app = Flask(__name__)

def read_json_data(filename):
    filepath = os.path.join('static', f'{filename}.json')
    try:
        with open(filepath, mode='r', encoding='utf-8') as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        return None

def filter_data(filename, data):
    if filename == 'codeql_result.json':
        fields = ["Severity", "Path", "Start_Line", "End_Line", "Start_Column", "End_Column", "Message"]
    elif filename == 'sonarqube_result.json':
        fields = ["Severity", "Component", "Start Line", "End Line", "Start Column", "End Column", "Message"]
    else:
        return data

    filtered_data = []
    for entry in data:
        filtered_entry = {field: entry[field] for field in fields if field in entry}
        filtered_data.append(filtered_entry)

    return filtered_data

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/result')
def show_result():
    data = read_json_data('codeql_result')
    if data is not None:
        filtered_data = filter_data('codeql_result.json', data)
        return render_template('result.html', data=filtered_data)
    else:
        return "File not found", 404

@app.route('/get-json-data')
def get_json_data():
    filename = request.args.get('filename')
    if filename in ['codeql_result.json', 'semgrep_result.json', 'sonarqube_result.json']:
        data = read_json_data(filename.replace('.json', ''))
        if data is not None:
            filtered_data = filter_data(filename, data)
            return jsonify(filtered_data)
        else:
            return jsonify({'error': 'File not found'}), 404
    return jsonify({'error': 'Invalid filename'}), 400

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/setting')
def setting():
    return render_template('setting.html')

@app.route('/test')
def test():
    return render_template('test.html')

if __name__ == '__main__':
    app.run(debug=True)
