class DeviceState {
  final double position;
  final double speed;
  final double error;
  final double output;

  DeviceState({
    required this.error,
    required this.output,
    required this.position,
    required this.speed,
  });
}
