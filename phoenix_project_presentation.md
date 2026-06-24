---
marp: true
theme: default
paginate: true
title: Phoenix Drone Search & Rescue System
---

# Phoenix
## Drone Search & Rescue System

Real-time ground control station for AI-assisted drone missions.

**Graduation Project Presentation**

![w:140](assets/images/splash/Phoenix.svg)

<!-- Speaker note: عرف المشروع في جملة واحدة: نظام يساعد فرق الإنقاذ تتابع درون لحظيا بالفيديو، الخريطة، والذكاء الاصطناعي. -->

---

# Problem

في حالات الكوارث والبحث والإنقاذ، فرق الإنقاذ بتواجه 3 مشاكل أساسية:

- صعوبة الوصول السريع للأماكن الخطرة
- ضعف الرؤية الميدانية واتخاذ القرار
- تأخير اكتشاف الضحايا أو نقاط الحرارة المهمة

<!-- Speaker note: ركز إن المشكلة مش "درون" فقط، المشكلة هي سرعة القرار في بيئة خطرة. -->

---

# Main Goal

بناء نظام عملي يساعد فريق الإنقاذ على:

- متابعة موقع الدرون Live على الخريطة
- مشاهدة Video Feed لحظي
- عرض AI detections فوق الفيديو
- مراقبة Telemetry مثل البطارية والسرعة والارتفاع
- إرسال أوامر للدرون من واجهة الموبايل

<!-- Speaker note: دي أهداف قابلة للقياس وليست مجرد features شكلية. -->

---

# High-Level Architecture

```text
Raspberry Pi Drone
  | GPS + Telemetry -> Firebase
  | Video Frames    -> TCP
  v
Laptop Server (FastAPI)
  | AI Processing
  | WebSocket Broadcast
  v
Flutter App
  | Live Video + Map + Controls
```

<!-- Speaker note: وضح إن Firebase مخصص للبيانات الخفيفة realtime، بينما الفيديو ماشي TCP/WebSocket لأنه أكبر وأسرع. -->

---

# Hardware Layer

دور الـ Raspberry Pi على الدرون:

- قراءة GPS location
- إرسال Telemetry مثل battery, height, speed, temperature
- التقاط video frames من الكاميرا
- إرسال الفيديو للـ laptop server عبر TCP

<!-- Speaker note: لو الهاردوير مش كله متاح وقت العرض، قول إن software interface جاهز للتكامل. -->

---

# Backend Layer

الـ laptop server مبني بـ **FastAPI** ويعمل كـ middleware:

- يستقبل frames من الدرون عبر TCP
- يشغل AI detection pipeline
- يبث الفيديو للـ app عبر WebSocket
- يبث detection JSON منفصل
- يستقبل commands من الموبايل

---

# Server Pipeline

```text
TCP Receiver
  -> Frame Queue
  -> Resize / Preprocess
  -> AI Detector
  -> Draw Bounding Boxes
  -> JPEG Encode
  -> WebSocket Broadcast
```

النظام يستخدم queues لتقليل blocking وتحسين التعامل مع real-time data.

---

# AI Integration

طبقة الـ AI مصممة لتدعم:

- YOLO-based human detection
- Bounding boxes + confidence score
- Thermal analysis placeholder
- Dummy detector fallback أثناء التطوير

هذا يجعل النظام قابل للتشغيل حتى قبل تسليم موديل الـ AI النهائي.

<!-- Speaker note: كن صريح: لو الموديل النهائي ليس مدمج بالكامل، قل إن integration point جاهز ومختبر ببديل. -->

---

# Real-Time Channels

استخدمنا WebSocket channels منفصلة:

- `/ws/video` لإرسال JPEG frames
- `/ws/detections` لإرسال detection JSON
- `/ws/commands` لاستقبال أوامر التحكم
- `/health` لمراقبة حالة السيرفر

فصل القنوات يجعل debugging والتوسع أسهل.

---

# Mobile App

تطبيق Flutter هو واجهة التحكم الأساسية:

- Dashboard للمتابعة السريعة
- Live video preview
- Fullscreen video mode
- Map tracking
- Reports and alerts
- Mission actions
- Authentication flow

---

# Flutter Architecture

استخدمنا **Feature-First Clean Architecture**:

