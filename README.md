<p align="center">
  <img src="assets/images/splash/Phoenix.svg" alt="Phoenix" width="120" />
</p>

<h1 align="center">Phoenix — Drone Search & Rescue System</h1>

<p align="center">
  <em>Real-time ground control station for AI-assisted drone search and rescue operations.</em>
  <br />
  <strong>ResQer</strong> — your smart companion in disaster zones.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.12-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/State%20Management-BLOC/Cubit-02569B" alt="BLoC" />
  <img src="https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-6DB33F" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License" />
</p>

---

## Overview

Phoenix is a four-tier drone ground control system for search and rescue operations. A mobile application receives real-time video feeds, AI-powered human detection overlays, and live telemetry from a drone, enabling rescue teams to coordinate missions from the field.

The system comprises four components:

- **Raspberry Pi (onboard the drone)** — Runs a FastAPI server for motor control via GPIO, sensor data (DHT11, gas sensors, IR), camera streaming over TCP, and GPS reporting to Firestore. Exposes WebSocket endpoints for real-time control.
- **ESP32 (onboard the drone)** — Microcontroller handling sensor data collection and GPS location; communicates with the Laptop Server over serial (UART).
- **Laptop Server** — FastAPI-based middleware that receives drone video (TCP from Pi), connects to ESP32 over serial for sensor/location data, runs AI detection (YOLO), syncs with Firebase, and broadcasts processed frames/detections to mobile clients over WebSockets.
- **Flutter Mobile App** — The ground control interface with live video, interactive maps, drone telemetry, virtual joystick control, mission management, and Pi health monitoring.

---

## Screenshots

> *Replace these with actual screenshots of your app.*

| Onboarding | Sign In | Home Dashboard | Map Tracking | Fullscreen Video |
|------------|---------|----------------|--------------|------------------|
| &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; |

---

## Features

### Core Capabilities

| Feature | Description |
|---------|-------------|
| **Live Video Streaming** | Real-time video feed from the drone camera via WebSocket with Normal, Thermal, and AI Overlay modes |
| **AI Human Detection** | YOLO-based object detection with bounding boxes, confidence scores, and system status labels rendered as a HUD overlay |
| **GPS Tracking** | Real-time drone location tracking on OpenStreetMap with path history and user location |
| **Telemetry Monitoring** | Battery level, altitude, speed, temperature, humidity, gas levels, and human detection count displayed via circular indicators and stats bars |
| **Virtual Joystick** | Full-screen touch-based joystick for remote drone control (move, start/stop mission, land) |
| **Mission Management** | Plan, start, and monitor rescue missions with status tracking — communicates directly with the Pi server over HTTP/WebSocket |
| **Pi Health Monitoring** | Polls Raspberry Pi health status (motors, battery, temperature) with automatic offline detection after 3 consecutive failures |
| **Motor Control Panel** | Individual motor start/stop controls with real-time status feedback from the Pi |
| **Reports & Alerts** | Real-time incident reports (human detected, system overheated, mission complete) with timestamps |
| **Authentication** | Email/password sign-up, sign-in, Google/Apple OAuth, password reset flow, and OTP verification |

### UX & Design

| Feature | Description |
|---------|-------------|
| **Responsive UI** | Built with `flutter_screenutil` for adaptive layouts across phone and tablet sizes |
| **Onboarding Flow** | 4-page animated carousel introducing the system to new users |
| **Light Theme** | Clean light interface with cyan/blue brand gradient, suitable for outdoor field readability |
| **Animated Transitions** | Snackbar, page, and state transitions with smooth animations |

---

## Tech Stack

### Flutter Application

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.12+ (Dart SDK ^3.12.0) |
| **State Management** | BLoC / Cubit (`flutter_bloc`) with sealed state classes and `Equatable` |
| **Navigation** | Declarative routing via `go_router` |
| **DI** | Service locator pattern with `get_it` |
| **Maps** | OpenStreetMap via `flutter_map` + `latlong2` |
| **Video Streaming** | `web_socket_channel` (MJPEG over WebSocket) + `flutter_vlc_player` |
| **Authentication** | Firebase Auth + `google_sign_in` |
| **Database** | Cloud Firestore (real-time streams) |
| **Local Storage** | `shared_preferences` |
| **HTTP Client** | `dio` (Pi HTTP communication + error handling) |
| **Location** | `geolocator` for user location services |
| **Error Handling** | Functional `Either` type via `dartz` |
| **SVG Rendering** | `flutter_svg` |

