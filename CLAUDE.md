# CLAUDE.md

## Project Context

Voltry adalah app Flutter untuk menganalisis makanan dari foto. User memotret makanan, lalu AI (Gemini lewat `firebase_ai`) memperkirakan nama makanan, kalori, dan makro (protein, karbo, lemak) untuk seluruh isi piring. Hasilnya disimpan sebagai riwayat lokal, dan Home menampilkan total kalori hari ini dibanding target harian.

Ini **proyek portofolio untuk Upwork**. Hasil akhirnya repo GitHub, README, dan video demo. App hanya dijalankan oleh owner (tidak ada rilis ke store atau APK publik). Prinsip scope: **kecil dan cepat selesai, dengan satu alur utama yang rapi**. Bahasa UI: Inggris. Satuan: metrik. Light mode saja.

Spec lengkap ada di `docs/superpowers/specs/2026-10-01-voltry-food-analyzer-design.md`. **Baca sebelum mengerjakan area yang belum kamu kenal.** Decision log D1–D29 di sana menjelaskan alasan tiap keputusan.

`../arsip-voltry` berisi Voltry versi lama (AI fitness coach, Supabase + Claude) yang sudah ditinggalkan. **Spec, plan, dan aturannya tidak berlaku di sini.** Dari arsip itu, yang dipakai hanya design system Candy Sport.

---

## Status Saat Ini

Bagian ini diperbarui setiap kali **tahap** berubah: spec disetujui, plan selesai ditulis, atau satu tahap selesai. Progres per task **tidak** dicatat di sini, tapi di checkbox plan.

- **Tahap aktif:** Tahap 1 selesai pada 2026-10-03. Kode tambahan D28 (pemilih model AI) selesai pada 2026-10-03, tinggal cek di device oleh owner
- **Branch:** `feat/model-picker`, menunggu cek di device dan keputusan owner untuk merge ke `main`
- **Spec:** `docs/superpowers/specs/2026-10-01-voltry-food-analyzer-design.md` (lokal, decision log D1–D29)
- **Plan:** `docs/superpowers/plans/2026-10-03-voltry-model-picker.md` (lokal, semua task selesai kecuali Task 5 Step 2: cek di device). Plan Tahap 1: `docs/superpowers/plans/2026-10-01-voltry-food-analyzer.md` (semua task selesai)
- **Langkah berikutnya:** owner menjalankan cek di device (plan Task 5 Step 2), merge `feat/model-picker` ke `main` setelah owner setuju, lalu brainstorming Tahap 2 (login + sinkron cloud, pertanyaan terbuka di spec §12)

---

## Melanjutkan Pekerjaan Antar Sesi

Pekerjaan dikerjakan bertahap dalam banyak sesi. Satu-satunya sumber progres per task adalah **checkbox di file plan**. Repo harus selalu dalam keadaan yang cocok dengan checkbox itu. File plan dan spec hanya ada di laptop owner (`docs/superpowers/` di-gitignore), jadi cocokkan juga checkbox dengan `git log`.

### Di awal sesi

1. Baca **Status Saat Ini** di atas.
2. Jalankan `git status` dan `git log --oneline -10`. Pastikan kamu ada di branch yang benar. Kalau ada perubahan yang belum di-commit dan tidak dijelaskan oleh catatan sesi, **tanya owner dulu** sebelum melanjutkan.
3. Buka plan aktif dan cari task pertama yang masih `- [ ]`. Kalau di bawahnya ada catatan sesi, baca dulu.
4. Baca bagian spec yang dirujuk task itu.
5. Sampaikan ke owner dalam satu atau dua kalimat task mana yang akan dikerjakan, lalu mulai.

### Saat satu task selesai

1. `flutter analyze` bersih dan `flutter test` hijau.
2. Centang task itu di plan (`- [x]`). Perubahan ini hanya lokal dan tidak ikut di-commit.
3. Commit kodenya.

### Kalau sesi harus berhenti di tengah task

