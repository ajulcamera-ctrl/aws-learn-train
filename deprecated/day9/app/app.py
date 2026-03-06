from flask import Flask, request, jsonify
import boto3
import uuid
import os

app = Flask(__name__)

TABLE = os.environ["TABLE_NAME"]
ddb = boto3.resource("dynamodb")
table = ddb.Table(TABLE)

@app.route("/")
def home():
    return "Day9 Notes API"

@app.route("/health")
def health():
    return "ok"

@app.route("/notes", methods=["GET"])
def get_notes():
    resp = table.scan()
    return jsonify([x["note"] for x in resp.get("Items", [])])

@app.route("/notes", methods=["POST"])
def add_note():
    data = request.get_json()
    table.put_item(Item={
        "id": str(uuid.uuid4()),
        "note": data["note"]
    })
    return jsonify({"status": "added"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)