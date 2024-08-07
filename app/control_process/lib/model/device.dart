import 'device_state.dart';

class Device {
  final String _id;

  double kp;
  double ki;
  double kd;
  double vmax;
  double setPoint;
  int isClosedLoop;

  final List<DeviceState> states = [];

  Device({
    required id,
    this.kp = 0,
    this.ki = 0,
    this.kd = 0,
    this.setPoint = 0,
    this.vmax = 100,
    this.isClosedLoop = 0,
  }) : _id = id;

  String get id => _id;
}
