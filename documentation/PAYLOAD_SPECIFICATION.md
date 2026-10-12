# IoT Vital Arm Band — Data Payload Specification (v1.0)

**Project:** Cellular & Wi-Fi Enabled Upper-Arm Vital Monitor  
**Authors:** Theophany Bandure (Embedded Systems Engineer) & Lee Rose (Backend Engineer)  
**Target Systems:** ESP32 Firmware $\rightarrow$ REST API / MQTT Broker $\rightarrow$ Cloud DB $\rightarrow$ Flutter Mobile App  

---

## 1. Overview
This document specifies the exact JSON data schemas transmitted from the ESP32 wearable device over Local Wi-Fi / 4G LTE Cat-M1. All timestamps adhere to ISO 8601 UTC format.

---

## 2. Topic / Endpoint Routes
* **HTTP POST Ingestion:** `POST /api/v1/telemetry/ingest`
* **HTTP Alert Ingestion:** `POST /api/v1/alerts/trigger`
* **MQTT Telemetry Topic:** `vitalband/{deviceId}/telemetry`
* **MQTT Emergency Alert Topic:** `vitalband/{deviceId}/alerts`

---

## 3. Payload Schemas

### 3.1. Standard Telemetry Payload (`telemetry`)
Transmitted periodically (default every 5 seconds over Wi-Fi, or every 30–60 seconds in low-power cellular mode).

```json
{
  "device_id": "VITAL-BAND-AU-001",
  "timestamp": "2026-10-12T02:30:00Z",
  "network_mode": "WIFI",
  "battery": {
    "percentage": 88,
    "voltage": 3.94,
    "is_charging": false
  },
  "vitals": {
    "heart_rate_bpm": 74,
    "spo2_percent": 98.2,
    "body_temperature_celsius": 36.8,
    "sensor_contact_detected": true
  },
  "location": {
    "latitude": -18.897520,
    "longitude": 32.609315,
    "altitude_meters": 1120.4,
    "speed_kmh": 1.2,
    "satellites": 8,
    "gps_fix": true
  },
  "status": "NORMAL"
}
```

#### Field Specifications:
| Field | Type | Description | Unit / Range |
|---|---|---|---|
| `device_id` | String | Unique hardware UUID / MAC ID | e.g. `VITAL-BAND-AU-001` |
| `timestamp` | String | ISO 8601 UTC timestamp | UTC string |
| `network_mode` | String | Active connection link | `"WIFI"` or `"CELLULAR_4G"` |
| `battery.percentage`| Integer | Remaining battery percentage | `0` – `100` % |
| `battery.voltage` | Float | LiPo cell terminal voltage | `3.20` – `4.20` V |
| `battery.is_charging`| Boolean| Charging state from TP4056 | `true` / `false` |
| `vitals.heart_rate_bpm`| Integer| Pulse rate from MAX30102 | `30` – `220` BPM (`0` if no contact) |
| `vitals.spo2_percent` | Float | Blood oxygen saturation | `70.0` – `100.0` % |
| `vitals.body_temperature_celsius`| Float | Temperature from DS18B20 | `30.0` – `44.0` °C |
| `vitals.sensor_contact_detected` | Boolean | Skin contact verification | `true` / `false` |
| `location.latitude` | Float | GPS Latitude | `-90.0` to `+90.0` |
| `location.longitude`| Float | GPS Longitude | `-180.0` to `+180.0` |
| `location.speed_kmh` | Float | Movement speed | km/h |
| `location.gps_fix` | Boolean | Accurate GPS satellite lock | `true` / `false` |
| `status` | String | General health state | `"NORMAL"` or `"WARNING"` |

---

### 3.2. Urgent Alert Payload (`emergency_alert`)
Transmitted immediately when biometric thresholds are breached or when the patient presses the SOS panic button.

```json
{
  "device_id": "VITAL-BAND-AU-001",
  "timestamp": "2026-10-12T02:32:15Z",
  "alert_type": "CRITICAL_VITALS",
  "severity": "HIGH",
  "triggers": [
    {
      "metric": "spo2",
      "measured_value": 88.0,
      "threshold_limit": 90.0,
      "message": "Hypoxemia detected: SpO2 dropped below safe limit (88%)."
    },
    {
      "metric": "heart_rate",
      "measured_value": 138,
      "threshold_limit": 120,
      "message": "Tachycardia detected: Heart rate abnormally elevated (138 BPM)."
    }
  ],
  "current_location": {
    "latitude": -18.897520,
    "longitude": 32.609315,
    "last_fix_time": "2026-10-12T02:32:10Z"
  },
  "action_required": "NOTIFY_CAREGIVER_IMMEDIATELY"
}
```

#### Alert Types:
* `SOS_BUTTON_PRESSED`: Manual patient panic trigger.
* `CRITICAL_VITALS`: Heart rate or $\text{SpO}_2$ breached safe envelope.
* `FALL_DETECTED`: Sudden accelerometer spike followed by inactivity.
* `GEOFENCE_BREACH`: Patient wandered beyond designated safe perimeter.

---

### 3.3. Device Handshake / Heartbeat Payload
Transmitted on boot or every 1 hour to verify device health.

```json
{
  "device_id": "VITAL-BAND-AU-001",
  "firmware_version": "v1.0.2",
  "hardware_revision": "ESP32-DEVKIT-V1",
  "uptime_seconds": 3600,
  "wifi_rssi_dbm": -64,
  "free_heap_bytes": 194820
}
```
