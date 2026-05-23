import asyncio
import logging
from fastapi import WebSocket

from config import MAX_CLIENTS

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        self._video_clients: set[WebSocket] = set()
        self._detection_clients: set[WebSocket] = set()
        self._lock = asyncio.Lock()

    async def connect_video(self, ws: WebSocket):
        await ws.accept()
        async with self._lock:
            self._video_clients.add(ws)
        logger.info(f"Video client connected. Total: {len(self._video_clients)}")

    async def connect_detection(self, ws: WebSocket):
        await ws.accept()
        async with self._lock:
            self._detection_clients.add(ws)
        logger.info(f"Detection client connected. Total: {len(self._detection_clients)}")

    async def connect_command(self, ws: WebSocket):
        await ws.accept()

    async def disconnect(self, ws: WebSocket):
        async with self._lock:
            self._video_clients.discard(ws)
            self._detection_clients.discard(ws)

    async def broadcast_video(self, jpeg_bytes: bytes):
        async with self._lock:
            dead = set()
            for ws in self._video_clients:
                try:
                    await ws.send_bytes(jpeg_bytes)
                except Exception:
                    dead.add(ws)
            self._video_clients -= dead

    async def broadcast_detections(self, data_json: str):
        async with self._lock:
            dead = set()
            for ws in self._detection_clients:
                try:
                    await ws.send_text(data_json)
                except Exception:
                    dead.add(ws)
            self._detection_clients -= dead

    @property
    def video_client_count(self) -> int:
        return len(self._video_clients)

    @property
    def detection_client_count(self) -> int:
        return len(self._detection_clients)
