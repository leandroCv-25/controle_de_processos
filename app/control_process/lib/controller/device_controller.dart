import 'dart:convert';

import 'package:control_process/model/device_state.dart';
import 'package:flutter/foundation.dart';

import '../model/device.dart';
import '../services/mqtt_service.dart';

class DeviceController extends ChangeNotifier {
  final Device _device;
  MqttService? _mqttService;

  DeviceController({required device}) : _device = device;

  update(MqttService mqttService) {
    if (_mqttService == null) {
      mqttService.subscribe(topicDeviceData);
    }
    _mqttService = mqttService;

    if (_mqttService != null &&
        !_mqttService!.hasError &&
        _mqttService!.hasData) {
      Map<String, String> data = _mqttService!.data.last;
      if (data.containsKey("topic") && data['topic'] == topicDeviceData) {
        final statesDecoded =
            json.decode(data['data']!) as Map<String, dynamic>?;
        _setStates(
          DeviceState(
            error: statesDecoded!['error'],
            output: statesDecoded['output'],
            position: statesDecoded['position'],
            speed: statesDecoded['speed'],
          ),
        );
        _mqttService!.clearData(data);
      }
    }
  }

  String get deviceId => _device.id;
  String get topicDeviceData => "/$deviceId/data";

  String _error = "";
  bool get isThereError => _error.isNotEmpty;
  String get error => _error;
  set error(String? error) {
    if (error == null) {
      _error = error!;
    } else {
      _error = "";
    }
    notifyListeners();
  }

  double get kp => _device.kp;
  set kp(double? gain) {
    if (gain != null) {
      _device.kp = gain;
    } else {
      _device.kp = 0;
    }
    notifyListeners();
  }

  double get ki => _device.ki;
  set ki(double? gain) {
    if (gain != null) {
      _device.ki = gain;
    } else {
      _device.ki = 0;
    }
    notifyListeners();
  }

  double get kd => _device.kd;
  set kd(double? gain) {
    if (gain != null) {
      _device.kd = gain;
    } else {
      _device.kd = 0;
    }
    notifyListeners();
  }

  bool get isClosedLoop => _device.isClosedLoop == 1;
  set isClosedLoop(bool? value) {
    if (value != null) {
      _device.isClosedLoop = value ? 1 : 0;
    } else {
      _device.isClosedLoop = 0;
    }
    notifyListeners();
  }

  double get setpoint => _device.setPoint;
  set setpoint(double? value) {
    if (value != null) {
      _device.setPoint = value;
    } else {
      _device.setPoint = 0;
    }
    notifyListeners();
  }

  double get vmax => _device.vmax;
  set vmax(double? value) {
    if (value != null) {
      _device.vmax = value;
    } else {
      _device.vmax = 0;
    }
    notifyListeners();
  }

  List<DeviceState> get states => _device.states;
  void _setStates(DeviceState state) {
    _device.states.add(state);
    notifyListeners();
  }

  sendMensage() {
    _mqttService?.published("/$deviceId/controller", _device.toJson());
  }
}