### Backend Server (Laptop)

| Category | Technology |
|----------|-----------|
| **Framework** | FastAPI 0.115 (Python 3.10+) |
| **Server** | Uvicorn 0.30 (ASGI) |
| **Video Processing** | OpenCV, NumPy, Pillow |
| **AI Detection** | YOLO via custom detection pipeline (with dummy fallback) |
| **Real-time** | WebSockets (video, detections, commands) |
| **TCP Receiver** | Async socket server for drone video ingestion (port 9000) |
| **Serial Communication** | pyserial + pyserial-asyncio for ESP32 data (UART) |
| **Firebase** | Firebase Admin SDK (server-side Firestore sync) |

### Raspberry Pi (Onboard Drone)

| Component | Role |
|-----------|------|
| **FastAPI Server** | Motor control, sensor reading, camera streaming, WebSocket command relay |
| **Stepper Motors** | Dual-motor control via GPIO (PUL/DIR/EN pins) with step/direction drivers |
| **Camera Module** | Video capture for live streaming over TCP |
| **GPS Module** | Real-time location reporting to Firestore |
| **DHT11 Sensor** | Temperature and humidity monitoring |
| **MQ-2 / MQ-8 Sensors** | Gas and smoke detection |
| **IR Sensors** | Left/right obstacle detection |

### ESP32 (Onboard Drone)

| Component | Role |
|-----------|------|
| **UART Serial** | Communicates sensor data and GPS location to Laptop Server |
| **Sensor Fusion** | Aggregates sensor readings and sends structured JSON over serial |

---

## Architecture

```
┌──────────────────┐     TCP Video      ┌────────────────────────┐     WebSocket      ┌──────────────────────┐
│                  │ ───────────────────▶│                        │ ──────────────────▶│                      │
│  Raspberry Pi    │     Stream          │   FastAPI Server       │    Video + Detects  │   Flutter Mobile App │
│  (Onboard)       │                     │   (Laptop)             │                     │   (Ground Control)   │
│                  │◄────────────────────│                        │◀────────────────────│                      │
│  - Camera        │  HTTP / WS Control  │   - AI Detection       │        Commands     │  - Live Video Feed   │
│  - Stepper Motor │                     │   - Thermal Analysis   │                     │  - Map Tracking      │
│  - GPIO Sensors  │                     │   - Frame Processing   │                     │  - Telemetry Display │
│  - Firestore     │                     │   - ESP32 Serial I/O   │                     │  - Joystick Control  │
└──────────────────┘                     │   - Firebase Sync      │                     │  - Mission Manager   │
        │                                └────────────────────────┘                     │  - Pi Health Monitor │
        │ GPS/Sensors via UART                     ▲                                    └──────────────────────┘
        ▼                                         │ Serial
┌──────────────────┐                               │
│     ESP32        │───────────────────────────────┘
│  - GPS Module    │
│  - Sensors       │
└──────────────────┘

┌──────────────────┐
│   Raspberry Pi   │  (Separate HTTP Server on the Pi)
│  FastAPI :8000   │
│                  │  GET  /health              — Health check
│                  │  GET  /sensors             — GPIO sensor readings
│                  │  POST /move/{direction}    — Motor movement
│                  │  POST /steps/{count}       — Step motors
│                  │  WS   /ws/control          — Real-time control
│                  │  WS   /ws/commands         — Mission commands
│  Motor Server    │
│  HTTP :5000      │  GET  /start  /stop  /status
└──────────────────┘
```

### Data Flow

1. **ESP32 → Laptop Server (Serial)**: ESP32 sends JSON frames over UART with sensor data (`sensor` type) and GPS location (`location` type).
2. **Pi → Laptop Server (TCP)**: Raspberry Pi streams MJPEG video frames over TCP (port 9000).
3. **Pi → Firestore**: Raspberry Pi writes GPS location, telemetry (battery, height, speed, temperature), and status to Cloud Firestore.
4. **Laptop Server → App (WebSocket)**: The server processes each frame (resize, AI detection, thermal analysis) and broadcasts over `/ws/video` (JPEG bytes) and `/ws/detections` (JSON bounding boxes).
5. **Laptop Server → Firestore**: Server writes ESP32 sensor data, location, and commands to Firestore via `LaptopFirebaseSync`.
6. **App → Laptop Server (WebSocket)**: The mobile app sends commands (move, start_mission, stop_mission, land, set_speed) over `/ws/commands`.
7. **App → Pi Server (HTTP)**: The mobile app directly polls Pi health (`/status`) and sends start/stop mission commands via `PiHttpClient`.
8. **App ← Firestore**: The mobile app subscribes to Firestore stream snapshots for real-time drone location, status, and reports.

