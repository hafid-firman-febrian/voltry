# Setup Firebase (Gemini lewat Firebase AI Logic)

Langkah ini cukup dilakukan sekali, dan diperlukan supaya analisis foto jalan. Tanpa langkah ini app tetap bisa dibuka, riwayat dan target tetap berfungsi, tetapi setiap analisis gagal dengan pesan "Couldn't analyze this photo".

## 1. Buat project Firebase dan aktifkan AI Logic

1. Buka https://console.firebase.google.com, lalu **Add project**. Beri nama, misalnya `voltry`. Google Analytics tidak diperlukan.
2. Buka **Build → AI Logic → Get started**, lalu pilih **Gemini Developer API**. Tidak perlu upgrade ke paket Blaze.

## 2. Hubungkan app ke project

Prasyarat: Firebase CLI (`npm install -g firebase-tools`) dan FlutterFire CLI.

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<project-id> --platforms=android,ios
```

Perintah terakhir membuat empat file berikut, dan keempatnya **di-gitignore**:

| File | Dipakai? |
| --- | --- |
| `android/app/google-services.json` | Ya, dibaca Firebase di Android |
| `ios/Runner/GoogleService-Info.plist` | Ya, dibaca Firebase di iOS |
| `lib/firebase_options.dart` | Tidak. `main.dart` memanggil `Firebase.initializeApp()` tanpa options |
| `firebase.json` | Tidak, hanya catatan FlutterFire CLI |

Alasannya: repo ini publik dan tidak memakai App Check. Siapa pun yang memegang konfigurasi ini bisa memakai kuota Gemini project kamu.

Perintah yang sama juga mengubah file Gradle Android (plugin `com.google.gms.google-services`) dan project Xcode (referensi ke `GoogleService-Info.plist`). Perubahan itu **di-commit**, karena tidak berisi data rahasia.

## 3. Cek

1. `git status --short` tidak boleh menampilkan keempat file di tabel atas.
2. `flutter run`, lalu foto makanan. Hasil analisis harus muncul dalam beberapa detik.

## Masalah yang sering muncul

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| App crash saat start dengan error `[core/...]` di Android | Plugin google-services belum terpasang | Pastikan `id("com.google.gms.google-services")` ada di blok `plugins` pada `android/app/build.gradle.kts`, dan versinya terdaftar di `android/settings.gradle.kts`. Jalankan ulang `flutterfire configure` |
| Sama, di iOS | `GoogleService-Info.plist` tidak masuk target Runner | Buka `ios/Runner.xcworkspace`, seret file itu ke grup Runner, lalu centang target Runner |
| Build iOS gagal "GoogleService-Info.plist not found" setelah clone | File di-gitignore | Jalankan langkah 2 |
| Setiap analisis gagal dengan "Couldn't analyze this photo" | AI Logic belum aktif, atau model sudah tidak tersedia | Cek langkah 1.2. Cocokkan `GeminiFoodAnalyzer.modelName` dengan https://firebase.google.com/docs/ai-logic/models |
| "You're offline or the connection is slow" padahal online | Gemini tidak menjawab dalam 30 detik | Coba lagi. Foto sudah dikecilkan ke lebar 1024 px sebelum dikirim |
