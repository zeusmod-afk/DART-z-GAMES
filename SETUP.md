# DART'z GAMES — panduan pemasangan

Website ini memakai:
- Vercel untuk hosting halaman website.
- Supabase Auth untuk login admin.
- Supabase Database untuk katalog dan statistik download.
- Supabase Storage untuk file game dan cover.

## 1. Buat project Supabase
1. Buka https://supabase.com/ lalu buat project.
2. Buka SQL Editor, tempel seluruh isi `supabase.sql`, lalu jalankan.
3. Buka Authentication > Users > Add user. Buat email dan password admin.
4. Salin UUID user admin dari Authentication > Users.
5. Buka SQL Editor dan jalankan (ganti UUID contoh):
   `insert into public.admins (user_id) values ('UUID-ADMIN-DARI-SUPABASE');`
6. Buka Project Settings > API. Salin Project URL dan anon/public key (atau publishable key jika dashboard menampilkannya).

## 2. Hubungkan website
Buka `index.html`, cari:
- `ISI_SUPABASE_PROJECT_URL`
- `ISI_SUPABASE_ANON_KEY`

Ganti dengan Project URL dan anon/public key milik project Supabase.
JANGAN pernah menaruh `service_role` / secret key di HTML, GitHub, atau Vercel.

## 3. Deploy ke Vercel
1. Buat akun GitHub dan repository baru bernama `dartz-games`.
2. Upload `index.html` ke root repository. `supabase.sql` dan `SETUP.md` boleh ikut di-upload.
3. Buka https://vercel.com/ dan login dengan GitHub.
4. Add New > Project > Import repository `dartz-games`.
5. Framework Preset pilih Other. Build Command dan Output Directory bisa dikosongkan; Deploy.
6. Setelah selesai, buka domain `.vercel.app` yang diberikan.

## 4. Mengelola game
1. Buka website, tekan Admin.
2. Login memakai email/password admin yang dibuat di Supabase.
3. Isi data game, pilih file, lalu Upload & Publikasikan.
4. Edit nama, versi, dan deskripsi melalui tombol Edit. Hapus entri lewat Hapus.

## Catatan penting
- File di bucket publik dapat diunduh siapa pun yang memiliki tautannya; ini memang diperlukan untuk halaman download publik.
- Batas ukuran file contoh adalah 500 MB per file game dan 10 MB per cover. Bisa diubah pada pengaturan bucket/SQL sesuai paket dan batas project.
- Kuota storage dan bandwidth mengikuti paket Supabase; cek penggunaan sebelum membagikan file besar.
- Menghapus game dari katalog tidak otomatis menghapus file lama di Storage. Hapus file lama dari Supabase Storage secara manual bila memang tidak diperlukan.
- Versi awal ini menghitung klik download, bukan menjamin file selesai diunduh.
- Jangan unggah game, mod, atau aset yang tidak punya izin distribusi. Periksa file sebelum dibagikan.
- Untuk file HTML, lebih baik bagikan sebagai ZIP atau tautan web; file HTML mentah yang diunduh bukan otomatis menjadi game yang bisa dipasang.
