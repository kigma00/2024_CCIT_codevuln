from flask import Flask, render_template, request, send_from_directory, send_file, jsonify, redirect, url_for
import os
import subprocess
from glob import glob
import zipfile
import tempfile

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/process_url', methods=['POST'])
def process_url():
    repository_url = request.form['repository_url']
    language = request.form['language']
    command = ['./scripts/query-setting.sh', repository_url, language]
    try:
        subprocess.Popen(command)
        return redirect(url_for('run_query'))
    except subprocess.CalledProcessError as e:
        print("CalledProcessError:", e)
        return render_template('index.html', error="Failed to start the process.")

@app.route('/check_process')
def check_process():
    codeql_status_file = "/home/codevuln/codeql_complete.txt"
    semgrep_status_file = "/home/codevuln/semgrep_complete.txt"
    if os.path.exists(codeql_status_file) and os.path.exists(semgrep_status_file):
        os.remove(codeql_status_file)
        os.remove(semgrep_status_file)
        return jsonify({"status": "complete", "redirect": url_for('ok')})
    else:
        return jsonify({}), 204

@app.route('/setting')
def settings():
    return render_template('setting.html')

@app.route('/run_query')
def run_query():
    return render_template('run_query.html')

def create_zip(files, directory):
    zip_filename = os.path.join(tempfile.gettempdir(), os.path.basename(directory) + '.zip')
    with zipfile.ZipFile(zip_filename, 'w') as zipf:
        for file in files:
            zipf.write(file, arcname=os.path.basename(file))
    return zip_filename

@app.route('/download/codeql', methods=['GET'])
def download_codeql():
    try:
        with open('/home/codevuln/directory_name.txt', 'r') as file:
            directory_name = file.read().strip()
        directory_path = f"/home/codevuln/target-repo/{directory_name}/codeql"
        csv_files = glob(os.path.join(directory_path, "*.csv"))
        if not csv_files:
            return "No CSV files found in the directory.", 404
        if len(csv_files) == 1:
            result = send_from_directory(directory_path, os.path.basename(csv_files[0]), as_attachment=True)
            os.remove('/home/codevuln/directory_name.txt')  # Remove directory_name.txt after download
            return result
        else:
            zip_path = create_zip(csv_files, directory_path)
            result = send_file(zip_path, as_attachment=True, attachment_filename=f'{directory_name}_codeql_results.zip')
            os.remove('/home/codevuln/directory_name.txt')  # Remove directory_name.txt after download
            return result
    except Exception as e:
        return f"An error occurred: {str(e)}", 500

@app.route('/download/semgrep', methods=['GET'])
def download_semgrep():
    try:
        with open('/home/codevuln/directory_name.txt', 'r') as file:
            directory_name = file.read().strip()
        directory_path = f"/home/codevuln/target-repo/{directory_name}/semgrep"
        csv_files = glob(os.path.join(directory_path, "*.csv"))
        if not csv_files:
            return "No CSV files found in the directory.", 404
        if len(csv_files) == 1:
            result = send_from_directory(directory_path, os.path.basename(csv_files[0]), as_attachment=True)
            os.remove('/home/codevuln/directory_name.txt')  # Remove directory_name.txt after download
            return result
        else:
            zip_path = create_zip(csv_files, directory_path)
            result = send_file(zip_path, as_attachment=True, attachment_filename=f'{directory_name}_semgrep_results.zip')
            os.remove('/home/codevuln/directory_name.txt')  # Remove directory_name.txt after download
            return result
    except Exception as e:
        return f"An error occurred: {str(e)}", 500

@app.route('/ok')
def ok():
    try:
        with open('/home/codevuln/directory_name.txt', 'r') as file:
            directory_name = file.read().strip()
    except Exception as e:
        directory_name = "Error reading directory name"
    return render_template('ok.html', directory_name=directory_name)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)

