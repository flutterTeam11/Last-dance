# Phoenix Drone System - خطة مشروع التخرج

---

## 1. توزيع الأدوار

```
┌────────────────────────────────────────────────────────────┐
│                   تيم الـ Hardware                          │
│  (Raspberry Pi + GPS + Cameras + Firebase scripts)         │
│  ← المفروض يسلموا Pi شغال بيبعث data على Firebase          │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────────┐
│                   أنت / فريقك (Integration)                │
│                                                           │
│  1. Laptop Server (FastAPI) ← المسؤولية الأساسية          │
│  2. Flutter App Updates ← وصلها بالـ server               │
│  3. Integration ← ربط كل حاجة ببعض                        │
│  4. Backup ← لو الـ HW scripts ناقصة تكملها               │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────────┐
│                   تيم الـ AI                               │
│  (YOLO model + thermal analysis + inference script)        │
│  ← المفروض يسلموا script يستقبل video ويخرج detections    │
└────────────────────────────────────────────────────────────┘
```

**الخلاصة:**
- الـ Hardware team = Pi يقرأ GPS ويكتب في Firebase + يصور فيديو ويبعت TCP
- الـ AI team = Script ياخد frame ويطلع detection boxes
- **أنت** = تبني الـ Laptop server اللي يربط دول + تعدل Flutter app تستقبل الـ video

---

## 2. تحليل الوضع الحالي

### ✅ خلص في Flutter (40 ملف)

#### Data Layer
| المكون | الحالة |
|--------|--------|
| Firebase initialization | ✅ Android, iOS, Web, macOS, Windows |
| `DroneRepositoryImpl` (Firestore) | ✅ location, status, reports, commands streams |
| `DroneLocation` model | ✅ lat, lng, timestamp |
| `DroneStatus` model | ✅ battery, humanCount, height, speed, isConnected |
| `DroneReport` + `ReportType` enum | ✅ humanDetected, systemOverheated, missionComplete |
| Service Locator (`getIt`) | ✅ كل الـ dependencies مسجلة |

#### Screens
| المكون | الحالة |
|--------|--------|
| `DroneMainShell` (Bottom Nav) | ✅ Home + Map tabs |
| `DroneHomeScreen` | ✅ Video preview, status, mode toggle, reports |
| `DroneMapScreen` | ✅ Map + status bar + mission card |
| `DroneFullscreenVideoScreen` | ✅ Immersive + joystick + stats |

#### Cubits
| المكون | الحالة |
|--------|--------|
| `DroneTrackingCubit` | ✅ Location + path history + disconnect timer |
| `DroneStatusCubit` | ✅ Status + reports streams |
| `VideoFeedCubit` | ✅ Normal / Thermal / Overlay modes |

#### Widgets (25)
| المكون | الحالة |
|--------|--------|
| `DroneMapView` + `DroneMapContent` + `MapMarkers` | ✅ flutter_map مع OpenStreetMap |
| `VirtualJoystick` + `JoystickPainter` | ✅ Touch joystick UI (مش متصل بحاجة) |
| `VideoPreviewCard` + `VideoFeedBackground` + `SimulatedFeed` | ✅ مازال simulated |
| `AiDetectionOverlay` | ✅ HUD مع reticle (hardcoded حالياً) |
| `ReportsSection` + `ReportTile` | ✅ Reports list |
| `ConnectionStatusBar` + `DroneStatsBar` + `DroneStatItem` | ✅ Stats UI |
| `DroneCircularIndicator` + `DroneStatusCard` | ✅ Status indicators |
| `StartMissionButton` + `MissionButton` + `MissionStatusCard` | ✅ Buttons (مش شغالة) |
| `DroneBottomNavBar` + `MapScreenHeader` | ✅ Navigation + header |
| `VideoModeToggle` + `VideoBackButton` | ✅ Mode switch |

#### Routing
| المسار | الحالة |
|--------|--------|
| Splash → Onboarding → Auth → Home | ✅ كامل |

---

### ❌ محتاج شغل (اللي عليك)

