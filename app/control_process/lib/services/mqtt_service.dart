import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttServiceStatusConnetion { disconnected, connected }

class MqttService extends ChangeNotifier {
  late final MqttServerClient client;
  int pongCount = 0;

  MqttServiceStatusConnetion _connetionStatus =
      MqttServiceStatusConnetion.disconnected;
  MqttServiceStatusConnetion get connectionStatus => _connetionStatus;
  set connectionStatus(MqttServiceStatusConnetion connection) {
    _connetionStatus = connection;
    notifyListeners();
  }

  String _error = "";
  bool get hasError => _error.isNotEmpty;
  String get error => _error;
  set error(String err) {
    _error = err;
    notifyListeners();
  }

  final List<Map<String, String>> data = [];
  bool get hasData => data.isNotEmpty;
  void clearData(value) {
    data.remove(value);
  }

  final List<String> _topics = [];

  MqttService();

  Future<void> mqttConnect(String clientId) async {
    client = MqttServerClient.withPort(
      '4138b3edeec543a6853636401d12dfdf.s2.eu.hivemq.cloud',
      clientId,
      8883,
    );

    client.autoReconnect = true;

    final SecurityContext context = SecurityContext.defaultContext;
    final ca = await rootBundle.load("assets/certs/isrgrootx1.pem");

    context.setTrustedCertificatesBytes(ca.buffer.asUint8List());
    client.secure = true;
    client.securityContext = context;

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 60;

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Add the successful connection callback
    client.onConnected = _onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = _onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = _pong;

    final connMess = MqttConnectMessage()
        .authenticateAs("esp32", "Le123456789")
        .withWillTopic(clientId) // If you set this you must set a will message
        .withWillMessage('Disconnected')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect("esp32", "Le123456789");
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      error = "Opa! Tivemos algum problema.";
      debugPrint('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      debugPrint('socket exception - $e');
      error = "Opa! Tivemos algum problema.";
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('Mosquitto client connected');
    } else {
      error = "Opa! Tivemos algum problema.";

      /// Use status here rather than state if you also want the broker return code.
      debugPrint(
          'ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    /// In general you should listen here as soon as possible after connecting, you will not receive any
    /// publish messages until you do this.
    /// Also you must re-listen after disconnecting.
    if (!_topics.contains(topic)) {
      _topics.add(topic);
    }
    client.subscribe(topic, MqttQos.exactlyOnce);
    client.updates!.listen(_onData);
  }

  /// The subscribed callback
  void _onData(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    final topic = recMess.payload.variableHeader?.topicName;

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    // debugPrint(
    //     'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    // debugPrint('');
    Map<String, String> msg = {};
    if (topic != null) {
      msg["topic"] = topic;
    }
    msg["data"] = payload;
    data.add(msg);

    notifyListeners();
  }

  void published(String topic, String msg) {
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    debugPrint('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.unsolicited) {
      error = "Ops! Nossos servidores estão fora de alcance.";
    }
    connectionStatus = MqttServiceStatusConnetion.disconnected;
  }

  /// The successful connect callback
  void _onConnected() {
    if (_topics.isNotEmpty) {
      for (String topic in _topics) {
        subscribe(topic);
      }
    }
    connectionStatus = MqttServiceStatusConnetion.connected;
  }

  /// Pong callback
  void _pong() {
    pongCount++;
  }
}
