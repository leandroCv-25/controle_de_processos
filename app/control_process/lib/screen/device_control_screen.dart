import 'package:control_process/widgets/settings_control_position.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/connect_controller.dart';
import '../model/device.dart';
import '../provider/connection_provider.dart';

class DeviceControlScreen extends StatelessWidget {
  const DeviceControlScreen({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<ConnectionProvider, ConnectController>(
      create: (context) {
        return ConnectController();
      },
      update: (BuildContext context, ConnectionProvider connectionProvider,
          ConnectController? connectController) {
        if (connectController != null) {
          return connectController..update(connectionProvider);
        } else {
          return ConnectController()..update(connectionProvider);
        }
      },
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Controle de Posição"),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Consumer<ConnectController>(
                      builder: (context, connectController, header) {
                        if (connectController.error != null ||
                            connectController.connectionName == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              header!,
                              const Icon(Icons.error),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Erro: ",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text: connectController.error,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              SettingsControlPosition(
                                kp: 0.5,
                                ki: 0.5,
                                kd: 50,
                                onChangedKp: (value) {},
                                onChangedKi: (value) {},
                                onChangedKd: (value) {},
                                isClosedLoop: false,
                                onChangedIsClosedLoop: (bool) {},
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
