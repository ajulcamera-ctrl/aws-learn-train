from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import workouts, hikes
from storage import dynamodb

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Storage
workout_store = dynamodb.WorkoutDynamoStorage()
hike_store = dynamodb.HikeDynamoStorage()

workouts.workout_store = workout_store
hikes.hike_store = hike_store

app.include_router(workouts.router, prefix="/workouts", tags=["workouts"])
app.include_router(hikes.router, prefix="/hikes", tags=["hikes"])

@app.get("/health")
def health():
    return {"status": "ok"}
