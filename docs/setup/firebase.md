# Setup Firebase (Gemini, login Google, dan Firestore)

Langkah ini cukup dilakukan sekali, dan wajib sebelum app dijalankan. `main.dart` memanggil `Firebase.initializeApp()`, jadi tanpa langkah ini build Android gagal (plugin google-services butuh `google-services.json`) dan app iOS crash saat start. `flutter test` dan `flutter analyze` tetap jalan tanpa konfigurasi ini.

Ketiga layanan (AI Logic, Authentication, dan Firestore) cukup memakai paket gratis Spark. Jangan upgrade ke Blaze: begitu billing aktif, semua request Gemini Developer API jadi berbayar (spec D35).

## 1. Buat project Firebase dan aktifkan AI Logic

1. Buka https://console.firebase.google.com, lalu **Add project**. Beri nama, misalnya `voltry`. Google Analytics tidak diperlukan.
2. Buka **Build → AI Logic → Get started**, lalu pilih **Gemini Developer API**.

## 2. Aktifkan login Google

1. Buka **Build → Authentication → Get started → Sign-in method**.
2. Pilih **Google**, nyalakan **Enable**, isi support email, lalu **Save**.

## 3. Buat database Firestore

1. Buka **Build → Firestore Database → Create database**.
2. Pilih lokasi **`asia-southeast2` (Jakarta)**. Lokasi tidak bisa diubah setelah database dibuat.
3. Pilih **Start in production mode**.
4. Di tab **Rules**, ganti isinya dengan isi `firestore.rules` di root repo, lalu **Publish**.
5. Cek di **Rules Playground**: `get` ke `/users/uid-a/meals/x` dengan *Authenticated* dan Firebase UID `uid-a` harus **Allowed**, sedangkan dengan UID `uid-b` harus **Denied**.

## 4. Daftarkan SHA-1 debug (Android)

Login Google di Android menolak app yang SHA-1 signing-nya tidak terdaftar.

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Salin nilai `SHA1`, lalu buka **Project settings → Your apps → app Android → Add fingerprint** dan tempel nilainya.

## 5. Hubungkan app ke project

Jalankan langkah ini **setelah** langkah 2 dan 4, supaya file konfigurasi yang dibuat sudah berisi OAuth client untuk login Google. Kalau sebelumnya sudah pernah dijalankan, jalankan ulang.

Prasyarat: Firebase CLI (`npm install -g firebase-tools`) dan FlutterFire CLI.

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=<project-id> --platforms=android,ios
```

Perintah terakhir membuat empat file berikut, dan keempatnya **di-gitignore**:

| File | Dipakai? |
| --- | --- |
| `android/app/google-services.json` | Ya, dibaca Firebase dan Google Sign-In di Android |
| `ios/Runner/GoogleService-Info.plist` | Ya, dibaca Firebase di iOS |
| `lib/firebase_options.dart` | Tidak. `main.dart` memanggil `Firebase.initializeApp()` tanpa options |
| `firebase.json` | Tidak, hanya catatan FlutterFire CLI |

Alasannya: repo ini publik dan tidak memakai App Check. Siapa pun yang memegang konfigurasi ini bisa memakai kuota Gemini project kamu.

Perintah yang sama juga mengubah file Gradle Android (plugin `com.google.gms.google-services`) dan project Xcode (referensi ke `GoogleService-Info.plist`). Perubahan itu **di-commit**, karena tidak berisi data rahasia.

## 6. Isi client ID Google di `Info.plist` (iOS)

Google Sign-In di iOS membaca `GIDClientID` dan butuh URL scheme `REVERSED_CLIENT_ID` di `ios/Runner/Info.plist`. Kedua key itu sudah ada di repo, berisi client ID project Firebase asli, jadi nilainya **diganti** (`Set`, bukan `Add`) dengan milik project kamu dari `GoogleService-Info.plist` yang baru:

```bash
CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print :CLIENT_ID" ios/Runner/GoogleService-Info.plist)
REVERSED_CLIENT_ID=$(/usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist)
/usr/libexec/PlistBuddy \
  -c "Set :GIDClientID $CLIENT_ID" \
  -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $REVERSED_CLIENT_ID" \
  ios/Runner/Info.plist