1. Tulis catatan tepat di bawah task itu di plan:
   `> Catatan sesi (YYYY-MM-DD): sudah …; belum …; langkah berikutnya …`
2. Commit dengan pesan `wip: <nama task>`. Tipe `wip:` hanya boleh di branch fitur.

### Kalau keputusan desain berubah

Perbarui decision log di spec (tambahkan D16, D17, dan seterusnya) dan bagian terkait di CLAUDE.md **lebih dulu**, baru ubah kodenya. Jangan mengubah keputusan diam-diam di kode.

---

## Tech Stack

- **Framework:** Flutter (iOS + Android), Dart
- **State:** Riverpod 3, `Notifier` / `AsyncNotifier`. **Provider ditulis manual**, tanpa `riverpod_generator`
- **Routing:** go_router, dengan `StatefulShellRoute` untuk 2 tab (Home, History)
- **AI:** Gemini lewat `firebase_ai` (Firebase AI Logic, backend Gemini Developer API), dipanggil langsung dari app. Model dipilih di app dari `enum AiModel` (default `gemini-3.7-flash`, spec D28)
- **Penyimpanan:** `sqflite` untuk riwayat makan, `shared_preferences` untuk target kalori, file foto di folder documents app
- **Model:** ditulis manual, **tanpa** Freezed atau json_serializable
- **Codegen:** tidak ada. Proyek ini tidak memakai `build_runner`
- **Styling:** Material 3 dengan token Candy Sport (`ThemeExtension`), font Urbanist sebagai asset

## Roadmap

1. **Tahap 1: analyzer lokal** (sekarang). Foto → AI → hasil → riwayat + total harian + target kalori.
2. **Tahap 2: login + sinkron cloud.** Akan punya spec dan plan sendiri. Pertanyaan terbukanya ada di spec §12.

Kerjakan satu tahap sampai skenario demonya jalan, baru lanjut ke tahap berikutnya.

## Key Directories

- `lib/core/` berisi kode yang dipakai lintas feature:
  - `theme/`: token, `VoltryColors`, `VoltryText`
  - `router/`
  - `widgets/`: komponen design system
  - `database/`: membuka sqflite + versi schema
  - `errors/`: `AppException` dan `errorMessage`
  - `formatting/`: format angka dan tanggal
  - `providers/`: `databaseProvider`, `sharedPreferencesProvider`, `clockProvider`, `idGeneratorProvider`, dan `todayProvider` (hari ini, maju saat tengah malam dan saat app kembali ke foreground)
- `lib/features/<feature>/` punya struktur `domain/`, `data/`, dan `presentation/{controllers,states,pages,widgets}`. Feature yang ada: `analysis`, `meal_log`, `calorie_target`.
- `test/` mengikuti struktur `lib/`. Versi palsu untuk test ada di `test/fakes/`.
- `docs/superpowers/specs/` dan `docs/superpowers/plans/`: spec dan plan per tahap. **Hanya lokal**: di-gitignore dan tidak pernah di-commit.
- `docs/design/`: referensi visual Candy Sport.
- `docs/setup/`: langkah setup Firebase.

## Commands

- `flutter run`: jalankan app. Analisis foto butuh konfigurasi Firebase lokal (lihat `docs/setup/firebase.md`)
- `flutter analyze`: linter
- `flutter test`: semua test
- `flutter test test/path/to/file_test.dart`: satu file test
- `dart format .`: formatter
- `flutter pub add <package>` / `flutter pub add --dev <package>`: pasang package
- `flutterfire configure`: setup Firebase, cukup sekali. **Tanya dulu sebelum menjalankan.**

---

## How I Want You to Work

### Before Coding

- Ikuti bagian **Melanjutkan Pekerjaan Antar Sesi** di atas.
- Kalau tidak yakin, tanya. Jangan berasumsi.
- Untuk pekerjaan yang kompleks, susun rencana dan konfirmasi dulu.

### While Coding

