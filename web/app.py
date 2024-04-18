from flask import Flask, render_template, g
import sqlite3

app = Flask(__name__)

@app.route('/')
def index():
  return render_template('index.html')

@app.route('/result')
def result():
  return render_template('result.html')

@app.route('/dashboard')
def dashboard():
  return render_template('dashboard.html')

@app.route('/setting')
def setting():
  return render_template('setting.html')

if __name__ == '__main__':
  app.run(debug=True)