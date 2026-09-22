# Cellular-Based Upper-Arm Vital Monitor for Remote Elderly Care

An affordable, dual-mode **Wi-Fi and 4G LTE vital-sign monitoring and fitness-tracking platform** designed primarily for elderly individuals and their caregivers, with additional functionality for users interested in monitoring their personal fitness and activity.

---

## 📌 Project Overview

The **Cellular-Based Upper-Arm Vital Monitor** is an IoT-based wearable system designed to provide continuous monitoring of vital signs, location, movement, and activity.

The system uses an ergonomic **upper-arm sleeve** containing a removable electronics pod. The wearable collects biometric information such as **Heart Rate (HR) and SpO2**, together with GPS location and movement information.

The device is designed to operate with minimal user interaction and supports **Wi-Fi and 4G LTE Cat-M1 connectivity**. It prioritizes available Wi-Fi and automatically falls back to cellular connectivity when Wi-Fi is unavailable.

Collected information is transmitted to a cloud platform and made available through a **Flutter/Firebase mobile application**, allowing caregivers to monitor elderly users remotely.

For users interested in fitness, the system can additionally provide **activity and fitness tracking**, including movement and heart-rate information.

---

## 🎯 Problem Statement

Commercial remote vital-monitoring systems and smartwatches can present several barriers for elderly users, particularly those living independently or in rural environments.

These barriers can include:

* High upfront hardware costs
* Monthly software subscriptions
* High battery consumption
* Dependence on smartphones
* Complex Bluetooth pairing
* Dependence on local Wi-Fi networks
* Motion artifacts associated with wrist-worn monitoring
* Potential skin sensitivity from wrist-worn devices

This project proposes an affordable, infrastructure-independent monitoring platform using an ergonomic **upper-arm form factor**, dual-mode connectivity, and automated caregiver alerts.

The proposed target cost is **below $40**, while the telemetry system targets low cellular data usage.

---

## 🎯 Project Objectives

### Main Objective

To develop an affordable, dual-mode **Wi-Fi and LTE vital-sign telemetry platform** housed in an ergonomic upper-arm sleeve that provides continuous biometric streaming and automatic emergency alerts to caregivers.

### Specific Objectives

#### 1. Ergonomic Design

Develop a washable upper-arm sleeve containing a removable TPU-encapsulated electronics pod to improve comfort and reduce motion noise during optical pulse measurements.

#### 2. Dual-Mode Connectivity

Implement an event-driven network fallback system that prioritizes available Wi-Fi and automatically switches to **4G LTE Cat-M1** when Wi-Fi is unavailable.

#### 3. Low-Bandwidth Telemetry

Implement lightweight **MQTT messaging over TLS** to transmit vital signs, GPS coordinates, and movement speed while targeting monthly SIM data usage below **5 MB**.

#### 4. Caregiver Mobile Dashboard

Develop a real-time **Flutter/Firebase mobile application** providing:

* Real-time vital monitoring
* Historical baseline visualization
* GPS tracking
* Geofencing
* Automated push notifications
* Biometric anomaly alerts

#### 5. Fitness Tracking

Provide additional activity and fitness-tracking functionality for users who are interested in monitoring their physical activity, movement, and heart-rate information.

---

# ✨ Key Features

## ❤️ Vital Sign Monitoring

* Continuous Heart Rate monitoring
* SpO2 monitoring
* Historical vital-sign data
* Biometric anomaly detection
* Automated alerts

## 📍 Location & Movement

* Real-time GPS tracking
* Movement speed monitoring
* Geofencing
* Location-based alerts
* Historical location/activity information

## 🏃 Fitness Tracking

For users interested in personal fitness and activity monitoring, the system can provide:

* Activity tracking
* Movement monitoring
* Heart-rate monitoring during activities
* GPS-based activity tracking
* Historical activity information
* Fitness/activity trends
* Activity visualization

Fitness tracking is an **additional use case** and does not replace the primary remote elderly-care functionality.

## 📶 Connectivity

* Wi-Fi connectivity
* 4G LTE Cat-M1 fallback
* Automatic network switching
* MQTT communication
* TLS-secured telemetry

## 📱 Mobile Application

* User login
* Device pairing
* Real-time dashboard
* Historical data visualization
* Caregiver monitoring
* Fitness/activity dashboard
* Geofencing
* Push notifications

## 🔋 Hardware

