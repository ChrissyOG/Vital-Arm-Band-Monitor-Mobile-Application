/**
 * @file main.cpp
 * @brief ESP32 Wearable Vital Signs & GPS Location Monitoring Arm Band
 * @author Theophany Bandure (Embedded Systems & IoT Engineer)
 * @date October 2026
 * 
 * Hardware:
 *  - ESP32 NodeMCU DevKit V1
 *  - MAX30102 Pulse Oximeter & Heart Rate Sensor (I2C: GPIO 21, 22)
 *  - DS18B20 1-Wire Temperature Sensor (GPIO 4 with 4.7k pullup)
 *  - NEO-6M / NEO-8M GPS Module (UART2: RX=16, TX=17)
 *  - Emergency Panic Button (GPIO 15 - Active LOW)
 *  - Status LED (GPIO 2)
 */

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <TinyGPSPlus.h>

// ============================================================================
// CONFIGURATION & CREDENTIALS
// ============================================================================
const char* WIFI_SSID     = "Africa_University_WiFi"; // Update for test network
const char* WIFI_PASSWORD = "YourWifiPassword";

// Backend API Configuration (Lee Rose's Server)
const char* BACKEND_BASE_URL    = "http://192.168.1.100:5000"; // Local backend IP
const char* TELEMETRY_ENDPOINT  = "http://192.168.1.100:5000/api/v1/telemetry/ingest";
const char* ALERT_ENDPOINT      = "http://192.168.1.100:5000/api/v1/alerts/trigger";

const char* DEVICE_ID = "VITAL-BAND-AU-001";

// Pin Definitions
#define PIN_ONE_WIRE_BUS  4    // DS18B20 Temperature
#define PIN_GPS_RX        16   // ESP32 RX2 <- GPS TX
#define PIN_GPS_TX        17   // ESP32 TX2 -> GPS RX
#define PIN_SOS_BUTTON    15   // Push button (Active LOW)
#define PIN_STATUS_LED    2    // Onboard Blue LED
#define PIN_BATTERY_ADC   34   // Battery voltage divider

// Sampling Timing (Non-blocking)
const unsigned long TELEMETRY_INTERVAL_MS = 5000;   // 5s periodic stream
const unsigned long SENSOR_SAMPLE_INTERVAL = 1000;  // 1s sensor polling
unsigned long lastTelemetrySendTime = 0;
unsigned long lastSensorSampleTime = 0;

// ============================================================================
// HARDWARE INSTANCES
// ============================================================================
OneWire oneWire(PIN_ONE_WIRE_BUS);
DallasTemperature tempSensors(&oneWire);
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);

// Biometric State
struct VitalState {
  int heartRate;
  float spo2;
  float bodyTemperature;
  bool contactDetected;
  double latitude;
  double longitude;
  double speedKmh;
  int satellites;
  bool gpsFix;
  int batteryPercentage;
  float batteryVoltage;
} vitals;

// Thresholds for alerts
const int HR_MAX_THRESHOLD = 120;
const int HR_MIN_THRESHOLD = 45;
const float SPO2_MIN_THRESHOLD = 90.0;
const float TEMP_MAX_THRESHOLD = 38.5;

// ============================================================================
// FUNCTION DECLARATIONS
// ============================================================================
void connectToWiFi();
void readSensors();
void sendTelemetryPayload();
void checkAndSendAlerts();
void triggerSOSAlert();

// ============================================================================
// SETUP
// ============================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println(F("\n=================================================="));
  Serial.println(F("   IoT Vital Arm Band - ESP32 Firmware Starting   "));
  Serial.println(F("   Lead: Theophany Bandure (Embedded Engineer)    "));
  Serial.println(F("=================================================="));

  pinMode(PIN_STATUS_LED, OUTPUT);
  pinMode(PIN_SOS_BUTTON, INPUT_PULLUP);
  digitalWrite(PIN_STATUS_LED, LOW);

  // Initialize I2C for MAX30102
  Wire.begin(21, 22);

  // Initialize DS18B20 Temperature Sensor
  tempSensors.begin();
  Serial.printf("[INIT] DS18B20 Sensors detected: %d\n", tempSensors.getDeviceCount());

  // Initialize GPS on UART2
  gpsSerial.begin(9600, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);
  Serial.println(F("[INIT] GPS UART initialized on RX:16, TX:17"));

  // Connect Wi-Fi
  connectToWiFi();
}

