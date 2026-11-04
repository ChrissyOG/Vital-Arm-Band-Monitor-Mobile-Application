import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'app_theme.dart';

enum DemoScenario {
  normal,
  exercise,
  emergency,
}

class TelemetrySnapshot {
  const TelemetrySnapshot({
    required this.scenario,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.batteryPercentage,
    required this.speedKmh,
    required this.heartRateHistory,
    required this.spo2History,
    required this.lastUpdated,
    required this.statusText,
    required this.statusColor,
    required this.isNotificationActive,
    required this.isEmergencyCallActive,
    required this.isActivityCorrelated,
    required this.countdownSeconds,
    this.alertMessage,
  });

  final DemoScenario scenario;
  final int heartRate;
  final double spo2;
  final double temperature;
  final int batteryPercentage;
  final double speedKmh;
  final List<double> heartRateHistory;
  final List<double> spo2History;
  final DateTime lastUpdated;
  final String statusText;
  final Color statusColor;
  final bool isNotificationActive;
  final bool isEmergencyCallActive;
  final bool isActivityCorrelated;
  final int countdownSeconds;
  final String? alertMessage;

  bool get isCritical => scenario == DemoScenario.emergency;
  bool get isExercise => scenario == DemoScenario.exercise;
  bool get isNormal => scenario == DemoScenario.normal;

