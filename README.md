# Ploopy

**Social Study Productivity App for Students**

Ploopy adalah aplikasi produktivitas belajar berbasis sosial untuk mahasiswa. Aplikasi ini menggabungkan manajemen tugas, jadwal belajar, aktivitas sosial, event berbasis lokasi, AI daily planner, scanner/OCR, gamifikasi, dan tools pendukung belajar dalam satu aplikasi mobile.

---

## Deskripsi Aplikasi

Ploopy dirancang untuk membantu mahasiswa mengelola aktivitas akademik dan produktivitas harian secara lebih terintegrasi. Di dalam aplikasi, pengguna dapat mencatat tugas, membuat jadwal, melacak waktu belajar, mengikuti event, membagikan aktivitas belajar, memakai tools produktivitas, serta mendapatkan rekomendasi jadwal harian dari AI.

Fitur utama yang tersedia di Ploopy meliputi:

- Manajemen tugas
- Jadwal belajar
- Event berbasis lokasi
- AI Daily Plan
- Scanner dokumen dan OCR
- Gamifikasi belajar melalui achievement dan streak
- Fitur sosial seperti activity feed dan friend request
- Tools tambahan seperti currency converter, timezone converter, compass, dan memory game

---

## Latar Belakang

Mahasiswa sering menghadapi kesulitan dalam mengatur jadwal kuliah, tugas, agenda belajar, dan kegiatan tambahan. Informasi akademik, event, dan aktivitas produktif sering tercecer di banyak tempat sehingga sulit dipantau secara konsisten.

Ploopy dibuat sebagai solusi terintegrasi yang menggabungkan produktivitas, sosial, AI, dan lokasi. Dengan pendekatan ini, mahasiswa dapat mengelola kegiatan belajar sekaligus tetap terhubung dengan aktivitas dan event produktif di sekitarnya.

---

## Fitur Utama

| Fitur | Deskripsi | Status |
| --- | --- | --- |
| Authentication | Login, register, session token, dan logout melalui backend Express | Done |
| Biometric Login | Login cepat menggunakan fingerprint/face authentication via `local_auth` | Done |
| Home Dashboard | Ringkasan jadwal, task, study minutes, dan notifikasi | Done |
| Task Management | CRUD task, pin task, completion, deadline, dan prioritas | Done |
| Schedule Management | CRUD jadwal harian, recurrence, reminder lokal, dan sinkronisasi backend | Done |
| AI Daily Plan | Rekomendasi jadwal harian berbasis task dan schedule menggunakan Groq API | Done |
| Event dan LBS | Event dengan latitude/longitude, Google Maps, rute, dan navigasi eksternal | In Progress |
| Study Tracker / Focus | Tracking sesi belajar dan durasi belajar harian/bulanan | Done |
| Social Activity | Activity feed, image upload, like, comment, dan public profile | Done |
| Scanner | Scan dokumen menggunakan document scanner | Done |
| OCR / Pict to Text | Ekstraksi teks dari gambar menggunakan ML Kit Text Recognition | Done |
| Currency Converter | Konversi mata uang multi-currency | Done |
| Timezone Converter | Konversi zona waktu termasuk WIB, WITA, WIT, dan London | Done |
| Compass | Kompas berbasis sensor perangkat | Done |
| Memory Game | Game sederhana untuk melatih memori | Done |
| Profile | Profil user, avatar, aktivitas, achievement, dan settings | Done |
| Achievement / Gamification | Achievement, streak, dan unlock achievement | Done |
| Notification | Notifikasi lokal dan daftar notifikasi dari backend | Done |
| Settings | Biometric preference, settings, dan logout | Done |

---

## Kesesuaian Requirement Project Akhir

| Requirement | Implementasi di Ploopy | Status |
| --- | --- | --- |
| Memiliki konsep projek akhir | Aplikasi produktivitas belajar sosial untuk mahasiswa | Done |
| Login dengan enkripsi dan session, tidak menggunakan Firebase | Backend Express memakai bcrypt untuk password hash dan JWT untuk session | Done |
| Login biometric | Menggunakan package `local_auth` dan token lokal aman | Done |
| Web service / REST API | Backend Node.js + Express dengan route per fitur | Done |
| Database | Supabase PostgreSQL untuk data utama, Isar untuk local cache/session | Done |
| LBS yang terkait dengan tema aplikasi | Event memiliki koordinat, map picker, route page, dan navigasi Google Maps | In Progress |
| Bottom navigation | Home, Social, Tools, Profile | Done |
| Menu profile dengan gambar | Profile page mendukung avatar user | Done |
| Menu saran dan kesan TPM | Ada menu "Saran & Kesan TPM" di profile settings section | Done |
| Logout | Logout melalui AuthBloc dan endpoint backend | Done |
| Konversi mata uang minimal 3 mata uang | Currency converter dan konversi harga event IDR/USD/EUR | Done |
| Konversi waktu: WIB, WITA, WIT, London | Timezone converter memuat Asia/Jakarta, Asia/Makassar, Asia/Jayapura, dan Europe/London | Done |
| Minimal 2 sensor | Compass memakai sensor magnetometer; sensor tambahan masih dapat dikembangkan | Need Improvement |
| AI / ML / LLM | OCR memakai ML Kit, AI Daily Plan memakai Groq API | Done |

