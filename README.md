# Smart Village Indonesia

Aplikasi Flutter untuk mencari rumah sakit, puskesmas, dan klinik di sekitar lokasi pengguna atau desa/kelurahan yang dipilih di seluruh Indonesia.

## Fitur

- Pemilihan wilayah bertingkat: provinsi, kabupaten/kota, kecamatan, dan desa/kelurahan.
- Pencarian fasilitas dalam radius 10, 25, atau 50 km.
- Daftar fasilitas dengan pencarian nama, filter kategori, jarak lurus, dan layanan yang tersedia pada sumber data.
- Peta OpenStreetMap dengan marker kategori, posisi pengguna, dan radius geofence.
- Detail fasilitas, telepon, berbagi lokasi, dan navigasi melalui aplikasi peta eksternal.
- Geofencing saat aplikasi terbuka: masuk pada 200 m dan keluar pada 250 m.
- Cache respons wilayah dan fasilitas, serta data demo berlabel ketika layanan publik tidak tersedia.

## Menjalankan aplikasi

Prasyarat: Flutter stable dan JDK 17 atau lebih baru.

```powershell
flutter pub get
flutter run
```

Pilih perangkat Android atau Chrome dari daftar Flutter. Pada Android, aplikasi meminta izin lokasi saat pertama digunakan. Pencarian wilayah tetap berfungsi jika izin ditolak.

Untuk membuat APK debug:

```powershell
flutter build apk --debug
```

Hasil normal berada di `build/app/outputs/flutter-apk/app-debug.apk`.

## Verifikasi

```powershell
flutter analyze
flutter test
flutter build web
```

Golden screenshots untuk empat layar utama berada di `test/goldens/` pada viewport 393 × 852.

## Sumber data dan batasan

- Wilayah administratif: API Wilayah Indonesia dari Emsifa.
- Fasilitas dan peta: OpenStreetMap dan Overpass API.
- Cakupan fasilitas bergantung pada data OpenStreetMap yang telah dipetakan dan bukan direktori resmi nasional.
- Public Overpass digunakan untuk kebutuhan demonstrasi praktikum dengan pencarian terbatas. Aplikasi produksi perlu backend dan sumber data yang dikelola sendiri.
- Geofencing berjalan saat aplikasi berada di foreground; tidak ada pemantauan lokasi latar belakang.