### Clean Architecture (Feature-First)

```
lib/
├── core/                          # Shared infrastructure
│   ├── di/                        # Dependency injection (GetIt)
│   ├── router/                    # GoRouter configuration
│   ├── theme/                     # Colors, dimensions, ThemeData
│   ├── websocket/                 # WS client + bridge + detection models
│   ├── helper/                    # Utility helpers (snackbar)
│   ├── error/                     # Failure classes
│   ├── utils/                     # SharedPreferences, location utils
│   ├── widgets/                   # Shared UI components
│   └── pi_http_client.dart        # HTTP client for Pi motor server
└── features/                      # Feature modules
    ├── auth/                      # Auth flow (sign-up, sign-in, OTP, reset)
    ├── drone/                     # Main drone interface (video, map, telemetry, control)
    ├── onboarding/                # Onboarding carousel
    └── splash/                    # App entry + auth gate
```

Each feature follows a 3-layer structure:

```
feature/
├── data/           # Repository implementations (Firebase, etc.)
├── domain/         # Abstract repositories, domain models
└── presentation/   # Cubits (BLoC), screens, widgets
```

---

## Project Structure

```
graduatio_project/
├── android/                        # Platform: Android
├── ios/                            # Platform: iOS
├── web/                            # Platform: Web
├── linux/                          # Platform: Linux
├── macos/                          # Platform: macOS
├── windows/                        # Platform: Windows
├── assets/
│   ├── diagrams/                   # Generated architecture diagrams (PPTX)
│   ├── icons/                      # SVG icons (Google, Apple)
│   ├── images/
│   │   ├── onboarding/             # 4 onboarding illustrations
│   │   └── splash/                 # App logo (Phoenix.svg)
│   └── map/                        # Map placeholder assets
├── laptop_server/                  # FastAPI backend (Laptop)
│   ├── ai_integration/
│   │   ├── detector.py             # YOLO detector (with dummy fallback)
│   │   └── pipeline.py             # Frame processing pipeline
│   ├── broadcast/
│   │   └── ws_manager.py           # WebSocket client connection management
│   ├── receivers/
│   │   └── tcp_receiver.py         # Async TCP server (port 9000)
│   ├── config.py                   # Server configuration
│   ├── esp32_interface.py          # Serial interface for ESP32 (sensors, GPS)
│   ├── firebase_sync.py            # Laptop-side Firebase sync (LaptopFirebaseSync)
│   ├── main.py                     # FastAPI entrypoint
│   └── requirements.txt            # Python dependencies
├── pi_server/                      # FastAPI backend (Raspberry Pi onboard)
│   ├── camera_stream.py            # Camera capture + TCP video streaming
│   ├── control.py                  # Keyboard control client (via WebSocket)
│   ├── firebase_sync.py            # Pi-side Firebase sync (status, location, commands)
│   ├── hardware.py                 # GPIO abstraction (stepper motors, sensor reads)
│   ├── main.py                     # FastAPI entrypoint (port 8000)
│   ├── motor_server.py             # Standalone HTTP motor control server (port 5000)
│   └── service_account.json        # Firebase service account (not committed)
├── tools/
│   ├── install_pi_server_to_sd.sh  # Deploy pi_server to Raspberry Pi SD card
│   ├── create_architecture_diagrams_pptx.py
│   ├── create_architecture_diagrams.py
│   ├── create_visual_english_presentation.py
│   └── markdown_to_pptx.py
├── lib/                            # Flutter source
│   ├── core/
│   │   ├── di/service_locator.dart
│   │   ├── error/failure.dart
│   │   ├── helper/show_snak_bar.dart
│   │   ├── pi_http_client.dart     # HTTP client for Pi motor server
│   │   ├── router/app_router.dart
│   │   ├── theme/
│   │   │   ├── app_dimensions.dart
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   │   ├── local_storage_service.dart
│   │   │   └── location_utils.dart
│   │   ├── websocket/
│   │   │   ├── connection_status.dart
│   │   │   ├── drone_ws_bridge.dart
│   │   │   └── ws_client.dart
│   │   └── widgets/
│   │       ├── gradient_button.dart
│   │       ├── onboarding_page_indicator.dart
│   │       └── svg_asset_image.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/auth_repository_impl.dart
│   │   │   ├── domain/auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── auth_cubit.dart
│   │   │       │   └── auth_state.dart
│   │   │       └── screens/
│   │   │           ├── widgets/
│   │   │           │   ├── auth_text_field.dart
│   │   │           │   ├── otp_input_field.dart
│   │   │           │   └── social_sign_in_button.dart
│   │   │           ├── forgot_password_screen.dart
│   │   │           ├── new_password_screen.dart
│   │   │           ├── otp_screen.dart
│   │   │           ├── sign_in_screen.dart
│   │   │           └── sign_up_screen.dart
│   │   ├── drone/
│   │   │   ├── data/drone_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── drone_location.dart
│   │   │   │   ├── drone_report.dart
│   │   │   │   ├── drone_repository.dart
│   │   │   │   └── drone_status.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── drone_status_cubit.dart
│   │   │       │   ├── drone_status_state.dart
│   │   │       │   ├── drone_tracking_cubit.dart
│   │   │       │   ├── drone_tracking_state.dart
│   │   │       │   ├── mission_cubit.dart
│   │   │       │   ├── mission_state.dart
│   │   │       │   ├── pi_health_cubit.dart
│   │   │       │   ├── pi_health_state.dart
│   │   │       │   ├── video_feed_cubit.dart
│   │   │       │   └── video_feed_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── drone_fullscreen_video_screen.dart
│   │   │       │   ├── drone_home_screen.dart
│   │   │       │   ├── drone_main_shell.dart
│   │   │       │   └── drone_map_screen.dart
│   │   │       └── widgets/
│   │   │           ├── ai_detection_overlay.dart
│   │   │           ├── connection_status_bar.dart
│   │   │           ├── drone_bottom_nav_bar.dart
│   │   │           ├── drone_circular_indicator.dart
│   │   │           ├── drone_map_content.dart
│   │   │           ├── drone_map_status_bar.dart
│   │   │           ├── drone_map_view.dart
│   │   │           ├── drone_stat_item.dart
│   │   │           ├── drone_stats_bar.dart
│   │   │           ├── drone_status_card.dart
│   │   │           ├── grid_painter.dart
│   │   │           ├── joystick_painter.dart
│   │   │           ├── map_markers.dart
│   │   │           ├── map_placeholder.dart
│   │   │           ├── map_screen_header.dart
│   │   │           ├── mission_button.dart
│   │   │           ├── mission_status_card.dart
│   │   │           ├── motor_control_panel.dart
│   │   │           ├── report_tile.dart
│   │   │           ├── reports_section.dart
│   │   │           ├── simulated_feed.dart
│   │   │           ├── start_mission_button.dart
│   │   │           ├── video_back_button.dart
│   │   │           ├── video_feed_background.dart
│   │   │           ├── video_mode_toggle.dart
│   │   │           ├── video_preview_card.dart
│   │   │           └── virtual_joystick.dart
│   │   ├── onboarding/
│   │   │   ├── cubit/
│   │   │   │   ├── onboarding_cubit.dart
│   │   │   │   └── onboarding_state.dart
│   │   │   ├── onboarding_data.dart
│   │   │   └── onboarding_screen.dart
│   │   └── splash/
│   │       └── splash_screen.dart
│   ├── firebase_options.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Installation

### Prerequisites

- Flutter SDK ^3.12.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK ^3.12.0
- Python 3.10+
- A Firebase project with Authentication and Firestore enabled
- Android Studio / Xcode (for device builds)
- Raspberry Pi (for onboard drone server)

### Clone & Dependencies

```bash
git clone https://github.com/your-org/phoenix-drone.git
cd phoenix-drone