#### 1. Laptop Server (FastAPI) — ✅ خلص
| المهمة | الحالة |
|--------|--------|
| FastAPI base + WebSocket manager | ✅ |
| TCP receiver (يستقبل فيديو من Pi) | ✅ |
| WebSocket video broadcast (يبعت للموبايل) | ✅ |
| WebSocket commands (يستقبل أوامر من الموبايل) | ✅ |
| دمج AI inference script (من تيم AI) | ✅ (placeholder جاهز) |
| دمج thermal analysis (من تيم AI) | ✅ (placeholder جاهز) |

#### 2. Flutter App — تعديلات
| المهمة | Priority |
|--------|----------|
| إضافة `web_socket_channel` package | 🔴 عالي |
| WebSocket client service (يتصل بالسيرفر) | 🔴 عالي |
| استبدال `SimulatedFeed` بـ video stream حقيقي | 🔴 عالي |
| ربط `AiDetectionOverlay` بـ detection الفعلي | 🟡 متوسط |
| ربط `VirtualJoystick` بـ WebSocket commands | 🟡 متوسط |
| تشغيل `PLAN MISSION` + `START MISSION` buttons | 🟡 متوسط |
| Fix: Map status bar (TEMP/SIGNAL نفس القيمة) | 🟢 سهل |
| Fix: Error handling في الـ cubits | 🟡 متوسط |
| Fix: Redundant subscription في MapScreen | 🟢 سهل |

#### 3. Raspberry Pi (Backup — لو HW team مقصر)
| المهمة | Priority |
|--------|----------|
| التأكد من GPS → Firebase script شغال | 🟡 متوسط |
| كتابة video TCP sender (لو مش موجود) | 🟡 متوسط |
| كتابة thermal camera streamer (لو مش موجود) | 🟢 منخفض |
| اختبار الـ Pi كامل مع اللاب | 🟡 متوسط |

#### 4. Integration
| المهمة | Priority |
|--------|----------|
| Pi → Laptop TCP : اتصال الفيديو | 🔴 عالي |
| Laptop → Mobile WebSocket : بث الفيديو | 🔴 عالي |
| Mobile → Laptop → Firebase → Pi : الأوامر | 🟡 متوسط |
| GPS → Firebase → Flutter Map : التتبع | ✅ شغال أصلاً |

---

## 3. Architecture الكامل (اللي هنركبه)