- Kode lengkap dan bisa jalan, tanpa placeholder atau TODO.
- Sederhana dan mudah dibaca, bukan "pintar".
- Ikuti pola yang sudah ada di codebase.
- Test ditulis lebih dulu daripada kodenya (TDD).

### After Coding

- Jalankan `flutter analyze` dan `flutter test` setelah **tiap task**, bukan hanya di akhir.
- Ringkas apa yang berubah dan kenapa.

### Git

- Satu branch per tahap (Tahap 1: `feat/food-analyzer`), lalu PR ke `main` saat tahapnya selesai.
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`. Tipe `wip:` hanya untuk berhenti di tengah task.
- **Jangan tambahkan `Co-Authored-By` atau atribusi Claude apa pun** di pesan commit maupun deskripsi PR. Aturan ini juga berlaku untuk commit yang dibuat subagent saat mengerjakan plan, jadi tulis larangan ini di setiap prompt subagent. Setelah commit, cek dengan `git log -1 --format=%B`. Kalau trailer atribusi ikut masuk, perbaiki dengan `git commit --amend`.
- Jangan push atau membuat PR tanpa diminta.
- Jangan commit spec atau plan (`docs/superpowers/`). Folder itu di-gitignore atas permintaan owner, karena repo-nya publik.
- Sebelum commit, cek `git status`. Pastikan file konfigurasi Firebase tidak ikut ter-stage.

---

## Aturan Keras

Aturan di bawah **tidak akan tertangkap `flutter analyze`**. Kalau dilanggar, kodenya terlihat benar padahal salah.

### 1. Konfigurasi Firebase tidak pernah di-commit

`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, dan `firebase.json` ada di `.gitignore`. Repo-nya publik dan tidak memakai App Check, jadi siapa pun yang memegang konfigurasi itu bisa menghabiskan kuota Gemini milik owner. `main.dart` memanggil `Firebase.initializeApp()` tanpa options (spec D16), jadi kode tetap compile dan test tetap jalan tanpa file-file itu. Jangan meng-import `firebase_options.dart`.

### 2. Output AI tidak pernah dipercaya mentah

Semua jawaban Gemini lewat `parseAnalysis` (`features/analysis/data/analysis_parser.dart`). Fungsi ini memvalidasi JSON, rentang angka, dan nama sebelum hasilnya dipakai. Jangan membaca field dari JSON AI di tempat lain.

### 3. Setiap sumber data hanya disentuh satu class

| Sumber | Satu-satunya class yang boleh menyentuh |
| --- | --- |
| sqflite | `LocalMealLogRepository` (dan `app_database.dart` untuk membuka database) |
| File foto | `PhotoStorage` |
| shared_preferences | `CalorieTargetRepository` (target kalori) dan `AiModelRepository` (model AI) |
| firebase_ai | `GeminiFoodAnalyzer` |
| image_picker (kamera, galeri) | `PhotoPicker` |

Widget → controller → repository/analyzer. Semua diakses lewat provider, supaya bisa diganti versi palsu di test. Aturan ini juga yang membuat Tahap 2 tinggal menambah implementasi `MealLogRepository` baru.

### 4. Exception pihak ketiga berhenti di layer data

`SocketException`, `TimeoutException`, exception `firebase_ai`, `DatabaseException`, `FileSystemException`, dan `PlatformException` dari `image_picker` diubah jadi `sealed class AppException` (`NetworkException`, `AiException`, `AiQuotaException`, `StorageException`, `PhotoAccessException`) di repository, analyzer, `PhotoStorage`, atau `PhotoPicker`. UI hanya mengenal `AppException`. "Bukan makanan" bukan exception, tapi hasil `NotFood`.

### 5. Waktu disimpan sebagai epoch milidetik UTC

Kolom `created_at` bertipe INTEGER (`millisecondsSinceEpoch` dari waktu UTC). **Jangan menyimpan string ISO**, karena digit mikrodetik dari `toIso8601String()` membuat urutan string salah. Untuk tampilan dan pengelompokan per hari, pakai `toLocal()`.

