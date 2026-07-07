# 🎮 GameHub

GameHub is an offline Flutter application that brings together multiple classic mini-games in a single, modern interface. The project is built with a shared architecture, reusable widgets, persistent local storage, and Material 3 design, making it easy to add new games and features over time.

## Features

### Core Application

* Material 3 UI with custom coral and teal color palette
* Light and Dark theme support
* Theme and sound preferences saved using Shared Preferences
* Offline gameplay
* Responsive layout for Android devices
* Navigation powered by `go_router`

### Shared Components

* Reusable `GameTileCard` for the Home screen
* Reusable `ScoreBoard` widget
* Generic `GameOverDialog`
* Shared "Coming Soon" placeholder widget
* Centralized game catalog for easy expansion

### Available Games

#### ✅ Tic Tac Toe

* Two-player local mode
* Easy AI (random moves)
* Hard AI (Minimax with Alpha-Beta pruning)
* Win and draw detection
* Winning line highlight
* Best win streak saved locally

#### ✅ Memory Match

* 4×4 and 6×6 difficulty levels
* Move counter
* Game timer
* Fastest completion time tracking
* Animated card flipping
* Persistent best scores

### Coming Soon

* 2048
* Flappy Bird
* Sudoku

---

## Project Structure

```text
lib/
├── core/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── home/
│   ├── tic_tac_toe/
│   ├── memory_match/
│   ├── game_2048/
│   ├── flappy_bird/
│   └── sudoku/
│
├── services/
│   ├── settings_service.dart
│   └── storage_service.dart
│
└── main.dart
```

---

## Technologies Used

* Flutter
* Dart
* Provider
* Go Router
* Shared Preferences
* Google Fonts

---

## Getting Started

### Prerequisites

* Flutter SDK
* Android Studio or Visual Studio Code
* Android Emulator or Physical Android Device

### Installation

Clone the repository:

```bash
git clone <repository-url>
cd game_hub
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Building the Android APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To generate an Android App Bundle (AAB) for Google Play:

```bash
flutter build appbundle --release
```

---

## Local Storage

The application uses Shared Preferences to persist:

* Theme mode
* Sound preference
* Best game scores
* Best completion times
* Coin balance

All data is stored locally on the device and works completely offline.

---

## Roadmap

* ✅ Project scaffold
* ✅ Application theme
* ✅ Navigation
* ✅ Home screen
* ✅ Settings
* ✅ Shared widgets
* ✅ Local storage
* ✅ Tic Tac Toe
* ✅ Memory Match
* ✅ 2048
* ✅ Flappy Bird
* ✅ Sudoku
* ⬜ Sound effects 
* ⬜ Coin and reward system
* ✅ Splash screen
* ✅ Custom app icon

*Ongoing: Sound Effects, Coin and reward system
---

## License

This project is intended for educational and personal use.
