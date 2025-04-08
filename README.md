<div align="center">
    <a href="https://404notfound.fun" target="_blank">
        <img src="./assets/icon/icon-foreground.png" width="200" alt="Kamus Banjar">
    </a>

<br />

[![GitHub Stars](https://img.shields.io/github/stars/404NotFoundIndonesia/kamus-banjar-mobile-app.svg)](https://github.com/404NotFoundIndonesia/kamus-banjar-mobile-app/stargazers)
[![GitHub license](https://img.shields.io/github/license/404NotFoundIndonesia/kamus-banjar-mobile-app)](https://github.com/404NotFoundIndonesia/kamus-banjar-mobile-app/blob/main/LICENSE)

</div>

# Kamus Banjar

Kamus Banjar adalah aplikasi mobile yang dirancang untuk menyediakan pengguna dengan kamus lengkap bahasa Banjar. Aplikasi ini memungkinkan pengguna untuk mencari kata dalam bahasa Banjar, melihat maknanya dalam bahasa Indonesia, dan mengakses informasi linguistik tambahan.

## 📥 Unduh Aplikasi
Aplikasi ini tersedia di Google Play Store:

<a href="https://play.google.com/store/apps/details?id=com.iqbaleff214.kamus_banjar_mobile_app" target="_blank">
    <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200" alt="Download on Google Play">
</a>

## 🚀 Fitur
- 🔍 Pencarian kata dalam bahasa Banjar
- 📜 Daftar kata dengan definisi lengkap
- ⭐ Simpan kata favorit
- 🎨 UI minimalis dan ringan

## 🛠️ Teknologi yang Digunakan
- **Frontend:** Flutter
- **Backend:** [Golang](https://github.com/iqbaleff214/kamus-banjar-api)
- **Database:** MySQL & JSON file

## 🔧 Cara Install dan Menjalankan
### 🧠 Backend (API) - Lokal

1. Clone dan jalankan backend:
   ```sh
   git clone https://github.com/iqbaleff214/kamus-banjar-api.git
   cd kamus-banjar-api
   ```

2. Install dependencies:
   ```sh
   go mod tidy
   ```

3. Jalankan server lokal:
   ```sh
   go run main.go
   ```

   > Secara default akan berjalan di `http://localhost:8001`.  
   Pastikan URL ini digunakan di `API_BASE_URL` saat menjalankan aplikasi mobile.

---

### 📱 Mobile App (Flutter)

1. Clone repository ini:
   ```sh
   git clone git@github.com:404NotFoundIndonesia/kamus-banjar-mobile-app.git
   cd kamus-banjar-mobile-app
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. Jalankan aplikasi dengan environment variable, silakan ikuti sesuai kebutuhan:

   #### ✅ Command Line
   ```sh
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001
   ```

   #### ✅ Android Studio
   - Buka **Run > Edit Configurations...**
   - Pilih konfigurasi `main.dart`
   - Isi **Additional run args**:
     ```
     --dart-define=API_BASE_URL=http://10.0.2.2:8001
     ```

   #### ✅ Visual Studio Code
   - Tekan `F5` → klik ikon roda gigi untuk edit `launch.json`
   - Tambahkan:
     ```json
     {
       "name": "Flutter",
       "request": "launch",
       "type": "dart",
       "program": "lib/main.dart",
       "args": [
         "--dart-define=API_BASE_URL=http://10.0.2.2:8001"
       ]
     }
     ```

## 📜 Lisensi
Proyek ini berlisensi di bawah [MIT License](LICENSE).

## 🤝 Kontribusi
Kontribusi sangat diterima! Jika ingin berkontribusi:
1. Fork repository ini
2. Buat branch baru (`git checkout -b feat/fitur-baru`)
3. Commit perubahan (`git commit -m 'Menambahkan fitur X'`)
4. Push ke branch (`git push origin feat/fitur-baru`)
5. Buat Pull Request

## 📬 Kontak
Jika ada pertanyaan atau saran, jangan ragu untuk menghubungi kamu:
- Email: [404nf.oa@gmail.com](mailto:404nf.oa@gmail.com) | [andikasujanadi@gmail.com](mailto:andikasujanadi@gmail.com) | [iqbaleff214@gmail.com](mailto:iqbaleff214@gmail.com)
- Website: [404notfound.fun](https://404notfound.fun)

Terima kasih telah menggunakan **Kamus Banjar**! 😊