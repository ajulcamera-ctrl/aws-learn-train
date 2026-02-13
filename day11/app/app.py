from flask import Flask, request, jsonify
import boto3
import os
import uuid

app = Flask(__name__)

TABLE_NAME = os.environ.get("TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

@app.route("/health")
def health():
    return "ok"

@app.route("/notes", methods=["POST"])
def add_note():
    data = request.json
    note = data.get("note")
    item = {"id": str(uuid.uuid4()), "note": note}
    table.put_item(Item=item)
    return jsonify({"status": "added"})

@app.route("/notes", methods=["GET"])
def get_notes():
    resp = table.scan()
    items = [i["note"] for i in resp.get("Items", [])]
    return jsonify(items)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)