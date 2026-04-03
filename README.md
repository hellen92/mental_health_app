# Moti - Mental Health App

A Flutter app designed to support mental health and wellness with features like mood tracking, breathing exercises, daily missions, and progress monitoring.

## Features

- 🎯 **Daily Missions** - Personalized wellness challenges
- 🧘 **Breathing Sessions** - Guided breathing exercises for calm
- 😊 **Mood Tracking** - Log and track your daily moods
- 📊 **Progress Dashboard** - Visualize your wellness journey
- 🎨 **Kawaii Mascot** - Cute companion to motivate you
- 🏃 **Movement Tracking** - Log physical activity

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for emulator or device support)
- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hellen92/mental_health_app.git
   cd mental_health_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## Running the App

### On Emulator/Simulator

1. **List available devices:**
   ```bash
   flutter devices
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

   Or, specify a device:
   ```bash
   flutter run -d <device_id>
   ```

### On Physical Device

1. **Connect your Android/iOS device via USB**

2. **Enable Developer Mode** (Android) or trust the device (iOS)

3. **Run the app:**
   ```bash
   flutter run
   ```

### Run in Release Mode

For better performance:
```bash
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── app.dart             # Main app widget
│   ├── app_shell.dart       # Navigation shell
│   └── app_state.dart       # App state management
├── features/
│   ├── home/                # Home screen
│   ├── calm/                # Breathing exercises
│   ├── move/                # Movement tracking
│   ├── progress/            # Progress dashboard
│   └── onboarding/          # Onboarding flow
├── models/                  # Data models
├── services/                # Business logic & storage
├── theme/                   # App theming
└── widgets/                 # Reusable components
```

## Development

### Hot Reload
During development, use hot reload for fast iteration:
```bash
flutter run
# Then press 'r' in the terminal to hot reload
# Or press 'R' for hot restart
```

### Debugging
```bash
flutter run -v  # Verbose mode for debugging
```

## Building

### Android APK
```bash
flutter build apk
```

### iOS IPA
```bash
flutter build ios
```

## Support

For issues or questions, please open an issue on GitHub.
