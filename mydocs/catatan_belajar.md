# 📚 Catatan Belajar Kontribusi Open Source: Iced-Latte

Catatan ini dibuat untuk mendokumentasikan perjalanan mempelajari dan berkontribusi pada proyek open source [Iced-Latte](https://github.com/Sunagatov/Iced-Latte).

## 🚀 Tahap 1: Persiapan & Infrastruktur (Selesai ✅)

### 1. Mempersiapkan Proyek
- Melakukan *Fork* project Iced-Latte dari repositori resmi di GitHub.
- Menyalin konfigurasi otomatis dan menyalakan infrastruktur utama (PostgreSQL, Redis, MinIO):
  ```bash
  cp .env.example .env && docker compose up -d postgres redis minio minio-init
  ```

### 2. Memastikan Infrastruktur Berjalan
Mengecek daftar *container* Docker menggunakan perintah `docker ps`:
```text
CONTAINER ID   IMAGE                COMMAND                  CREATED       STATUS                 PORTS                                                           NAMES
5e548c342ca4   redis:7-alpine       "docker-entrypoint.s…"   4 hours ago   Up 4 hours (healthy)   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp                       iced-latte-redis
1bc1f886449e   postgres:16-alpine   "docker-entrypoint.s…"   4 hours ago   Up 4 hours (healthy)   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                       iced-latte-postgresdb
a5ef1b898a55   minio/minio:latest   "/usr/bin/docker-ent…"   4 hours ago   Up 4 hours (healthy)   0.0.0.0:9000-9001->9000-9001/tcp, :::9000-9001->9000-9001/tcp   iced-latte-minio
```

---

## 🏃 Tahap 2: Setup Workspace & Menjalankan Backend (Selesai ✅)

Kita perlu menyesuaikan spesifikasi lokal untuk kepentingan kontribusi agar sesuai dengan bahasa aplikasi backend (*Java 25* dan *Maven*). 

### 1. Install & Upgrade SDKMAN
Saat mengatur versi lewat SDKMAN, kebetulan sistem sudah punya instalasi lama (v5.14.2) sehingga ikut sekalian meminta *upgrade* ke versi baru (v5.22.4).
```bash
# Menjalankan instalasi Java 25 dan Maven
zsh -c "export sdkman_auto_answer=true; source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 25-open && sdk install maven"
```
Karena ini diproses di belakang layar, kita perlu membuka *terminal tab* baru atau *"menyiram"* konfigurasi dengan:
```bash
source ~/.sdkman/bin/sdkman-init.sh
```

### 2. Isolasi Environment dengan SDKMAN (Local Env)
Langkah wajib ini kita lakukan untuk menjaga agar Java lokal di `Sistem OS Utama / Global` kita aman dan tidak berubah, jadi Java 25 & Maven baru hanya menyala di dalam folder *Iced-Latte*.

- Membuat aturan versi khusus folder proyek:
  ```bash
  sdk env init
  ```
- Menyalakan fitur pendeteksi otomatis pindah versi (*auto_env*):
  ```bash
  sed -i 's/sdkman_auto_env=false/sdkman_auto_env=true/g' ~/.sdkman/etc/config
  ```
- Menghapus aturan `global default` buatan SDKMAN secara radikal dari lokal:
  ```bash
  rm -f ~/.sdkman/candidates/java/current
  rm -f ~/.sdkman/candidates/maven/current
  ```

### 3. Mengatur Git Ignore Lokal (Mencegah Kebocoran Config)
Agar konfigurasi rahasia atau personal seperti `.sdkmanrc` dan `catatan_belajar.md` tidak sengaja ter-*commit* dan terkirim (*push*) ke repositori umum GitHub, kita memakai trik "Daftar Hitam Git Lokal". 

Bedanya dengan `.gitignore`, trik `.git/info/exclude` ini tidak akan pernah di-*commit*, artinya ini jadi rahasia eksklusif di laptop kita saja:
```bash
echo ".sdkmanrc" >> .git/info/exclude
echo "catatan_belajar.md" >> .git/info/exclude
```

### 4. Sukses Menjalankan Spring Boot Pertama Kali!
Kita menyalakan mesin *backend* Java-nya menggunakan *Allexport Mode* (`set -a`) khusus pengguna `zsh` agar variabel `.env` bisa terkonversi mulus:
```bash
set -a; source .env; set +a; mvn spring-boot:run
```

---

## 💻 Tahap 3: Memulai Kontribusi Pertama / Bug Fixing
- Memilih **Issue #270** (Memperbaiki pesan error *Regex* pada form validasi password).
- Memilih **Issue #270** (Memperbaiki pesan error *Regex* pada form validasi password).

### Cara Mengakses & Menguji API

#### Swagger UI
Hanya aktif saat `SPRING_PROFILES_ACTIVE=dev` (bukan `prod`). Buka di browser:
```
http://localhost:8083/api/docs/swagger-ui/index.html
```
> ⚠️ **Catatan Kendala:** Tombol **Authorize** (gembok) untuk memasukkan JWT Token tidak muncul di Swagger UI proyek ini. Kemungkinan karena proyek menggunakan banyak file YAML OpenAPI terpisah sehingga konfigurasi `securitySchemes` global tidak terbaca dengan benar oleh Springdoc.

#### Postman (Solusi Alternatif yang Lebih Lengkap)
Karena Swagger tidak bisa di-*authorize*, gunakan Postman sebagai pengganti utama.

**Cara import semua endpoint sekaligus tanpa mengetik ulang:**
1. Buka Postman → klik tombol **Import**
2. Pilih opsi **Link / URL**
3. Tempel URL skema OpenAPI:
   ```
   http://localhost:8083/api/docs/schema
   ```
4. Klik **Import** → Postman otomatis men-*generate* semua *folder* dan *endpoint* Iced-Latte.

**Cara pasang JWT Token untuk semua request (Token Master):**
1. Klik nama **Koleksi Induk** di panel kiri Postman.
2. Buka tab **Authorization**.
3. Pilih *Type*: **Bearer Token**.
4. Tempel token dari hasil *login* (`eyJhbG...`).
5. *Save* → semua *request* di bawahnya otomatis pakai token ini.


---

## 🛠️ Tahap Extra: Troubleshooting Lingkungan Terminal ZSH
Sempat terjadi beberapa "bencana kecil" karena konfigurasi sisa proyek masa lalu di terminal, yang berhasil diselesaikan dengan konsep pengelolaan yang lebih maju (*Clean Environment*):

### 1. Mematikan `sdkman_auto_env`
Ternyata berganti versi *Java* setiap kali *cd* masuk ke folder cukup merepotkan (terkadang kita masuk cuma untuk cek file). Akhirnya fitur otomasi diganti ke `false`:
```bash
sed -i 's/sdkman_auto_env=true/sdkman_auto_env=false/g' ~/.sdkman/etc/config
```
Sekarang, jika ingin beralih versi, kita cukup mengetik `sdk env` di dalam folder proyek untuk mengaktifkan versi secara **sementara/per-tab**. Kalau tab / terminal di *close*, maka ia akan kembali ke versi utama komputer.

### 2. Bahaya Konfigurasi *Hardcode* PATH di `.zshrc`
Meski `sdk env` sudah ditekan, kadang perintah `mvn -version` atau `java -version` *nyangkut* di versi lama komputer (`3.9.5` atau `jdk-17`). 
Penyebabnya: Di `.zshrc` terdapat baris paksa seperti `export M2_HOME="/opt..."` atau `export JAVA_HOME="..."`. Ini membuat `zsh` selalu meletakkan direktori lokal itu sebagai prioritas pertama (atau sudah di-*cache* hash).
**Solusi:** Mematikan (*comment* / bari tanda `#`) baris ekspor `PATH` lama tersebut di `~/.zshrc` agar SDKMAN bisa bekerja murni sendiri tanpa ditabrak.

### 3. Mengontrol Versi Menggunakan Terminal SDKMAN
Mendaftarkan folder lokal (seperti Java 17) agar diurus SDKMAN:
```bash
sdk install java 17.0.5-lokalku /usr/lib/jvm/jdk-17
sdk install maven 3.9.5
```
Mengecek daftar yang sudah terpasang dan tersedia:
```bash
sdk list java
sdk list maven
```
Menjadikan versi lokal / versi spesifik sebagai "Default Utama / Konfigurasi Pabrik Komputer":
```bash
sdk default java 17.0.5-lokalku
sdk default maven 3.9.5
```

### 4. Pelajaran Penting: Duplikasi Pesan Validasi
Saat menggunakan `x-field-extra-annotation` untuk `jakarta.validation.constraints.Pattern`, kita harus **menghapus** properti `pattern` standar di YAML. 
- Jika keduanya ada: Generator akan membuat satu `@Pattern` di field (dari extra annotation) dan satu lagi di getter (dari property pattern bawaan).
- Akibatnya: Spring Boot menjalankan validasi dua kali dan mengembalikan dua pesan error sekaligus.
- Solusi: Cukup gunakan `x-field-extra-annotation` agar kita punya kendali penuh atas pesannya.

---

## 💻 Tahap Akhir: Pengiriman Kontribusi (Success! 🚀)

Alur kerja profesional yang kita gunakan untuk menjaga kebersihan repositori:

1. **Local Stashing:** Mengamankan file catatan ini agar tidak ikut "bocor" ke publik:
   ```bash
   git stash push catatan_belajar.md -m "catatan: hasil testing regex & dev setup"
   ```
2. **Branching:** Selalu gunakan branch terpisah untuk setiap issue (Misal: `fix/issue-270-...`).
3. **Professional Commit:** Menggunakan gaya "Learning Journal" di dalam commit message untuk menjelaskan alur pikir (Why & How).
4. **Visual Proof:** Melampirkan screenshot Postman (Before vs After) di deskripsi Pull Request untuk meyakinkan maintainer.

**Status Terakhir:** 
✅ Issue #270 Sukses di-fix.
✅ Pull Request sudah di-submit ke branch `development` repositori asli.
✅ Menunggu review/merge dari maintainer.

---
> *"Progress is more important than perfection, but today we got both!"* 🤜🤛

---

## 🎯 Rencana Selanjutnya (Upcoming Issues)

Berikut adalah beberapa target *issue* menarik yang bisa kita eksekusi selanjutnya untuk memperdalam ilmu:

### 🔵 Pilihan 2: Benerin Dokumentasi API (Issue #274)
- **🛠️ Masalah:** Di dokumentasi Swagger, tertulis bahwa untuk mengambil data user harus mengirim "User ID". Padahal aplikasi cuma butuh token dari user yang sedang login.
- **🎯 Goal:** Mencari Controller User dan memperbaiki deskripsi anotasi Swagger agar lebih akurat.

### 🔵 Pilihan 3: Benerin Tipe Data Rating (Issue #306)
- **🛠️ Masalah:** inkonsistensi tipe data `averageRating` (String "4.5" vs Float 4.5) di berbagai endpoint.
- **🎯 Goal:** Menyeragamkan tipe data response object menjadi angka (float/double) agar memudahkan tim Frontend.

*Mau lanjut hajar sekarang atau simpan buat "jatah" besok bro?* 😎
