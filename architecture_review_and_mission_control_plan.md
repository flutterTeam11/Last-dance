# Phoenix Drone — Architecture Review & Mission Control Plan

## 1. System Architecture Overview

The Phoenix Drone Search & Rescue System has **three tiers**:

```
┌──────────────────────┐     TCP Video      ┌────────────────────────┐     WebSocket      ┌─────────────────────┐
│  Raspberry Pi        │ ──────────────────> │  Laptop Server         │ ──────────────────> │  Flutter Mobile App  │
│  (Drone / Robot)     │    port 9000        │  (Ground Station)      │    video+dets      │                     │
│                      │                     │  Port 8000             │                    │                     │
│  - Motors (GPIO)     │                     │  - AI Pipeline         │ <────────────────── │  - Commands         │
│  - Sensors           │                     │  - WebSocket Manager   │    /ws/commands    │  - Map + Video      │
│  - Camera            │                     │  - ESP32 (serial)      │                    │  - Telemetry         │
│  - Firebase sync     │                     │  - Firebase sync       │                    │  - Firebase sync     │
└──────────────────────┘                     └────────────────────────┘                    └─────────────────────┘
                                                           │                                       │
                                                           │          Firebase Firestore           │
                                                           │       ┌──────────────────────┐        │
                                                           └───────│  drone/              │ <──────┘
                                                                   │   - location         │
                                                                   │   - status           │
                                                                   │   - commands         │
                                                                   │   - reports/entries  │
                                                                   └──────────────────────┘
```

### Tiers

| Tier | System | Role | Technology |
|------|--------|------|------------|
| 1 | Raspberry Pi (Drone) | Motor control, sensor reading, camera capture | Python, GPIO, OpenCV, Firebase SDK |
| 2 | Laptop Server | AI processing, WebSocket relay, Firebase sync | FastAPI, OpenCV, YOLO, Firebase Admin |
| 3 | Flutter App | User interface, real-time map, video, commands | Flutter, BLoC, WebSocket, Firestore SDK |

---

## 2. Critical Issues Found

### 🔴 ISSUE 1: Flutter WebSocket URL Points to Pi, Not Laptop Server

- **File**: `lib/core/di/service_locator.dart:25`
- **Code**: `WsClient(baseUrl: 'ws://raspaberry.local:8000')`
- **Root Cause**: `raspaberry` is the Pi's hostname. The Pi's FastAPI server has only `/ws/control` and `/ws/commands` — it **does not** have `/ws/video` or `/ws/detections`. The laptop server has all three, but Flutter never connects to it.
- **Impact**: Video streaming and AI detection feeds are **completely broken**. `WsClient` opens three simultaneous connections; video and detection fail with unreachable endpoint errors.

### 🔴 ISSUE 2: GPIO Pin Conflict — Two Services Compete for Same Hardware

| Service | File | GPIO Library | Pins |
|---------|------|-------------|------|
| `graduation-project.service` | `project2.py` | `gpiozero.OutputDevice` | 17,27,22 (M1), 23,24,25 (M2) |
| `phoenix-pi-server.service` | `pi_server/hardware.py` | `RPi.GPIO` | **Exact same pins** |

- **Both services are enabled at boot** (`multi-user.target.wants`).
- **Impact**: GPIO contention, unpredictable motor behavior, risk of hardware damage. Simultaneous `step()` calls from both services can cause erratic movement or driver damage.

### 🔴 ISSUE 3: Camera Streaming Not Auto-Started

- **File**: `pi_server/camera_stream.py` (standalone, no systemd service)
- **Impact**: Must SSH into Pi and run manually. Video pipeline never starts without manual terminal intervention.

### 🔴 ISSUE 4: Hardcoded Laptop IP in Camera Stream

- **File**: `pi_server/camera_stream.py:9`
- **Code**: `SERVER_IP = "192.168.1.17"`
- **Impact**: Completely breaks on any different network (hotspot, different subnet). No auto-discovery (mDNS, etc.).

### 🔴 ISSUE 5: Three Independent Firebase Syncs Overwrite Each Other

| Instance | File | Status Fields Written |
|----------|------|---------------------|
| Pi `project2.py` | `pi_firebase_sync.py` | `temperature`, `humidity`, `mq2`, `mq8`, `irLeft`, `irRight` |
| Pi `main.py` | `pi_server/firebase_sync.py` | `temperature` only |
| Laptop Server | `laptop_server/firebase_sync.py` | `temperature`, `humidity`, `gasLevel` |