# Install Flutter dependencies
flutter pub get

# Install Laptop server Python dependencies
cd laptop_server
pip install -r requirements.txt
cd ..
```

### Pi Server Dependencies

On Raspberry Pi:

```bash
pip install fastapi uvicorn websockets opencv-python numpy firebase-admin

# Optional: Motor control via GPIO
# RPi.GPIO and gpiozero are pre-installed on Raspberry Pi OS

# Optional: DHT11/22 sensor
pip install adafruit-circuitpython-dht
```

---

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Authentication** providers: Email/Password, Google, Apple (optional).
3. Create a **Cloud Firestore** database.
4. Register your app platforms (Android, iOS, Web) in Firebase Console.
5. Install the FlutterFire CLI and configure:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=your-firebase-project-id
```

This generates `lib/firebase_options.dart` with your platform-specific Firebase credentials.

6. Download a service account JSON from Firebase Console → Project Settings → Service Accounts and save it as `pi_server/service_account.json` for the Raspberry Pi (and optionally `laptop_server/service_account.json` for the laptop server).

### Firestore Data Schema

```
drone/                          # Root collection
├── location/                   # Document: real-time GPS
│   ├── lat: double
│   ├── lng: double
│   └── timestamp: Timestamp
├── status/                     # Document: telemetry
│   ├── battery: int
│   ├── humanCount: int
│   ├── height: double
│   ├── speed: double
│   ├── isConnected: bool
│   ├── temperature: double
│   ├── humidity: double         (Laptop sync)
│   └── gasLevel: int           (Laptop sync)
├── commands/                   # Document: outbound commands
│   ├── command: string
│   ├── data: map
│   └── timestamp: Timestamp
└── reports/                    # Document
    └── entries/                # Subcollection: incident reports
        └── {docId}
            ├── type: string
            ├── message: string
            └── timestamp: Timestamp

users/                          # Root collection
└── {uid}/                      # User profile
    ├── uid: string
    ├── email: string
    └── createdAt: Timestamp
```

