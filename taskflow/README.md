# TaskFlow – Task Management App for Gig Workers

TaskFlow is a productivity and task management app tailored for gig workers and freelancers to balance fast-paced deadlines, varied categories, and shifting schedules.

Built across **Phase 1** (UI/UX, design system, Provider state management) and **Phase 2** (Firebase Auth with Google Sign-In, Cloud Firestore real-time streams, offline cache, and secure per-user rules).

---

## 📱 Features

- **Onboarding Flow**: 3-screen animated intro highlighting workload tracking, priority sorting, and calendar scheduling.
- **Authentication (Phase 2 Live Firebase)**:
  - Email & Password sign-up and sign-in with instant inline validation and user-friendly Firebase error mapping.
  - Native Google Sign-In with configured Android debug SHA-1 and SHA-256 certificate fingerprints.
  - Password reset email delivery.
  - Auto-login via `FirebaseAuth.authStateChanges()` listener.
- **Home & Task Management**:
  - Gradient header with personalized greeting, search bar, and filter chips (*Status: All / Pending / Completed*, *Priority: All / High / Medium / Low*).
  - Tasks grouped dynamically into **Overdue**, **Today**, **Tomorrow**, and **Upcoming**.
  - Interactive completion checkboxes with confetti burst animation.
  - Swipe-to-delete with an instantaneous "Undo" SnackBar.
- **Cloud Firestore Real-Time Sync & Offline Support**:
  - Tasks stored under `users/{userId}/tasks/{taskId}`.
  - Real-time updates with Firestore reactive streams.
  - Offline persistence enabled by default.
  - Initial seed tasks seeded automatically on new account creation.
- **Add & Edit Task**:
  - Shared, reusable form screen with title, description, priority selector, category picker, and custom date picker.
- **Calendar View**:
  - Custom month grid with task indicator dots and day-by-day task lists.
- **Profile Screen**:
  - User details display, statistics overview, and sign-out flow.

---

## 🔑 Firebase & Android Configuration

- **Firebase Project ID**: `whatbytes-task-app-68831`
- **Application / Package ID**: `com.whatbytes.taskflow`
- **Registered SHA-1**: `E5:21:96:77:DF:1E:F7:74:16:7A:2D:40:7D:8D:56:E4:68:10:89:EA`
- **Registered SHA-256**: `96:BE:CA:74:CE:40:04:55:74:88:04:03:9C:06:25:28:0C:0E:3E:ED:CE:06:A8:51:1D:D4:BE:52:C6:8B:BE:CD`
- **Firestore Security Rules**: Deployed with strict per-user isolation (`request.auth.uid == userId`).

---

## 🏗 Architecture & Code Structure

```text
lib/
├── core/
│   ├── constants/       # App strings, constants
│   ├── router/          # GoRouter configuration & page transitions
│   ├── theme/           # Color tokens, typography, ThemeData
│   └── utils/           # Date grouping, regex validators
├── models/              # Immutable data models (TaskModel, AppUser)
├── providers/           # Provider state management (AuthProvider, TaskProvider)
├── services/            # Services with Firebase & In-Memory options (AuthService, TaskService)
├── widgets/             # Reusable atomic UI components (buttons, textfields, chips, tiles)
├── screens/
│   ├── auth/            # Login and sign-up screens
│   ├── calendar/        # Calendar screen with month grid
│   ├── home/            # Home screen and grouped task list
│   ├── onboarding/      # 3-step animated onboarding
│   ├── profile/         # Profile & account screen
│   └── task_form/       # Add / Edit task modal screen
├── firebase_options.dart # Generated FlutterFire options for Android & iOS
├── app.dart             # App root configuring MultiProvider & MaterialApp.router
└── main.dart            # Firebase initialization & runApp
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Dart SDK 3.x+

### Setup
```bash
# Clone and enter directory
cd taskflow

# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit tests
flutter test

# Run app on Android device / emulator
flutter run
```

---

## 🧪 Testing & Code Quality

- **Static Analysis**: `flutter analyze` reports 0 issues.
- **Formatting**: Adheres strictly to `dart format`.
- **Unit Tests**: Full test suite passing in `test/widget_test.dart`.
