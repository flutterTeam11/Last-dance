import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/drone_location.dart';
import '../domain/drone_report.dart';
import '../domain/drone_repository.dart';
import '../domain/drone_status.dart';

class DroneRepositoryImpl implements DroneRepository {
  final FirebaseFirestore _firestore;

  DroneRepositoryImpl({required this._firestore});

  @override
  Stream<DroneLocation> watchDroneLocation() {
    return _firestore.collection('drone').doc('location').snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) {
        return const DroneLocation(lat: 30.0444, lng: 31.2357);
      }
      return DroneLocation(
        lat: (data['lat'] as num).toDouble(),
        lng: (data['lng'] as num).toDouble(),
        timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      );
    });
  }

  @override
  Stream<DroneStatus> watchDroneStatus() {
    return _firestore.collection('drone').doc('status').snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) {
        return const DroneStatus.initial();
      }
      return DroneStatus(
        battery: (data['battery'] as num?)?.toInt() ?? 0,
        humanCount: (data['humanCount'] as num?)?.toInt() ?? 0,
        height: (data['height'] as num?)?.toDouble() ?? 0,
        speed: (data['speed'] as num?)?.toDouble() ?? 0,
        isConnected: data['isConnected'] as bool? ?? false,
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
      );
    });
  }

  @override
  Stream<List<DroneReport>> watchDroneReports() {
    return _firestore
        .collection('drone')
        .doc('reports')
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return DroneReport(
              type: _parseReportType(data['type'] as String? ?? ''),
              message: data['message'] as String? ?? '',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  @override
  Future<void> sendCommand(String command, Map<String, dynamic> data) async {
    await _firestore.collection('drone').doc('commands').set({
      'command': command,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  ReportType _parseReportType(String type) {
    switch (type) {
      case 'human_detected':
        return ReportType.humanDetected;
      case 'system_overheated':
        return ReportType.systemOverheated;
      case 'mission_complete':
        return ReportType.missionComplete;
      default:
        return ReportType.humanDetected;
    }
  }
}