---

## Environment Configuration

### Flutter App

The server IP addresses are configured in `lib/core/di/service_locator.dart`:

```dart
// lib/core/di/service_locator.dart
// Pi HTTP server (motor control)
getIt.registerLazySingleton<PiHttpClient>(
  () => PiHttpClient(baseUrl: 'http://raspaberry.local:5000'),
);

// Pi WebSocket server (commands)
getIt.registerLazySingleton<WsClient>(
  () => WsClient(baseUrl: 'ws://raspaberry.local:8000'),
);
```

Update `raspaberry.local` to your Raspberry Pi's hostname or IP address. The laptop server WebSocket URLs are also configured in `WsClient`.

### Laptop Server Configuration

```python
# laptop_server/config.py
TCP_PORT = 9000           # Port for Pi video stream (TCP)
WS_PORT = 8000            # Port for WebSocket server
FRAME_WIDTH = 640         # Processing resolution
FRAME_HEIGHT = 480
JPEG_QUALITY = 75         # Compression quality
FRAME_SKIP = 3            # Process every Nth frame for AI
AI_MODEL_PATH = "models/yolov8n.pt"
THERMAL_ENABLED = False
ESP32_PORT = "/dev/ttyUSB0"
ESP32_BAUD = 115200
```

### Pi Server Hardware

```python
# pi_server/hardware.py — GPIO pin mapping
PUL1: GPIO 17    # Stepper motor 1 pulse
DIR1: GPIO 27    # Stepper motor 1 direction
EN1:  GPIO 22    # Stepper motor 1 enable
PUL2: GPIO 23    # Stepper motor 2 pulse
DIR2: GPIO 24    # Stepper motor 2 direction
EN2:  GPIO 25    # Stepper motor 2 enable
```

---

## Running the Project

### 1. Start the Backend Server (Laptop)

```bash
cd laptop_server
python main.py
```

The server starts on `http://0.0.0.0:8000` with:
- `GET /health` — Health check endpoint (server IP, connected clients, pipeline status, ESP32 status)
- `WS /ws/video` — Video stream broadcast
- `WS /ws/detections` — AI detection data broadcast
- `WS /ws/commands` — Command reception from mobile

### 2. Start the Pi Server (Raspberry Pi)

```bash
cd pi_server
python main.py  # FastAPI server on port 8000

# Optional: start the motor HTTP server separately
python motor_server.py  # HTTP server on port 5000

# Optional: start camera streaming
python camera_stream.py
```

Pi server endpoints:
- `GET /health` — Health check (HW status, Firebase sync)
- `GET /sensors` — GPIO sensor readings (temperature, humidity, gas, IR)
- `POST /move/{direction}` — Motor movement (forward/backward/left/right/stop)
- `POST /steps/{count}` — Step motors N times
- `WS /ws/control` — Real-time motor and sensor control
- `WS /ws/commands` — Mission commands from mobile (move, start_mission)

### 3. Run the Flutter App