---

## Tech Stack

### Mobile App

- Flutter
- Dart
- BLoC / Cubit (`flutter_bloc`)
- Isar local database
- SharedPreferences
- Flutter Secure Storage
- Local Auth
- Google Maps Flutter
- Geolocator
- Flutter Compass
- Google ML Kit Text Recognition
- Image Picker
- Cunning Document Scanner
- URL Launcher
- Dio dan HTTP

### Backend

- Node.js
- Express.js
- Supabase PostgreSQL
- JWT
- bcrypt
- Groq API untuk AI Daily Plan

### External Services

- Supabase
- Groq API
- Google Maps API
- Currency API / exchange-rate service
- Google ML Kit

---

## Struktur Folder

```text
ploopy/
├── android/
├── ios/
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── network/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   └── features/
│       ├── activity/
│       ├── ai_daily_plan/
│       ├── auth/
│       ├── calendar/
│       ├── event/
│       ├── home/
│       ├── memory_game/
│       ├── notification/
│       ├── ocr/
│       ├── profile/
│       ├── scanner/
│       ├── schedule/
│       ├── settings/
│       ├── social/
│       ├── study/
│       ├── task/
│       └── tools/
├── backend/
│   ├── package.json
│   ├── sql/
│   └── src/
│       ├── config/
│       ├── middleware/
│       ├── routes/
│       ├── services/
│       └── server.js
└── docs/
    └── screenshots/
```

---

## Arsitektur Aplikasi

Ploopy menggunakan pendekatan **feature-based architecture** dengan gaya clean architecture sederhana. Setiap fitur dipisahkan ke dalam folder sendiri agar kode lebih rapi dan mudah dikembangkan.

Struktur umum fitur Flutter:

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Alur data:

1. UI mengirim event atau action.
2. BLoC memproses event dan memanggil repository.
3. Repository mengambil data dari local datasource atau remote API.
4. Backend Express memproses request dan mengakses Supabase.
5. Response dikembalikan ke Flutter sebagai state baru.

Pendekatan ini dipakai karena:

- Struktur lebih rapi.
- Setiap fitur terpisah.
- Logic UI dan logic data tidak bercampur.
- Lebih mudah diuji dan dikembangkan.
- Cocok untuk aplikasi berskala menengah.

---

## BLoC State Management

Ploopy menggunakan BLoC untuk memisahkan UI dan business logic. UI hanya menerima state, sedangkan perubahan data dilakukan melalui event/action yang diproses oleh BLoC.

Contoh fitur yang menggunakan BLoC:

- `AuthBloc` untuk login, register, logout, dan biometric.
- `TaskBloc` untuk manajemen task.
- `ScheduleBloc` untuk jadwal.
- `StudyBloc` untuk sesi belajar.
- `ActivityBloc` untuk activity feed.
- `EventBloc` dan `EventRouteBloc` untuk event dan rute.
- `ProfileBloc` untuk data profile, achievement, dan friends.
- `AiDailyPlanBloc` untuk generate, revise, dan accept AI plan.

---

## API Backend

Base URL default backend:

```text
http://localhost:3000
```

Untuk Android emulator, Flutter biasanya menggunakan:

```text
http://10.0.2.2:3000
```

### Auth

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| POST | `/api/auth/register` | Register user baru |
| POST | `/api/auth/login` | Login user dan menerima JWT |
| GET | `/api/auth/me` | Mengambil user aktif |
| POST | `/api/auth/logout` | Logout session |

### User / Profile

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/users/search?q=` | Search public users |
| GET | `/api/users/:id` | Detail user |
| PATCH | `/api/users/:id` | Update profile user |
| POST | `/api/users/:id/avatar` | Upload avatar user |
| PATCH | `/api/users/:id/biometric` | Update status biometric |

### Task

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/tasks` | List task user |
| GET | `/api/tasks?date=` | List task berdasarkan tanggal |
| GET | `/api/tasks?pinned=true` | List task pinned |
| GET | `/api/tasks/:id` | Detail task |
| POST | `/api/tasks` | Buat task |
| PATCH | `/api/tasks/:id` | Update task |
| PATCH | `/api/tasks/:id/completion` | Update status selesai |
| PATCH | `/api/tasks/:id/pin` | Update pinned task |
| DELETE | `/api/tasks/:id` | Hapus task |