- **Impact**: Status field names are inconsistent (`gasLevel` vs `mq2`/`mq8`). Pi's `project2.py` overwrites laptop's data every 5 seconds. Flutter reads `humanCount`, `height`, `speed` which are hardcoded to 0 by the Pi.

### 🔴 ISSUE 6: Fragmented "Start Mission" Command Flow

Three separate handlers, none coordinated:

| Path | Handler | Behavior |
|------|----------|----------|
| Flutter → Firebase → Pi's `project2.py` | `_handle_firebase_command("start_mission")` | Calls `forward()` — **continuous** motion |
| Flutter → WS → Pi's `main.py` | `commands_endpoint("start_mission")` | Calls `hardware.run_start_mission()` — **600 steps then stops** |
| Flutter → WS → Laptop Server | `_handle_command({"type":"start_mission"})` | Sends to ESP32 (may not be connected), writes Firebase |

- **Impact**: Depending on which path reaches the Pi first, the drone either moves continuously or stops after 600 steps.

### 🟡 ISSUE 7: Missing `requirements.txt` in `pi_server/`

- No dependency manifest. Install script only `pip install`s `fastapi` and `uvicorn`.
- Missing: `firebase-admin`, `opencv-python`, `adafruit-circuitpython-dht`, `RPi.GPIO`.

### 🟡 ISSUE 8: Pi's `project2.py` Lacks Clean Shutdown

- No `SIGTERM`/`SIGINT` handler. Systemd restart leaves GPIO pins in unknown state.
- `running` global never properly synchronized with systemd's stop/restart.

### 🟡 ISSUE 9: WiFi Configuration Mismatch

- SD card `network-config` connects to SSID `"iPhone"` with password `"Ma123123"`.
- Laptop's hotspot scripts (`hotspot-on.sh`, `hotspot-auto.sh`) create SSID `"Pi-Project"`.
- **Impact**: Pi and laptop may not be on the same network unless user manually configures.

### 🟢 ISSUE 10: Service Account Credentials Duplicated

- `pi_server/service_account.json` and `/home/beso/graduation_project/service_account.json` (SD card) — live Firebase private key duplicated across locations.

---

## 3. Proposed Architecture Solution

### Decision: Single Pi Service + Laptop Server as Primary WebSocket Hub

```
Flutter App                      Laptop Server                       Raspberry Pi
─────────────                    ─────────────                       ────────────
                                  ┌──────────────────┐              ┌────────────────────────┐
WS → /ws/commands ────────────>  │  FastAPI :8000   │             │  consolidated-pi.service │
   {"start_mission"}             │  /ws/video        │  TCP :9000  │  - project2.py (motors)  │
                                  │  /ws/detections   │ <────────── │  - camera_stream thread │
WS ← /ws/video (JPEG) <─────── │  /ws/commands     │             │  - Firebase command poll  │
WS ← /ws/detections (JSON) <── │  AI Pipeline      │             │  - Sensor processing      │
                                  │  Firebase sync    │             │  - Status report          │
Firebase ← location/status <─── │  ESP32 (optional) │             └────────────────────────┘
Firebase → write commands ─────> └──────────────────┘                       │
                                  │                                          │ Firebase poll
                                  │ Firebase Firestore                       │ (drone/commands)
                                  │ (drone/commands)                        │ every 1s
                                  ▼                                          ▼
                           ┌──────────────────────────┐          ┌──────────────────────┐
                           │  drone/commands           │          │  drone/commands       │
                           │  {command:"start_mission"}│          │  → forward()          │
                           └──────────────────────────┘          └──────────────────────┘
```

### What Changes

| Component | Action | Rationale |
|-----------|--------|-----------|
| Flutter WebSocket URL | Change to laptop server IP | Pi doesn't have video/detection endpoints |
| `pi_server/main.py` + `hardware.py` | **Remove** | GPIO conflict with `project2.py` |
| `phoenix-pi-server.service` | **Disable** | No longer needed |
| `project2.py` | **Enhance** | Add camera thread, signal handlers |
| `graduation-project.service` | **Keep & enhance** | Add ExecStop, camera integration |
| `pi_server/camera_stream.py` | **Parameterize** | Accept target IP as CLI arg |
| Laptop `firebase_sync.py` | **Align fields** | Match Pi's status field names |

### Unified "Start Mission" Flow

