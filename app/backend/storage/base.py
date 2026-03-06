from abc import ABC, abstractmethod
from typing import List, Dict, Any

class BaseStorage(ABC):
    @abstractmethod
    def get_all(self) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    def get(self, id: str) -> Dict[str, Any]:
        pass

    @abstractmethod
    def create(self, item: Dict[str, Any]) -> None:
        pass

    @abstractmethod
    def update(self, id: str, item: Dict[str, Any]) -> None:
        pass

    @abstractmethod
    def delete(self, id: str) -> None:
        pass

class WorkoutStorage(BaseStorage):
    pass

class HikeStorage(BaseStorage):
    pass