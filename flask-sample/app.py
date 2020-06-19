import os

from flask import Flask

app = Flask(__name__)


@app.route('/', methods=['GET'])
def top():
    return 'Hello World!'


@app.route('/env', methods=['GET'])
def env():
    return dict(os.environ)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
