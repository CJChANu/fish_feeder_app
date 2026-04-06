# 🐟 Smart Fish Feeder App

A Flutter-based mobile application for monitoring and controlling an ESP32-powered smart fish feeder via Firebase Realtime Database. The app provides real-time sensor data, automated feeding schedules, feeding history, and push notifications — all from your phone.

---

## ✨ Features

- 📊 **Live Dashboard** — Real-time display of water temperature, pH level, and turbidity sensor readings
- 🎮 **Remote Control** — Trigger feeding manually or set up automated schedules directly from the app
- 📋 **Feeding History** — Browse logs of past feeding events with timestamps
- 🔔 **Notifications** — Receive alerts for feeding events and abnormal sensor readings
- 📱 **Device Picker** — Connect and manage multiple fish feeder devices
- ⚙️ **Settings** — Customize app preferences, thresholds, and notification behavior
- 🌐 **Connectivity Check** — Detects internet/Firebase connectivity status gracefully

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Backend / Database | Firebase Realtime Database |
| State & Storage | `shared_preferences` |
| Charts | `fl_chart` |
| Connectivity | `connectivity_plus` |
| Hardware | ESP32 microcontroller with RTC, temperature, pH & turbidity sensors |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point, Firebase initialization
└── src/
    ├── app.dart               # App root widget & routing
    ├── models/                # Data models (sensor readings, feed events, etc.)
    ├── services/              # Firebase service layer
    ├── storage/               # Local storage with shared_preferences
    ├── notifications/         # Notification handling logic
    └── ui/
        ├── dashboard/         # Live sensor data screen
        ├── control/           # Manual & scheduled feeding control
        ├── history/           # Feeding event history screen
        ├── home/              # Home/landing screen
        ├── device_picker/     # Device selection screen
        ├── notifications/     # Notifications screen
        ├── settings/          # App settings screen
        ├── components/        # Shared UI components
        └── widgets/           # Reusable custom widgets
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.10.7`
- A configured [Firebase](https://firebase.google.com/) project with Realtime Database enabled
- An ESP32 device running the fish feeder firmware connected to the same Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CJChANu/fish_feeder_app.git
   cd fish_feeder_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Realtime Database**
   - Add your Android/iOS app to the Firebase project
   - Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) and place them in the respective platform directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_database` | Realtime Database reads/writes |
| `shared_preferences` | Local persistent storage |
| `connectivity_plus` | Network connectivity detection |
| `fl_chart` | Sensor data charts and graphs |
| `intl` | Date/time formatting |
| `cupertino_icons` | iOS-style icon set |

---

## 🔧 Hardware Requirements

This app is designed to work alongside an **ESP32** smart fish feeder device equipped with:
- 🌡️ **Temperature sensor** — Monitors water temperature
- 🧪 **pH sensor** — Measures water acidity/alkalinity
- 💧 **Turbidity sensor** — Tracks water clarity
- ⏰ **RTC module** — Keeps accurate time for scheduled feedings
- 🔌 **Servo/motor** — Dispenses fish food

The ESP32 firmware should write sensor data and read feeding commands from the same Firebase Realtime Database that this app connects to.

---

## 📱 Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Linux | ✅ |
| macOS | ✅ |
| Windows | ✅ |

---

## 📄 License

This project is for educational and personal use. All rights reserved © CJChANu.
