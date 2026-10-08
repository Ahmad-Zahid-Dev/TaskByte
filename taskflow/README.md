# TaskFlow – Task Management App for Gig Workers

TaskFlow is a productivity and task management app tailored for gig workers and freelancers to balance fast-paced deadlines, varied categories, and shifting schedules.

Built for Phase 1 with clean Flutter fundamentals, Provider-based reactive state management, in-memory mock services, custom design tokens, and comprehensive unit tests.

---

## 📱 Features

- **Onboarding Flow**: 3-screen animated intro highlighting workload tracking, priority sorting, and calendar scheduling.
- **Authentication (Phase 1 In-Memory)**:
  - Clean Login & Sign-up screens with real-time email & password validation.
  - Forgot password dialog.
  - Google Sign-In mock integration.
- **Home & Task Management**:
  - Gradient header with greeting, search bar, and filter chips (Status: *All / Pending / Completed*, Priority: *All / High / Medium / Low*).
  - Tasks grouped dynamically into **Overdue**, **Today**, **Tomorrow**, and **Upcoming**.
  - Interactive completion checkboxes with confetti burst animation on task completion.
  - Swipe-to-delete with an instantaneous "Undo" snackbar.
- **Add & Edit Task**:
  - Shared, reusable form screen with title, description, priority selector, category picker, and custom date picker.
- **Calendar View**:
  - Custom month grid with task indicator dots and day-by-day task lists.
- **Profile Screen**:
  - User details display, statistics overview, and sign-out flow.

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
├── services/            # In-memory services with seed datasets (AuthService, TaskService)
├── widgets/             # Reusable atomic UI components (buttons, textfields, chips, tiles)
├── screens/
│   ├── auth/            # Login and sign-up screens
│   ├── calendar/        # Calendar screen with month grid
│   ├── home/            # Home screen and grouped task list
│   ├── onboarding/      # 3-step animated onboarding
│   ├── profile/         # Profile & account screen
│   └── task_form/       # Add / Edit task modal screen
├── app.dart             # App root configuring MultiProvider & MaterialApp.router
└── main.dart            # Clean entrypoint
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

# Run unit & widget tests
flutter test

# Run app
flutter run
```

---

## 🧪 Testing & Code Quality

- **Static Analysis**: Clean pass (`flutter analyze` reports 0 issues).
- **Formatting**: Adheres strictly to `dart format`.
- **Unit Tests**: Full coverage for `TaskModel` serialization/deserialization, `TaskProvider` filtering, and CRUD operations with undo behavior.