  String get formattedCountdown {
    final mins = countdownSeconds ~/ 60;
    final secs = countdownSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class TelemetryService extends ChangeNotifier {
  TelemetryService._() {
    _applyScenarioDefaults();
    start();
  }

  static final TelemetryService instance = TelemetryService._();

  DemoScenario _scenario = DemoScenario.normal;
  Timer? _tickTimer;
  Timer? _countdownTimer;
  final Random _rand = Random();

  late int _heartRate;
  late double _spo2;
  late double _temperature;
  int _batteryPercentage = 88;
  late double _speedKmh;
  late List<double> _heartRateHistory;
  late List<double> _spo2History;
  late DateTime _lastUpdated;
  String? _alertMessage;
  String _statusText = 'Within baseline';
  Color _statusColor = forest;

  // Notification and emergency escalation fields
  bool _isNotificationActive = false;
  bool _isEmergencyCallActive = false;
  bool _isActivityCorrelated = false;
  int _countdownSeconds = 120; // 2 minutes

  DemoScenario get scenario => _scenario;

  TelemetrySnapshot get snapshot => TelemetrySnapshot(
        scenario: _scenario,
        heartRate: _heartRate,
        spo2: _spo2,
        temperature: _temperature,
        batteryPercentage: _batteryPercentage,
        speedKmh: _speedKmh,
        heartRateHistory: List.unmodifiable(_heartRateHistory),
        spo2History: List.unmodifiable(_spo2History),
        lastUpdated: _lastUpdated,
        statusText: _statusText,
        statusColor: _statusColor,
        isNotificationActive: _isNotificationActive,
        isEmergencyCallActive: _isEmergencyCallActive,
        isActivityCorrelated: _isActivityCorrelated,
        countdownSeconds: _countdownSeconds,
        alertMessage: _alertMessage,
      );

  void start() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) => _tick());
  }

  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void setScenario(DemoScenario scenario) {
    if (_scenario == scenario) return;
    _scenario = scenario;
    _applyScenarioDefaults();
    notifyListeners();
  }

  /// Triggers stationary critical spike (unexplained spike -> starts 2-minute escalation timer).
  void triggerStationarySpike() {
    _scenario = DemoScenario.emergency;
    _applyScenarioDefaults();
    _startEmergencyCountdown();
    notifyListeners();
  }

  /// Triggers exercise spike (activity-correlated -> smart filter prevents false alarm).
  void triggerExerciseSpike() {
    _scenario = DemoScenario.exercise;
    _applyScenarioDefaults();
    _cancelCountdown();
    notifyListeners();
  }

  /// Fast-forwards the 2-minute timer to 0 so the automated caregiver call screen triggers immediately for demo.
  void fastForwardCountdown() {
    if (_isNotificationActive) {
      _countdownSeconds = 0;
      _triggerEmergencyCall();
    }
  }

  /// User / Caregiver acknowledges notification -> cancels countdown.
  void acknowledgeNotification() {
    _isNotificationActive = false;
    _cancelCountdown();
    if (_scenario == DemoScenario.emergency) {
      _statusText = 'Alert acknowledged by caregiver';
      _statusColor = const Color(0xFFE89635);
    }
    notifyListeners();
  }

  /// Ends the automated emergency call and returns system to nominal monitoring.
  void endEmergencyCall() {
    _isEmergencyCallActive = false;
    _isNotificationActive = false;
    _cancelCountdown();
    setScenario(DemoScenario.normal);
  }

  /// Ingests live telemetry payload from ESP32 via MQTT (broker.hivemq.com)
  void ingestLiveTelemetry({
    required int heartRate,
    required double spo2,
    required double temperature,
    required int batteryPercentage,
    required double speedKmh,
    String? status,
  }) {
    _heartRate = heartRate;
    _spo2 = spo2;
    _temperature = temperature;
    _speedKmh = speedKmh;
    _batteryPercentage = batteryPercentage;
    _lastUpdated = DateTime.now();

    _heartRateHistory.add(heartRate.toDouble() / 150.0);
    if (_heartRateHistory.length > 20) _heartRateHistory.removeAt(0);
    _spo2History.add(spo2 / 100.0);
    if (_spo2History.length > 20) _spo2History.removeAt(0);

    // Smart activity filter: speed > 5.5 km/h correlates elevated HR with exercise
    if (_speedKmh >= 5.5 && _heartRate > 105) {
      _isActivityCorrelated = true;
      _scenario = DemoScenario.exercise;
      _statusText = 'Aerobic exercise detected (Smart Filter Active)';
      _statusColor = forest;
      _cancelCountdown();
      _isNotificationActive = false;
      _alertMessage = 'Activity-Induced Elevation: Pulse rate $_heartRate BPM correlated with movement (${_speedKmh.toStringAsFixed(1)} km/h).';
    } else if (_spo2 < 90.0 || _heartRate > 125 || _heartRate < 45 || status == 'WARNING' || status == 'CRITICAL') {
      _isActivityCorrelated = false;
      _scenario = DemoScenario.emergency;
      _statusText = 'Critical Anomaly: HR ${_heartRate}bpm, SpO2 ${_spo2.toStringAsFixed(1)}%';
      _statusColor = coral;
      _alertMessage = _spo2 < 90.0
          ? 'Hypoxemia Alert: Blood oxygen critically low (${_spo2.toStringAsFixed(1)}%).'
          : 'Tachycardia Alert: Heart rate elevated at $_heartRate BPM.';
      if (!_isNotificationActive && !_isEmergencyCallActive) {
        _startEmergencyCountdown();
      }
    } else {
      _isActivityCorrelated = false;
      _scenario = DemoScenario.normal;
      _statusText = 'Within baseline';
      _statusColor = forest;
      _alertMessage = null;
    }

    notifyListeners();
  }

  /// Ingests critical SOS Panic Button alert from ESP32 via MQTT
  void ingestLiveEmergencyAlert(String message) {
    _scenario = DemoScenario.emergency;
    _alertMessage = message;
    _statusText = 'CRITICAL: $message';
    _statusColor = coral;
    _startEmergencyCountdown();
    notifyListeners();
  }

  void _startEmergencyCountdown() {
    _countdownTimer?.cancel();
    _countdownSeconds = 120; // 2 minutes
    _isNotificationActive = true;
    _isEmergencyCallActive = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        _countdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _triggerEmergencyCall();
      }
    });
  }

  void _triggerEmergencyCall() {
    _countdownTimer?.cancel();
    _isNotificationActive = false;
    _isEmergencyCallActive = true;
    notifyListeners();
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isNotificationActive = false;
  }

  void _applyScenarioDefaults() {
    _lastUpdated = DateTime.now();
    switch (_scenario) {
      case DemoScenario.normal:
        _cancelCountdown();
        _isEmergencyCallActive = false;
        _isActivityCorrelated = false;
        _heartRate = 72;
        _spo2 = 98.2;
        _temperature = 36.7;
        _speedKmh = 1.2;
        _statusText = 'Within baseline';
        _statusColor = forest;
        _alertMessage = null;
        _heartRateHistory = [
          0.44, 0.48, 0.46, 0.50, 0.47, 0.52, 0.48, 0.51, 0.47, 0.49, 0.52, 0.48,
        ];
        _spo2History = [
          0.70, 0.73, 0.71, 0.74, 0.72, 0.75, 0.73, 0.72, 0.74, 0.73, 0.75, 0.74,
        ];
        break;

      case DemoScenario.exercise:
        _cancelCountdown();
        _isEmergencyCallActive = false;
        // Optimization: Correlate spike with movement (smart motion filter)
        _isActivityCorrelated = true;
        _heartRate = 118;
        _spo2 = 96.5;
        _temperature = 37.2;
        _speedKmh = 5.6;
        _statusText = 'Elevated · Exercise correlated (No false alarm)';
        _statusColor = const Color(0xFFE89635);
        _alertMessage = 'Activity-Induced Elevation: Pulse rate 118 BPM correlated with movement (5.6 km/h). Emergency escalation bypassed.';
        _heartRateHistory = [
          0.60, 0.65, 0.70, 0.72, 0.78, 0.81, 0.79, 0.83, 0.80, 0.84, 0.82, 0.85,
        ];
        _spo2History = [
          0.65, 0.64, 0.63, 0.65, 0.62, 0.64, 0.63, 0.62, 0.64, 0.63, 0.62, 0.63,
        ];
        break;

      case DemoScenario.emergency:
        // Stationary acute spike: true emergency -> triggers 2-min escalation
        _isActivityCorrelated = false;
        _heartRate = 138;
        _spo2 = 88.0;
        _temperature = 38.6;
        _speedKmh = 0.0;
        _statusText = 'CRITICAL ALERT · Hypoxemia & Tachycardia';
        _statusColor = coral;
        _alertMessage = 'EMERGENCY: SpO₂ dropped to 88% (<90%) & Pulse 138 BPM while stationary. Relative call in 2m if unacknowledged.';
        _heartRateHistory = [
          0.50, 0.55, 0.62, 0.70, 0.82, 0.90, 0.94, 0.92, 0.96, 0.95, 0.98, 0.96,
        ];
        _spo2History = [
          0.72, 0.68, 0.60, 0.52, 0.44, 0.38, 0.32, 0.28, 0.25, 0.22, 0.20, 0.18,
        ];
        _startEmergencyCountdown();
        break;
    }
  }

  void _tick() {
    _lastUpdated = DateTime.now();

    switch (_scenario) {
      case DemoScenario.normal:
        final deltaHr = _rand.nextInt(3) - 1;
        _heartRate = (_heartRate + deltaHr).clamp(69, 76);
        final deltaSpo2 = (_rand.nextDouble() - 0.5) * 0.4;
        _spo2 = double.parse(((_spo2 + deltaSpo2).clamp(97.2, 99.0)).toStringAsFixed(1));
        _temperature = 36.6 + (_rand.nextInt(3) * 0.1);

        _pushHistory(_heartRateHistory, (_heartRate - 50) / 100.0);
        _pushHistory(_spo2History, (_spo2 - 80) / 25.0);
        break;

      case DemoScenario.exercise:
        final deltaHr = _rand.nextInt(5) - 2;
        _heartRate = (_heartRate + deltaHr).clamp(112, 126);
        final deltaSpo2 = (_rand.nextDouble() - 0.5) * 0.5;
        _spo2 = double.parse(((_spo2 + deltaSpo2).clamp(95.0, 97.2)).toStringAsFixed(1));
        _temperature = 37.1 + (_rand.nextInt(3) * 0.1);
        _speedKmh = double.parse((5.2 + _rand.nextDouble() * 0.8).toStringAsFixed(1));

        _pushHistory(_heartRateHistory, (_heartRate - 50) / 100.0);
        _pushHistory(_spo2History, (_spo2 - 80) / 25.0);
        break;

      case DemoScenario.emergency:
        final deltaHr = _rand.nextInt(5) - 2;
        _heartRate = (_heartRate + deltaHr).clamp(134, 144);
        final deltaSpo2 = (_rand.nextDouble() - 0.5) * 0.4;
        _spo2 = double.parse(((_spo2 + deltaSpo2).clamp(86.5, 89.4)).toStringAsFixed(1));
        _temperature = 38.5 + (_rand.nextInt(3) * 0.1);
        _speedKmh = 0.0;

        _pushHistory(_heartRateHistory, (_heartRate - 50) / 100.0);
        _pushHistory(_spo2History, (_spo2 - 80) / 25.0);
        break;
    }

    notifyListeners();
  }

  void _pushHistory(List<double> list, double value) {
    list.removeAt(0);
    list.add(value.clamp(0.05, 0.95));
  }
}
