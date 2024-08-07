class Connection {
  String connectionName;
  String connectionBSSID;
  String? connectionPassword;

  Connection({
    required this.connectionBSSID,
    required this.connectionName,
    this.connectionPassword,
  });
}
