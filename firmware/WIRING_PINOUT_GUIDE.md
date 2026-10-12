# ESP32 Hardware Wiring & Pinout Guide

**Project:** IoT-Enabled Vital Signs & Location Monitoring Arm Band  
**Hardware Lead:** Theophany Bandure (Embedded Systems & IoT Engineer)  
**Microcontroller:** ESP32 NodeMCU DevKit V1 (30-Pin)  

---

## 1. Pin Allocation Matrix

| Subsystem / Sensor | Sensor Pin | ESP32 GPIO Pin | Protocol | Notes |
|:---|:---|:---|:---|:---|
| **MAX30102** (Pulse Oximeter & HR) | **VCC** | `3V3` | Power | Use clean 3.3V rail |
| | **GND** | `GND` | Power | Common ground |
| | **SDA** | `GPIO 21` | $\text{I}^2\text{C}$ (Data) | Default ESP32 $\text{I}^2\text{C}$ SDA |
| | **SCL** | `GPIO 22` | $\text{I}^2\text{C}$ (Clock) | Default ESP32 $\text{I}^2\text{C}$ SCL |
| | **INT** | `GPIO 19` | Interrupt | Optional: FIFO ready interrupt |
| **DS18B20** (Body Temperature) | **VDD** | `3V3` | Power | 3.0V – 5.5V supported |
| | **GND** | `GND` | Power | Common ground |
| | **DQ** | `GPIO 4` | 1-Wire Data | **Requires 4.7 kΩ pull-up resistor** between VDD & DQ |
| **NEO-6M / NEO-8M** (GPS Module) | **VCC** | `3V3` / `5V` (VIN) | Power | 3.3V logic tolerant, VIN for 5V reg |
| | **GND** | `GND` | Power | Common ground |
| | **TXD** | `GPIO 16` (`RX2`) | UART2 (ESP32 RX) | Receives NMEA sentences |
| | **RXD** | `GPIO 17` (`TX2`) | UART2 (ESP32 TX) | Sends configuration commands |
| **SOS Emergency Button** | **Pin 1** | `GPIO 15` | Digital Input | Internal `INPUT_PULLUP` enabled |
| | **Pin 2** | `GND` | Power | Pressed = Active LOW (0V) |
| **Status Indicator LED** | **Anode (+)** | `GPIO 2` | Digital Output | Built-in Blue LED / External with 220 Ω resistor |
| | **Cathode (-)** | `GND` | Power | Common ground |

---

## 2. Power Supply & Battery Integration
* **Nominal Battery:** 3.7V 800mAh–1200mAh Single-cell LiPo battery.
* **Charging Module:** TP4056 Micro-USB / USB-C Li-Ion charging board with over-discharge protection (DW01A).
* **Voltage Regulation:** Output from TP4056 $\rightarrow$ connected to ESP32 `VIN` (via onboard LDO) or a high-efficiency 3.3V Buck-Boost regulator (e.g. ME6211).
* **Battery Level Sensing:** Voltage divider ($100\text{ k}\Omega / 100\text{ k}\Omega$) connected to `GPIO 34` (ADC1_CHANNEL_6) to measure battery voltage safely ($0\text{V} - 4.2\text{V} \rightarrow 0\text{V} - 2.1\text{V}$).

---

## 3. Breadboard Wiring Instructions

1. **Power Rails:**
   - Connect ESP32 `3V3` pin to the breadboard positive (+) red rail.
   - Connect ESP32 `GND` pin to the breadboard negative (-) blue rail.
2. **MAX30102 Connection:**
   - Connect VCC $\rightarrow$ `3V3`, GND $\rightarrow$ `GND`.
   - Connect SDA $\rightarrow$ `GPIO 21`, SCL $\rightarrow$ `GPIO 22`.
   - *Note:* Most breakout boards have internal 4.7kΩ pullups. If using raw sensor, add 4.7kΩ pullups to 3.3V.
3. **DS18B20 Connection:**
   - Connect Pin 1 (GND) $\rightarrow$ `GND`.
   - Connect Pin 3 (VDD) $\rightarrow$ `3V3`.
   - Connect Pin 2 (Data/DQ) $\rightarrow$ `GPIO 4`.
   - Place a `4.7 kΩ` resistor across Pin 2 (DQ) and Pin 3 (VDD).
4. **GPS NEO-6M Connection:**
   - Connect VCC $\rightarrow$ `3V3` (or `VIN` if using a 5V-only regulator board), GND $\rightarrow$ `GND`.
   - Connect GPS `TX` $\rightarrow$ ESP32 `GPIO 16`.
   - Connect GPS `RX` $\rightarrow$ ESP32 `GPIO 17`.
   - Position GPS antenna near an open window or outdoors for initial satellite lock (fix LED will blink).
5. **Emergency SOS Button:**
   - Connect one leg of the tactile push button to `GPIO 15`.
   - Connect the opposite leg to `GND`. No external resistor needed (handled in software via `INPUT_PULLUP`).
