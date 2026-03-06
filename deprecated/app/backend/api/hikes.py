from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime

router = APIRouter()

class Hike(BaseModel):
    id: str
    date: str
    location: str
    duration: int  # minutes
    distance: float  # km
    elevation_gain: int  # meters
    notes: str = ""

# Store will be assigned in main.py
hike_store = None

@router.get("/", response_model=List[Hike])
def get_hikes():
    return hike_store.get_all()

@router.get("/{hike_id}", response_model=Hike)
def get_hike(hike_id: str):
    hike = hike_store.get(hike_id)
    if not hike:
        raise HTTPException(status_code=404, detail="Hike not found")
    return hike

@router.post("/", response_model=Hike)
def create_hike(hike: Hike):
    hike_store.create(hike.dict())
    return hike

@router.put("/{hike_id}", response_model=Hike)
def update_hike(hike_id: str, hike: Hike):
    if hike_store.get(hike_id):
        hike_store.update(hike_id, hike.dict())
        return hike
    raise HTTPException(status_code=404, detail="Hike not found")

@router.delete("/{hike_id}")
def delete_hike(hike_id: str):
    if hike_store.get(hike_id):
        hike_store.delete(hike_id)
        return {"message": "Hike deleted"}
    raise HTTPException(status_code=404, detail="Hike not found")