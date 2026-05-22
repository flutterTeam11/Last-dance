import 'drone_location.dart';
import 'drone_report.dart';
import 'drone_status.dart';

abstract class DroneRepository {
  Stream<DroneLocation> watchDroneLocation();
  Stream<DroneStatus> watchDroneStatus();
  Stream<List<DroneReport>> watchDroneReports();
  Future<void> sendCommand(String command, Map<String, dynamic> data);
}
