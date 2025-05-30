from flask import Flask, request, jsonify
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch
import os

app = Flask(__name__)

model_path = "model/" 

# load model and tokenizer
try:
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForSequenceClassification.from_pretrained(model_path)
    model.eval()
except Exception as e:
    print(f"Error loading model or tokenizer: {e}")
    raise

LABELS = {0: "not-spam", 1: "spam"}

@app.route('/classify', methods=['POST'])
def classify_sms():
    try:
        data = request.get_json()
        if not data or 'message' not in data:
            return jsonify({"error": "No message provided"}), 400

        message = data['message'].lower()
        if not isinstance(message, str) or not message.strip():
            return jsonify({"error": "Invalid message format"}), 400

        inputs = tokenizer(message, return_tensors="pt", truncation=True, padding=True, max_length=512)

        # Perform classification
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            prediction = torch.argmax(logits, dim=1).item()

        # Get the classification result
        status = LABELS.get(prediction, "unknown")
        return jsonify({"status": status}), 200

    except Exception as e:
        return jsonify({"error": f"Classification error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)