from flask import Flask, request, jsonify
import torch
import sqlite3
import uuid
import os
from datetime import datetime
from db import *
from prediction import *

app = Flask(__name__)

model_path = "model/"
model, tokenizer = load_model(model_path)

# Define labels
LABELS = {0: "not-spam", 1: "spam"}

# Initialize SQLite database
DATABASE = os.getenv('DATABASE', 'messages.db')

# Ensure database is initialized
if DATABASE and not os.path.exists(DATABASE):
    init_db()

@app.route('/classify', methods=['POST'])
def classify_sms():
    try:
        data = request.get_json()
        if not data or 'message' not in data:
            return jsonify({"error": "No message provided"}), 400
        if 'sender' not in data:
            data['sender'] = 'Unknown'
        if 'timestamp' not in data:
            data['timestamp'] = datetime.utcnow().isoformat()

        
        message = data['message'].lower()
        sender = data['sender']
        timestamp = data['timestamp']
        is_verified = data.get('is_verified', False)

        if not isinstance(message, str) or not message.strip():
            return jsonify({"error": "Invalid message format"}), 400

        # Tokenize and classify
        prediction = classify_message(model, tokenizer, message)

        status = LABELS.get(prediction, "unknown")
        message_id = str(uuid.uuid4())

        # Store in database
        store_message(
            message_id=message_id,
            sender=sender,
            content=data['message'],
            timestamp=timestamp,
            status=status,
            is_verified=is_verified
        )

        return jsonify({"id": message_id, "status": status}), 200

    except Exception as e:
        return jsonify({"error": f"Classification error: {str(e)}"}), 500

@app.route('/messages', methods=['GET'])
def get_messages_route():
    try:
        messages = get_db_messages()
        if not messages:
            return jsonify({"message": "No messages found"}), 404
        return jsonify(messages), 200
    except Exception as e:
        return jsonify({"error": f"Error fetching messages: {str(e)}"}), 500

@app.route('/messages/<message_id>', methods=['PUT'])
def update_message_route(message_id):
    try:
        data = request.get_json()
        status = data.get('status')
        is_verified = data.get('is_verified')

        if not status and is_verified is None:
            return jsonify({"error": "No updates provided"}), 400

        updated = update_message(
            message_id=message_id,
            status=status,
            is_verified=is_verified
        )
        if not updated:
            return jsonify({"error": "Message not found"}), 404
        return jsonify({"message": "Updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Error updating message: {str(e)}"}), 500

@app.route('/messages/<message_id>', methods=['DELETE'])
def delete_message_route(message_id):
    try:
        deleted = delete_message(message_id)
        if not deleted:
            return jsonify({"error": "Message not found"}), 404
        return jsonify({"message": "Deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Error deleting message: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)