plutil -lint ios/Runner/Info.plist
```

`Add` tidak bisa dipakai di sini: untuk key yang sudah ada, `PlistBuddy` hanya mencetak "Entry Already Exists" dan client ID lama tetap terpakai, sehingga login Google di iOS gagal.

Perubahan `Info.plist` ini **di-commit** (spec D40). OAuth client ID adalah identifier publik, bukan rahasia, dan tidak memberi akses ke Gemini maupun Firestore.

## 7. Cek

1. `git status --short` tidak boleh menampilkan keempat file di tabel langkah 5.
2. `flutter run` → layar Sign in → **Continue with Google** → pilih akun → Home.
3. Foto makanan → Save. Di **Firestore Database → Data**, dokumen `users/<uid>/meals/<id>` muncul.

## Masalah yang sering muncul

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| App crash saat start dengan error `[core/...]` di Android | Plugin google-services belum terpasang | Pastikan `id("com.google.gms.google-services")` ada di blok `plugins` pada `android/app/build.gradle.kts`, dan versinya terdaftar di `android/settings.gradle.kts`. Jalankan ulang `flutterfire configure` |
| Sama, di iOS | `GoogleService-Info.plist` tidak masuk target Runner | Buka `ios/Runner.xcworkspace`, seret file itu ke grup Runner, lalu centang target Runner |
| Build iOS gagal "GoogleService-Info.plist not found" setelah clone | File di-gitignore | Jalankan langkah 5 |
| "Couldn't sign in with Google" di Android, dan console `flutter run` menampilkan `AuthRepository failed: GoogleSignInException(...)` | SHA-1 belum terdaftar, atau `google-services.json` dibuat sebelum login Google aktif | Langkah 4, lalu jalankan ulang langkah 5 |
| Setelah memilih akun Google tidak terjadi apa-apa (tetap di layar Sign in, tanpa pesan), dan console menampilkan `AuthRepository sign-in canceled: GoogleSignInException(...)` | Di Android, SHA-1 yang belum terdaftar atau OAuth client yang tidak cocok dilaporkan sebagai *cancel* | Langkah 4, lalu jalankan ulang langkah 5 |
| App iOS berhenti saat **Continue with Google** diketuk, dengan pesan *missing support for the following URL schemes* | URL scheme `REVERSED_CLIENT_ID` belum ada di `Info.plist` | Langkah 6 |
| "Couldn't access your data" setelah login, dan console menyebut `permission-denied` atau `NOT_FOUND` | Database Firestore belum dibuat, atau Rules belum dipasang | Langkah 3 |
| Setiap analisis gagal dengan "Couldn't analyze this photo" | AI Logic belum aktif, atau model yang dipilih sudah tidak tersedia | Cek langkah 1.2. Di console `flutter run`, baris `GeminiFoodAnalyzer (<model>) failed: …` menyebut model yang dipakai dan alasan Google menolaknya. Ganti model lewat tombol nama model di kanan header Home, lalu cocokkan daftar di `lib/features/analysis/domain/ai_model.dart` dengan https://firebase.google.com/docs/ai-logic/models |
| "This AI model has reached its free limit" | Kuota tier gratis model itu habis (dihitung per model) | Ketuk **Switch AI model** dan pilih model lain. Kuota harian reset tengah malam waktu Pasifik (sekitar 14.00 WIB) |
| "You're offline or the connection is slow" padahal online | Gemini tidak menjawab dalam 30 detik | Coba lagi. Foto sudah dikecilkan ke lebar 1024 px sebelum dikirim |
