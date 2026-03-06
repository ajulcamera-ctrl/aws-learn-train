from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import workouts, hikes
from config import STORAGE_TYPE
from storage import memory, dynamodb, postgres, redis_cache

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For dev, allow all
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Storage selection
if STORAGE_TYPE == "memory":
    workout_store = memory.WorkoutMemoryStorage()
    hike_store = memory.HikeMemoryStorage()
elif STORAGE_TYPE == "dynamodb":
    workout_store = dynamodb.WorkoutDynamoStorage()
    hike_store = dynamodb.HikeDynamoStorage()
elif STORAGE_TYPE == "postgres":
    workout_store = postgres.WorkoutPostgresStorage()
    hike_store = postgres.HikePostgresStorage()
elif STORAGE_TYPE == "redis":
    workout_store = redis_cache.WorkoutRedisCache()
    hike_store = redis_cache.HikeRedisCache()
else:
    raise Exception("Unknown STORAGE_TYPE")

# Make stores available to routers
workouts.workout_store = workout_store
hikes.hike_store = hike_store

# Include routers
app.include_router(workouts.router, prefix="/workouts", tags=["workouts"])
app.include_router(hikes.router, prefix="/hikes", tags=["hikes"])

@app.get("/health")
def health():
    return {"status": "ok"}