```
┌──────────────────────────────────────────────────────────────────┐
│  Raspberry Pi (Onboard) — Hardware Team                          │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐   │
│  │ GPS (NEO-6M) │    │   Camera     │    │  Thermal Camera  │   │
│  │ → Firebase   │    │   (CSI)      │    │  (I2C)           │   │
│  └──────┬───────┘    └──────┬───────┘    └────────┬─────────┘   │
│         │                   │                      │            │
│         ▼                   ▼                      ▼            │
│  ┌──────────────┐    ┌─────────────────────────────────────┐    │
│  │ Firebase SDK │    │  Python: Video Streaming (TCP)      │    │
│  │ (GPS data)   │    │  picamera2 → JPEG → socket.send()   │    │
│  └──────┬───────┘    └────────────────┬────────────────────┘    │
└─────────┼────────────────────────────┼──────────────────────────┘
          │                            │
          │ WiFi                       │ WiFi (Same network)
          ▼                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  Laptop (Local Server) — أنت                                      │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                   FastAPI Server                          │    │
│  │                                                          │    │
│  │  ┌──────────────┐                                        │    │
│  │  │ TCP Receiver  │◄── JPEG frames from Pi                │    │
│  │  │ (asyncio)     │                                        │    │
│  │  └──────┬───────┘                                        │    │
│  │         │                                                 │    │
│  │         ▼                                                 │    │
│  │  ┌──────────────┐                                        │    │
│  │  │  AI Detector  │◄── script من تيم AI                    │    │
│  │  │ (YOLO +       │    (ياخد frame ويرجع boxes)           │    │
│  │  │  Thermal)     │                                        │    │
│  │  └──────┬───────┘                                        │    │
│  │         │                                                 │    │
│  │         ▼                                                 │    │
│  │  ┌──────────────────────┐                                │    │
│  │  │  WebSocket Manager   │──► /ws/video (processed)       │    │
│  │  │  (broadcast)         │──► /ws/detections (JSON)       │    │
│  │  │                      │◄── /ws/commands (من الموبايل)   │    │
│  │  └──────────────────────┘                                │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────┬───────────────────────────────────┘
                               │
                               │ LAN (Same WiFi)
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│  Flutter App (Mobile) — أنت                                      │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  ┌──────────────────────────────────────────────────┐    │    │
│  │  │  WebSocket Client (جديد)                         │    │    │
│  │  │  ├── يستقبل video frames → Image.memory يعرضهم    │    │    │
│  │  │  ├── يستقبل detections JSON → AiDetectionOverlay  │    │    │
│  │  │  └── يبعت joystick commands → /ws/commands        │    │    │
│  │  └──────────────────────────────────────────────────┘    │    │
│  │                                                          │    │
│  │  ┌────────────────┐  ┌──────────────┐  ┌────────────┐   │    │
│  │  │ Live Map       │  │  Video Feed  │  │ AI Overlay │   │    │
│  │  │ (Firebase GPS) │  │  (WebSocket) │  │ (Real Data)│   │    │
│  │  └────────────────┘  └──────────────┘  └────────────┘   │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4. الخطة التفصيلية (Phase by Phase)

### Phase 1: Laptop Server (FastAPI) — ✅ DONE
**🕒 4-5 أيام — خلص 30 مارس 2026 (8 files)**

```
laptop_server/
├── main.py                     # FastAPI + lifespan + 4 WS endpoints
├── config.py                   # All config (ports, quality, frame size)
├── requirements.txt
├── receivers/
│   ├── __init__.py
│   └── tcp_receiver.py         # Async TCP → length-prefixed JPEG → queue
├── broadcast/
│   ├── __init__.py
│   └── ws_manager.py           # ConnectionManager (video/detection/command)
└── ai_integration/
    ├── __init__.py
    ├── detector.py             # Detector class + dummy YOLO + draw boxes + thermal
    └── pipeline.py             # Queue → resize → detect → encode → output
```

**التفاصيل اللي اتعملت:**
| المكون | الوصف |
|--------|-------|
| `main.py` | FastAPI مع `lifespan` يدير TCP + pipeline + broadcaster |
| `GET /health` | Server status + client counts + queue size |
| `WS /ws/video` | WebSocket يبث JPEG frames لكل الـ mobile clients |
| `WS /ws/detections` | WebSocket يبث JSON detections |
| `WS /ws/commands` | WebSocket يستقبل أوامر من الموبايل |
| `tcp_receiver.py` | Async TCP: يقرا 4 bytes size → N bytes JPEG → cv2 → queue |
| `ws_manager.py` | ConnectionManager مع broadcast_video و broadcast_detections |
| `detector.py` | يستدعي AI script لو موجود، لو لا: dummy detections للاختبار |
| `pipeline.py` | Frame queue → resize → detect → draw → encode → output queue |
| `_broadcaster()` | Background task ياخد من output queue ويوزع على كل الـ WS clients |

**ملف checkpoint:** `server_progress_checkpoint.md`

---

### Phase 2: Flutter App Updates
**🕒 3-4 أيام — مسؤوليتك كاملة**

#### Day 1-2: WebSocket Client
**1. إضافة package:**
```yaml
dependencies:
  web_socket_channel: ^3.0.1
```

**2. إنشاء `lib/core/websocket/`:**
```
lib/core/websocket/
├── ws_client.dart           # WebSocket client service
├── ws_video_receiver.dart   # يستقبل video frames
├── ws_command_sender.dart   # يبعت أوامر
└── ws_detection_handler.dart # يستقبل detections
```

**3. `ws_client.dart`:**
```dart
class WsClient {
  WebSocketChannel? _channel;
  final _videoStream = StreamController<Uint8List>.broadcast();
  final _detectionStream = StreamController<String>.broadcast();
  
