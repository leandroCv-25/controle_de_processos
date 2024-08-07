import 'package:flutter/foundation.dart';

import 'package:permission_handler/permission_handler.dart';

class PermissionProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _error;
  String? get error => _error;
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  bool location = false;
  bool notification = false;

  PermissionProvider() {
    initPermissionProvider();
  }

  Future<void> initPermissionProvider() async {
    loading = true;
    error = null;

    try {
      if (!await Permission.locationWhenInUse.isGranted) {
        await Permission.locationWhenInUse.request();
        if (!await Permission.nearbyWifiDevices.isGranted) {
          await Permission.nearbyWifiDevices.request();
        }
      } else {
        location = true;
      }

      if (!await Permission.locationWhenInUse.isGranted) {
        error = "Não podemos realizar a operação sem a autorização.";
      } else {
        location = true;
      }
    } catch (e) {
      error = e.toString();
    }
    loading = false;
  }
}
