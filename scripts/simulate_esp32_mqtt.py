"""
Utano Vital Band - ESP32 Hardware Simulator via HiveMQ MQTT
Authors: Theophany Bandure (Embedded Lead)
"""

import time
import json
import random
import paho.mqtt.client as mqtt

BROKER = "broker.hivemq.com"
PORT = 1883
TOPIC_TELEMETRY = "utano/AU-001/telemetry"
TOPIC_ALERTS = "utano/AU-001/alerts"

def main():
    print("=" * 60)
    print("   Utano Vital Band - ESP32 Hardware MQTT Live Feed")
    print(f"   Streaming to {BROKER}:{PORT}")
    print(f"   Telemetry Topic: {TOPIC_TELEMETRY}")
    print("=" * 60)

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f"Utano_Sim_{random.randint(1000, 9999)}")
    client.connect(BROKER, PORT, 60)
    print("[MQTT] Connected to HiveMQ! Streaming live sensor packets every 3s...")
    print("Press Ctrl+C to stop.\n")

    seq = 0
    while True:
        seq += 1
        # Realistic nominal vital fluctuations
        heart_rate = random.randint(70, 78)
        spo2 = round(97.5 + random.uniform(0.0, 1.8), 1)
        temp = round(36.5 + random.uniform(0.0, 0.4), 1)
        batt = max(80, 96 - (seq // 20))

        payload = {
            "device_id": "VITAL-BAND-AU-001",
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "network_mode": "WIFI",
            "battery": {
                "percentage": batt,
                "voltage": 4.05,
                "is_charging": False
            },
            "vitals": {
                "heart_rate_bpm": heart_rate,
                "spo2_percent": spo2,
                "body_temperature_celsius": temp,
                "sensor_contact_detected": True
            },
            "location": {
                "latitude": -18.897520,
                "longitude": 32.609315,
                "speed_kmh": 0.0,
                "satellites": 9,
                "gps_fix": True
            },
            "status": "NORMAL"
        }

        json_str = json.dumps(payload)
        client.publish(TOPIC_TELEMETRY, json_str)
        print(f"[{seq}] Published -> HR: {heart_rate} BPM | SpO2: {spo2}% | Temp: {temp}°C | Batt: {batt}%")
        time.sleep(3)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nSimulator stopped.")
