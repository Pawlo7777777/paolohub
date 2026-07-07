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

## Available Games

### ✅ Tic Tac Toe

* Play against another player locally or challenge the AI.
* Easy mode uses random moves, while Hard mode uses the Minimax algorithm with Alpha-Beta pruning.
* Tracks win streaks and saves the best streak locally.

### ✅ Memory Match

* Match pairs of cards in the shortest time possible.
* Includes 4×4 and 6×6 difficulty levels.
* Tracks moves, elapsed time, and best completion times.

### ✅ 2048

* Slide and merge numbered tiles to reach the 2048 tile.
* Supports swipe gestures with smooth tile movement.
* Best score is saved locally.

### ✅ Flappy Bird

* Tap to keep the bird flying while avoiding obstacles.
* Features score tracking and persistent high scores.
* Simple physics-based gameplay.

### ✅ Sudoku

* Solve Sudoku puzzles with a clean and intuitive interface.
* Includes puzzle validation and completion detection.
* Tracks completion time and best records.

## Coming Soon

* 🔊 Sound Effects
* 🪙 Coin & Reward System
* ✨ Additional mini-games and gameplay improvements



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
git clone https://github.com/Pawlo7777777/paolohub
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
* ✅ Splash screen
* ✅ Custom app icon
---

## License

This project is intended for educational and personal use.
