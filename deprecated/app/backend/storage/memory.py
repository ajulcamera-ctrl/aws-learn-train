from .base import WorkoutStorage, HikeStorage
from typing import Dict, Any, List

class WorkoutMemoryStorage(WorkoutStorage):
    def __init__(self):
        self.data: Dict[str, Dict[str, Any]] = {}

    def get_all(self) -> List[Dict[str, Any]]:
        return list(self.data.values())

    def get(self, id: str) -> Dict[str, Any]:
        return self.data.get(id)

    def create(self, item: Dict[str, Any]) -> None:
        self.data[item['id']] = item

    def update(self, id: str, item: Dict[str, Any]) -> None:
        if id in self.data:
            self.data[id] = item

    def delete(self, id: str) -> None:
        self.data.pop(id, None)

class HikeMemoryStorage(HikeStorage):
    def __init__(self):
        self.data: Dict[str, Dict[str, Any]] = {}

    def get_all(self) -> List[Dict[str, Any]]:
        return list(self.data.values())

    def get(self, id: str) -> Dict[str, Any]:
        return self.data.get(id)

    def create(self, item: Dict[str, Any]) -> None:
        self.data[item['id']] = item

    def update(self, id: str, item: Dict[str, Any]) -> None:
        if id in self.data:
            self.data[id] = item

    def delete(self, id: str) -> None:
        self.data.pop(id, None)