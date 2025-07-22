from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import json
import os
import random
from typing import List
import uvicorn

app = FastAPI(title="Random Choice Game API")

# Enable CORS for all origins (development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_FILE = "choices_data.json"

class Choice(BaseModel):
    text: str

def load_choices():
    if not os.path.exists(DATA_FILE):
        return []
    try:
        with open(DATA_FILE, 'r', encoding='utf-8') as file:
            data = json.load(file)
            return data.get('choices', [])
    except Exception as e:
        print(f"Error loading choices: {e}")
        return []

def save_choices(choices: List[str]):
    try:
        with open(DATA_FILE, 'w', encoding='utf-8') as file:
            json.dump({'choices': choices}, file, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Error saving choices: {e}")

@app.get("/")
async def root():
    return {
        "message": "Random Choice Game API is running!",
        "version": "2.0.0",
        "endpoints": ["/choices", "/random", "POST /choices", "DELETE /choices"]
    }

@app.get("/choices")
async def get_choices():
    choices = load_choices()
    return {"choices": choices, "count": len(choices)}

@app.post("/choices")
async def add_choice(choice: Choice):
    choices = load_choices()
    
    choice_text = choice.text.strip().lower()
    if not choice_text:
        raise HTTPException(status_code=400, detail="Choice cannot be empty!")
    
    if choice_text in choices:
        raise HTTPException(status_code=400, detail="Choice already exists!")
    
    choices.append(choice_text)
    save_choices(choices)
    
    return {"message": f"'{choice_text}' added successfully!", "choices": choices}

@app.delete("/choices")
async def clear_choices():
    save_choices([])
    return {"message": "All choices cleared!"}

@app.delete("/choices/{choice_text}")
async def delete_choice(choice_text: str):
    from urllib.parse import unquote
    
    decoded_choice = unquote(choice_text)
    
    choices = load_choices()
    
    if decoded_choice not in choices:
        raise HTTPException(status_code=404, detail="Choice not found!")
    
    choices.remove(decoded_choice)
    save_choices(choices)
    
    return {
        "message": f"'{decoded_choice}' deleted successfully!",
        "remaining_choices": len(choices)
    }

@app.get("/random")
async def get_random_choice():
    choices = load_choices()
    if not choices:
        raise HTTPException(status_code=404, detail="No choices available!")
    
    random_choice = random.choice(choices)
    return {"choice": random_choice, "total_choices": len(choices)}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "choices_count": len(load_choices())}

if __name__ == "__main__":
    print("🚀 Starting Random Choice Game Server...")
    print("📡 Server will be available at: http://localhost:8000")
    print("📋 API documentation at: http://localhost:8000/docs")
    print("❌ Press Ctrl+C to stop the server")
    print()
    
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8000,
        log_level="info"
    )
