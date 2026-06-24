# Phoenix Presentation Q&A

## 1. Why did you use Firebase and WebSocket together?

Firebase is better for light real-time data such as GPS, telemetry, reports, and authentication. WebSocket is better for high-frequency video frames and AI detection messages because it keeps a direct live connection between the server and the app.

## 2. Why is there a laptop server instead of sending everything directly to the phone?

The laptop server reduces processing load on the phone, receives TCP video from the drone, runs AI processing, and broadcasts processed data to one or more clients. It also makes debugging and integration easier during development.

## 3. What happens if the AI model is not ready?

The system has a dummy detector fallback. This keeps the full pipeline working: video input, processing, detection output, and UI overlay. When the final YOLO model is ready, it can replace the fallback through the existing detector interface.

## 4. How is the drone location updated?

The Raspberry Pi writes location data to Firestore. The Flutter app listens to Firestore snapshots, so the map marker and path history update automatically whenever new GPS data arrives.

## 5. How does the video stream reach the app?

The drone sends JPEG frames to the laptop server through TCP. The server decodes and processes frames, then sends JPEG bytes to the Flutter app through `/ws/video`.

## 6. How are detections displayed?

The server sends detection JSON through `/ws/detections`. Flutter parses the bounding boxes and renders them over the video feed using the AI overlay widget.

## 7. How are commands sent to the drone?

The virtual joystick sends movement commands from Flutter to the server through `/ws/commands`. The server currently receives and logs the commands, and the next integration step is forwarding them to the drone control layer.

## 8. What are the strongest technical parts of the project?

- Full real-time architecture
- Clean Flutter structure with Cubit state management
- FastAPI middleware with TCP and WebSocket channels
- Firebase integration for auth, status, reports, and GPS
- AI-ready processing pipeline

## 9. What is not fully complete yet?

- Final hardware end-to-end test
- Final YOLO model integration
- Complete mission planning workflow
- Command acknowledgement from drone back to app

## 10. How can the project be improved later?

The project can add mission recording, multi-user team access, offline caching, better reconnect handling, final thermal camera integration, and real drone command acknowledgement.

