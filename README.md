<div align="center">

# Voltry

**Snap a meal, get its calories and macros.**

![Flutter](https://img.shields.io/badge/Flutter-3.44-1F1A17?style=flat-square&logo=flutter&logoColor=54C5F8)
![Dart](https://img.shields.io/badge/Dart-3.12-1F1A17?style=flat-square&logo=dart&logoColor=40C4FF)
![Gemini](https://img.shields.io/badge/AI-Gemini%20via%20Firebase-1F1A17?style=flat-square&logo=googlegemini&logoColor=8E75FF)
![sqflite](https://img.shields.io/badge/sqflite-SQLite-1F1A17?style=flat-square&logo=sqlite&logoColor=8FD3F4)
![Riverpod](https://img.shields.io/badge/State-Riverpod%203-1F1A17?style=flat-square)
![Local first](https://img.shields.io/badge/Local--first-No%20account-FF5A5F?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-FFD23F?style=flat-square)

</div>

Voltry is a Flutter app for iOS and Android that estimates the nutrition of a meal from a photo. Gemini, called through Firebase AI Logic, returns the meal name, calories, protein, carbs and fat for the whole plate as schema-constrained JSON. The app validates that answer before showing it, saves the meals you confirm to an on-device SQLite database, and tracks today's total against your daily calorie target. There is **no account and no backend of its own**: meal history, photos and settings stay on the device, and the only network call is the photo analysis itself.

---

## Contents

- [Screenshots](#screenshots)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Data & Storage](#data--storage)
- [AI & Security](#ai--security)
- [Build & Distribution](#build--distribution)
- [Testing](#testing)
- [License](#license)

---

## Screenshots

The three main screens:

| Home | Analyze | History |
| :---: | :---: | :---: |
| <img src="docs/screenshots/home.png" width="100%" alt="Home: today's calories against the target, macro totals, and today's meals"> | <img src="docs/screenshots/analyze.png" width="100%" alt="Analyze: the AI estimate for a photo, with Save and Retake"> | <img src="docs/screenshots/history.png" width="100%" alt="History: meals grouped by day with daily totals"> |
| Today's calories against the target, macro tiles, today's meals, and the active AI model | The AI estimate for one photo, with Save and Retake | Meals grouped by day with daily totals, swipe to delete |

---

## Features

| Area | Capabilities |
| --- | --- |
| **Photo analysis** | Take a photo or pick one from the gallery with the camera button in the middle of the navbar. Gemini estimates the meal name, calories, protein, carbs and fat for everything on the plate |
| **Validated AI output** | The answer is schema-constrained JSON, then checked for type and range before anything reaches the UI. Photos without food get a *No food found* state instead of made-up numbers |
| **Explicit save** | Nothing is stored until you tap **Save**, so a bad estimate can be discarded or retaken |
| **Today** | Today's calories with a ring showing the percentage of your target (and *kcal over* past 100%), protein / carbs / fat tiles, and today's meals |
| **Calorie target** | Edit the daily target from the Home card. Whole numbers from 800 to 5,000 kcal |
| **History** | Meals grouped by day with daily totals (*Today*, *Yesterday*, *Sat, 28 Sep*). Swipe to delete, with Undo |
| **Meal detail** | Photo, date and time, the nutrition card, and delete with confirmation |
| **AI model picker** | Switch between four Gemini models from the Home header. Each free-tier model has its own quota, and when one runs out the Analyze screen offers **Switch AI model** and re-runs the same photo |
| **Error handling** | Offline and timeouts, a used-up AI quota, denied camera or photo access, and storage errors each get a specific message and a way forward |
| **Day rollover** | *Today* moves forward at local midnight and whenever the app returns to the foreground, so opening it in the morning never shows yesterday's totals |
| **Design system** | Candy Sport: color, type and radius tokens in a `ThemeExtension`, the Urbanist font, and a floating blurred navbar. Widgets take every visual value from the theme |

---

## Tech Stack

| Need | Package |
| --- | --- |
| State management | `flutter_riverpod` (Riverpod 3) |
| Navigation | `go_router`, with a `StatefulShellRoute` for the two tabs |
| AI | `firebase_ai` (Firebase AI Logic, Gemini Developer API), `firebase_core` |
| Camera and gallery | `image_picker` |
| Local database | `sqflite` |
| Files | `path_provider`, `path` |
| Settings | `shared_preferences` |
| IDs and formatting | `uuid`, `intl` |
| Loading animation | `lottie` |
| App icon | `flutter_launcher_icons` (dev) |
| Testing | `flutter_test`, `sqflite_common_ffi` (dev) |

**No code generation.** Models, their `fromRow` / `toRow` mapping, and every Riverpod provider are written by hand. There is no `freezed`, `json_serializable`, `riverpod_generator` or `build_runner`, so every file reads as it runs. The Urbanist font ships as an asset instead of coming from `google_fonts`.

---

## Architecture

Each feature is split into three layers, and dependencies only point one way:

```text
Widget → Controller (Riverpod Notifier) → Repository / Analyzer → sqflite · files · shared_preferences · Gemini
```

```text
features/<feature>/
├── domain/              Hand-written models, sealed result types, pure business rules
├── data/                Repositories, the Gemini analyzer and its parser, photo picking and storage
└── presentation/
    ├── controllers/     Riverpod Notifier / AsyncNotifier, the glue between data and UI
    ├── states/          Sealed state classes for screens with several states
    ├── pages/           Full screens
    └── widgets/         Widgets local to the feature
```

### Layer rules

| Layer | May use | Must not use |
| --- | --- | --- |
| `domain` | Plain Dart, `flutter/foundation` | Widgets, Riverpod, sqflite, Firebase |
| `data` | The one SDK it owns (see below), domain models, `AppException`, its own provider | Widgets, controllers, letting third-party exceptions escape |
| `presentation/controllers` | Repositories and the analyzer through `ref`, pure domain functions | sqflite, files, Firebase, widgets |
| `presentation/pages` + `widgets` | `ref.watch` on controllers, theme tokens | Data sources, business rules, hard-coded colors or font sizes |

### One owner per data source

Every external source is touched by exactly one class, and everything else reaches it through a provider so tests can swap in a fake:

| Source | Only class allowed to touch it |
| --- | --- |
| sqflite | `LocalMealLogRepository` (plus `app_database.dart` to open the file) |
| Photo files | `PhotoStorage` |
| shared_preferences | `CalorieTargetRepository`, `AiModelRepository` |
| firebase_ai | `GeminiFoodAnalyzer` |
| image_picker | `PhotoPicker` |

These classes also translate third-party exceptions (`SocketException`, `TimeoutException`, Firebase AI errors, `DatabaseException`, `FileSystemException`, `PlatformException`) into a sealed `AppException`. The UI only ever sees `AppException`, and a photo without food is a `NotFood` result rather than an exception.

Business rules are pure functions with their own unit tests: `parseAnalysis` for the AI answer, `summarizeDay` and `groupByDay` for totals, `dayLabel`, target validation, and `errorMessage`. Controllers only connect them to the UI. Meals are read through a `MealLogRepository` interface, so another storage backend can be added without touching any screen.

### Layers per feature

| Feature | `domain` | `data` | `presentation` |
| --- | :---: | :---: | --- |
| `analysis` | ✓ | ✓ | controllers, states, pages, widgets |
| `meal_log` | ✓ | ✓ | controllers, pages, widgets |
| `calorie_target` | ✓ | ✓ | controllers, widgets |

Deliberate exceptions, so they are not mistaken for drift:

- **[`snap_meal_flow.dart`](lib/features/analysis/presentation/snap_meal_flow.dart) sits at the root of `analysis/presentation/`.** It is a flow (photo source sheet → picker → Analyze → back to the sheet on Retake), not a page or a widget, and it is started from the navbar camera button in [`app_shell.dart`](lib/core/router/app_shell.dart) so both tabs share it.
- **Only `analysis` has `states/`.** The Analyze screen has four states (loading, result, not food, failure), modelled as a sealed `AnalyzeState`. The other controllers expose a plain `AsyncValue<List<MealLog>>` or `int`.
- **`calorie_target` has no `pages/`.** Its only UI is a dialog opened from the Home card.

The rules above are also documented for contributors in [CLAUDE.md](CLAUDE.md).

---

## Project Structure

```text
lib/
├── core/
│   ├── database/    app_database.dart: opens voltry.db, schema version
│   ├── errors/      sealed AppException + errorMessage()
│   ├── formatting/  number and date formatting (formatNumber, dayLabel, …)
│   ├── providers/   database, shared_preferences, clock, id generator, todayProvider
│   ├── router/      go_router routes and the two-tab shell with the navbar
│   ├── theme/       Candy Sport tokens: VoltryColors, VoltryText, VoltryRadius
│   └── widgets/     design system: VoltryNavBar, HeroCard, CalorieRing, StatTile, …
├── features/
│   ├── analysis/        photo → Gemini → validated result, AI model picker
│   ├── calorie_target/  daily calorie target
│   └── meal_log/        saved meals, Home, History, Meal detail
├── app.dart
└── main.dart
```

`test/` mirrors `lib/`, with hand-written fakes in `test/fakes/`. The SQLite schema (version 1) holds a single `meal_logs` table indexed on `created_at`.

---

## Getting Started

### Prerequisites

- Flutter 3.44 with Dart `^3.12.2`
- Android Studio or Xcode for an emulator or simulator, or a real device to use the camera
- Targets: Android (Flutter's default `minSdk`) and iOS 15.0+
- A Firebase project with AI Logic enabled. The Gemini Developer API free tier is enough, no billing needed

### Install and run

```bash
flutter pub get
flutter run
```

There is no code generation step. `flutter test` and `flutter analyze` work right after cloning, but running the app needs the Firebase setup below.

### Firebase setup

1. In the [Firebase console](https://console.firebase.google.com), create a project, then open **Build → AI Logic → Get started** and choose **Gemini Developer API**.
2. Connect the app:

   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<project-id> --platforms=android,ios
   ```

3. Check that `git status` does not list the generated files. `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart` and `firebase.json` are all git-ignored.

`main.dart` calls `Firebase.initializeApp()` without options, so the app reads the two native config files and never imports `firebase_options.dart`. Without them the Android build fails and the iOS app crashes at launch. The full guide, including troubleshooting, is in [docs/setup/firebase.md](docs/setup/firebase.md) (Indonesian).

> **Use your own Firebase project.** The config files are kept out of this public repo because the app has no App Check: anyone holding them could spend the Gemini quota of the project they belong to.

### Regenerating the app icon

Run after changing `assets/icon/voltry-app-icon.png`:

```bash
dart run flutter_launcher_icons
git checkout -- ios/Runner.xcodeproj/project.pbxproj
```

The second command undoes a side effect of `flutter_launcher_icons` 0.14.4, which rewrites every Xcode build setting containing `ASSETCATALOG`, including `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`. The app icon name is already `AppIcon`, so reverting the project file loses nothing.

---

## Data & Storage

- **Source of truth.** An on-device SQLite database (`voltry.db`) with one `meal_logs` table. No account is needed, and meal history never leaves the device.
- **Explicit save.** An analysis is only stored when you tap **Save**. The meal's ID is a UUID generated on the device, and its time is the moment you saved it.
- **Timestamps.** `created_at` is stored as UTC epoch milliseconds in an `INTEGER` column, not an ISO string: the microsecond digits that `toIso8601String()` sometimes adds break string ordering. Grouping by day uses the local date.
- **Photos.** Saved photos are copied to `<documents>/meal_photos/<id>.<ext>`, and the database stores only the file name. The full path is built at runtime because the iOS documents path changes when the app is reinstalled or updated. A missing file shows a placeholder instead of crashing.
- **Settings.** The calorie target (default 2,000 kcal) and the chosen AI model live in `shared_preferences`. The model is stored by its ID rather than its enum index, and an unknown ID falls back to Gemini 3.7 Flash.
- **Delete and Undo.** Swiping a meal in History removes the row at once, but the photo file is only deleted after the Undo snackbar closes without Undo. Deleting from Meal detail asks for confirmation and removes both immediately.

> **Everything is local.** Uninstalling the app or clearing its data removes the meal history.

---

## AI & Security

The analysis pipeline, from photo to screen:

```text
Camera / gallery ─▶ PhotoPicker            image_picker, max 1024 px wide, quality 85
                 ─▶ GeminiFoodAnalyzer     prompt + photo, JSON response schema, 30 s timeout
                 ─▶ parseAnalysis()        types, ranges, and name checked
                 ─▶ FoodFound / NotFood ─▶ Analyze screen ─▶ Save
```

- **Structured output.** The request sets `responseMimeType: application/json` and a `responseSchema` with six required fields: `is_food`, `food_name`, `calories`, `protein_g`, `carbs_g` and `fat_g`. Temperature is left at the default, as Google recommends for the Gemini 3 family.
- **Never trusted raw.** [`parseAnalysis`](lib/features/analysis/data/analysis_parser.dart) is the only code that reads the AI's JSON. It requires a JSON object, returns `NotFood` when `is_food` is false, trims the name (empty is rejected, longer than 60 characters is cut), rounds numbers that arrive as doubles, and rejects calories outside 0–5,000 or a macro outside 0–1,000. Anything else becomes an `AiException`.
- **Model choice.** Four free-tier Gemini models that accept images and structured output are listed in [`AiModel`](lib/features/analysis/domain/ai_model.dart). Google retires models regularly, so the list should be checked against the [Firebase AI Logic model docs](https://firebase.google.com/docs/ai-logic/models) before it changes. In debug builds the analyzer prints the model name and the original error, so a rejected or rate-limited model is easy to spot.

What the user sees when something fails, from the pure [`errorMessage`](lib/core/errors/app_exception.dart) function:

| Condition | Message | Actions |
| --- | --- | --- |
| Offline or 30 s timeout | You're offline or the connection is slow. Check it and try again. | Try again, Retake |
| AI quota used up | This AI model has reached its free limit. Switch models or try again later. | **Switch AI model**, Try again, Retake |
| Invalid or failed AI response | Couldn't analyze this photo. Please try again. | Try again, Retake |
| Camera or photos access denied | Couldn't open the camera or photos. Check Voltry's access in Settings. | |
| Database, file or settings error | Couldn't access your data on this device. Please try again. | Retry |
| Photo without food (not an error) | No food found in this photo. | Retake |

### Security notes

- **Firebase config is never committed**, as described in [Firebase setup](#firebase-setup).
- **No App Check and no per-user rate limiting.** Only the owner runs the app, so neither is in scope. Add App Check before handing builds to anyone else.
- **No login.** The photo sent to Gemini for analysis is the only data that leaves the device.

---

## Build & Distribution

Voltry is a portfolio project. It is not published to the App Store or Google Play, and there are no public builds. To try it, build from source against your own Firebase project:

```bash
flutter run --release   # on a connected device
```

---

## Testing

```bash
flutter test              # unit & widget tests
flutter test --coverage   # writes coverage/lcov.info
flutter analyze           # lint
```

139 tests in 29 files run without a device, network, Firebase config or Google account. SQLite runs in memory through `sqflite_common_ffi`, `shared_preferences` uses mock initial values, files go to temporary directories, and every fake in `test/fakes/` is written by hand, with no mocking library:

| Scope | Covered |
| --- | --- |
| Pure functions | `parseAnalysis` (valid answer, not food, missing fields, negative or out-of-range numbers, doubles, broken JSON, empty or long names), daily totals, grouping by day, day labels, error messages, target validation, `AiModel.fromId` |
| Data | `LocalMealLogRepository` against in-memory SQLite (insert, ordering, delete, restore with the same ID), `PhotoStorage` (save, resolve, delete, missing file), the calorie target and AI model repositories (defaults, stored values, failed writes), and `GeminiFoodAnalyzer` exception mapping through an injected request function |
| Controllers | Analyze (loading → result / not food / failure, retry, save), meal logs (add, delete, restore, purge photo), calorie target, AI model selection |
| Widgets | Home (ring, over target, list, empty), Analyze (all four states, Switch AI model on quota), History (day groups and totals), Meal detail, the target dialog, the AI model sheet, the full snap → analyze → save flow, the design system components and theme |

Real Gemini calls and the camera are not automated. They are checked by hand on a device with real meal photos and one photo without food.

---

## License

Released under the [MIT License](LICENSE).

The Urbanist font in `assets/fonts/` is licensed separately under the SIL Open Font License ([OFL.txt](assets/fonts/OFL.txt)).
