LORONGSATU21 UNDANGAN — SUPABASE EDITION

1. Supabase database, RLS, admin user, dan bucket product-images harus sudah dibuat.
2. Jalankan file supabase-public-order.sql SEKALI di Supabase SQL Editor.
3. Upload index.html, config.js, manifest.webmanifest ke repository GitHub Pages.
4. Login Admin memakai email/password Supabase Authentication yang sudah dibuat.
5. Publishable key di config.js aman untuk frontend; keamanan tetap bergantung pada RLS.
6. JANGAN pernah memasukkan sb_secret_, service_role, atau database password ke GitHub.

Fitur aktif:
- katalog publik dari Supabase
- produk + harga bertingkat
- kategori
- upload foto ke Supabase Storage
- login Admin
- pesanan publik via RPC aman
- status pesanan
- pelanggan dan laporan dasar
