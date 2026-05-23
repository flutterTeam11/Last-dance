import asyncio
import logging

import cv2
import numpy as np

from config import FRAME_WIDTH, FRAME_HEIGHT
from .detector import Detector

logger = logging.getLogger(__name__)


class Pipeline:
    def __init__(self, frame_queue: asyncio.Queue, detector: Detector):
        self.frame_queue = frame_queue
        self.detector = detector
        self._output_queue: asyncio.Queue[tuple[bytes, str]] = asyncio.Queue(maxsize=30)
        self._running = False

    async def start(self):
        self._running = True
        asyncio.create_task(self._run())

    async def stop(self):
        self._running = False

    async def _run(self):
        while self._running:
            try:
                frame = await asyncio.wait_for(
                    self.frame_queue.get(), timeout=1.0
                )
            except asyncio.TimeoutError:
                continue

            frame = self._resize(frame)
            jpeg_bytes, data_json, _ = self.detector.process(frame)
            await self._output_queue.put((jpeg_bytes, data_json))

    def _resize(self, frame: np.ndarray) -> np.ndarray:
        h, w = frame.shape[:2]
        if w != FRAME_WIDTH or h != FRAME_HEIGHT:
            return cv2.resize(frame, (FRAME_WIDTH, FRAME_HEIGHT))
        return frame

    async def get_output(self) -> tuple[bytes, str]:
        return await self._output_queue.get()

    def output_queue_size(self) -> int:
        return self._output_queue.qsize()
