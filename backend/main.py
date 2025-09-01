from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(
    title="HellaFresh API",
    description="Slang registry platform API",
    version="0.1.0",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

@app.get("/")
async def root():
    return {
        "message": "Welcome to HellaFresh API", 
        "version": "0.1.0",
        "status": "active"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "hellafresh-api"}

# API Routes will be added here
@app.get("/api/search")
async def search_slang(query: str):
    """Search for existing slang terms"""
    # TODO: Implement Elasticsearch search
    return {"query": query, "results": [], "message": "Search not implemented yet"}

@app.get("/api/words/{word_id}")
async def get_word_details(word_id: str):
    """Get detailed information about a specific word"""
    # TODO: Implement word lookup
    return {"word_id": word_id, "message": "Word lookup not implemented yet"}

@app.post("/api/words")
async def submit_word(word_data: dict):
    """Submit a new slang word for review"""
    # TODO: Implement word submission with conflict detection
    return {"message": "Word submission not implemented yet", "data": word_data}

@app.get("/api/review/queue")
async def get_review_queue():
    """Get pending words for community review"""
    # TODO: Implement review queue
    return {"queue": [], "message": "Review queue not implemented yet"}

@app.post("/api/review/{word_id}/vote")
async def submit_review_vote(word_id: str, vote_data: dict):
    """Submit a review vote for a pending word"""
    # TODO: Implement community voting
    return {"word_id": word_id, "vote": vote_data, "message": "Voting not implemented yet"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
