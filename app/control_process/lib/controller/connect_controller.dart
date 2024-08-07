import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:esp_smartconfig/esp_smartconfig.dart';

import '../model/connection.dart';
import '../provider/connection_provider.dart';

class ConnectController extends ChangeNotifier {
  final provisioner = Provisioner.espTouch();
  late final StreamSubscription<ProvisioningResponse> listen;

  late ConnectionProvider? _connectionProvider;

  late Connection? _connection;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _done = false;
  bool get done => _done;
  set done(bool value) {
    _done = value;
    notifyListeners();
  }

  String? _error = "";
  String? get error => _error;
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  void obscurePasswordToogle() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  ConnectController() {
    listen = provisioner.listen((response) {
      debugPrint("Device ${response.bssidText} connected to WiFi!");
      done = true;
      loading = false;
    });

    listen.pause();
  }

  update(ConnectionProvider connectionProvider) {
    _connectionProvider = connectionProvider;

    if (_connectionProvider != null) {
      loading = _connectionProvider!.loading;
      error = _connectionProvider!.error;

      _connection = _connectionProvider?.connection;

      connectionName = _connection?.connectionName.replaceAll("\"", "");

      connectionPassword = "";

      if (connectionName == null && error != null) {
        error = "Não temos qual será a rede.";
      }
    }
  }

  String? _connectionName;
  String? get connectionName => _connectionName;
  set connectionName(String? value) {
    _connectionName = value;
    notifyListeners();
  }

  String? _connectionPassword = "";
  String? get connectionPassword => _connectionPassword;
  set connectionPassword(String? value) {
    _connectionPassword = value;
    _connection?.connectionPassword = value;
    notifyListeners();
  }

  bool get connectionPasswordError =>
      _connectionPassword == null || _connectionPassword!.length < 8;

  Future<void> sendConnection() async {
    loading = true;
    listen.resume();

    try {
      if (_connection != null && _connection!.connectionPassword!.isNotEmpty) {
        await provisioner.start(
          ProvisioningRequest.fromStrings(
            ssid: _connection!.connectionName.replaceAll("\"", ""),
            bssid: _connection!.connectionBSSID,
            password: _connection!.connectionPassword,
          ),
        );

        await Future.delayed(const Duration(seconds: 10));
      } else {
        error = "Não temos qual será a rede.";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      provisioner.stop();
      listen.pause();
      loading = false;
    }
  }
}
