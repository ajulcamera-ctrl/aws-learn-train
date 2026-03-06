from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()

class Hike(BaseModel):
    id: str
    date: str
    location: str
    duration: int
    distance: float
    elevation_gain: int
    notes: str = ""

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
    if not hike_store.get(hike_id):
        raise HTTPException(status_code=404, detail="Hike not found")
    hike_store.update(hike_id, hike.dict())
    return hike

@router.delete("/{hike_id}")
def delete_hike(hike_id: str):
    if not hike_store.get(hike_id):
        raise HTTPException(status_code=404, detail="Hike not found")
    hike_store.delete(hike_id)
    return {"message": "Hike deleted"}