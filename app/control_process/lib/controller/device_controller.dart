import 'dart:convert';

import 'package:control_process/model/device_state.dart';
import 'package:flutter/foundation.dart';

import '../model/device.dart';
import '../services/mqtt_service.dart';

enum VisibleDataStateController { error, position, output, speed }

class DeviceController extends ChangeNotifier {
  final Device _device;
  MqttService? _mqttService;

  VisibleDataStateController _visibleDataStateController =
      VisibleDataStateController.error;

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
            speed: statesDecoded['output'] >= 0
                ? statesDecoded['speed']
                : -statesDecoded['speed'],
            time: statesDecoded['time'],
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
    _device.states.sort(
      (a, b) => a.time.compareTo(b.time),
    );
    notifyListeners();
  }

  VisibleDataStateController get visibleDataStateController =>
      _visibleDataStateController;

  set visibleDataStateController(VisibleDataStateController data) {
    _visibleDataStateController = data;
    notifyListeners();
  }

  double maxValue = 200;
  double minValue = 200;
  int lastPeriod = 0;

  Map<int, double> dataToMap() {
    final Map<int, double> map = {};
    double maxY = -200;
    double minY = 200;

    for (var state in states) {
      if (visibleDataStateController == VisibleDataStateController.error) {
        map[state.time] = state.error;
        if (maxY < state.error) maxY = state.error;
        if (minY > state.error) minY = state.error;
      } else if (visibleDataStateController ==
          VisibleDataStateController.position) {
        map[state.time] = state.position;
        if (maxY < state.position) maxY = state.position;
        if (minY > state.position) minY = state.position;
      } else if (visibleDataStateController ==
          VisibleDataStateController.output) {
        map[state.time] = state.output;
        if (maxY < state.output) maxY = state.output;
        if (minY > state.output) minY = state.output;
      } else if (visibleDataStateController ==
          VisibleDataStateController.speed) {
        map[state.time] = state.speed;
        if (maxY < state.speed) maxY = state.speed;
        if (minY > state.speed) minY = state.speed;
      }
    }
    if (states.isNotEmpty) {
      maxValue = maxY;
      minValue = minY;
      lastPeriod = states.last.time;
    }
    return map;
  }

  sendMensage() {
    states.clear();
    _mqttService?.published("/$deviceId/controller", _device.toJson());
  }
}