### 6. Foto disimpan sebagai nama file, bukan path lengkap

Database hanya menyimpan `photo_file_name` (misalnya `3f2a….jpg`). Path lengkapnya disusun saat runtime oleh `PhotoStorage.resolve`, karena path folder documents di iOS berubah setiap kali app diinstal ulang atau diupdate.

### 7. Provider ditulis manual, memakai `Notifier` / `AsyncNotifier`

Jangan pakai `@riverpod`, `riverpod_annotation`, atau `build_runner`. Jangan pakai `StateNotifier` atau mengimpor `package:flutter_riverpod/legacy.dart`. Tipe `Override` di-import dari `package:flutter_riverpod/misc.dart`.

### 8. Business logic di fungsi murni

Total harian (`summarizeDay`), pengelompokan per hari (`groupByDay`), label hari (`dayLabel`), validasi output AI (`parseAnalysis`), validasi target kalori, dan pesan error (`errorMessage`) adalah fungsi murni yang di-test. Controller hanya menyambungkan semuanya ke UI.

### 9. Tidak ada nilai visual yang di-hardcode di widget

Warna, ukuran font, dan radius diambil dari theme (`Theme.of(context)`, `VoltryColors`, `VoltryText`). Tidak boleh ada `Color(0xFF…)` atau `TextStyle(fontSize: …)` langsung di widget.

---

## Model Dart (manual)

```dart
class MealLog {
  const MealLog({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.photoFileName,
    required this.createdAt,
  });

  final String id;
  final String foodName;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final String photoFileName;
  final DateTime createdAt;

  factory MealLog.fromRow(Map<String, Object?> row) => MealLog(
        id: row['id'] as String,
        foodName: row['food_name'] as String,
        calories: row['calories'] as int,
        proteinG: row['protein_g'] as int,
        carbsG: row['carbs_g'] as int,
        fatG: row['fat_g'] as int,
        photoFileName: row['photo_file_name'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int, isUtc: true),
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'food_name': foodName,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'photo_file_name': photoFileName,
        'created_at': createdAt.toUtc().millisecondsSinceEpoch,
      };
}
```

- Field `final` dan `const` constructor. Key map memakai snake_case, sesuai nama kolom.
- `copyWith` hanya ditambahkan ke model yang memang diedit.
- State yang punya beberapa kondisi memakai `sealed class` (misalnya `AnalyzeState`, `AnalysisResult`).

## Provider (manual)

```dart
final mealLogRepositoryProvider = Provider<MealLogRepository>(
  (ref) => LocalMealLogRepository(ref.watch(databaseProvider)),
);

final mealLogsControllerProvider =
    AsyncNotifierProvider<MealLogsController, List<MealLog>>(MealLogsController.new);

class MealLogsController extends AsyncNotifier<List<MealLog>> {
  @override
  Future<List<MealLog>> build() => ref.watch(mealLogRepositoryProvider).fetchAll();
}
```

- Nama provider diakhiri dengan `Provider`. Provider ditulis di file yang sama dengan class yang disediakannya.
- `databaseProvider` dan `sharedPreferencesProvider` melempar `UnimplementedError` dan di-override di `main()` (serta di test).

---

## Design System: Terkunci

Visual **Candy Sport**. Referensinya ada di `docs/design/visual-direction.png`. Mockup itu dibuat untuk versi fitness, jadi yang dipakai adalah **gaya visualnya**, sedangkan susunan layar mengikuti spec §4. **Jangan ubah token, font, atau perilaku navbar tanpa bertanya.**

- **Warna:**
  - coral `#FF5A5F` (brand utama)
  - blue `#3A86FF`
  - yellow `#FFD23F`
  - teal `#2EC4B6`
  - ink `#1F1A17`
  - background `#FFF9F4`
  - surface `#FFFFFF`
  - muted `#9A8F86`
  - line `#EADFD6`
  - danger `#E5484D`