### Schedule

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/schedules` | List schedule user |
| GET | `/api/schedules?date=` | List schedule berdasarkan tanggal |
| GET | `/api/schedules?upcoming=true` | List upcoming schedule |
| GET | `/api/schedules/:id` | Detail schedule |
| POST | `/api/schedules` | Buat schedule |
| PATCH | `/api/schedules/:id` | Update schedule |
| DELETE | `/api/schedules/:id` | Hapus schedule |

### Study

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/study/sessions` | List study session |
| GET | `/api/study/sessions?date=` | Study session berdasarkan tanggal |
| POST | `/api/study/sessions` | Mulai sesi belajar |
| PATCH | `/api/study/sessions/:id/end` | Akhiri sesi belajar |
| GET | `/api/study/today` | Total menit belajar hari ini |
| GET | `/api/study/month?year=&month=` | Statistik belajar bulanan |

### Achievement

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/achievements` | List achievement |
| GET | `/api/achievements/users/:userId` | Achievement user |
| POST | `/api/achievements/users/:userId` | Unlock achievement |

### Activity

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/activities` | Activity feed |
| GET | `/api/activities?mine=true` | Activity milik user aktif |
| GET | `/api/activities/users/:userId` | Activity berdasarkan user |
| POST | `/api/activities/uploads` | Upload image activity |
| POST | `/api/activities` | Buat activity |
| DELETE | `/api/activities/:id` | Hapus activity |
| POST | `/api/activities/:id/like` | Like/unlike activity |
| GET | `/api/activities/:id/comments` | List komentar |
| POST | `/api/activities/:id/comments` | Tambah komentar |
| DELETE | `/api/activities/comments/:id` | Hapus komentar |

### Friend

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/friends` | List friendship |
| POST | `/api/friends` | Kirim friend request |
| PATCH | `/api/friends/:id` | Update status friendship |
| DELETE | `/api/friends/:id` | Hapus friendship |

### Event

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/events` | List event |
| GET | `/api/events?upcoming=true` | Event upcoming |
| GET | `/api/events/:id` | Detail event |
| POST | `/api/events` | Buat event |
| PATCH | `/api/events/:id` | Update event |
| DELETE | `/api/events/:id` | Hapus event |
| POST | `/api/events/:id/join` | Join event |
| DELETE | `/api/events/:id/join` | Leave event |

### Notification

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/notifications` | List notifikasi |
| GET | `/api/notifications?unread=true` | List notifikasi belum dibaca |
| POST | `/api/notifications` | Buat notifikasi |
| PATCH | `/api/notifications/:id/read` | Tandai notifikasi terbaca |
| PATCH | `/api/notifications/read-all` | Tandai semua terbaca |
| DELETE | `/api/notifications/:id` | Hapus notifikasi |

### Dashboard, Settings, Streak, AI

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| GET | `/api/dashboard/home?date=` | Data dashboard home |
| GET | `/api/settings/me` | Settings user aktif |
| PATCH | `/api/settings/me` | Update settings |
| GET | `/api/streaks/me` | Streak user aktif |
| POST | `/api/streaks/check-in` | Check-in streak |
| PATCH | `/api/streaks/me` | Update streak |
| POST | `/api/ai/daily-plan` | Generate / revise AI Daily Plan dengan Groq |

---

## Environment Variables

File `.env` tidak boleh di-commit ke GitHub. Gunakan `.env.example` sebagai template dan isi value sesuai environment lokal.

### Flutter `.env`

```env
API_BASE_URL=http://10.0.2.2:3000
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

### Backend `backend/.env`

```env
PORT=3000
APP_ORIGIN=*
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
JWT_SECRET=change-this-secret
GROQ_API_KEY=your-groq-api-key
GROQ_MODEL=llama-3.3-70b-versatile
```

---

## Cara Menjalankan Backend

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

Alternatif production/local start:

```bash
npm start
```

Backend berjalan di:

```text
http://localhost:3000
```

---

## Cara Menjalankan Flutter App

```bash
flutter pub get
cp .env.example .env
flutter run
```

Pastikan:

- Backend sudah aktif.
- `API_BASE_URL` sesuai device.
- Android emulator memakai `http://10.0.2.2:3000`.
- Physical device memakai IP LAN komputer, misalnya `http://192.168.x.x:3000`.

---

## Generate File Isar

Project ini menggunakan Isar untuk local storage/cache. Jika ada perubahan model Isar, jalankan:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Atau:

```bash
dart run build_runner build
```

---

## Konfigurasi Google Maps API

1. Buat API key di Google Cloud Console.
2. Aktifkan API yang diperlukan:
   - Maps SDK for Android
   - Maps SDK for iOS jika build iOS
   - Directions API
   - Geocoding API
3. Tambahkan key ke konfigurasi Android:

```properties
# android/local.properties
mapsApiKey=your-google-maps-api-key
```

