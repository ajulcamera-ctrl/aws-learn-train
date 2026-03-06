from flask import Flask, request, jsonify

app = Flask(__name__)

notes = []

@app.route("/health")
def health():
    return "ok"

@app.route("/notes", methods=["POST"])
def add_note():
    data = request.get_json()
    notes.append(data.get("note", ""))
    return jsonify({"status": "added"})

@app.route("/notes", methods=["GET"])
def list_notes():
    return jsonify(notes)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
