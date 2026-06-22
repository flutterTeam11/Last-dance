import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'connection_status.dart';

class WsClient {
  final String _baseUrl;

  WebSocket? _videoSocket;
  WebSocket? _detectionSocket;
  WebSocket? _commandSocket;

  final _videoStreamController = StreamController<Uint8List>.broadcast();
  final _detectionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<Uint8List> get videoStream => _videoStreamController.stream;
  Stream<Map<String, dynamic>> get detectionStream =>
      _detectionStreamController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus _status = const ConnectionDisconnected();
  ConnectionStatus get currentStatus => _status;

  WsClient({required this._baseUrl});

  Future<void> connect() async {
    final results = await Future.wait([
      _connectVideo(),
      _connectDetection(),
      _connectCommand(),
    ]);
    if (results.any((r) => r)) {
      _status = ConnectionConnected(_baseUrl);
      _statusController.add(_status);
    }
  }

  Future<bool> _connectVideo() async {
    try {
      final ws = await WebSocket.connect('$_baseUrl/ws/video');
      _videoSocket = ws;
      ws.listen(
        (data) {
          if (data is List<int>) {
            _videoStreamController.add(Uint8List.fromList(data));
          }
        },
        onError: (_) {
          _videoSocket = null;
          _emitDisconnected();
        },
        onDone: () {
          _videoSocket = null;
          _emitDisconnected();
        },
        cancelOnError: false,
      );
      return true;
    } catch (_) {
      _emitDisconnected();
      return false;
    }
  }

  Future<bool> _connectDetection() async {
    try {
      final ws = await WebSocket.connect('$_baseUrl/ws/detections');
      _detectionSocket = ws;
      ws.listen(
        (data) {
          if (data is String) {
            final json = jsonDecode(data) as Map<String, dynamic>;
            _detectionStreamController.add(json);
          }
        },
        onError: (_) => _detectionSocket = null,
        onDone: () => _detectionSocket = null,
        cancelOnError: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _connectCommand() async {
    try {
      final ws = await WebSocket.connect('$_baseUrl/ws/commands');
      _commandSocket = ws;
      ws.listen(
        (data) {},
        onError: (_) => _commandSocket = null,
        onDone: () => _commandSocket = null,
        cancelOnError: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void _emitDisconnected() {
    _status = const ConnectionDisconnected();
    _statusController.add(_status);
  }

  void sendCommand(String type, [Map<String, dynamic>? data]) {
    if (_commandSocket == null) return;
    final msg = jsonEncode({
      'type': type,
      'data': data ?? {},
    });
    _commandSocket!.add(msg);
  }

  Future<void> disconnect() async {
    await Future.wait([
      Future(() => _videoSocket?.close()),
      Future(() => _detectionSocket?.close()),
      Future(() => _commandSocket?.close()),
    ]);
    _emitDisconnected();
  }

  void dispose() {
    disconnect();
    _videoStreamController.close();
    _detectionStreamController.close();
    _statusController.close();
  }
}
