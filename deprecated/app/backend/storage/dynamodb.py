import boto3
from .base import WorkoutStorage, HikeStorage
from typing import Dict, Any, List
import os

dynamodb = boto3.resource('dynamodb', region_name=os.getenv('AWS_REGION', 'us-east-1'))

class WorkoutDynamoStorage(WorkoutStorage):
    def __init__(self):
        self.table = dynamodb.Table('workouts')

    def get_all(self) -> List[Dict[str, Any]]:
        response = self.table.scan()
        return response['Items']

    def get(self, id: str) -> Dict[str, Any]:
        response = self.table.get_item(Key={'id': id})
        return response.get('Item')

    def create(self, item: Dict[str, Any]) -> None:
        self.table.put_item(Item=item)

    def update(self, id: str, item: Dict[str, Any]) -> None:
        self.table.put_item(Item=item)  # Assuming full update

    def delete(self, id: str) -> None:
        self.table.delete_item(Key={'id': id})

class HikeDynamoStorage(HikeStorage):
    def __init__(self):
        self.table = dynamodb.Table('hikes')

    def get_all(self) -> List[Dict[str, Any]]:
        response = self.table.scan()
        return response['Items']

    def get(self, id: str) -> Dict[str, Any]:
        response = self.table.get_item(Key={'id': id})
        return response.get('Item')

    def create(self, item: Dict[str, Any]) -> None:
        self.table.put_item(Item=item)

    def update(self, id: str, item: Dict[str, Any]) -> None:
        self.table.put_item(Item=item)

    def delete(self, id: str) -> None:
        self.table.delete_item(Key={'id': id})