* Low-power operation
* Rechargeable battery
* Removable electronics pod
* Washable wearable sleeve
* Upper-arm form factor

---

# 🏗️ System Architecture

The project consists of three primary layers:

### 1. Wearable IoT Layer

The wearable device collects biometric, location, and movement information.

```text
┌─────────────────────────────┐
│       Wearable Device       │
│                             │
│  MAX30102 → HR / SpO2       │
│  GPS      → Location        │
│  ESP32    → Processing      │
│  Battery  → Power           │
└──────────────┬──────────────┘
               │
               ▼
```

### 2. Connectivity & Cloud Layer

```text
             ┌─────────────────┐
             │ ESP32-Cellular  │
             └────────┬────────┘
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
      Wi-Fi Available     Wi-Fi Unavailable
             │                 │
             ▼                 ▼
          Wi-Fi           4G LTE Cat-M1
             │                 │
             └────────┬────────┘
                      │
                      ▼
                 MQTT over TLS
                      │
                      ▼
               Firebase Cloud
```

The device prioritizes Wi-Fi and automatically switches to LTE when Wi-Fi is unavailable.

### 3. Application Layer

```text
                   Firebase
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
 Caregiver Dashboard       Fitness Dashboard
          │                       │
          ▼                       ▼
  Elderly Monitoring       Activity Tracking
  Alerts & Location        Fitness Data
```

---

# 🔧 Hardware Components

| Component                            | Purpose                          |
| ------------------------------------ | -------------------------------- |
| **MAX30102 Pulse Oximeter**          | Heart Rate and SpO2 monitoring   |
| **ESP32-Cellular Board**             | Main controller and connectivity |
| **GPS Module**                       | Location and movement tracking   |
| **Rechargeable LiPo Battery**        | Power supply                     |
| **TPU-Encapsulated Electronics Pod** | Protects electronic components   |
| **3D-Printed Pod**                   | Houses the electronics           |
| **Washable Fabric Sleeve**           | Upper-arm wearable enclosure     |

The electronics pod is designed to be removable from the washable sleeve.

The sensor is positioned flush against the skin to support accurate readings and reduce motion artifacts.

---

# 💻 Software Stack

## Embedded System

* ESP32
* MAX30102 sensor integration
* GPS
* Wi-Fi
* 4G LTE Cat-M1
* MQTT
* TLS
* Deep-sleep power management

## Cloud

* Firebase
* MQTT-based telemetry
* Cloud data storage
* Push notifications

## Mobile Application

* Flutter
* Firebase
* Real-time monitoring
* Historical visualization
* Geofencing
* Fitness/activity tracking
* Caregiver alerts

---

# 📡 Connectivity Architecture

The system uses an automatic Wi-Fi/LTE fallback mechanism.

```text
                 ┌──────────────┐
                 │ Collect Data │
                 └───────┬──────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Wi-Fi Available?│
                └───────┬─────────┘
                    Yes │ No
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
        ┌──────────┐        ┌──────────┐
        │   Wi-Fi  │        │   LTE    │
        └────┬─────┘        └────┬─────┘
             │                   │
             └─────────┬─────────┘
                       ▼
                ┌─────────────┐
                │ MQTT / TLS  │
                └──────┬──────┘
                       ▼
                ┌─────────────┐
                │  Firebase   │
                └──────┬──────┘
                       ▼
                Mobile Application
```

---

# 📱 Application Functionality

## 👨‍👩‍👧 Caregiver Monitoring

Caregivers can access:

* Real-time Heart Rate
* SpO2 readings
* User location
* Movement speed
* Historical data
* Geofence status
* Biometric alerts
* Location-based notifications

## 🏃 Fitness & Activity Monitoring

Users interested in fitness can access:

* Activity information
* Movement tracking
* Heart-rate information
* GPS-based activity tracking
* Historical activity data
* Activity trends
* Fitness visualization

This allows the same wearable platform to support both **remote elderly care** and **personal fitness/activity monitoring**.

---

# 📋 Functional Requirements

The system is designed to support:

1. User login and device pairing
2. Continuous Heart Rate monitoring
3. Continuous SpO2 monitoring
4. GPS location tracking
5. Movement speed monitoring
6. Fitness and activity tracking
7. Historical fitness/activity visualization
8. Automatic Wi-Fi/LTE fallback
9. Cloud data storage
10. Historical vital-sign visualization
11. Geofencing
12. Location-based alerts
13. Biometric anomaly detection
14. Automated push notifications
15. Real-time caregiver dashboard
16. Fitness/activity dashboard

