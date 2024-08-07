import 'dart:io';

import 'package:control_process/screen/device_control_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/devices_provider.dart';
import 'barcode_scanner.dart';
import 'connect_screen.dart';
import 'new_device_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Olá!"),
        actions: [
          IconButton(
            onPressed: () async {
              String? code;
              if (Platform.isAndroid || Platform.isIOS) {
                code = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScanner(),
                  ),
                );
              } else {
                code = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewDeviceScreen(),
                  ),
                );
              }

              if (code != null && context.mounted) {
                Provider.of<DevicesProvider>(context, listen: false)
                    .saveDevice(code);
              }
            },
            icon: (Platform.isAndroid || Platform.isIOS)
                ? const Icon(
                    Icons.qr_code_scanner_rounded,
                  )
                : const Icon(
                    Icons.add,
                  ),
          ),
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConnectScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.connect_without_contact,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16),
        child: Stack(
          alignment: Alignment.topCenter,
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset("assets/logo.png"),
            ),
            Consumer<DevicesProvider>(builder: (context, devices, _) {
              if (devices.loading) {
                return const CircularProgressIndicator();
              }
              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width > 900 ? 100 : 25,
                  vertical: 0,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 25,
                  childAspectRatio: 1,
                ),
                itemCount: devices.listDevices.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceControlScreen(
                          device: devices.listDevices[index],
                        ),
                      ),
                    ),
                    child: Card(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          devices.listDevices[index].id,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
