# Vital Band Mobile App

Flutter prototype for the mobile-app requirements in the repository README.

## Run

```powershell
cd mobile-app
flutter pub get
flutter run
```

## Included screens

- Sign in and a three-step sign-up flow with caregiver, fitness tracking, relative, and personal health roles.
- Optional monitored-person details and a device-code entry step.
- Role-aware overview with prominent heart-rate and SpO2 readings.
- Historical vital charts, fitness activity summaries, location and movement views, a geofence control, alert history, and Wi-Fi/LTE/battery status.
- Responsive layouts for narrow phones and wider screens.

## Prototype boundary

The app currently uses local sample values and does not authenticate accounts or connect to a Vital Band. Map markers, geofence events, notifications, historical readings, and connectivity status are illustrative UI; they are not live GPS or sensor data. The demo readings are not medical measurements and must not be used for diagnosis or emergency decisions.

Production integration still needs Firebase project configuration and security rules, Firebase Authentication and data storage, MQTT/TLS telemetry ingestion, Firebase Cloud Messaging, a maps/location provider with permission handling, and a device-pairing protocol for the ESP32-Cat-M1 hardware. Connectivity fallback and anomaly alerts must be driven by real device/cloud state before being presented as operational.# vital_arm_band_monitor

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
