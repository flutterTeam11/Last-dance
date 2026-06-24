import json
import logging
import os
import threading
import time

logger = logging.getLogger("laptop-firebase")

SERVICE_ACCOUNT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    "pi_server",
    "service_account.json",
)
_alt_service_account = os.path.join(os.path.dirname(__file__), "service_account.json")
COLLECTION = "drone"

FIREBASE_AVAILABLE = False
db = None
firestore = None


def _init_firebase():
    global FIREBASE_AVAILABLE, db, firestore
    path = SERVICE_ACCOUNT_PATH
    if not os.path.exists(path):
        if os.path.exists(_alt_service_account):
            path = _alt_service_account
        else:
            logger.warning(f"service_account.json not found")
            return False
    try:
        import firebase_admin
        from firebase_admin import credentials
        from firebase_admin import firestore as _fs

        firestore = _fs
        cred = credentials.Certificate(path)
        firebase_admin.initialize_app(cred, name="laptop_server")
        db = firestore.client(app=firebase_admin.get_app(name="laptop_server"))
        FIREBASE_AVAILABLE = True
        logger.info("Laptop Firebase initialized")
        return True
    except Exception as e:
        logger.error(f"Laptop Firebase init failed: {e}")
        return False


class LaptopFirebaseSync:
    def __init__(self):
        self._thread = None
        self._running = False
        self.is_running = False
        self._latest_sensors = {}
        self._latest_location = {}
        self._lock = threading.Lock()

    def start(self):
        if not _init_firebase():
            logger.warning("Firebase disabled for laptop server")
            self.is_running = True
            return
        self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()
        self.is_running = True
        logger.info("Laptop Firebase sync started")

    def stop(self):
        self._running = False
        self.is_running = False

    def update_sensors(self, data: dict):
        with self._lock:
            self._latest_sensors.update(data)

    def update_location(self, lat: float, lng: float):
        with self._lock:
            self._latest_location = {"lat": lat, "lng": lng}

    def write_command(self, command: str, data: dict = None):
        if db is None:
            return
        try:
            db.collection(COLLECTION).document("commands").set({
                "command": command,
                "data": data or {},
                "timestamp": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            logger.error(f"Failed to write command: {e}")

    def add_report(self, report_type: str, message: str):
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

    def _run(self):
        last_status = 0
        last_location = 0
        while self._running:
            now = time.time()
            if now - last_status >= 3:
                with self._lock:
                    sensors = dict(self._latest_sensors)
                self._write_status(sensors)
                last_status = now
            if now - last_location >= 10:
                with self._lock:
                    location = dict(self._latest_location)
                if location:
                    self._write_location(location)
                last_location = now
            time.sleep(1)

    def _write_status(self, sensors: dict):
        if db is None:
            return
        try:
            doc = {
                "battery": sensors.get("battery", 85),
                "humanCount": sensors.get("humanCount", 0),
                "height": sensors.get("height", 0),
                "speed": sensors.get("speed", 0),
                "isConnected": True,
                "temperature": sensors.get("temperature", 0) or 0,
                "humidity": sensors.get("humidity", 0) or 0,
                "gasLevel": sensors.get("gas", 0) or 0,
            }
            db.collection(COLLECTION).document("status").set(doc)
        except Exception as e:
            logger.error(f"Failed to write status: {e}")

    def _write_location(self, location: dict):
        if db is None:
            return
        try:
            db.collection(COLLECTION).document("location").set({
                "lat": location.get("lat", 0),
                "lng": location.get("lng", 0),
                "timestamp": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            logger.error(f"Failed to write location: {e}")