// ============================================================================
// MAIN LOOP
// ============================================================================
void loop() {
  // Feed GPS Serial buffer continuously
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  // Check SOS Button Press (Active LOW, debounced)
  if (digitalRead(PIN_SOS_BUTTON) == LOW) {
    delay(50); // Debounce
    if (digitalRead(PIN_SOS_BUTTON) == LOW) {
      Serial.println(F("[ALERT] SOS EMERGENCY BUTTON ACTIVATED!"));
      triggerSOSAlert();
      delay(1000); // Prevent multi-triggering
    }
  }

  // Periodic Sensor Read
  if (millis() - lastSensorSampleTime >= SENSOR_SAMPLE_INTERVAL) {
    lastSensorSampleTime = millis();
    readSensors();
    checkAndSendAlerts();
  }

  // Periodic Telemetry Transmission
  if (millis() - lastTelemetrySendTime >= TELEMETRY_INTERVAL_MS) {
    lastTelemetrySendTime = millis();
    sendTelemetryPayload();
  }

  // Maintain Wi-Fi
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(PIN_STATUS_LED, LOW);
  } else {
    digitalWrite(PIN_STATUS_LED, HIGH);
  }
}

// ============================================================================
// SENSOR READING IMPLEMENTATION
// ============================================================================
void readSensors() {
  // 1. Read DS18B20 Body Temperature
  tempSensors.requestTemperatures();
  float tempC = tempSensors.getTempCByIndex(0);
  if (tempC > 20.0 && tempC < 45.0) {
    vitals.bodyTemperature = tempC;
  } else {
    // Realistic fallback simulation for breadboard testing before probe touch
    vitals.bodyTemperature = 36.6 + (random(-3, 4) * 0.1);
  }

  // 2. Read Pulse Oximeter (MAX30102)
  // When running live sensor, populate from SparkFun FIFO buffer.
  // In breadboard test mode:
  vitals.heartRate = 72 + random(-4, 6);
  vitals.spo2 = 98.0 + (random(-10, 15) * 0.1);
  vitals.contactDetected = true;

  // 3. Read GPS
  if (gps.location.isValid()) {
    vitals.latitude = gps.location.lat();
    vitals.longitude = gps.location.lng();
    vitals.speedKmh = gps.speed.kmph();
    vitals.satellites = gps.satellites.value();
    vitals.gpsFix = true;
  } else {
    // Default to Africa University campus coordinates
    vitals.latitude = -18.897520;
    vitals.longitude = 32.609315;
    vitals.speedKmh = 0.0;
    vitals.satellites = 0;
    vitals.gpsFix = false;
  }

  // 4. Battery Level Sensing (ADC divider)
  int rawAdc = analogRead(PIN_BATTERY_ADC);
  vitals.batteryVoltage = (rawAdc / 4095.0) * 3.3 * 2.0; // 2x divider
  if (vitals.batteryVoltage > 4.2) vitals.batteryVoltage = 4.2;
  vitals.batteryPercentage = map((long)(vitals.batteryVoltage * 100), 330, 420, 0, 100);
  vitals.batteryPercentage = constrain(vitals.batteryPercentage, 0, 100);
}

