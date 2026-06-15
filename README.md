# PlayAll Verse 🎌

Aplikasi streaming anime, manga, novel & donghua untuk Android/iOS.

## Tech Stack
- **Frontend**: Flutter 3.32
- **Backend**: PHP 8.1 + MariaDB (playall.dev)
- **API**: REST API dari playall.dev/api

## Fitur
- 🏠 Home dengan hero banner auto-play
- 🎌 Browse anime, manga, novel, donghua
- 🔍 Search dengan filter
- 📄 Detail konten + daftar episode/chapter
- 🔖 Bookmark
- 👤 Profil & autentikasi

## Build APK
APK otomatis di-build via GitHub Actions setiap ada push ke `main`.
Download di tab **Releases** atau **Actions → Artifacts**.

## Arsitektur
```
App Flutter ←→ playall.dev/api ←→ Database
```
Ganti server = cukup arahkan domain. App tidak perlu diubah.
