# ShapakSC

Private repo script Growtopia (Bothax), dijual via SC Hub.

## Cara Pakai (untuk pembeli)
1. Paste isi `- ShapakHub.lua` ke Bothax → Enter (execute).
2. Buka menu ImGui `Shapak SC Hub`.
3. Klik nama script → otomatis tarik dari repo + LoadEncrypt + jalan.

## Cara Update Script (untuk owner)
1. Edit script `.lua` di laptop.
2. Generate versi encrypted di Bothax:
   ```
   EncryptFile('namascript.lua', 12345)
   ```
   → hasil: `namascript_enc` di folder scripts.
3. Rename jadi `namascript_enc.enc` dan upload ke repo (folder `enc/`).
4. Update daftar di `- ShapakHub.lua` kalau ada script baru.

> Kunci `12345` contoh — ganti rahasia. Semua script HARUS pakai kunci sama biar LoadEncrypt jalan.
