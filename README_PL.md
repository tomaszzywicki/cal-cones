# Aplikacja wspomagająca planowanie diety z wykorzystaniem analizy obrazu 🍎📸

[English Version](./README.md)

Kompleksowy system mobilny do monitorowania diety, który automatyzuje proces logowania posiłków dzięki zaawansowanym modelom wizji komputerowej.

---

## 👥 Autorzy

- **Kornel Tłaczała** ([@korneltlaczala](https://github.com/korneltlaczala))
- **Bartłomiej Wójcik** ([@wojcikbart](https://github.com/wojcikbart))
- **Tomasz Żywicki** ([@tomaszzywicki](https://github.com/tomaszzywicki))

**Promotor:** dr inż. Adam Żychowski  
**Uczelnia:** Politechnika Warszawska, Wydział Matematyki i Nauk Informacyjnych

---

## 📄 Dokumentacja (Praca Inżynierska)

Pełny tekst pracy inżynierskiej opisujący metodologię, proces trenowania modeli oraz architekturę systemu dostępny jest poniżej:

[📥 Pobierz PDF z Pracą Inżynierską](./Aplikacja%20wspomagająca%20planowanie%20diety%20z%20wykorzystaniem%20analizy%20obrazu.pdf)

---

## 🌟 O projekcie

Głównym celem projektu było stworzenie narzędzia, które maksymalnie upraszcza żmudny proces śledzenia kalorii. Aplikacja pozwala na automatyczną identyfikację produktów na talerzu na podstawie zdjęcia, wylicza spersonalizowane zapotrzebowanie energetyczne (BMR/TDEE) oraz wspiera użytkownika w osiąganiu celów sylwetkowych.

### Kluczowe funkcjonalności:

- **AI Food Detection:** Rozpoznawanie wielu produktów spożywczych na jednym zdjęciu przy użyciu dwuetapowej architektury (Detekcja YOLOv11m + wyspecjalizowana klasyfikacja).
- **Dziennik posiłków:** Szybkie dodawanie produktów poprzez wyszukiwarkę, skaner kodów kreskowych (Open Food Facts API) lub moduł AI.
- **Inteligentny kalkulator:** Automatyczne wyliczanie zapotrzebowania na makroskładniki na podstawie równania Mifflina i parametrów antropometrycznych.
- **Monitorowanie postępów:** Interaktywne wykresy wagi, wskaźnik BMI oraz historia realizacji celów.
- **AI Recipe Recommender:** Generowanie przepisów kulinarnych na podstawie posiadanych składników z wykorzystaniem modelu Gemini-2.0-Flash.
- **Tryb Offline:** Lokalna baza danych SQLite umożliwia korzystanie z aplikacji bez dostępu do sieci.

---

## 🛠️ Architektura Techniczna

System składa się z trzech współpracujących komponentów:

1. **Frontend:** Aplikacja mobilna (**Flutter / Dart**).
2. **Backend:** REST API (**FastAPI / Python**) obsługujące logikę biznesową i inferencję modeli AI.
3. **Database:** Relacyjna baza danych (**PostgreSQL**) oraz **Firebase** (Autentykacja).

---

## 🚀 Instrukcja Instalacji

### 1. Backend (Serwer API i Modele)

Backend najlepiej uruchomić w środowisku Docker.

```bash
# Sklonuj repozytorium
git clone [https://github.com/tomaszzywicki/cal-cones.git](https://github.com/tomaszzywicki/cal-cones.git)
cd cal-cones/backend

# Skonfiguruj zmienne środowiskowe
cp .env.example .env

# Uruchom kontenery (API + PostgreSQL)
docker-compose up -d

# Wykonaj migracje bazy danych
docker-compose exec backend alembic upgrade head
```

### 2. Aplikacja Mobilna (Flutter)

Wymagane zainstalowanie `Flutter SDK`.

```bash
cd cal-cones/frontend

# Pobierz zależności
flutter pub get

# Skonfiguruj adres serwera w lib/core/network/api_client.dart
# static const String baseUrl = 'http://<TWOJE_IP>:8000';

# Uruchom aplikację
flutter run
```

---

## 📊 Wyniki Modeli AI

Zastosowany model **YOLOv11m** osiągnął precyzję detekcji na poziomie **0.808** (mAP50: **0.702**). Średni czas analizy zdjęcia wynosi ok. **2.5 sekundy**, co zapewnia wysoką płynność działania aplikacji.

© 2026 Politechnika Warszawska
