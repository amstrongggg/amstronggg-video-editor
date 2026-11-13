# 🎬 Amstronggg Video Editor

Video editor gratis dan open source untuk Windows — rebrand dari **Shotcut v26.9.27** dengan tema Amstronggg.

## ⬇️ Download

Ambil installer Windows terbaru di halaman [**Releases**](https://github.com/amstronggg/amstronggg-video-editor/releases):

- `amstronggg-video-editor-setup.exe` — Windows 10/11 64-bit

## ✨ Fitur

- Edit video lengkap: timeline multi-track, potong, gabung, transisi, filter, keyframes, color grading, dan export (MP4, dll).
- Tema gelap Amstronggg — biru `#5fb2ff`, hitam `#0c0e11`, ikon play oranye.
- Mendukung banyak format video/audio lewat FFmpeg.
- Update check mengarah ke repo ini (nonaktif secara default).

## 🛠️ Build dari source (Windows)

Dibangun dengan **MSYS2 + MinGW64** (bukan MSVC). Panduan lengkap ada di `README-AMSTRONGGG.md`.

```bash
bash scripts/build-amstronggg-video-editor.sh
```

Hasilnya: folder portable `AmstrongggVideoEditor/` + installer `.iss` untuk Inno Setup 6.

## 🙏 Kredit & Lisensi

- Berdasarkan **Shotcut v26.9.27** oleh Meltytech, LLC — lisensi **GPL-3.0** (lihat file `COPYING`).
- Rebrand (nama, tema, ikon, installer) oleh **Amstronggg**.
- Proyek ini gratis dan open source; kode sumber tersedia di repo ini.
