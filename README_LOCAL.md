# PasarGuard Yerel Geliştirme ve Panel Rehberi

PasarGuard paneli bilgisayarınızda **birebir gerçek bir Ubuntu sunucusunda çalışıyormuş gibi** tüm özellikleri ve REST API'siyle birlikte yerel (local) olarak kuruldu ve çalışır hale getirildi.

---

## 🚀 Hızlı Erişim Adresleri

| Servis | Adres | Açıklama |
|---|---|---|
| **Arayüz (Geliştirme / Canlı Yenileme)** | [http://localhost:5173](http://localhost:5173) | **Vite Dev Server (HMR)**: Kodda yapacağınız her değişiklik sayfayı yenilemeden anında görünür. |
| **Tam Panel (Backend Dahili)** | [http://127.0.0.1:8000/dashboard/](http://127.0.0.1:8000/dashboard/) | FastAPI tarafından sunulan derlenmiş arayüz. |
| **API Dokümantasyonu (Swagger UI)** | [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) | Tüm REST API uç noktaları, testler ve şemalar. |

---

## 🔑 Yönetici (Admin) Giriş Bilgileri

Panel için gerekli Owner (Sahip) yönetici hesabı oluşturuldu:

- **Kullanıcı Adı:** `admin`
- **Şifre:** `ADmin123456!@#`

*(Giriş ekranında bu bilgileri yazarak doğrudan yönetim paneline girebilirsiniz.)*

---

## 📂 Neler İndirildi / Ne Lazım?

Sisteminizde zaten yüklü olanlar ve bu süreçte kurduklarımız:

1. **Git:** Sisteminizde mevcuttu (v2.53).
2. **Node.js & npm:** Sisteminizde mevcuttu (v24.13 / npm 11.8).
3. **uv (Python Yöneticisi):** Sisteminizde mevcuttu (v0.10.7). Projenin ihtiyaç duyduğu CPython 3.14 sanal ortamını (`panel/.venv`) otomatik oluşturdu ve 90 adet Python kütüphanesini eksiksiz kurdu.
4. **Bun (JavaScript/TypeScript Runtime):** PasarGuard panelinin kullandığı ultra hızlı paket yöneticisi. `npm install -g bun` ile kuruldu (v1.4.2).
5. **Veritabanı:** Gerçek bir sunucudaki gibi SQLite (`db.sqlite3`) üzerinde tüm Alembic migration'ları (60+ versiyon) çalıştırıldı ve tablolar eksiksiz oluşturuldu.

---

## 🖱️ Tek Tıkla Başlatma Dosyaları (Kısayollar)

Klasör içerisinde hazır `.bat` dosyaları oluşturuldu:

- **`start-all.bat`**: Hem Backend'i hem de Frontend Geliştirme sunucusunu iki ayrı pencerede otomatik başlatır.
- **`run-backend.bat`**: Sadece FastAPI backend sunucusunu (Port 8000) başlatır.
- **`run-frontend-dev.bat`**: Sadece Vite canli arayüz sunucusunu (Port 5173) başlatır.
- **`build-frontend.bat`**: Arayüzde yaptığınız değişiklikleri derleyip `panel/dashboard/build` içine atar.

---

## 🎨 Arayüzde Değişiklik Yapma ve Özellik Ekleme

Arayüz kodları **React 19**, **TypeScript**, **Tailwind CSS**, **Radix UI** ve **React Router** ile yazılmıştır.

Tüm arayüz kodları şu klasörde yer alır:
👉 `Pasarguard project\panel\dashboard\src`

### Önemli Klasör ve Dosyalar:
- **Sayfalar:** `panel/dashboard/src/pages/`
  - `_dashboard._index.tsx`: Ana gösterge paneli (Dashboard Home)
  - `_dashboard.users.tsx`: Kullanıcılar sayfası
  - `_dashboard.nodes._index.tsx`: Sunucu/Düğüm (Node) yönetimi
  - `_dashboard.hosts.tsx`: Host ve Inbound ayarları
  - `_dashboard.admins.tsx`: Yöneticiler ve RBAC rolleri
  - `_dashboard.statistics.tsx`: İstatistik ve grafikler
  - `login.tsx`: Giriş ekranı
- **Bileşenler (UI Components):** `panel/dashboard/src/components/ui/` (Butonlar, diyaloglar, tablolar, kartlar vb.)
- **Özellikler (Features):** `panel/dashboard/src/features/` (Kullanıcı ekleme modalları, formlar, ayarlar)
- **API İstekleri:** `panel/dashboard/src/service/api.ts` (Backend API fonksiyonları)
- **Çeviriler (Diller):** `panel/dashboard/src/locales/`

### Nasıl Geliştirme Yapılır?
1. `run-backend.bat` ve `run-frontend-dev.bat` çalıştırın (veya `start-all.bat`).
2. Tarayıcınızda [http://localhost:5173](http://localhost:5173) adresini açın.
3. `panel/dashboard/src` içerisindeki herhangi bir `.tsx` veya `.css` dosyasında değişiklik yapıp kaydedin (`Ctrl + S`).
4. Tarayıcınız sayfayı bile yenilemeden (Hot Module Replacement) değişikliği anında gösterecektir!