```
1. User presses "Start Mission" in Flutter
2. Flutter writes {command:"start_mission"} to Firestore drone/commands
3. Flutter sends {"type":"start_mission"} over WebSocket to Laptop Server
4. Laptop Server receives command, writes to Firebase (backup)
5. Laptop Server optionally forwards to ESP32
6. Pi's project2.py polls Firestore every 1 second
7. Pi sees command "start_mission", calls forward()
8. Pi starts continuous motor operation
9. Pi starts camera streaming thread (NEW - integrated)
10. Pi reports status + mission report to Firebase every 5 seconds
11. Flutter receives status/location via Firebase streams
12. Video flows: Pi camera → TCP 9000 → Laptop Server → WS → Flutter
```

---

## 4. Files Requiring Modification

| # | File | Change |
|---|------|--------|
| 1 | `lib/core/di/service_locator.dart` | Change `ws://raspaberry.local:8000` → laptop server IP/mDNS |
| 2 | `pi_server/camera_stream.py` | Add `SERVER_IP` CLI argument / env var |
| 3 | `pi_server/main.py` | **Delete** — remove conflicting service |
| 4 | `pi_server/firebase_sync.py` | **Delete** — redundant with `pi_firebase_sync.py` |
| 5 | `pi_server/hardware.py` | **Delete** — redundant with `project2.py` GPIO code |
| 6 | `pi_server/control.py` | **Delete** — dev-only test script |
| 7 | SD: `/home/beso/graduation_project/project2.py` | Add camera streaming thread, SIGTERM handler |
| 8 | SD: `/home/beso/graduation_project/pi_firebase_sync.py` | Add `fields` param for field name compatibility |
| 9 | SD: `graduation-project.service` | Add `ExecStop` for clean GPIO shutdown |
| 10 | SD: `phoenix-pi-server.service` | **Disable** (`systemctl disable`) |
| 11 | `tools/install_pi_server_to_sd.sh` | Update to new architecture (remove phoenix-pi-server) |
| 12 | `pi_server/requirements.txt` | **Create** with all dependencies |
| 13 | `laptop_server/firebase_sync.py` | Align field names with Pi's `write_status` |

---

## 5. Implementation Plan (6 Phases)

### Phase 1: Configuration Fixes (No Code Changes)

1. Disable `phoenix-pi-server.service` on the SD card:
   ```bash
   sudo systemctl disable phoenix-pi-server
   ```
2. Align `network-config` SSID with laptop hotspot (`Pi-Project`) or use static IP.

### Phase 2: Flutter App Updates

3. Change `lib/core/di/service_locator.dart:25`:
   - Before: `WsClient(baseUrl: 'ws://raspaberry.local:8000')`
   - After: `WsClient(baseUrl: 'ws://<laptop-ip>:8000')` (configurable)

### Phase 3: Pi Service Consolidation

4. Enhance `project2.py`:
   - Add camera streaming thread (subprocess/thread wrapping `camera_stream.py`)
   - Add `SIGTERM`/`SIGINT` handlers for clean GPIO cleanup
   - Add retry logic for Firebase connection
   - Add periodic camera frame capture and TCP send
5. Update `start_project.sh` to verify OpenCV and other camera dependencies.

### Phase 4: Laptop Server Alignment

6. Update `laptop_server/firebase_sync.py`:
   - Add `humidity`, `mq2`, `mq8`, `irLeft`, `irRight` to status writes
   - Map `gasLevel` from input or compute from `mq2`/`mq8`

### Phase 5: Camera Stream Fix

7. Update `pi_server/camera_stream.py`:
   - Accept `SERVER_IP` from environment variable or CLI argument
   - Add reconnection backoff
   - Make frame rate configurable

### Phase 6: Cleanup

8. Create `pi_server/requirements.txt` with full dependency list
9. Remove unused files (`main.py`, `hardware.py`, `firebase_sync.py`, `control.py`)
10. Update `tools/install_pi_server_to_sd.sh` to reflect new architecture

---

## 6. Verification Steps

After implementation, verify the end-to-end flow:

1. **Boot Pi** → `graduation-project.service` starts → GPIO initialized → Firebase listener polls every 1s
2. **WiFi Connect** → Pi auto-connects to hotspot → mDNS/network reachable
3. **Start laptop server** → `python laptop_server/main.py` → TCP :9000, WS :8000 ready
4. **Start Flutter app** → WebSocket connects to laptop server :8000
5. **Press "Start Mission"** →
   - Flutter logs: `[Mission] Start mission command sent`
   - Laptop server logs: `Command received: {"type":"start_mission"}`
   - Pi logs: `📡 Firebase command: start_mission`
   - Motors begin running
   - Camera stream starts → TCP → laptop → WS → Flutter
