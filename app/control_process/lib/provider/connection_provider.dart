import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../model/connection.dart';
import 'permission_provider.dart';

class ConnectionProvider extends ChangeNotifier {
  late final NetworkInfo _networkInfo;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _error = "";
  String? get error => _error;
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  Connection? _connection;
  Connection? get connection => _connection;
  set connection(Connection? value) {
    _connection = value;
    notifyListeners();
  }

  PermissionProvider? _permissionProvider;

  ConnectionProvider() {
    _networkInfo = NetworkInfo();
  }

  updatePermissions(PermissionProvider permissionProvider) {
    _permissionProvider = permissionProvider;

    if (_permissionProvider != null) {
      loading = _permissionProvider!.loading;
      error = _permissionProvider!.error;
    }

    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    loading = true;
    String? connectionName;
    String? connectionBSSID;

    try {
      if (_permissionProvider != null && _permissionProvider!.location) {
        connectionName = await _networkInfo.getWifiName();
        connectionBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get Wifi Name ${e.toString()}');
      connectionName = 'Failed to get Wifi Name';
      error = 'Erro ao obter informações da Conexão';
    }

    if (connectionBSSID != null && connectionName != null) {
      connection = Connection(
          connectionBSSID: connectionBSSID, connectionName: connectionName);

      debugPrint("Teste ${connection!.connectionName}");
    } else if (_permissionProvider != null &&
        _permissionProvider!.error != null) {
      error = _permissionProvider!.error!;
    } else {
      error = 'Erro ao obter informações da Conexão';
    }
    loading = false;
  }
}
