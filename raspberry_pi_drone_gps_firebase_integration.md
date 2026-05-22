# Raspberry Pi Drone GPS Tracking → Firebase Integration

This document explains how to run a Raspberry Pi as a GPS tracker for a drone and send real-time location data to Firebase Firestore.

---

# 1. Overview

The system works as follows:

```
GPS Module → Raspberry Pi → Firebase Firestore → Flutter App
```

The Raspberry Pi reads GPS coordinates and uploads them to Firebase every few seconds.

---

# 2. Requirements

## Hardware:
- Raspberry Pi (any model with GPIO UART support)
- GPS Module (e.g. NEO-6M)
- Jumper wires

## Software:
- Python 3
- Firebase Admin SDK
- pyserial
- pynmea2

---

# 3. Install Dependencies

```bash
pip install firebase-admin pyserial pynmea2
```

---

# 4. Enable Serial on Raspberry Pi

Run configuration tool:

```bash
sudo raspi-config
```

Then:
- Interface Options
- Serial Port
  - Disable login shell over serial: YES
  - Enable hardware serial: YES

Reboot:

```bash
sudo reboot
```

---

# 5. Wiring GPS Module

| GPS Pin | Raspberry Pi Pin |
|--------|------------------|
| VCC    | 5V               |
| GND    | GND              |
| TX     | GPIO 15 (RX)     |
| RX     | GPIO 14 (TX)     |

---

# 6. Firebase Setup

1. Go to Firebase Console
2. Create project
3. Enable Firestore Database
4. Generate Service Account Key
5. Download:

```
serviceAccountKey.json
```

Place it in the same folder as your script.

---

# 7. Raspberry Pi Python Code

## Full Working Example

```python
import time
import firebase_admin
from firebase_admin import credentials, firestore
import serial
import pynmea2

# ---------------- Firebase Setup ----------------
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# ---------------- GPS Setup ----------------
port = serial.Serial("/dev/serial0", baudrate=9600, timeout=1)

def get_gps():
    while True:
        line = port.readline().decode('utf-8', errors='ignore')

        if line.startswith('$GPGGA'):
            try:
                msg = pynmea2.parse(line)

                lat = msg.latitude
                lng = msg.longitude

                if lat != 0 and lng != 0:
                    return lat, lng
            except:
                pass

# ---------------- Main Loop ----------------
while True:
    lat, lng = get_gps()

    db.collection("drone").document("location").set({
        "lat": lat,
        "lng": lng,
        "timestamp": firestore.SERVER_TIMESTAMP
    })

    print("Sent:", lat, lng)

    time.sleep(2)
```

---

# 8. How It Works

1. Raspberry Pi reads raw GPS NMEA data
2. Extracts latitude and longitude
3. Sends data to Firebase Firestore
4. Flutter app listens in real-time and updates map

---

# 9. Notes

- Ensure GPS module has clear sky view for fix
- First GPS fix may take 30–60 seconds
- Do not send data every 1 second in production (2–5 seconds is better)
- Make sure internet is available on Raspberry Pi

---

# 10. Common Issues

## No GPS data
- Check wiring TX/RX
- Ensure serial is enabled

## Firebase error
- Verify serviceAccountKey.json path
- Check Firestore permissions

## No location fix
- Wait outside or near window
- Check GPS LED blinking

---

# End of File

