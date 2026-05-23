import json
import logging
from typing import Any

import cv2
import numpy as np

from config import FRAME_SKIP

logger = logging.getLogger(__name__)

_AI_SCRIPT_AVAILABLE = False

try:
    from ai_team_script import detect as ai_detect
    _AI_SCRIPT_AVAILABLE = True
    logger.info("AI team script loaded successfully")
except ImportError:
    logger.warning("AI team script not found. Using dummy detector.")

def detect_humans(frame: np.ndarray) -> list[dict[str, Any]]:
    if _AI_SCRIPT_AVAILABLE:
        try:
            return ai_detect(frame)
        except Exception as e:
            logger.error(f"AI script error: {e}")
            return _dummy_detect(frame)
    return _dummy_detect(frame)


def _dummy_detect(frame: np.ndarray) -> list[dict[str, Any]]:
    h, w, _ = frame.shape
    return [
        {
            "label": "human",
            "confidence": 0.92,
            "x": int(w * 0.3),
            "y": int(h * 0.25),
            "w": int(w * 0.15),
            "h": int(h * 0.5),
        },
        {
            "label": "human",
            "confidence": 0.78,
            "x": int(w * 0.55),
            "y": int(h * 0.3),
            "w": int(w * 0.12),
            "h": int(h * 0.45),
        },
    ]


def analyze_thermal(frame: np.ndarray) -> dict[str, Any]:
    return {
        "avg_temp": 36.5,
        "max_temp": 38.2,
        "hotspots": [],
    }


def draw_detections(frame: np.ndarray, detections: list[dict[str, Any]]) -> np.ndarray:
    for det in detections:
        x, y, w, h = det["x"], det["y"], det["w"], det["h"]
        conf = det["confidence"]
        label = det["label"]
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)
        text = f"{label} {conf:.0%}"
        cv2.putText(
            frame, text, (x, y - 6),
            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2,
        )
    return frame


class Detector:
    def __init__(self):
        self._frame_count = 0

    def process(
        self, frame: np.ndarray, run_ai: bool = True
    ) -> tuple[bytes, str, list[dict]]:
        self._frame_count += 1
        detections = []
        thermal = {}

        if run_ai and self._frame_count % FRAME_SKIP == 0:
            detections = detect_humans(frame)
            thermal = analyze_thermal(frame)
            frame = draw_detections(frame, detections)

        _, jpeg_bytes = cv2.imencode(".jpg", frame, [
            cv2.IMWRITE_JPEG_QUALITY, 75,
        ])

        data_json = json.dumps({
            "detections": detections,
            "thermal": thermal,
            "frame": self._frame_count,
        })

        return jpeg_bytes.tobytes(), data_json, detections
