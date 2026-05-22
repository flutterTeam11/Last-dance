# Flutter Drone Live Tracking System (Firebase + Map)

This document explains how to build a Flutter app that receives real-time GPS data from a Raspberry Pi drone and displays it live on a map.

---

# 1. Overview

The system architecture:

```
Raspberry Pi (GPS)
        ↓
Firebase Firestore (Realtime DB)
        ↓
Flutter App
        ↓
Live Map (Marker updates)
```

The Flutter app listens to Firebase changes and updates the drone position instantly.

---

# 2. Dependencies

Add these packages to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0

  flutter_map: ^8.2.1
  latlong2: ^0.9.1
```

---

# 3. Firebase Setup

1. Create Firebase project
2. Enable Firestore Database
3. Add Android/iOS app
4. Download configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

---

# 4. Initialize Firebase in Flutter

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DroneMapScreen(),
    );
  }
}
```

---

# 5. Firestore Data Structure

The Raspberry Pi writes data here:

```
drone (collection)
  └── location (document)
        lat: double
        lng: double
        timestamp: server time
```

---

# 6. Live Location Listener

This is the core logic of the app:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

LatLng dronePosition = LatLng(30.0, 31.0);

@override
void initState() {
  super.initState();

  FirebaseFirestore.instance
      .collection('drone')
      .doc('location')
      .snapshots()
      .listen((snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    setState(() {
      dronePosition = LatLng(
        data['lat'],
        data['lng'],
      );
    });
  });
}
```

---

# 7. Map UI (flutter_map)

We use OpenStreetMap tiles (free):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DroneMapScreen extends StatefulWidget {
  const DroneMapScreen({super.key});

  @override
  State<DroneMapScreen> createState() => _DroneMapScreenState();
}

class _DroneMapScreenState extends State<DroneMapScreen> {

  LatLng dronePosition = LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: dronePosition,
          initialZoom: 15,
        ),
        children: [

          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: dronePosition,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.flight,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

# 8. How It Works

1. Raspberry Pi sends GPS coordinates to Firebase
2. Firestore updates `drone/location`
3. Flutter listens in real-time using snapshots()
4. Marker updates instantly on the map

---

# 9. Optional Improvements

## 1. Smooth movement
Avoid sudden jumps by interpolating positions

## 2. Path tracking
Store history of coordinates and draw Polyline

## 3. Connection status
Show OFFLINE if no updates for X seconds

## 4. Auto center map
Keep camera focused on drone

```dart
mapController.move(dronePosition, 16);
```

---

# 10. Notes

- Requires stable internet on Flutter device
- Firebase latency ~1–2 seconds
- OpenStreetMap tiles are free but rate-limited

---

# End of File

