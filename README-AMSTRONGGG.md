# Amstronggg Video Editor — README

**Amstronggg Video Editor v1.0.0** adalah rebrand dari **Shotcut v26.9.27**
(tag `v26.9.27`, rilis 27 Sep 2026) — video editor open source berbasis Qt 6
dan MLT. Semua fitur Shotcut tetap ada: timeline multi-track, filter,
transisi, keyframes, proxy, hardware encoding, dsb.

- **Upstream:** Shotcut oleh Meltytech, LLC (Dan Dennedy) — https://www.shotcut.org/
- **Lisensi:** GNU GPL v3.0 — file `COPYING` dipertahankan apa adanya.
  Rebrand ini legal karena GPL mengizinkan modifikasi + redistribusi selama
  credit upstream dan lisensi tetap disertakan. **Jangan hapus file `COPYING`,
  copyright Meltytech di dialog About, dan baris "Based on Shotcut".**
- **Repo rebrand (rencana):** https://github.com/amstronggg/amstronggg-video-editor
  (belum dibuat — buat repo ini kalau mau publish release + update check).

## Yang diubah dari Shotcut (rebrand)

| Bagian | Perubahan |
|---|---|
| Nama app | `Amstronggg Video Editor` — title bar, About, menu, dialog, installer, registry, mutex, settings (`%APPDATA%\Amstronggg\Amstronggg Video Editor`), file settings `amstronggg-video-editor.ini`, log `amstronggg-video-editor-log.txt` |
| Versi | `1.0.0` (versi Shotcut asal: 26.9.27) |
| Exe | `AmstrongggVideoEditor.exe` (dulu `shotcut.exe`) |
| Ikon | Baru: film/play biru `#5fb2ff` + oranye `#ff9d00` di atas gelap `#0c0e11` — `icons/shotcut-logo-*.png` (nama file dipertahankan supaya `.qrc` tidak berubah), `.svg`, `.ico`, `.bmp` installer |
| Tema | Gelap Amstronggg: highlight `#5fb2ff`, window/base `#0c0e11`, aksen tab `#5fb2ff` (`src/mainwindow.cpp` + `src/resources/qtquickcontrols2-*.conf`) |
| Installer | `packaging/windows/amstronggg-video-editor.iss` (Inno Setup): nama, publisher, folder `Amstronggg Video Editor`, `AmstrongggVideoEditor-Setup-1.0.0.exe` |
| Version resource | `packaging/windows/amstronggg-video-editor.rc.in`: CompanyName Amstronggg, ProductName, OriginalFilename |
| Update check | **Dimatikan by default** (`noupgrade=true`) supaya app tidak menelepon shotcut.org. URL check sudah diarahkan ke repo GitHub ini (`version.json` — lihat bawah). |
| Build script | `scripts/build-shotcut-msys2.sh`: versi default `1.0.0`, folder install `AmstrongggVideoEditor` (tanpa spasi — spasi di nama folder bikin cmake pecah, lihat catatan build), nama SDK tar baru |
| Helper baru | `scripts/build-amstronggg-video-editor.sh` — build ulang hanya Shotcut (fase 2, lihat bawah) |

**Sengaja TIDAK diubah (internal, tidak terlihat user):** nama target CMake
`shotcut`, modul QML `Shotcut.*`, kunci properti MLT `shotcut:*` di file
proyek `.mlt` (supaya file proyek Shotcut lama tetap bisa dibuka), nama class
`ShotcutSettings`, file terjemahan `translations/shotcut_*.ts`, icon theme
`oxygen/dark`, packaging Linux/macOS, link bantuan forum Shotcut
(`forum.shotcut.org` — masih jadi tempat bantuan yang benar).

> Catatan terjemahan: string yang saya ubah di kode (mis. dialog About)
> akan tampil dalam bahasa Inggris sampai ada yang menerjemahkan ulang —
> file `.ts` lama masih berisi string Shotcut yang lama.

---

## ⚠️ BACA DULU SEBELUM BUILD — PRASYARAT BERAT

Jujur di depan (pelajaran dari build Audacity kemarin): **ini build BERAT**,
bukan seperti rebrand Electron/Python. Yang wajib dipahami:

