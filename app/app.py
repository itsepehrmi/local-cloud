from flask import Flask, jsonify
import socket
import os
from datetime import datetime

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "message": "Hello from Local Cloud!",
        "hostname": socket.gethostname(),
        "timestamp": datetime.now().isoformat(),
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/info")
def info():
    return jsonify({
        "app": "myapp",
        "version": "1.0.0",
        "python": os.sys.version.split()[0],
        "hostname": socket.gethostname(),
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
