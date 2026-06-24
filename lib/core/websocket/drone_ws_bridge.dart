import 'dart:async';
import 'dart:typed_data';

import '../../features/drone/domain/drone_report.dart';
import 'ws_client.dart';

class DroneWsBridge {
  final WsClient _client;

  DroneWsBridge(this._client);

  final _detectionBoxesController =
      StreamController<List<DetectionBox>>.broadcast();
  final _videoFrameController = StreamController<Uint8List>.broadcast();
  final _reportController = StreamController<DroneReport>.broadcast();

  Stream<List<DetectionBox>> get detectionBoxes =>
      _detectionBoxesController.stream;
  Stream<Uint8List> get videoFrame => _videoFrameController.stream;
  Stream<DroneReport> get reportStream => _reportController.stream;

  StreamSubscription? _detectionSub;
  StreamSubscription? _videoSub;

  void start() {
    _videoSub = _client.videoStream.listen((frame) {
      _videoFrameController.add(frame);
    });

    _detectionSub = _client.detectionStream.listen(_onDetection);
  }

  void stop() {
    _videoSub?.cancel();
    _detectionSub?.cancel();
  }

  void _onDetection(Map<String, dynamic> data) {
    final detections =
        (data['detections'] as List<dynamic>?)?.map((d) {
          final map = d as Map<String, dynamic>;
          return DetectionBox(
            label: map['label'] as String? ?? 'unknown',
            confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
            x: (map['x'] as num?)?.toDouble() ?? 0,
            y: (map['y'] as num?)?.toDouble() ?? 0,
            w: (map['w'] as num?)?.toDouble() ?? 0,
            h: (map['h'] as num?)?.toDouble() ?? 0,
          );
        }).toList() ??
        [];

    _detectionBoxesController.add(detections);

    final thermal = data['thermal'] as Map<String, dynamic>?;
    if (thermal != null) {
      final avgTemp = (thermal['avg_temp'] as num?)?.toDouble();
      if (avgTemp != null && avgTemp > 40) {
        _reportController.add(
          DroneReport(
            type: ReportType.humanDetected,
            message: 'Heat signature detected: ${avgTemp.toStringAsFixed(1)}°C',
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }

  bool sendCommand(String type, [Map<String, dynamic>? data]) {
    return _client.sendCommand(type, data);
  }

  void dispose() {
    stop();
    _detectionBoxesController.close();
    _videoFrameController.close();
    _reportController.close();
  }
}

class DetectionBox {
  final String label;
  final double confidence;
  final double x;
  final double y;
  final double w;
  final double h;

  const DetectionBox({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}
