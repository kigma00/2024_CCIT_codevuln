from flask import Flask, render_template
#블루프린트 임포트
from input_tag_analysis import input_tag_bp

app = Flask(__name__)

#블루프린트 라우팅 등록
#input_tag_parser가 기능, input_tag_analysis가 라우팅을 통해 렌더링 해준다고 보면 됨
app.register_blueprint(input_tag_bp)

#기본적인 라우팅을 통한 html 렌더링 형태
@app.route('/')
def index():
  return render_template('index.html')

@app.route('/result')
def result():
  return render_template('result.html')

#아래와 같이 html 렌더링이 아닌 특정 값을 리턴할 수도 있다.
@app.route('/hello')
def hello():
  return 'Hello World'

if __name__ == '__main__':
  app.run(debug=True)