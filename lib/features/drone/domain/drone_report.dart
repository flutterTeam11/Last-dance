import 'package:equatable/equatable.dart';

enum ReportType { humanDetected, systemOverheated, missionComplete }

class DroneReport extends Equatable {
  final ReportType type;
  final String message;
  final DateTime timestamp;

  const DroneReport({
    required this.type,
    required this.message,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  @override
  List<Object?> get props => [type, message, timestamp];
}
