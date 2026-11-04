import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'telemetry_service.dart';

class MqttService extends ChangeNotifier {
  MqttService._();
  static final MqttService instance = MqttService._();

  MqttServerClient? _client;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  String? _lastPayload;

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  String? get lastPayload => _lastPayload;

  static const String broker = 'broker.hivemq.com';
  static const int port = 1883;
  static const String topicTelemetry = 'utano/AU-001/telemetry';
  static const String topicAlerts = 'utano/AU-001/alerts';

  Future<void> connect() async {
    if (_isConnected) return;

    final clientId = 'utano_app_${DateTime.now().millisecondsSinceEpoch % 100000}';
    _client = MqttServerClient.withPort(broker, clientId, port);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    _connectionStatus = 'Connecting to HiveMQ...';
    notifyListeners();

    try {
      final status = await _client!.connect();
      if (status?.state == MqttConnectionState.connected) {
        _isConnected = true;
        _connectionStatus = 'Connected to HiveMQ Cloud';
        notifyListeners();

        _client!.subscribe(topicTelemetry, MqttQos.atMostOnce);
        _client!.subscribe(topicAlerts, MqttQos.atLeastOnce);

        _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          for (final msg in messages) {
            final recMessage = msg.payload as MqttPublishMessage;
            final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
            _lastPayload = payload;
            _handleMessage(msg.topic, payload);
          }
        });
      } else {
        _isConnected = false;
        _connectionStatus = 'Connection failed: ${status?.state}';
        notifyListeners();
      }
    } catch (e) {
      _isConnected = false;
      _connectionStatus = 'Error: $e';
      notifyListeners();
    }
  }

  void _handleMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (topic == topicAlerts) {
        final alertMsg = data['message'] ?? data['alert_type'] ?? 'Emergency SOS Alert Received!';
        TelemetryService.instance.ingestLiveEmergencyAlert(alertMsg.toString());
      } else {
        final vitals = data['vitals'] as Map<String, dynamic>? ?? {};
        final battery = data['battery'] as Map<String, dynamic>? ?? {};
        final location = data['location'] as Map<String, dynamic>? ?? {};

        final hr = (vitals['heart_rate_bpm'] ?? vitals['heartRate'] ?? 72) as num;
        final spo2 = (vitals['spo2_percent'] ?? vitals['spo2'] ?? 98.0) as num;
        final temp = (vitals['body_temperature_celsius'] ?? vitals['temperature'] ?? 36.6) as num;
        final batt = (battery['percentage'] ?? 90) as num;
        final speed = (location['speed_kmh'] ?? 0.0) as num;
        final status = data['status']?.toString();

        TelemetryService.instance.ingestLiveTelemetry(
          heartRate: hr.toInt(),
          spo2: spo2.toDouble(),
          temperature: temp.toDouble(),
          batteryPercentage: batt.toInt(),
          speedKmh: speed.toDouble(),
          status: status,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[MQTT] Error parsing payload: $e');
    }
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
  }
}
