import 'package:flutter/foundation.dart';

import '../model/device.dart';

class DeviceController extends ChangeNotifier {
  final Device device;

  DeviceController({required this.device});
}
