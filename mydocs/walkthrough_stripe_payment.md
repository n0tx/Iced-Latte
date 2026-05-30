# Walkthrough: Integrasi Stripe & Pemodelan Database Iced-Latte

Dokumen ini merangkum proses integrasi sistem pembayaran (Payment Gateway) dan analisis relasi database pada aplikasi Iced-Latte. Ini adalah catatan yang sangat bagus untuk portofolio *engineering* kamu.

## 1. Pemodelan Database (ERD ke SQL)
Sebuah arsitektur yang baik dimulai dari *User Story* yang jelas, lalu diekstrak menjadi tabel database:
- **Tabel Master:** `user_details` dan `product`. Berdiri sendiri (Mandiri).
- **Tabel Parent/Child:** `orders` bergantung pada `user_details`, sedangkan `order_item` bergantung pada `orders` dan `product`.

**Cara Membaca Simbol ERD (DBeaver) ke SQL:**
*   **Diamond + Garis Lurus (Parent, Mandatory 1):** Diwujudkan dengan `NOT NULL` pada kolom Foreign Key.
    *   *Contoh:* Kolom `user_id uuid NOT NULL` di tabel `orders` memastikan setiap pesanan WAJIB punya satu pemilik.
*   **Lingkaran (Optional 0):** Diwujudkan dari *ketiadaan* relasi yang memaksa di tabel Parent. 
    *   *Contoh:* Tabel `user_details` tidak memiliki kolom `order_id`, sehingga seorang *user* tidak wajib memiliki pesanan.
*   **Cabang Tiga (Many):** Diwujudkan dengan ketiadaan `UNIQUE` constraint pada Foreign Key.
    *   *Contoh:* Kolom `user_id` di tabel `orders` tidak bersifat unik, sehingga satu *user* bisa memiliki banyak pesanan.

---

## 2. Arsitektur Pembayaran (Tanpa Tabel Payment)
Iced-Latte **TIDAK MEMILIKI** tabel `payment`. Alih-alih membuat tabel sendiri yang rawan diretas, Iced-Latte mendelegasikan tanggung jawab ini kepada **Stripe**.
1. **Inisiasi (Session Creator):** Aplikasi mengirim daftar keranjang belanja ke Stripe, dan Stripe membalas dengan `Session ID`.
2. **Checkout:** Pelanggan membayar langsung di halaman Stripe menggunakan *Hosted Checkout*.
3. **Webhook (Kurir Stripe):** Stripe menghubungi server Iced-Latte via rute rahasia (`/api/v1/payment/stripe/webhook`) untuk melapor bahwa `Session ID` tersebut sudah lunas.
4. **Finalisasi:** Iced-Latte membuat baris di tabel `orders`, memindahkan isi `shopping_cart` ke `order_item`, menempelkan `Session ID` Stripe di struk pesanan, dan mengosongkan keranjang.

---

## 3. Bug Hunting: Masalah pada Integrasi Stripe

Selama proses pengujian, kita menemukan dua *bug* krusial yang berhubungan dengan ekosistem Spring Boot:

### Bug A: Error 502 (Stripe API Compatibility)
*   **Gejala:** Stripe menolak pembuatan sesi pembayaran dengan pesan bahwa `return_url` hanya boleh dipakai di mode `ui_mode: embedded`.
*   **Solusi:** Karena kita melakukan pengujian via Postman (tanpa frontend), kita memodifikasi `StripeSessionCreator.java` menjadi mode **Hosted Checkout** dengan mengganti parameter `.setReturnUrl()` menjadi `.setSuccessUrl()` dan `.setCancelUrl()`.

### Bug B: Error 401 Unauthorized pada Webhook
*   **Gejala:** Terminal CLI Stripe menunjukkan penolakan `[401]` saat mengirim event `checkout.session.completed`.
*   **Penyebab:** Kesalahan urutan evaluasi *filter* di `SpringSecurityConfiguration.java`. Aturan `/api/v1/payment/**` (yang butuh login) ditulis *sebelum* `/api/v1/payment/stripe/webhook` (yang `permitAll`). Spring membaca dari atas ke bawah, sehingga rute Webhook tertangkap oleh aturan pertama.
*   **Solusi:** Menukar posisi aturan agar rute spesifik Webhook (permitAll) dievaluasi lebih dulu.

### Bug C: Error 500 Internal Server Error saat Webhook Diterima
*   **Gejala:** Event Webhook berhasil masuk (`[200]`), tapi event puncak `checkout.session.completed` melempar `[500]`.
*   **Penyebab:** Setelah order dibuat, sistem mencoba mengirim Email Konfirmasi. Karena kredensial SMTP Gmail (`MAIL_USERNAME`) kosong di `.env`, Java Mail Sender *crash*, membuat seluruh fungsi gagal memberikan respons sukses ke Stripe.
*   **Solusi:** Membungkus perintah `paymentEmailConfirmation.send(session)` dengan blok `try-catch` di dalam `StripeWebhookService.java` agar kegagalan fitur opsional (Email) tidak mengganggu fitur utama (Validasi Pembayaran).
