# Catatan Keuangan PRO

Aplikasi Flutter untuk mencatat pemasukan dan pengeluaran harian dengan tampilan seperti referensi screenshot.

## Fitur

- Catatan pemasukan dan pengeluaran.
- Ringkasan harian, mingguan, bulanan, dan tahunan.
- Pencarian transaksi berdasarkan kata kunci, kategori, tipe, dan rentang jumlah.
- Kelola kategori pemasukan dan pengeluaran.
- Data tersimpan lokal memakai `shared_preferences`.
- Backup dan restore file JSON.
- Backup Google Drive melalui share sheet Android, lalu pilih Google Drive.
- Export laporan CSV/JSON.
- Git hook otomatis menaikkan build number `pubspec.yaml` setiap commit.

## Flutter

Project ini dipin ke Flutter FVM `3.41.2`.

```bash
fvm flutter pub get
fvm flutter run
```

## Signing Android

Keystore lokal dibuat di:

```text
D:\KEYSTORE\CatatanKeuangan.jks
```

Konfigurasi signing lokal berada di `android/key.properties` dan sengaja tidak dimasukkan ke Git.

## Build

```bash
fvm flutter build apk --release
```
