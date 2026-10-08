# ⚡ TaskByte — Gig Worker Task Management App

TaskByte is a clean, modern task manager built for gig workers and freelancers to effortlessly manage fast-paced tasks, deadlines, priorities, and schedules with audio feedback and real-time cloud sync.

---

## 🛠 Tech Stack

- **Framework**: Flutter 3.x (Dart 3.x) — Android, iOS & Web
- **State Management**: Provider (reactive MVVM pattern)
- **Backend & Auth**: Firebase Auth (Email/Password + Google Sign-In) & Cloud Firestore
- **Design & Typography**: Google Fonts (Poppins), custom `#6C63FF` design system
- **Sound & Haptics**: AudioPlayers with offline WAV sound effects and haptic feedback
- **Animations**: Flutter Animate, custom page transitions & micro-interactions

---

## 🏛 Code Architecture

The codebase follows a **Clean, Layered Architecture** with clear separation of concerns:

```
lib/
├── core/         # Theme tokens, GoRouter routes, constants, sound & date helpers
├── models/       # Immutable data models (TaskModel, AppUser, Priority)
├── services/     # Firebase Auth, Cloud Firestore & In-Memory fallback services
├── providers/    # Reactive state management (AuthProvider, TaskProvider with optimistic UI)
├── screens/      # Feature screens (Onboarding, Auth, Home, Calendar, TaskForm, Profile)
└── widgets/      # Reusable components (TaskTile, FilterBar, AppButton, AppTextField)
```

**Key Architectural Highlights**:
- **Optimistic UI Updates**: Task creation, deletion, and undo update the UI instantly without network lag.
- **Dependency Inversion**: Core business logic relies on service contracts, allowing seamless in-memory or Firebase switching.
- **Reactive Streams**: Real-time Firestore sync with automated sample task seeding for new users.

---

## 🚀 Simple Setup Guide (Step-by-Step)

Follow these simple steps to run the app:

### 1. Prerequisites
- Install **Flutter SDK** on your computer ([flutter.dev](https://flutter.dev)).
- Have an Android phone/emulator or Google Chrome browser ready.

### 2. Download & Install Packages
Open your terminal in the project directory and run:
```bash
flutter pub get
```

### 3. Setup Environment File (.env)
Copy `.env.example` to create your local `.env` file:
```bash
cp .env.example .env
```
*(All sensitive Firebase keys and IDs are securely stored in `.env` and excluded from Git via `.gitignore`.)*

### 4. Run the Application
- **Run in Google Chrome**:
  ```bash
  flutter run -d chrome
  ```
- **Run on Android Phone / Emulator**:
  ```bash
  flutter run
  ```
- **Build Release APK**:
  ```bash
  flutter build apk --release
  ```
  *(Note: ensure there is no space between `--` and `release`)*

---

## 📱 Key Features
- **Smart Grouping**: Tasks automatically organized into Overdue, Today, Tomorrow, and Later.
- **Sound Effects**: Uplifting chime on task creation; celebratory fanfare on task completion.
- **Modern Filters**: Clean unified filters for Status, Priority, and Category (Personal, Work, Study).
- **Calendar View**: Visual month calendar with workload dots and single-tap date filtering.
- **Instant Undo**: Floating snackbar allows 1-tap recovery for deleted tasks.