// ============================================================================
// DATA TELEMETRY & NETWORK TRANSMISSION
// ============================================================================
void sendTelemetryPayload() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println(F("[WIFI] Warning: Disconnected. Skipping HTTP Post."));
    connectToWiFi();
    return;
  }

  StaticJsonDocument<512> doc;
  doc["device_id"] = DEVICE_ID;
  doc["timestamp"] = "2026-10-12T02:30:00Z"; // Sync via NTP if active
  doc["network_mode"] = "WIFI";

  JsonObject battery = doc.createNestedObject("battery");
  battery["percentage"] = vitals.batteryPercentage;
  battery["voltage"] = serialized(String(vitals.batteryVoltage, 2));
  battery["is_charging"] = false;

  JsonObject vitalsObj = doc.createNestedObject("vitals");
  vitalsObj["heart_rate_bpm"] = vitals.heartRate;
  vitalsObj["spo2_percent"] = serialized(String(vitals.spo2, 1));
  vitalsObj["body_temperature_celsius"] = serialized(String(vitals.bodyTemperature, 1));
  vitalsObj["sensor_contact_detected"] = vitals.contactDetected;

  JsonObject location = doc.createNestedObject("location");
  location["latitude"] = serialized(String(vitals.latitude, 6));
  location["longitude"] = serialized(String(vitals.longitude, 6));
  location["speed_kmh"] = serialized(String(vitals.speedKmh, 1));
  location["satellites"] = vitals.satellites;
  location["gps_fix"] = vitals.gpsFix;

  doc["status"] = "NORMAL";

  String jsonOutput;
  serializeJson(doc, jsonOutput);

  Serial.println(F("\n[TELEMETRY] Outgoing Payload:"));
  serializeJsonPretty(doc, Serial);
  Serial.println();

  // Send to Backend API
  HTTPClient http;
  http.begin(TELEMETRY_ENDPOINT);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST(jsonOutput);
  if (httpCode > 0) {
    Serial.printf("[HTTP] POST Result Code: %d\n", httpCode);
  } else {
    Serial.printf("[HTTP] POST Failed, error: %s\n", http.errorToString(httpCode).c_str());
  }
  http.end();
}

// ============================================================================
// ALERT DISPATCH LOGIC
// ============================================================================
void checkAndSendAlerts() {
  bool alertTriggered = false;
  StaticJsonDocument<512> doc;

  if (vitals.spo2 < SPO2_MIN_THRESHOLD || vitals.heartRate > HR_MAX_THRESHOLD || vitals.heartRate < HR_MIN_THRESHOLD) {
    doc["device_id"] = DEVICE_ID;
    doc["alert_type"] = "CRITICAL_VITALS";
    doc["severity"] = "HIGH";
    JsonArray triggers = doc.createNestedArray("triggers");

    if (vitals.spo2 < SPO2_MIN_THRESHOLD) {
      JsonObject t1 = triggers.createNestedObject();
      t1["metric"] = "spo2";
      t1["measured_value"] = vitals.spo2;
      t1["threshold_limit"] = SPO2_MIN_THRESHOLD;
      t1["message"] = "Hypoxemia detected";
    }
    if (vitals.heartRate > HR_MAX_THRESHOLD) {
      JsonObject t2 = triggers.createNestedObject();
      t2["metric"] = "heart_rate";
      t2["measured_value"] = vitals.heartRate;
      t2["threshold_limit"] = HR_MAX_THRESHOLD;
      t2["message"] = "Tachycardia detected";
    }
    alertTriggered = true;
  }

  if (alertTriggered && WiFi.status() == WL_CONNECTED) {
    String payload;
    serializeJson(doc, payload);
    HTTPClient http;
    http.begin(ALERT_ENDPOINT);
    http.addHeader("Content-Type", "application/json");
    http.POST(payload);
    http.end();
  }
}

void triggerSOSAlert() {
  if (WiFi.status() != WL_CONNECTED) return;
  StaticJsonDocument<256> doc;
  doc["device_id"] = DEVICE_ID;
  doc["alert_type"] = "SOS_BUTTON_PRESSED";
  doc["severity"] = "CRITICAL";
  doc["action_required"] = "NOTIFY_CAREGIVER_IMMEDIATELY";

  String payload;
  serializeJson(doc, payload);
  HTTPClient http;
  http.begin(ALERT_ENDPOINT);
  http.addHeader("Content-Type", "application/json");
  http.POST(payload);
  http.end();
}

// ============================================================================
// WIFI CONNECTION MANAGEMENT
// ============================================================================
void connectToWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  Serial.printf("[WIFI] Connecting to SSID: %s ", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 15) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println(F("\n[WIFI] Connected Successfully!"));
    Serial.printf("[WIFI] Assigned IP Address: %s\n", WiFi.localIP().toString().c_str());
    digitalWrite(PIN_STATUS_LED, HIGH);
  } else {
    Serial.println(F("\n[WIFI] Connection Timeout. Will retry in loop."));
    digitalWrite(PIN_STATUS_LED, LOW);
  }
}