4. Tambahkan key untuk request Directions/Geocoding di Flutter:

```env
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

5. Beri restriction pada API key, misalnya berdasarkan package name, SHA-1, bundle id, dan API restriction.

---

## AI Daily Plan

AI Daily Plan membantu user menyusun jadwal harian otomatis berdasarkan task yang belum selesai, jadwal yang sudah ada, prioritas, deadline, dan slot waktu kosong.

Alur fitur:

1. User memilih tanggal.
2. Aplikasi mengambil task dan schedule user.
3. Data dikirim ke backend.
4. Backend memanggil Groq API.
5. AI mengembalikan rekomendasi jadwal dalam format JSON.
6. User dapat melakukan revise dengan instruksi tambahan.
7. Jika user memilih Accept & Save, jadwal AI disimpan ke schedule aplikasi.

Fitur ini menggunakan backend route:

```text
POST /api/ai/daily-plan
```

---

## LBS / Location Based Service

Fitur LBS diterapkan pada Event. Event offline dapat memiliki latitude dan longitude sehingga user dapat melihat lokasi event di peta.

Implementasi LBS:

- Event menyimpan data lokasi berbasis koordinat.
- User dapat memilih lokasi event melalui Google Map picker.
- Detail event menampilkan marker lokasi event.
- User dapat melihat rute dari lokasi saat ini ke event.
- User dapat membuka navigasi eksternal menggunakan Google Maps.

Fitur ini relevan dengan tema aplikasi karena mahasiswa dapat menemukan dan menghadiri event akademik, seminar, lomba, workshop, dan kegiatan produktif lain berdasarkan lokasi.

Catatan: integrasi LBS sudah tersedia dan masih dapat ditingkatkan pada sisi polish UI, validasi data lama, dan testing lintas perangkat.

---

## Sensor

Sensor yang sudah digunakan:

- Compass / magnetometer melalui package `flutter_compass`.
- Location/GPS melalui `geolocator` untuk fitur LBS Event.

Planned improvement:

- Accelerometer untuk mendeteksi gerakan perangkat saat focus mode.
- Gyroscope untuk mini game atau fitur fokus berbasis gerakan.

---

## Biometric Login

Biometric login menggunakan package `local_auth`. Setelah user memiliki session, token dapat disimpan secara aman dan digunakan untuk login cepat melalui fingerprint atau face authentication jika perangkat mendukung.

Penyimpanan token dan flag biometric menggunakan Flutter Secure Storage.

---

## Screenshots

Tambahkan screenshot aplikasi ke folder `docs/screenshots/`.

```markdown
![Login Page](docs/screenshots/login.png)
![Home Page](docs/screenshots/home.png)
![Task Page](docs/screenshots/task.png)
![Schedule Page](docs/screenshots/schedule.png)
![AI Daily Plan](docs/screenshots/ai-daily-plan.png)
![Event Map](docs/screenshots/event-map.png)
![Tools Page](docs/screenshots/tools.png)
![Profile Page](docs/screenshots/profile.png)
```

---

## Demo Account

```text
Email: demo@ploopy.app
Password: password123
```

Catatan: akun demo dapat disesuaikan dengan data yang tersedia pada database Supabase masing-masing.

---

## Database

Ploopy menggunakan Supabase PostgreSQL untuk menyimpan data utama aplikasi, antara lain:

- User
- Task
- Schedule
- Study session
- Event
- Activity
- Friend request
- Achievement
- Notification
- Settings

Selain database remote, aplikasi juga menggunakan local storage seperti Isar, SharedPreferences, dan Flutter Secure Storage untuk cache, session, token, dan data lokal tertentu.

---

## Security Notes

- Password user di-hash menggunakan bcrypt.
- Authentication menggunakan JWT.
- Token disimpan di Flutter Secure Storage.
- Backend menggunakan middleware auth untuk endpoint yang membutuhkan login.
- `.env` tidak boleh di-push ke repository.
- API key seperti Supabase, Groq, dan Google Maps harus diberi restriction.
- Service role key Supabase hanya boleh digunakan di backend.

---

## Project Status

| Area | Status |
| --- | --- |
| Core features | Implemented |
| Requirement completion | Mostly implemented |
| Backend REST API | Implemented |
| AI Daily Plan | Implemented |
| Event LBS | In Progress |
| Sensor features | Need Improvement |
| Testing | Need Improvement |
| Screenshots dokumentasi | Planned |

Remaining improvements:

- Finalisasi sensor tambahan.
- Polish dan testing rute Event pada beberapa device.
- Menambahkan screenshot asli aplikasi ke README.
- Menambah test otomatis untuk repository, service, dan BLoC.
- Menyiapkan demo data untuk presentasi.

---

## Author

**Nikita**  
Informatika  
Project Akhir Praktikum Mobile / TPM
