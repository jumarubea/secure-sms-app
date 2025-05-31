from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch

def load_model(model_path):
    """
    Loads the tokenizer and model from the specified path.
    Returns (model, tokenizer).
    """
    try:
        tokenizer = AutoTokenizer.from_pretrained(model_path)
        model = AutoModelForSequenceClassification.from_pretrained(model_path)
        model.eval()  # Set the model to evaluation mode
        return model, tokenizer
    except Exception as e:
        print(f"Error loading model or tokenizer: {e}")
        raise

def classify_message(model, tokenizer, message):
    """
    Classifies a message using the provided model and tokenizer.
    Returns the predicted class index.
    """
    try:
        inputs = tokenizer(message, return_tensors="pt", truncation=True, padding=True, max_length=512)
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            prediction = torch.argmax(logits, dim=1).item()
        return prediction
    except Exception as e:
        print(f"Error during classification: {e}")
        raise