  Future<void> connect(String url);    // ws://192.168.1.100:8000/ws/video
  void sendCommand(Map<String, dynamic> cmd);
  void disconnect();
}
```

**4. Service Locator:**
```dart
getIt.registerLazySingleton<WsClient>(() => WsClient());
```

**5. Video Screen: استبدال `SimulatedFeed`:**
- `VideoFeedBackground` ياخد frames من `WsClient.videoStream`
- `Image.memory(frame)` بدل `SimulatedFeed`

#### Day 3: AI Detection + Joystick
**1. AiDetectionOverlay — real data:**
- يستقبل JSON من `WsClient.detectionStream`
- يرسم bounding boxes الحقيقية
- يعرض confidence scores الفعلي

**2. VirtualJoystick — connect:**
```dart
void onDirectionChanged(double x, double y) {
  getIt<WsClient>().sendCommand({
    'type': 'move',
    'data': {'x': x, 'y': y},
  });
}
```

#### Day 4: Fixes + Buttons
1. **Bug fixes:**
   - `drone_map_status_bar.dart`: TEMP و SIGNAL يقرأوا القيم الصح
   - `drone_tracking_cubit.dart`: إضافة try-catch و logging
   - `drone_map_screen.dart`: إزالة `startTracking()` الإضافية
2. **Mission buttons:**
   - `PLAN MISSION`: يفتح modal (حتى لو empty)
   - `START MISSION`: يبعت command عبر WebSocket

---

### Phase 3: Raspberry Pi (Backup — لو HW team محتاج مساعدة)
**🕒 2-3 أيام — لو الـ HW scripts مش كاملة**

**شوف الـ Pi سلمك إيه بالظبط، ونقص:**

| لو ناقص | هتعمل إيه |
|---------|-----------|
| GPS script | استخدم الـ Python code من `raspberry_pi_drone_gps_firebase_integration.md` — جاهز |
| Video sender | اكتب `video_streamer.py` — picamera2 → JPEG → TCP |
| Thermal sender | اكتب `thermal_streamer.py` — MLX90640 → numpy → TCP (أو استخدم `adafruit_mlx90640`) |
| Command listener | اكتب `command_listener.py` — يستمع على Firebase `drone/commands` |

---

### Phase 4: Integration + Testing
**🕒 2-3 أيام**

#### اختبار الـ Flow الكامل:
```
1. شغل الـ FastAPI server على اللاب
2. شغل الـ Pi scripts (GPS + video)
3. افتح Flutter app على الموبايل (نفس WiFi)
4. اتأكد:
   - [ ] الخريطة بتظهر موقع الدرون (GPS → Firebase → Map)
   - [ ] الفيديو بيظهر على الشاشة (Pi → TCP → Laptop → WS → Mobile)
   - [ ] AI detection شغال (boxes بتظهر على الفيديو)
   - [ ] الـ joystick يبعت أوامر (والـ Pi يستقبلها)
   - [ ] Mission buttons شغالة
