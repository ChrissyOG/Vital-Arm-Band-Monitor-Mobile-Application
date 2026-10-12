# ESP32 Firmware Module

**Lead:** Theophany Bandure (Embedded Systems & IoT Engineer)  
**Target:** ESP32 NodeMCU DevKit V1 (30-pin)

---

## 🛠️ Required Libraries
If flashing via the **Arduino IDE**, install the following libraries via the Library Manager (`Ctrl + Shift + I`):
1. **ArduinoJson** (by Benoît Blanchon)
2. **OneWire** (by Paul Stoffregen)
3. **DallasTemperature** (by Miles Burton)
4. **TinyGPSPlus** (by Mikal Hart)
5. **SparkFun MAX3010x Pulse and Proximity Sensor Library**

If flashing via **PlatformIO (VS Code)**:
All dependencies are automatically managed via `platformio.ini`.

---

## 🚀 How to Flash Firmware

1. Connect the ESP32 to your PC via a Micro-USB data cable.
2. Open `firmware/src/main.cpp` in VS Code / Arduino IDE.
3. Update `WIFI_SSID` and `WIFI_PASSWORD` with your local Wi-Fi credentials.
4. Set `BACKEND_BASE_URL` to Lee Rose's backend server IP (e.g., `http://192.168.1.100:5000`).
5. Select Board: **ESP32 Dev Module** / `esp32doit-devkit-v1`.
6. Select Port: (e.g. `COM3` on Windows).
7. Upload and open the Serial Monitor at baud rate **`115200`**.

---

## 🔌 Hardware Pinout Summary
Refer to [WIRING_PINOUT_GUIDE.md](./WIRING_PINOUT_GUIDE.md) for breadboard connection diagrams.
* **MAX30102:** $\text{I}^2\text{C}$ on `GPIO 21` (SDA) and `GPIO 22` (SCL)
* **DS18B20:** 1-Wire on `GPIO 4` (with 4.7kΩ pull-up to 3.3V)
* **GPS NEO-6M:** UART2 on `GPIO 16` (RX) and `GPIO 17` (TX)
* **Panic Button:** `GPIO 15` (Internal Pull-up)
* **Status LED:** `GPIO 2`
