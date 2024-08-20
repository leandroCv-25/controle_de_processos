import 'package:control_process/widgets/charts_widget.dart';
import 'package:control_process/widgets/settings_control_position_widget.dart';
import 'package:control_process/widgets/state_position_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/device_controller.dart';
import '../model/device.dart';
import '../services/mqtt_service.dart';

class DeviceControlScreen extends StatelessWidget {
  const DeviceControlScreen({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<MqttService, DeviceController>(
      create: (context) {
        return DeviceController(device: device);
      },
      update: (BuildContext context, MqttService mqttService,
          DeviceController? deviceController) {
        if (deviceController != null) {
          return deviceController..update(mqttService);
        } else {
          return DeviceController(device: device)..update(mqttService);
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
                    child: Consumer<DeviceController>(
                      builder: (context, deviceController, _) {
                        if (deviceController.isThereError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.error),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Erro: ",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text: deviceController.error,
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
                              SettingsControlPositionWidget(
                                kp: deviceController.kp,
                                ki: deviceController.ki,
                                kd: deviceController.kd,
                                setPoint: deviceController.setpoint,
                                vmax: deviceController.vmax,
                                isClosedLoop: deviceController.isClosedLoop,
                                onChangedKp: (value) =>
                                    deviceController.kp = value,
                                onChangedKi: (value) =>
                                    deviceController.ki = value,
                                onChangedKd: (value) =>
                                    deviceController.kd = value,
                                onChangedSetPoint: (value) =>
                                    deviceController.setpoint = value,
                                onChangedVMax: (value) =>
                                    deviceController.vmax = value,
                                onChangedIsClosedLoop: (value) =>
                                    deviceController.isClosedLoop = value,
                                sendMensage: deviceController.sendMensage,
                              ),
                              StatePositionWidget(
                                states: deviceController.states,
                              ),
                              DefaultTabController(
                                length:
                                    VisibleDataStateController.values.length,
                                child: TabBar(
                                  tabs: VisibleDataStateController.values
                                      .map(
                                        (element) => Tab(text: element.name),
                                      )
                                      .toList(),
                                  onTap: (value) => deviceController
                                          .visibleDataStateController =
                                      VisibleDataStateController.values[value],
                                ),
                              ),
                              ChartsWidget(
                                data: deviceController.dataToMap(),
                                height: 500,
                                maxValue: deviceController
                                            .visibleDataStateController ==
                                        VisibleDataStateController.output
                                    ? 100
                                    : 200,
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
