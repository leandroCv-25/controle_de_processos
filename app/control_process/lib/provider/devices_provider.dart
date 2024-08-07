import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/device.dart';
import '../services/mqtt_service.dart';
import 'permission_provider.dart';

class DevicesProvider extends ChangeNotifier {
  final List<Device> listDevices = [];
  late final String profile;

  MqttService? _mqttProvider;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool load) {
    _loading = load;
    notifyListeners();
  }

  String _error = "";
  bool get hasError => _error.isNotEmpty;
  String get error => _error;
  set error(String err) {
    _error = err;
    notifyListeners();
  }

  DevicesProvider() {
    setProfile();
  }

  update(MqttService? mqttProvider, PermissionProvider? permissions) {
    _mqttProvider = mqttProvider;

    if (_mqttProvider != null && _mqttProvider!.hasError) {
      error = _mqttProvider!.error;
    }

    if (permissions != null && Platform.isIOS && !permissions.notification) {
      error = "Os Soulmates não funcionam como deveriam sem a notificação";
    }

    if (_mqttProvider != null &&
        _mqttProvider!.hasData &&
        !_mqttProvider!.hasError) {}
  }

  Future<void> setProfile() async {
    loading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Try reading data from the 'id' key. If it doesn't exist, returns null.
    String? id = prefs.getString('id');

    if (id == null) {
      Uuid uuid = const Uuid();
      // Generate a v8 (time-random) id
      String idInit = uuid.v8();

      List<String> list = idInit.split('-');

      id = "${(int.parse(list[0].substring(0, 4)) - 2024) % 16}";
      id += (int.parse(list[0].substring(4, 6))).toRadixString(16);
      id += "${int.parse(list[0].substring(6, 8))}";

      id += (int.parse(list[1][1]) + int.parse(list[1][2])).toRadixString(16);
      id += (int.parse(list[1][0]) + int.parse(list[1][3])).toRadixString(16);

      id += ((int.parse(list[2].substring(1, 2), radix: 16) +
                  int.parse(list[2].substring(2, 3), radix: 16) +
                  int.parse(list[2].substring(3, list[2].length), radix: 16)) %
              8)
          .toRadixString(16);

      id += list[3];
      id += list[4];

      // Save an String value to 'id' key.
      await prefs.setString('id', id);
    }

    profile = id;

    final List<String>? list = prefs.getStringList('idDevice');

    if (list == null) {
      prefs.setStringList('idDevice', []);
    } else {
      for (id in list) {
        listDevices.add(Device(
          id: id,
        ));
      }
    }

    loading = false;
  }

  saveDevice(String idDevice) async {
    loading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList('idDevice');

    list!.add(idDevice);
    await prefs.setStringList('idDevice', list);

    listDevices.add(Device(id: idDevice));

    loading = false;
  }

  // sendILoveYou() {
  //   _mqttProvider!.published('C');
  //   _sendTheMsg = true;
  // }
}