- **Teks di atas warna:** putih di atas coral dan blue, `ink` di atas yellow, `#10302D` di atas teal. Label kecil putih di atas coral/blue diizinkan, mengikuti mockup (spec D22).
- **Pemetaan warna:**
  - Tab aktif navbar: Home coral, History blue. Tombol kamera di tengah: ink.
  - Makro: Protein blue, Carbs yellow, Fat teal.
  - `CalorieRing`: yellow di atas `HeroCard` coral.
- **Navbar (`VoltryNavBar`):** mengambang, blur (`BackdropFilter`), dan hanya berisi ikon. Tab aktif berupa lingkaran 52px yang sedikit keluar dari bar. Di tengah ada tombol kamera: lingkaran ink 64px dengan ikon putih, menonjol sekitar 22px di atas bar. Ini satu-satunya tombol kamera di app (spec D26).
- **Font:** Urbanist, disertakan sebagai asset (tanpa `google_fonts`). Skala tipografi ada di spec §10.2.
- **Radius:** 24 untuk kartu besar, 20 untuk kartu, 18 untuk baris list, pill untuk chip dan tombol.
- **Ikon petir** menandai semua yang dibuat AI.

---

## Do Not

- **Jangan bangun fitur di luar scope tahap yang sedang dikerjakan.** Daftar yang di luar scope Tahap 1 ada di spec §11: login/cloud, edit hasil, rincian per item, target makro, saran AI, dark mode, i18n, satuan imperial, App Check, rate limiting, rilis ke store, dan notifikasi.
- **Jangan pasang package di luar daftar Dependencies.**
- **Jangan commit secret atau konfigurasi Firebase** (Aturan Keras 1).
- **Jangan tinggalkan placeholder, TODO, atau kode yang dikomentari-mati.**
- **Jangan bekerja di luar scope task.**
- Jangan berasumsi. Tanya kalau tidak jelas.

---

## Dependencies

Pasang lewat `flutter pub add` (atau `flutter pub add --dev`). Jangan menulis angka versi secara manual.

| Jenis | Package |
| --- | --- |
| App (sudah ada) | `firebase_ai`, `image_picker`, `lottie`, `cupertino_icons` |
| App (Tahap 1) | `flutter_riverpod`, `go_router`, `firebase_core`, `sqflite`, `path_provider`, `path`, `shared_preferences`, `uuid`, `intl` |
| Dev (Tahap 1) | `sqflite_common_ffi` |

**Jangan pasang tanpa diminta:** `freezed`, `json_serializable`, `build_runner`, `riverpod_generator`, `riverpod_annotation`, `mocktail`, `google_fonts`, `dio`, `get_it`, `provider`, `flutter_bloc`, `hive`, `isar`, `drift`, dan SDK LLM lain selain `firebase_ai`.

---

## Code Style

- File: snake_case. Class: PascalCase.
- Konstanta ditulis sebagai `static const` di dalam class (`VoltryColors.coral`), bukan dengan prefix `k`.
- Nama model tanpa suffix: `MealLog`, bukan `MealLogModel`. Nama file tetap `meal_log_model.dart`.
- Copy UI dalam bahasa Inggris. Dokumen di `docs/` dalam bahasa Indonesia, dengan istilah teknis tetap bahasa Inggris.
- Nama variabel deskriptif.

### Komentar

Kode yang baik menjelaskan dirinya sendiri. **Tulis komentar hanya untuk menjelaskan *kenapa*, bukan *apa*.**

```dart
// ✗ Mengulang kode
// Ambil semua catatan makan, urut terbaru
final rows = await _db.query('meal_logs', orderBy: 'created_at DESC');

// ✓ Menjelaskan keputusan yang tidak terbaca dari kode
// Disimpan sebagai epoch ms, bukan ISO string: digit mikrodetik dari
// toIso8601String() membuat urutan string tidak sama dengan urutan waktu.
'created_at': createdAt.toUtc().millisecondsSinceEpoch,
```

Hindari juga header dekoratif (`// =====`) dan doc comment basa-basi yang hanya mengulang nama method.
