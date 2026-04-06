# 🐟 Fish_Feeder_App

A Flutter-based mobile application for monitoring and controlling the **Smart Fish Feeder System** through Firebase Realtime Database. This app acts as the companion mobile interface for the ESP32/Arduino-based feeder hardware.

***

## ✨ Features

- 📊 **Live Dashboard** — Monitor water temperature, pH level, and turbidity data in real time.
- 🎮 **Remote Feeding Control** — Trigger feeding manually from your mobile device.
- ⏰ **Feeding Schedule Support** — Work with scheduled feeding logic provided by the connected device.
- 📋 **Feeding History** — Review previous feeding events and recorded activity.
- 🔔 **Notifications** — Receive alerts and feeder-related updates.
- 📱 **Device Management** — Select and manage supported fish feeder devices.
- ⚙️ **Settings** — Store local preferences and customize app behavior.

***

## 🔗 Related Repository

This repository contains the **mobile application** for the Smart Fish Feeder project.

The **hardware and firmware** side of the system is maintained separately in:

- **Firmware Repository:** [CJChANu/FishFeeder](https://github.com/CJChANu/FishFeeder)

Use the firmware repository for:
- ESP32 / Arduino source code
- Sensor integration and hardware control
- Servo or feeder motor logic
- Real-time device-side Firebase communication
- Embedded setup and hardware wiring

Together, **Fish_Feeder_App** and **FishFeeder** form the complete Smart Fish Feeder solution.

***

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile Framework | Flutter (Dart) |
| Backend | Firebase Realtime Database |
| Local Storage | `shared_preferences` |
| Connectivity | `connectivity_plus` |
| Charts | `fl_chart` |
| Formatting | `intl` |

***

## 📁 Project Structure

```text
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── models/
    ├── notifications/
    ├── services/
    ├── storage/
    └── ui/
        ├── components/
        ├── control/
        ├── dashboard/
        ├── device_picker/
        ├── history/
        ├── home/
        ├── notifications/
        ├── settings/
        └── widgets/
```

***

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- A configured Firebase project
- Android Studio, VS Code, or another Flutter-compatible IDE
- The matching firmware from the [FishFeeder](https://github.com/CJChANu/FishFeeder) repository

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/CJChANu/Fish_Feeder_App.git
   cd Fish_Feeder_App
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Make sure your Firebase Realtime Database is enabled and matches the feeder firmware configuration

4. Run the app
   ```bash
   flutter run
   ```

***

## 📦 Main Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Initializes Firebase |
| `firebase_database` | Connects to Realtime Database |
| `shared_preferences` | Stores local settings |
| `connectivity_plus` | Detects connectivity state |
| `fl_chart` | Displays charts and sensor data visually |
| `intl` | Formats date and time values |

***

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

***

## 📄 License

This project uses the custom license included in this repository. See the `LICENSE` file for full usage terms.
