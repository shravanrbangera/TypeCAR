# 🏎️ TypeRacer — Multiplayer Typing Car Racing Game

A mobile car racing game built with **Flutter & Dart** and powered by **Firebase Realtime Database & Anonymous Auth**. Friends race against each other in real-time by typing sentences accurately. The faster and more accurately you type, the faster your car accelerates down the track!

---

## ✨ Features

- 🏎️ **Arcade Visual Design**: Dark charcoal theme (`#0B0F19`) with electric cyan (`#00E5FF`), neon green (`#00E676`), and nitro flame effects.
- 🎨 **6 Custom Arcade Race Cars**: Formula 1, Cyber Neon Coupe, Beach Sun Dazer Buggy, Old Timer Retro Muscle, Skull Monster Truck, and Phantom Hypercar with custom paint and stat ratings.
- 👥 **Real-Time Multiplayer (2–8 Players)**:
  - 6-character room codes with 1-tap Copy & Share.
  - Live lobby with avatars, custom cars, and ready status badges.
  - Host controls (start race, kick player, close room).
  - Safe host migration when host leaves.
- 🚦 **Synchronized Countdown**: 3-2-1-GO! countdown synchronized with server timestamp across all connected clients.
- ⌨️ **Precision Typing Engine**:
  - Green for correctly typed letters, red box with underline for mistakes.
  - Must fix errors with Backspace before advancing.
  - Standard WPM calculation `(chars / 5) / minutes`.
  - Accuracy and character streak tracking.
- 🔥 **Nitro Boost**: Flawless streak of 20 characters triggers blazing exhaust flames and a turbo speed boost!
- 🏁 **Live Racetrack**: Multi-lane asphalt racetrack with smooth interpolation between real-time database updates, dynamic nickname pills, and rumble curbs.
- 🏆 **Results & Rematch**: Podium ceremony with confetti particle explosions, full ranking table, and 1-tap host rematch restart.
- 🤖 **Offline Practice & Solo Bot Racing**: Full offline practice mode with AI bot racers (TurboBot, CyberDrifter) and instant retry.
- 🔒 **Dual-Mode Backend**: Works out of the box in Local Simulation Mode and seamlessly connects to Firebase Realtime Database.

---

## 🏗️ Architecture

```
lib/
├── main.dart                      # App entrypoint & system overlays
├── app.dart                       # MultiProvider DI root
├── core/
│   ├── theme/                     # AppColors, AppTheme, AppTypography
│   ├── constants/                 # AppConstants, SampleTexts library
│   ├── utils/                     # WpmCalculator, RoomCodeGenerator
│   └── audio/                     # AudioController (Sound & Haptics)
├── models/
│   ├── car_model.dart             # Car definitions & stat ratings
│   ├── player_model.dart          # Player state, progress, and WPM
│   ├── race_model.dart            # Race metadata & sync timestamps
│   ├── room_model.dart            # Room status & leaderboard sorting
│   └── user_stats_model.dart      # Lifetime stats & win rates
├── services/
│   ├── firebase_service.dart      # Safe Firebase init & error detection
│   ├── auth_service.dart          # Firebase Anonymous Auth + Guest UUID
│   ├── room_service_interface.dart# Abstract IRoomService contract
│   ├── room_service.dart          # Firebase Realtime Database implementation
│   ├── mock_room_service.dart     # Local multiplayer & AI bot engine
│   ├── storage_service.dart       # SharedPreferences persistence
│   └── typing_engine.dart         # Core typing verification & nitro engine
├── widgets/
│   ├── car/                       # CustomCarPainter, CarPreviewCard, NitroFlame
│   ├── track/                     # RacingTrack, RacingLane, RaceCountdown
│   ├── typing/                    # TypingPanel, TypingHUD, NitroMeter
│   ├── common/                    # ArcadeButton, ArcadeCard, GlowingAvatar, NeonText
│   └── modals/                    # HowToPlay, GarageCustomizer, FirebaseSetupGuide
└── screens/
    ├── splash_screen.dart         # Intro logo & animated racing car
    ├── home_screen.dart           # Garage profile, stats ribbon, main actions
    ├── create_room_screen.dart    # Room setup, text category, difficulty, max racers
    ├── join_room_screen.dart      # 6-character room code validator
    ├── lobby_screen.dart          # Player lobby, ready indicators, host controls
    ├── race_screen.dart           # Real-time multi-lane race track & typing console
    ├── results_screen.dart        # Victory podium, confetti, scoreboard, rematch
    └── practice_screen.dart       # Offline practice & solo bot racing
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run Static Analysis
```bash
dart analyze
```

### 4. Run the App
```bash
flutter run
```

---

## 🧪 Testing

The repository includes a comprehensive unit and widget test suite covering:
- `test/typing_engine_test.dart`: Keystroke verification, backspace behavior, streak counting, and finish triggers.
- `test/wpm_calculator_test.dart`: WPM calculation, division by zero safeguards, accuracy percentages, and duration formatting.
- `test/room_code_test.dart`: 6-character room code generation, collision resistance, and validation.
- `test/room_model_test.dart`: Leaderboard finish-time sorting, all-ready verification, and JSON serialization.
- `test/widget_test.dart`: Widget tests for `ArcadeButton`, `GlowingAvatar`, `CarPreviewCard`, `RacingTrackWidget`, and `TypingPanelWidget`.
