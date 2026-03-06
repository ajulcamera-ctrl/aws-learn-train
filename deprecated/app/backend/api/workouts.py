from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime

router = APIRouter()

class Workout(BaseModel):
    id: str
    date: str
    type: str
    duration: int  # minutes
    distance: float  # km
    notes: str = ""

# Store will be assigned in main.py
workout_store = None

@router.get("/", response_model=List[Workout])
def get_workouts():
    return workout_store.get_all()

@router.get("/{workout_id}", response_model=Workout)
def get_workout(workout_id: str):
    workout = workout_store.get(workout_id)
    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")
    return workout

@router.post("/", response_model=Workout)
def create_workout(workout: Workout):
    workout_store.create(workout.dict())
    return workout

@router.put("/{workout_id}", response_model=Workout)
def update_workout(workout_id: str, workout: Workout):
    if workout_store.get(workout_id):
        workout_store.update(workout_id, workout.dict())
        return workout
    raise HTTPException(status_code=404, detail="Workout not found")

@router.delete("/{workout_id}")
def delete_workout(workout_id: str):
    if workout_store.get(workout_id):
        workout_store.delete(workout_id)
        return {"message": "Workout deleted"}
    raise HTTPException(status_code=404, detail="Workout not found")