```

#### Performance:
- قيس الـ latency: Pi → Mobile
- ضبط JPEG quality (70-80 للسرعة)
- اتأكد إن WebSocket ما بيفصلش

#### Demo Prep:
- جهز network (WiFi router واحد)
- اعرف IP الـ laptop (static preferred)
- اختبر كل حاجة قبل العرض

---

## 5. الـ Dependencies (المطلوب)

### Flutter (فاضل تضيفه)
| Package | ليه؟ |
|---------|------|
| `web_socket_channel: ^3.0.1` | WebSocket client للموبايل |

### Python — Laptop Server
```txt
# requirements.txt
fastapi==0.115.0
uvicorn[standard]==0.30.0
opencv-python==4.10.0
numpy==1.26.0
Pillow==10.4.0
websockets==13.0
```

### Python — Raspberry Pi (لو HW team مقصر)
```txt
# pi_requirements.txt
firebase-admin==6.5.0
pyserial==3.5
pynmea2==1.18.0
opencv-python==4.10.0
numpy==1.26.0
picamera2==0.3.0
adafruit-circuitpython-mlx90640==1.3.0  # لو MLX90640
```

---

## 6. هيكل الملفات النهائي (بعد ما نخلص)

```
graduatio_project/
├── lib/
│   ├── core/
│   │   ├── di/
│   │   │   └── service_locator.dart      # + WsClient registration
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   ├── websocket/                    # 🔴 جديد
│   │   │   ├── ws_client.dart
│   │   │   ├── ws_video_receiver.dart
│   │   │   ├── ws_command_sender.dart
│   │   │   └── ws_detection_handler.dart
│   │   └── ...
│   ├── features/
│   │   └── drone/
│   │       ├── data/                     # زي ما هو
│   │       ├── domain/                   # زي ما هو
│   │       └── presentation/
│   │           ├── cubit/                # + error handling
│   │           ├── screens/              # + fixes
│   │           └── widgets/              # + WebSocket integration
│   ├── firebase_options.dart
│   └── main.dart
│
├── laptop_server/                        # 🔴 جديد (على اللاب مش هنا)
│   ├── main.py
│   ├── config.py
│   ├── requirements.txt
│   ├── receivers/
│   │   └── tcp_receiver.py
│   ├── broadcast/
│   │   └── ws_manager.py
│   └── ai_integration/
│       └── detector.py
│
├── raspberry_pi/                         # 🔴 جديد (على الـ Pi مش هنا)
│   ├── main.py
│   ├── gps_tracker.py
│   ├── video_streamer.py
│   ├── thermal_streamer.py
│   └── command_listener.py
│
├── pubspec.yaml
├── flutter_drone_live_tracking_firebase_map.md
├── raspberry_pi_drone_gps_firebase_integration.md
└── graduation_project_plan.md
```

---

## 7. الـ Timeline (على أساس full time)

```
الأسبوع 1: الـ Server
  Day 1-2:   FastAPI base + TCP receiver + WS manager
  Day 3-4:   AI integration (مع script تيم AI)
  Day 5:     Commands flow + اختبار السيرفر

الأسبوع 2: الـ Flutter + الـ Pi
  Day 1-2:   WebSocket client في Flutter
  Day 3:     AI overlay + Joystick commands
  Day 4:     Fixes + Buttons + Backup Pi scripts
  Day 5:     Backup Pi (لو محتاج)

الأسبوع 3: Integration + Demo
  Day 1-2:   End-to-end testing
  Day 3:     Performance + Bug fixes
  Day 4-5:   Demo preparation
```

---

## 8. ملخص: إيه اللي عليك بالظبط؟

### 🔴 Priority 1 (اعمله الأول)
1. **Laptop Server (FastAPI)** — ✅ Done (8 files, checkpoint موجود)
2. **Flutter WebSocket package** — `web_socket_channel` + `WsClient` service
3. **استبدال simulated video** بـ real WebSocket stream

### 🟡 Priority 2 (بعد ما الأول يشتغل)
4. **AI overlay real data** — ربط detection JSON بالـ UI
5. **Virtual joystick commands** — يبعت أوامر للـ server
6. **Mission buttons** — يبعتوا أوامر

### 🟢 Priority 3 (في الآخر)
7. **Bug fixes** — status bar, error handling, redundant subscription
8. **Backup Pi scripts** — لو HW team مقصر

---

## 9. أول خطوة؟ 🚀

لما تبقى جاهز تبدأ، أول حاجة هنعملها:

1. **ننشئ مجلد `laptop_server/`** في المشروع
2. **نكتب `main.py`** — FastAPI مع WebSocket endpoints فاضية
3. **نكتب `tcp_receiver.py`** — يستقبل frames
4. **نكتب `ws_manager.py`** — يدير الـ connections
5. **نختبر السيرفر** — حتى من غير Pi (بـ test script)

كده يبقى الـ server backbone جاهز ونبدأ نركب عليه باقي القطع.

---

## End of Plan