```bash
# For development
flutter run

# For a specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

The app launches to the splash screen, checks authentication state, and navigates to onboarding (first launch) or the main drone dashboard.

---

## Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## State Management

The project uses the **BLoC / Cubit** pattern from `flutter_bloc`. Seven cubits manage distinct concerns:

| Cubit | Responsibility | States |
|-------|---------------|--------|
| `AuthCubit` | Authentication flow (sign-up, sign-in, OTP, password reset, Google OAuth) | `AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailureState`, `OtpSent`, `PasswordResetEmailSent` |
| `OnboardingCubit` | Onboarding page navigation | `OnboardingState(currentPage)` |
| `DroneTrackingCubit` | Real-time GPS location + path history via Firestore streams | `DroneTrackingInitial`, `Loading`, `Active`, `Disconnected` |
| `DroneStatusCubit` | Telemetry data + incident reports + connection status | `DroneStatusInitial`, `DroneStatusLoaded` |
| `VideoFeedCubit` | Video mode (normal/thermal/overlay) + fullscreen toggle | `VideoFeedState(mode, isFullscreen)` |
| `MissionCubit` | Mission lifecycle (start/stop via Pi HTTP + WebSocket) | `MissionState(idle, starting, running, stopping, stopped, error, piOffline)` |
| `PiHealthCubit` | Raspberry Pi health polling (motors, battery, temperature, online status) | `PiHealthState(isOnline, motorsRunning, battery, temperature, lastSeen)` |

### Pattern

- **Immutable state classes** with `Equatable` for value equality and change comparison.
- **Sealed state hierarchies** enable exhaustive pattern matching in `BlocBuilder`/`BlocSelector`/`BlocListener`.
- **`MultiBlocProvider`** scopes cubits to the widget tree in `DroneMainShell`.
- **`GetIt` service locator** registers cubits as `lazySingleton` or `factory` for dependency injection.
- **`PiHealthCubit`** polls the Pi motor server every 5 seconds; marks Pi offline after 3 consecutive failures.

---

## API / Backend

### Laptop Server WebSocket Endpoints

| Endpoint | Direction | Format | Description |
|----------|-----------|--------|-------------|
| `/ws/video` | Server → Client | Binary (JPEG bytes) | Processed video frames at ~15-30 FPS |
| `/ws/detections` | Server → Client | JSON | AI detection results: bounding boxes, confidence, thermal data |
| `/ws/commands` | Bidirectional | JSON | Mobile sends: `move`, `start_mission`, `stop_mission`, `land`, `set_speed`. Server relays to ESP32. |

### Pi Server WebSocket Endpoints

| Endpoint | Direction | Format | Description |
|----------|-----------|--------|-------------|
| `/ws/control` | Bidirectional | JSON | Real-time motor control + sensor queries (`move`, `step`, `sensors`) |
| `/ws/commands` | Bidirectional | JSON | Mission commands (`move` with x/y, `start_mission`) |

### Pi Server HTTP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Server health + hardware status |
| `/sensors` | GET | Current sensor readings (temperature, humidity, gas, IR) |
| `/move/{direction}` | POST | Motor movement (forward/backward/left/right/stop) |
| `/steps/{count}` | POST | Execute N stepper motor steps |

### Motor Server HTTP Endpoints (port 5000)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/start` | GET | Start motors moving forward |
| `/stop` | GET | Stop motors |
| `/status` | GET | Motor running status + health |

### Detection JSON Format

```json
{
  "detections": [
    {
      "label": "person",
      "confidence": 0.92,
      "x": 0.35,
      "y": 0.25,
      "w": 0.12,
      "h": 0.30
    }
  ],
  "thermal": {
    "avg_temp": 36.5,
    "max_temp": 37.2,
    "overheated": false
  }
}
```

### ESP32 Serial Protocol (JSON over UART)

ESP32 → Laptop (sensor data):
```json
{"type": "sensor", "temperature": 28.5, "humidity": 55, "battery": 85, "gas": 120}
```

ESP32 → Laptop (location):
```json
{"type": "location", "lat": 30.0444, "lng": 31.2357}
```

Laptop → ESP32 (commands):
```json
{"type": "command", "command": "move", "data": {"x": 0.5, "y": -0.3}}
```

### Laptop Server Processing Pipeline

```
TCP Receiver (port 9000) → Frame Queue
                                     ↘
                               Pipeline (resize + AI detect + encode)
                                     ↗
ESP32 (serial) → Sensor/Location Data
                                     ↘
                               Output Queue → Broadcaster → WS Clients
```