6. **Verify** video feed visible in Flutter UI ✓
7. **Verify** AI detection overlay visible ✓
8. **Verify** telemetry (status, location) updating via Firebase ✓
9. **Verify** reports section shows "Mission started" ✓

---

## 7. Dependency Matrix

### pi_server/ (`project2.py`) — Required Python Packages

| Package | Purpose | In Venv? |
|---------|---------|----------|
| `gpiozero` | GPIO motor control | ✓ |
| `lgpio` | GPIO backend for gpiozero | ✓ |
| `spidev` | MCP3008 ADC (gas sensor) | ✓ |
| `adafruit-circuitpython-dht` | DHT11 temp/humidity | ✓ |
| `numpy` | Audio processing | ✓ |
| `sounddevice` | Sound detection | ✓ |
| `firebase-admin` | Firebase Firestore | ✓ (auto-installed by start_project.sh) |
| `opencv-python` | Camera capture | ❌ Missing |
| `RPi.GPIO` | GPIO (fallback) | ✓ |

### laptop_server/ — Required Python Packages

| Package | Purpose | In requirements.txt? |
|---------|---------|---------------------|
| `fastapi` | Web framework | ✓ |
| `uvicorn[standard]` | ASGI server | ✓ |
| `opencv-python` | Frame processing | ✓ |
| `numpy` | Numerical ops | ✓ |
| `Pillow` | Image processing | ✓ (unused in code) |
| `websockets` | WS support | ✓ |
| `firebase-admin` | Firebase | ✓ |
| `pyserial` | ESP32 serial | ✓ |
| `pyserial-asyncio` | Async serial | ✓ |
| `pyyaml` | YAML parsing | ❌ Needed for `ai_team_script` (TBD) |
| `torch` | YOLO inference | ❌ Not yet added |

### Flutter App — pubspec.yaml Dependencies

| Package | Purpose | Actually Used? |
|---------|---------|---------------|
| `flutter_bloc` | State management | ✓ |
| `get_it` | DI | ✓ |
| `cloud_firestore` | Firestore | ✓ |
| `web_socket_channel` | WebSocket | ❌ (uses `dart:io` WebSocket directly) |
| `flutter_vlc_player` | Video player | ❌ (uses `Image.memory()`) |
| `dio` | HTTP client | ❌ (only in error handling stubs) |
| `geolocator` | Device GPS | ✓ |

---

## 8. Current Systemd Services on SD Card

| Service | File | Status | Problem |
|---------|------|--------|---------|
| `graduation-project.service` | `/etc/systemd/system/graduation-project.service` | **Enabled** | No SIGTERM handler |
| `phoenix-pi-server.service` | `/etc/systemd/system/phoenix-pi-server.service` | **Enabled** | GPIO conflict with above |
| `ssh.service` | Standard | **Enabled** | No authorized keys configured |
| `avahi-daemon` | Standard | **Enabled** | mDNS support |

### Proposed Final Service State

| Service | Action | Notes |
|---------|--------|-------|
| `graduation-project.service` | **Keep** | Enhance with ExecStop, camera integration |
| `phoenix-pi-server.service` | **Disable** | GPIO conflict resolved by removal |
| `ssh.service` | **Keep** | Add authorized_keys for convenience |

---

## 9. Firestore Schema (After Alignment)

```
drone/
├── location          { lat, lng, timestamp }
├── status            { battery, humanCount, height, speed, isConnected,
│                       temperature, humidity, gasLevel, mq2, mq8,
│                       irLeft, irRight }
├── commands          { command, data, timestamp }
└── reports/
    └── entries/      { type, message, timestamp }
```

The laptop server and Pi both write to the same document. The Pi's `project2.py` is the primary status writer (runs every 5s). The laptop server augments with data from ESP32 when connected.

---

## 10. Summary

| Metric | Count |
|--------|-------|
| Critical issues (🔴) | 6 |
| Moderate issues (🟡) | 3 |
| Minor issues (🟢) | 1 |
| Files to modify | 13 |
| Files to delete | 4 |
| New files to create | 1 |
| Services to disable | 1 |
| Implementation phases | 6 |

The core problem is **architectural fragmentation**: three independent systems evolved in parallel (Firebase-polling motor controller, FastAPI WebSocket server, laptop ground station) without coordination. The fix consolidates to one Pi service, routes Flutter through the laptop server for WebSocket, and uses Firebase as the command bus.
