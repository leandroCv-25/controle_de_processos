import 'dart:convert';

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
    this.kp = 0.4,
    this.ki = 0.2,
    this.kd = 0.1,
    this.setPoint = 100,
    this.vmax = 100,
    this.isClosedLoop = 1,
  }) : _id = id;

  String get id => _id;

  String toJson() {
    final Map<String, dynamic> map = {
      "kp": double.parse(kp.toStringAsFixed(3)),
      "ki": double.parse(ki.toStringAsFixed(3)),
      "kd": double.parse(kd.toStringAsFixed(3)),
      "setpoint": setPoint,
      "vmax": vmax,
      "isClosedLoop": isClosedLoop,
    };

    return json.encode(map);
  }
}