---

# 👥 Target Users

## Primary Users

* Elderly individuals
* Elderly people living alone
* Elderly individuals in rural settings
* Family caregivers

## Secondary Users

* Nurses
* Doctors
* Home-care service providers
* Individuals interested in personal fitness and activity tracking

## Beneficiaries

The project aims to improve elderly safety and independence while giving caregivers access to timely health and location information.

It can also provide useful fitness and activity information to users who want to monitor their physical activity.

---

# 📊 Data Flow

```text
Sensors
   │
   ├── Heart Rate
   ├── SpO2
   ├── GPS
   └── Movement
          │
          ▼
    ESP32-Cellular
          │
          ▼
   Wi-Fi / 4G LTE
          │
          ▼
      MQTT / TLS
          │
          ▼
      Firebase
          │
          ▼
    Flutter App
       /     \
      /       \
     ▼         ▼
Caregiver    Fitness
Dashboard   Dashboard
```

---

# 📁 Repository Structure

```text
cellular-upper-arm-vital-monitor/
│
├── hardware/
│   ├── circuit/
│   ├── pcb/
│   ├── 3d-models/
│   └── schematics/
│
├── firmware/
│   ├── src/
│   ├── sensors/
│   ├── connectivity/
│   └── gps/
│
├── mobile-app/
│   ├── lib/
│   ├── assets/
│   └── test/
│
├── cloud/
│   ├── firebase/
│   └── mqtt/
│
├── documentation/
│   ├── proposal/
│   ├── diagrams/
│   └── screenshots/
│
├── README.md
└── LICENSE
```

---

# 🚀 Getting Started

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
```

## 2. Enter the Project Directory

```bash
cd YOUR-REPOSITORY
```

## 3. Hardware Setup

Connect the MAX30102 sensor, GPS module, cellular connectivity hardware, and battery to the ESP32-Cellular development platform according to the project's circuit documentation.

## 4. Firmware Setup

Configure the firmware with the required:

* Wi-Fi credentials
* LTE/APN settings
* MQTT broker
* TLS certificates
* Firebase/cloud configuration
* GPS settings

## 5. Mobile Application

Navigate to the mobile application directory:

```bash
cd mobile-app
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

> Configuration requirements may change as the hardware, firmware, cloud infrastructure, and mobile application are developed.

---

# 🔐 Security

The proposed system uses **MQTT over TLS** for secure telemetry communication.

Security considerations include:

* Encrypted communication
* Secure authentication
* Protected Firebase access
* Secure device credentials
* Controlled caregiver access
* Protection of sensitive health and location information

---

# ⚠️ Important Disclaimer

This project is an **academic/student prototype** intended for research, learning, development, and demonstration purposes.

It is **not a certified medical device** and should not be used as a replacement for professional medical diagnosis, treatment, or emergency medical services.

Fitness information provided by the system should also be treated as informational rather than professional medical or fitness advice.

---

# 🔮 Future Improvements

Potential future development areas include:

* Additional biometric sensors
* Improved battery optimization
* More advanced anomaly detection
* Improved cellular connectivity
* Smaller electronics enclosure
* Improved waterproofing
* Advanced fitness analytics
* More detailed activity tracking
* Healthcare-provider integration
* Advanced caregiver analytics
* Expanded notification mechanisms
* Extensive real-world testing

---

# 👨‍💻 Development Team

1. **Theophany Bandure**
2. **Isheanesu Mzite**
3. **Elson Chakonza**
4. **Christisen Zembe**
5. **Leerose Bwanya**

---

# 📚 Project Documentation

The project proposal defines the problem, objectives, hardware architecture, proposed solution, target users, and functional requirements for the system.

Additional documentation, diagrams, hardware designs, firmware, cloud configuration, and mobile application source code will be added to this repository as development progresses.

---

# 📜 License

This project is currently intended for **academic and educational purposes**.

A formal open-source license can be added when the project is prepared for public distribution.

---

## ❤️ Project Vision

> **Affordable technology. Continuous monitoring. Greater independence. Better-informed caregivers.**

The project aims to combine affordable IoT technology, remote elderly monitoring, and optional fitness tracking into a single wearable platform.