### Health Checks

```bash
# Laptop server
curl http://localhost:8000/health
# {"status":"ok","server_ip":"192.168.x.x","tcp_port":9000,"ws_port":8000,...}

# Pi server
curl http://raspberrypi.local:8000/health
# {"status":"ok","running":false,"hw_ok":true,"fb_sync":true}

# Pi motor server
curl http://raspberrypi.local:5000/status
# {"motors_running":false}
```

---

## Responsive & Adaptive Design

The UI is built with `flutter_screenutil` using a base design size of 393 × 852 (iPhone-like profile). All dimensions, fonts, and spacing scale proportionally across screen sizes.

```dart
// main.dart — responsive configuration
ScreenUtilInit(
  designSize: const Size(393, 852),
  minTextAdapt: true,
  splitScreenMode: true,
  child: const PhoenixApp(),
)
```

Key decisions:
- **Layout widgets** use `ScreenUtil` extensions (`.w`, `.h`, `.sp`, `.r`) for proportional sizing.
- **Bottom navigation** and **control overlays** adapt to safe areas on notched devices.
- **The map** fills available space using `Expanded` with status bars overlaid.
- **Video preview** maintains 16:9 aspect ratio with `AspectRatio` widget.
- **Motor Control Panel** and **Pi Health status** only appear when the Pi is online.

---

## Pi Server Installation (SD Card)

An automated deployment script is available at `tools/install_pi_server_to_sd.sh`:

```bash
# 1. Insert Raspberry Pi SD card into your Linux machine
# 2. Run the deployment script with sudo
sudo bash tools/install_pi_server_to_sd.sh

# 3. The script installs:
#    - pi_server/ files to /home/beso/pi_server on the rootfs
#    - systemd service (phoenix-pi-server.service) for auto-start on boot
#    - WiFi configuration (iPhone hotspot by default)
```

Edit the script to customize WiFi SSID/password, Pi hostname, or service configuration before running.

---

## Performance Optimizations

| Area | Approach |
|------|----------|
| **Video Streaming** | MJPEG-over-WebSocket with compressed JPEG frames (quality: 75); frames processed server-side before transmission |
| **State Updates** | Cubit `BlocSelector` for granular rebuilds; `Equatable` prevents unnecessary notifications |
| **Firestore Streams** | Single-document listeners (not collection scans) with server timestamps |
| **Map Rendering** | `flutter_map` with OpenStreetMap raster tiles (no WebGL overhead); polyline path uses simplified coordinate set |
| **AI Detection** | Server-side YOLO processing; `FRAME_SKIP=3` skips every 2 out of 3 frames to reduce CPU load |
| **Pi Health Polling** | 5-second interval with 3-failure tolerance avoids flaky disconnects |
| **Asset Loading** | SVG images with in-memory caching via `flutter_svg` |
| **Widget Tree** | Minimal rebuilds via `const` constructors and `BlocBuilder` granularity |
| **Disconnect Handling** | 10-second timeout timer in `DroneTrackingCubit` — avoids brief network blips triggering disconnected states |

---

## Roadmap

- [x] Firebase Authentication (email/password, Google, Apple)
- [x] Real-time drone GPS tracking with path history
- [x] Live video streaming with mode switching
- [x] AI human detection overlay
- [x] Virtual joystick drone control
- [x] Pi health monitoring and motor control
- [x] ESP32 serial communication (sensors + GPS)
- [x] Raspberry Pi server with GPIO motor control
- [x] Dual-server architecture (Pi onboard + Laptop middleware)
- [ ] YOLO model fine-tuning for aerial SAR datasets
- [ ] Offline mode with cached map tiles
- [ ] Multi-drone support (fleet management)
- [ ] Push notifications for critical detections
- [ ] Mission history replay
- [ ] Automated flight path planning
- [ ] End-to-end encryption for video stream

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit changes: `git commit -m "feat: add your feature"`
4. Push: `git push origin feat/your-feature`
5. Open a pull request.

### Guidelines

- Follow [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) and the existing feature-first structure.
- Use BLoC/Cubit for state management — no direct `setState` in feature code.
- Write immutable state classes with `Equatable`.
- Keep widgets focused — extract reusable components to feature-level widget directories.
- Run `flutter analyze` before committing.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contact

**Project Team** — Graduation Project 2026

---

<p align="center">
  Built with Flutter, Firebase, and FastAPI.
</p>