1. **Build resmi Shotcut di Windows pakai MSYS2 + MinGW64 — BUKAN MSVC.**
   Toolchain Audacity kemarin (**Visual Studio 2022, Qt 6.12 MSVC di `J:\`,
   CMake, Ninja**) **TIDAK bisa dipakai** untuk build ini: MLT/FFmpeg/Qt
   yang dipakai Shotcut di-build dengan MinGW, dan tidak bisa di-link
   dengan Qt MSVC. Jangan buang waktu mencoba MSVC.
   Yang dipakai: MSYS2 + paket `mingw-w64-x86_64-qt6-*` + toolchain MinGW.
   (CMake 4.4.5 dan Ninja yang sudah ada tetap berguna — MSYS2 juga
   menyediakan cmake/ninja sendiri.)
2. **Waktu & disk:** build pertama (fase 1) me-build ~20 dependensi dari
   source (FFmpeg 9.0, MLT, OpenCV, whisper.cpp, frei0r, movit, dav1d, aom,
   SVT-AV1, VMAF, dsb.) — siapkan **30–50 GB disk kosong** dan waktu
   **beberapa jam** (2–6 jam tergantung PC). Build ulang Shotcut saja
   (fase 2) hanya beberapa menit.
3. **Butuh internet kencang** untuk download source + paket MSYS2.
4. **Inno Setup 6** (gratis) untuk membuat installer `.exe` dari `.iss`.

Kalau tiga hal di atas memberatkan, **jangan mulai dulu** — tidak apa-apa.
Rebrand ini tetap tersimpan dan bisa di-build kapan saja.

---

## Cara build di Windows (langkah demi langkah)

Semua perintah di bawah dijalankan di **MSYS2 MINGW64 shell**
(bukan PowerShell, bukan cmd) — kecuali langkah Inno Setup.

### Fase 0 — Pasang MSYS2 + paket

1. Download + install **MSYS2** dari https://www.msys2.org/ (installer
   `msys2-x86_64-*.exe`, install ke `C:\msys64` — default).
2. Buka **MSYS2 MINGW64** (bukan MSYS2 MSYS, bukan UCRT64).
3. Update dulu (jalankan 2x kalau diminta restart):
   ```bash
   pacman -Syu
   ```
4. Install semua paket build (satu perintah panjang — copy-paste saja):
   ```bash
   pacman -S --noconfirm autotools base-devel bzip2 coreutils git gzip tar xz zip \
     perl-List-MoreUtils perl-XML-Parser \
     mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-meson \
     mingw-w64-x86_64-nasm mingw-w64-x86_64-ninja mingw-w64-x86_64-yasm \
     mingw-w64-x86_64-cairo mingw-w64-x86_64-eigen3 mingw-w64-x86_64-dlfcn \
     mingw-w64-x86_64-fftw mingw-w64-x86_64-gcc-fortran \
     mingw-w64-x86_64-gettext-tools mingw-w64-x86_64-harfbuzz mingw-w64-x86_64-lame \
     mingw-w64-x86_64-libarchive mingw-w64-x86_64-libepoxy mingw-w64-x86_64-libexif \
     mingw-w64-x86_64-libimagequant mingw-w64-x86_64-libsamplerate \
     mingw-w64-x86_64-libtheora mingw-w64-x86_64-libvorbis mingw-w64-x86_64-libvpx \
     mingw-w64-x86_64-libwebp mingw-w64-x86_64-libxml2 mingw-w64-x86_64-lilv \
     mingw-w64-x86_64-onevpl mingw-w64-x86_64-openblas mingw-w64-x86_64-openssl \
     mingw-w64-x86_64-opus mingw-w64-x86_64-potrace mingw-w64-x86_64-python-pip \
     mingw-w64-x86_64-qt6-base mingw-w64-x86_64-qt6-charts \
     mingw-w64-x86_64-qt6-declarative mingw-w64-x86_64-qt6-imageformats \
     mingw-w64-x86_64-qt6-multimedia mingw-w64-x86_64-qt6-multimedia-wmf \
     mingw-w64-x86_64-qt6-svg mingw-w64-x86_64-qt6-tools \
     mingw-w64-x86_64-qt6-translations mingw-w64-x86_64-qt6-websockets \
     mingw-w64-x86_64-rubberband mingw-w64-x86_64-sox mingw-w64-x86_64-svt-av1 \
     mingw-w64-x86_64-vid.stab mingw-w64-x86_64-vulkan-headers \
     mingw-w64-x86_64-vulkan-loader mingw-w64-x86_64-x264 mingw-w64-x86_64-x265 \
     mingw-w64-x86_64-zimg
   ```
   Lalu hapus `aom` bawaan MSYS2 (script me-build aom sendiri):
   ```bash
   pacman --noconfirm -Rdd mingw-w64-x86_64-aom
   ```
5. Download dependensi prebuilt MLT (dipakai script saat deploy) — di
   MSYS2 MINGW64 shell:
   ```bash
   cd ~
   curl -kLO https://s3.amazonaws.com/misc.meltymedia/shotcut-build/mlt-prebuilt-mingw64-v7.txz
   tar -xJf mlt-prebuilt-mingw64-v7.txz
   rm mlt-prebuilt-mingw64-v7.txz
   ```
   (Hasilnya: folder `~/bin/` berisi DLL-DLL MLT. Kalau link di atas mati,
   cek nama file terbaru di `.github/workflows/build-windows.yml`.)

### Fase 1 — Build semua dependensi + Shotcut upstream (sekali saja, lama)

Masih di MSYS2 MINGW64 shell:

```bash
mkdir -p ~/build/src
cd ~/build/src
git clone --depth 1 --branch v26.9.27 https://github.com/mltframework/shotcut.git shotcut
cd shotcut
cat > ~/build-shotcut.conf <<'EOF'
INSTALL_DIR="$HOME/build"
SHOTCUT_VERSION="1.0.0"
EOF
bash scripts/build-shotcut-msys2.sh -c ~/build-shotcut.conf
```

Tunggu sampai selesai (beberapa jam). Kalau ada satu dependensi yang gagal,
catat nama + error-nya — biasanya tinggal install paket MSYS2 yang kurang,
lalu jalankan ulang perintah terakhir (script melanjutkan dari yang gagal
selama `ACTION_CLEAN_SOURCE=0`).

Hasil fase 1: folder portable `~/build/Shotcut/` (nama folder masih Shotcut
di fase ini — tidak apa-apa) berisi Shotcut upstream yang jalan.

### Fase 2 — Timpa dengan source rebrand, build ulang hanya Shotcut (cepat)

1. Copy folder source rebrand ini (isi zip `amstronggg-video-editor.zip`)
   ke mana saja, misal `~/amstronggg-video-editor`.
2. Di MSYS2 MINGW64 shell:
   ```bash
   cd ~/amstronggg-video-editor
   bash scripts/build-amstronggg-video-editor.sh
   ```
   Script ini: menyalin source rebrand ke `~/build/src/shotcut` (menimpa
   source upstream), lalu menjalankan build script dengan `ACTION_GET=0`
   dan `SUBDIRS="shotcut"` — jadi **hanya Shotcut** yang di-configure +
   compile + install + deploy ulang (beberapa menit, dependensi tidak
   di-build ulang).
3. Hasil: folder portable **`~/build/AmstrongggVideoEditor/`** berisi
   `AmstrongggVideoEditor.exe` — jalankan untuk mencoba.
4. Installer: file **`~/build/amstronggg-video-editor.iss`** + gambar
   `amstronggg-logo-64.bmp` (sudah disalin ke `~/build/` oleh helper).
   Buka `.iss` di **Inno Setup 6 Compiler** → Compile → hasilnya
   `AmstrongggVideoEditor-Setup-1.0.0.exe` (di `Documents\Inno Setup Examples Output`
   secara default — ubah `OutputDir` di `.iss` kalau mau).

> ⚠️ **JANGAN** menjalankan `scripts/build-shotcut-msys2.sh` dengan
> `ACTION_GET=1` di atas source rebrand ini — script akan
> `git reset --hard` + `git pull` dari upstream dan **menghapus semua
> perubahan rebrand**. Selalu pakai helper di atas untuk build ulang.

### Kalau mau build ulang setelah edit source

Edit file di `~/amstronggg-video-editor/`, lalu jalankan lagi:
```bash
cd ~/amstronggg-video-editor
bash scripts/build-amstronggg-video-editor.sh
```

---

## Update check (opsional, untuk nanti)

Update check dimatikan by default. Supaya bisa jalan dengan repo sendiri:

1. Buat repo GitHub `amstronggg/amstronggg-video-editor` (Public).
2. Buat file `version.json` di root repo (branch `main`) berisi:
   ```json
   {"version_string": "1.0.0", "url": "https://github.com/amstronggg/amstronggg-video-editor/releases"}
   ```
   Naikkan `version_string` tiap rilis baru.
3. Di PC, buka file settings
   `%APPDATA%\Amstronggg\Amstronggg Video Editor.ini`
   (nama file: `amstronggg-video-editor.ini` di folder data app) dan ubah
   `noupgrade=true` menjadi `false` — atau jalankan app dengan
   `--noupgrade` dimatikan. Menu *Help → Check for Upgrade* akan muncul
   lagi dan mengecek `version.json` di atas.

---

## File yang diubah (ringkas)

`CMakeLists.txt`, `src/main.cpp`, `src/mainwindow.cpp`,
`src/mainwindow.ui`, `src/settings.cpp`, `src/CMakeLists.txt`,
`src/models/multitrackmodel.cpp`, `src/mltcontroller.cpp`,
`src/mltxmlchecker.cpp`, `src/docks/{encodedock,filesdock,timelinedock}.cpp`,
`src/dialogs/saveimagedialog.cpp`, `src/hdrpreviewwindow.cpp`,
`src/jobs/{encodejob,meltjob,videoqualityjob}.cpp`,
`src/widgets/{avformat,image}producerwidget.ui`, `src/widgets/newprojectfolder.ui`,
`src/resources/qtquickcontrols2-{dark,light}.conf`,
`icons/shotcut-logo-*.png`, `icons/shotcut-logo-64.svg`,
`packaging/windows/amstronggg-video-editor.{iss,rc.in}`,
`packaging/windows/amstronggg-logo-64.{ico,bmp}`,
`scripts/build-shotcut-msys2.sh`, `scripts/build-amstronggg-video-editor.sh` (baru),
`.github/workflows/build-{windows,sdk-windows}.yml`, `AGENTS.md`,
`README-AMSTRONGGG.md` (baru).

## Kredit

- Shotcut © 2011–2026 Meltytech, LLC — GPL-3.0 — https://www.shotcut.org/
- MLT, FFmpeg, Qt, frei0r, Glaxnimate, dan semua proyek yang disebut di
  dialog About — tetap dikreditkan di dalam app.
- Rebrand (nama, tema, ikon, installer): Amstronggg.
