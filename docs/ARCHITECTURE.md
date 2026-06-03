# Flutter Feature Architecture

Setiap fitur ditempatkan di `lib/features/<feature_name>` dan hanya membuat
folder yang benar-benar berisi file.

## Struktur

```text
lib/features/<feature_name>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
  presentation/
    bloc/
    pages/
    widgets/
```

Folder opsional seperti `datasources`, `models`, `bloc`, atau `widgets` boleh
tidak ada kalau fiturnya belum membutuhkannya.

## Dependency Rule

```text
presentation -> domain
data -> domain
domain -> tidak boleh import data/presentation
```

Aturan praktis:

- `domain/entities`: pure Dart object untuk kebutuhan bisnis/UI.
- `domain/repositories`: kontrak repository. Return type harus entity/domain
  type, bukan data model.
- `data/models`: bentuk data dari API, Isar, Supabase, atau JSON.
- `data/datasources`: akses HTTP, database lokal, storage, atau SDK eksternal.
- `data/repositories`: implementasi kontrak domain dan tempat mapping
  `Model <-> Entity`.
- `presentation/bloc`: state management, event, dan state UI.
- `presentation/pages/widgets`: widget Flutter.

## Auth Reference Implementation

Fitur `auth` sudah mengikuti pola ini:

- `domain/entities/user_entity.dart` dipakai oleh repository contract dan BLoC.
- `data/models/user_model.dart` hanya dipakai data layer untuk Isar/API mapping.
- `data/repositories/auth_repository_impl.dart` mengubah `UserModel` menjadi
  `UserEntity` sebelum keluar ke domain/presentation.
- `presentation/bloc/auth_bloc.dart` tidak import file dari `data`.

Gunakan pola auth sebagai referensi saat merapikan fitur lain.

## Current Migration Status

Sudah sesuai aturan:

- `auth`: domain contract memakai `UserEntity`; `UserModel` hanya di data layer.
- `schedule`, `study`, `chat`: sebagian besar repository domain sudah memakai
  entity/domain type.

Masih legacy dan perlu dimigrasi bertahap:

- `task`: `TaskRepository`, `TaskBloc`, dan beberapa page masih memakai
  `TaskModel` langsung.
- `notification`: repository dan BLoC masih expose `NotificationModel`.
- `activity`, `event`, `home`, `profile`: beberapa contract domain dan UI masih
  import `data/models`.

Saat migrasi fitur legacy, lakukan dari domain entity dulu, lalu mapper model,
repository implementation, BLoC state/event, terakhir UI.
