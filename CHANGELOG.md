# Changelog

All notable changes to Voltry are documented here. Newest release first.

Voltry is a portfolio project that only its owner runs. It is not published to the App Store or Google Play, so a release here is a version on `main`, not a store build.

---

## 1.1.0 — 2026-10-06

Covers everything merged after 1.0.0. This release adds **Google sign-in and cloud sync**: meals and the daily calorie target now belong to a Google account and live in Cloud Firestore instead of on the phone, so they come back after a reinstall or on another phone. The on-device SQLite database is gone, and meals saved with 1.0.0 are not carried over (see Upgrade notes).

### Added

**Google sign-in**

- Voltry now opens on a **Sign in** screen with the app icon and one **Continue with Google** button, drawn like Google's own button with the official "G" logo. The app cannot be used without an account.
- The session survives restarts, so signing in is needed only once per phone.
- Closing the Google account picker leaves you on Sign in without an error. A failed sign-in shows *Couldn't sign in with Google. Please try again.*
- The Home header shows your Google photo, or your initial when there is none. Tap it to open the account sheet with your name, email, and **Sign out**, which asks for confirmation.

**Cloud sync with Cloud Firestore**

- Every saved meal and the daily calorie target are stored in your account. Reinstall the app or sign in on another phone and they come back.
- Each account sees only its own data. [firestore.rules](firestore.rules) lets a signed-in user read and write `users/{their uid}` and its meals, and denies everything else.
- The history stays readable offline from Firestore's local cache. **Save**, **Delete**, **Undo**, and a new target apply at once and are sent when the connection returns, so nothing freezes offline.
- Coming back to the app fetches the history again in the background, so a meal saved on another phone appears without a spinner. If that fetch fails, the list on screen stays.

### Changed

- **Meals are stored in Firestore instead of an on-device SQLite database.** `sqflite` is removed. No screen or controller changed: only the `MealLogRepository` implementation was swapped.
- **The calorie target moves from `shared_preferences` to the account**, in the `users/{uid}` document. If it cannot be loaded, Home shows the error with **Retry**.
- **The storage error message** now reads *Couldn't access your data. Please try again.*, without "on this device", since the data no longer lives only on the phone. Firestore errors caused by a missing or slow connection show the offline message instead.

### Upgrade notes

- **Sign-in is required.** The first launch after updating opens Sign in.
- **Meals and the target from 1.0.0 are not carried over.** 1.1.0 no longer reads the on-device database, so every account starts empty, with the default target of 2,000 kcal. 1.0.0 only ever held the owner's test data, so there is no migration. The old database and photo files stay on the phone, unused.
- **The chosen AI model is kept.** It stays in `shared_preferences` on the phone, because the free Gemini quotas belong to the Firebase project, not to the account.
- **More Firebase setup to build from source.** The Firebase project now also needs Google enabled under Authentication, a Cloud Firestore database with [firestore.rules](firestore.rules) published, the debug keystore's SHA-1 for Android, and the Google client IDs in `ios/Runner/Info.plist` for iOS. The steps are in the README's [Firebase setup](README.md#firebase-setup).
- **Known limitation:** meal photos are not synced. On another phone or after a reinstall, those meals show a placeholder instead of the photo. Syncing them would need Cloud Storage for Firebase, which requires the pay-as-you-go Blaze plan.
- **Known limitation:** there are no live updates. A meal saved on another phone appears the next time the app starts or returns to the foreground.
- **Known limitation:** a write that the server rejects is reported only in the debug console, while the screen already shows the change.

---

## 1.0.0 — 2026-10-03

The first version: the full photo → AI → log flow, running on the phone without an account. Meals are stored in an on-device SQLite database, the calorie target and the chosen AI model in `shared_preferences`, and photos in the app's documents folder.

### Added

**Photo analysis**

- Take a photo or pick one from the gallery with the camera button in the middle of the navbar, on both tabs.
- Gemini, called through Firebase AI Logic, estimates the meal name, calories, protein, carbs, and fat for everything on the plate, as JSON that follows a fixed schema.
- Every answer is checked for type and range before it reaches the screen. A photo without food gets *No food found in this photo.* instead of made-up numbers.
- Nothing is stored until you tap **Save**, so a bad estimate can be retaken or thrown away.

**Today on Home**

- A coral card shows today's calories with a ring for the percentage of your target, and *kcal over* once you pass 100%.
- Protein, carbs, and fat tiles in blue, yellow, and teal, with today's meals below.
- Tap the pencil on the card to set the daily target: a whole number from 800 to 5,000 kcal, 2,000 by default.
- *Today* moves forward at local midnight and whenever the app returns to the foreground, so opening it in the morning never shows yesterday's totals.

**History and Meal detail**

- History groups meals by day with daily totals, labelled *Today*, *Yesterday*, or a date such as *Sat, 28 Sep*.
- Swipe a meal to delete it, with Undo. The photo file is deleted only once the Undo snackbar closes.
- Meal detail shows the photo, the date and time, the nutrition card, and delete with confirmation.

**AI model picker**

- The Home header shows the active Gemini model in a pill. Tap it to switch between Gemini 3.8 Flash, 3.7 Flash, 3.6 Flash, and 3.5 Flash-Lite. The choice is remembered, and 3.7 Flash is the default.
- Each free-tier model has its own daily quota. When one runs out, the Analyze screen offers **Switch AI model** and analyzes the same photo again with the new one.

**Error handling**

Being offline or timing out after 30 seconds, a used-up AI quota, an invalid AI answer, denied camera or photo access, and storage errors each get a specific message and a way forward: Try again, Retake, Switch AI model, or Retry.

**Candy Sport design and app icon**

- Coral, blue, yellow, and teal tokens, the Urbanist font, and a floating, blurred, icon-only navbar with the ink camera button raised in the middle.
- A Voltry app icon on Android and iOS, generated with `flutter_launcher_icons`.

### Known limitations

- **Data lives only on this phone.** There is no account, so uninstalling the app deletes every meal and the target, and nothing moves to a new phone. 1.1.0 solves this with Google sign-in and Firestore.
- **No App Check and no rate limiting.** Only the owner runs the app, and the Firebase config files are kept out of the repo so nobody else can spend its Gemini quota.
