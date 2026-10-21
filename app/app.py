import os
from flask import Flask, jsonify

app = Flask(__name__)
REQUIRED = ("DB_PASSWORD", "API_KEY")

@app.get("/health")
def health():
    ok = all(os.environ.get(k) for k in REQUIRED)
    return jsonify(status="ok" if ok else "missing-secrets"), (200 if ok else 503)

@app.get("/secrets-status")
def status():
    return jsonify({k: {"loaded": bool(os.environ.get(k))} for k in REQUIRED})
