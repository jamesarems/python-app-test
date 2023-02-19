import snyk
from snowplow_tracker import Tracker, Snowplow
from flask import Flask , jsonify, render_template

app = Flask(__name__)

@app.route("/")
def home():
    json_data = {"hello": "world"}
    return jsonify(json_data)

def main():
    app.run(port=4444)