# Voltry

AI food analyzer built with Flutter. Snap a meal, Gemini estimates its calories and macros, and Voltry keeps a daily log against your calorie target.

<p>
  <img src="docs/screenshots/home.png" width="260" alt="Home: today's calories against the target">
  <img src="docs/screenshots/analyze.png" width="260" alt="Analyze: the AI estimate for a photo">
  <img src="docs/screenshots/history.png" width="260" alt="History: meals grouped by day">
</p>

## Features

- **Photo to nutrition estimate.** Take a photo or pick one from the gallery. Gemini returns the meal name, calories, protein, carbs and fat as JSON that follows a fixed schema.
- **AI output is validated, never trusted raw.** Every field is checked for type and range before it reaches the UI. Photos without food get a clear "No food found" state.
- **Daily progress.** A calorie ring shows today's total against your own target, with macro totals underneath.
- **History.** Meals are grouped by day with daily totals. Swipe to delete, with Undo.
- **Graceful failures.** Offline, timeouts, a used-up AI quota, denied camera access and storage errors each get a specific message and a way forward.

## Tech stack

Flutter 3.44 · Dart 3.12 · Riverpod 3 · go_router · sqflite · shared_preferences · Firebase AI Logic (`firebase_ai`, Gemini) · image_picker · Lottie

## Architecture

```
Widget → Controller (Riverpod Notifier) → Repository / Analyzer → sqflite · files · Gemini
```

- **Feature-first folders:** `analysis`, `meal_log` and `calorie_target`, each split into `domain`, `data` and `presentation`.
- **Local-first, ready for sync.** Widgets never touch storage. All meal data goes through a `MealLogRepository` interface, so a cloud implementation can be added without changing any screen.
- **Business rules are pure functions:** daily totals, grouping by day, target progress and AI response parsing. Each is unit tested.
- **Hand-written models and providers.** No code generation, so every file reads as-is.
- **One error type for the UI.** Third-party exceptions are translated into a sealed `AppException` at the data layer.

## Run it locally

1. Install Flutter 3.44 or newer.
2. Set up Firebase AI Logic: [docs/setup/firebase.md](docs/setup/firebase.md). The Firebase config files are not committed.
3. Run `flutter pub get`, then `flutter run`.

## Tests

```bash
flutter test
```

Over 100 tests:

- Unit tests for the AI response parser, daily summaries and formatters.
- The SQLite repository against an in-memory database.
- Controllers with hand-written fakes.
- Widget tests for every screen, including the full snap → analyze → save flow.
