import json
import logging
import os
import threading
import time

import hardware

logger = logging.getLogger("pi-firebase")

SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), "service_account.json")
COLLECTION = "drone"

FIREBASE_AVAILABLE = False
db = None
firestore = None


def _init_firebase():
    global FIREBASE_AVAILABLE, db, firestore
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        logger.warning(f"service_account.json not found")
        return False
    try:
        import firebase_admin
        from firebase_admin import credentials
        from firebase_admin import firestore as _fs
        firestore = _fs
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        FIREBASE_AVAILABLE = True
        logger.info("Firebase initialized")
        return True
    except Exception as e:
        logger.error(f"Firebase init failed: {e}")
        return False


def _write_status(sensors):
    if db is None:
        return
    try:
        db.collection(COLLECTION).document("status").set({
            "battery": 85,
            "humanCount": 0,
            "height": 0,
            "speed": 0,
            "isConnected": True,
            "temperature": sensors.get("temperature", 0) or 0,
        })
    except Exception as e:
        logger.error(f"Failed to write status: {e}")


def _write_location():
    if db is None:
        return
    try:
        db.collection(COLLECTION).document("location").set({
            "lat": 30.0444,
            "lng": 31.2357,
            "timestamp": firestore.SERVER_TIMESTAMP,
        })
    except Exception as e:
        logger.error(f"Failed to write location: {e}")


def _add_report(report_type, message):
    if db is None:
        return
    try:
        db.collection(COLLECTION).document("reports").collection("entries").add({
            "type": report_type,
            "message": message,
            "timestamp": firestore.SERVER_TIMESTAMP,
        })
    except Exception as e:
        logger.error(f"Failed to add report: {e}")


def _check_commands(last_cmd_time):
    if db is None:
        return None, last_cmd_time
    try:
        doc_ref = db.collection(COLLECTION).document("commands")
        doc = doc_ref.get()
        if doc.exists:
            data = doc.to_dict()
            ts = data.get("timestamp", 0)
            if isinstance(ts, int):
                ts_val = ts
            else:
                ts_val = ts.timestamp() if hasattr(ts, "timestamp") else 0
            if ts_val > last_cmd_time:
                return data, ts_val
    except Exception as e:
        logger.error(f"Failed to read commands: {e}")
    return None, last_cmd_time


def _execute_command(cmd_data):
    if cmd_data is None:
        return
    cmd = cmd_data.get("command")
    data = cmd_data.get("data", {})
    logger.info(f"Command: {cmd} {data}")
    if cmd == "move":
        direction = data.get("direction", "forward")
        if direction == "forward":
            hardware.DIR1.on(); hardware.DIR2.off()
        elif direction == "backward":
            hardware.DIR1.off(); hardware.DIR2.on()
        elif direction == "stop":
            hardware.PUL1.off(); hardware.PUL2.off()
    elif cmd == "start_mission":
        ok = hardware.run_start_mission()
        _add_report(
            "mission_complete",
            "Mission started" if ok else "Mission start failed",
        )


class FirebaseSync:
    def __init__(self):
        self._thread = None
        self._running = False
        self._last_cmd_time = 0
        self.is_running = False

    def start(self):
        if not _init_firebase():
            logger.info("Firebase disabled (no service_account.json)")
            self.is_running = True
            return
        self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()
        self.is_running = True
        logger.info("Firebase sync started")

    def stop(self):
        self._running = False
        self.is_running = False

    def _run(self):
        last_status = 0
        last_location = 0
        while self._running:
            now = time.time()
            sensors = hardware.get_sensors()

            if now - last_status >= 5:
                _write_status(sensors)
                last_status = now

            if now - last_location >= 10:
                _write_location()
                last_location = now

            cmd, ts = _check_commands(self._last_cmd_time)
            if cmd and ts > self._last_cmd_time:
                self._last_cmd_time = ts
                _execute_command(cmd)

            time.sleep(1)