```text
lib/
  core/
    di, router, theme, websocket, utils
  features/
    auth/
    drone/
    onboarding/
    splash/
```

كل feature مقسمة إلى data, domain, presentation.

إدارة الحالة مبنية على **BLoC / Cubit**:

- `DroneTrackingCubit`
- `DroneStatusCubit`
- `VideoFeedCubit`
- `AuthCubit`

هذا فصل الـ UI عن business logic وخلى التطبيق أسهل في الاختبار والتعديل.

---

# Firebase Usage

Firebase مستخدم في:

- Authentication
- Firestore live location stream
- Drone status stream
- Reports stream
- User document management
- Commands backup path

الـ app يستقبل تحديثات Firestore مباشرة باستخدام snapshots.

---

# Live Map Tracking

الخريطة مبنية بـ:

- `flutter_map`
- OpenStreetMap tiles
- `latlong2`
- Path history
- Disconnect timer
- Last known location handling

<!-- Speaker note: قول إن الخريطة لا تعرض نقطة فقط، لكنها تحتفظ بمسار الحركة وتتعامل مع الانقطاع. -->

---

# Video & Detection UI

الـ video system يدعم:

- Normal mode
- Thermal mode
- AI overlay mode
- Fullscreen immersive mode
- Real-time detection boxes
- HUD-style rescue interface

الـ frame يأتي كـ bytes من WebSocket ويتعرض داخل Flutter.

---

# Drone Control

واجهة التحكم تشمل:

- Virtual joystick
- Movement commands
- Start mission command
- Stop/neutral command عند ترك joystick
- قابلية إضافة Land / Return commands

الأوامر تُرسل من Flutter إلى server عبر WebSocket.

---

# Reports & Alerts

النظام يعرض تقارير لحظية مثل:

- Human detected
- Heat signature detected
- System overheated
- Mission complete

التقارير تساعد فريق الإنقاذ يراجع الأحداث بدون متابعة الفيديو طوال الوقت.

---

# Authentication & UX

تجربة المستخدم تشمل:

- Splash screen
- Onboarding flow
- Email/password sign up and sign in
- Google sign in
- Password reset
- OTP/new password screens

الواجهة Dark-first ومناسبة للاستخدام الميداني.

---

# Tech Stack

| Layer | Technologies |
|---|---|
| Mobile | Flutter, Dart, BLoC/Cubit |
| Backend | Python, FastAPI, Uvicorn |
| Real-time | WebSocket, TCP |
| Cloud | Firebase Auth, Firestore |
| Maps | flutter_map, OpenStreetMap |
| AI/Video | OpenCV, NumPy, YOLO integration point |

---

# What Is Completed

- Flutter app structure and UI
- Auth flow
- Firebase location/status/reports streams
- Map tracking
- FastAPI server
- TCP video receiver
- WebSocket video/detection/command channels
- Flutter WebSocket client
- AI overlay integration path
- Virtual joystick command sending

---

# Current Limitations

- Real drone hardware integration depends on Raspberry Pi final scripts
- Final AI model needs to replace the dummy fallback
- PLAN MISSION button still needs final workflow
- Full end-to-end test requires hardware, server, and phone on the same network

<!-- Speaker note: عرض القيود بشكل مهني يعطي ثقة، خصوصا لو قلت معها next steps. -->

---

# Demo Scenario

1. User signs in
2. App opens drone dashboard
3. Server receives video frames
4. App displays live feed
5. AI overlay shows detections
6. Map tracks drone GPS location
7. User opens fullscreen video
8. Joystick sends control commands

# Future Work

- Integrate final YOLO model
- Add real Raspberry Pi video sender script
- Complete mission planning workflow
- Add command acknowledgement
- Add recording and mission history
- Improve offline/reconnect handling
- Add role-based access for rescue teams

---

# Conclusion

Phoenix يقدم prototype متكامل لنظام إنقاذ ذكي:

- Real-time tracking
- Live video streaming
- AI-assisted detection
- Field-friendly mobile interface
- Scalable architecture ready for full hardware integration

**Thank You**

<!-- Speaker note: اختم بأن المشروع قابل للتطوير من prototype إلى نظام ميداني أكثر اكتمالا. -->
