# Diet Planning Support Application using Image Analysis 🍎📸

[Wersja Polska (Polish Version)](./README_PL.md)

An advanced mobile system designed to simplify diet monitoring through automated meal logging, powered by computer vision models.

---

## 👥 Authors

- **Kornel Tłaczała** ([@korneltlaczala](https://github.com/korneltlaczala))
- **Bartłomiej Wójcik** ([@wojcikbart](https://github.com/wojcikbart))
- **Tomasz Żywicki** ([@tomaszzywicki](https://github.com/tomaszzywicki))

**Supervisor:** Adam Żychowski, PhD  
**University:** Warsaw University of Technology, Faculty of Mathematics and Information Science

---

## 📄 Documentation (Engineering Thesis)

The full text of the engineering thesis, covering methodology, model training processes, and system architecture, is available below:

[📥 Download Thesis PDF (Polish Version)](./Aplikacja%20wspomagająca%20planowanie%20diety%20z%20wykorzystaniem%20analizy%20obrazu.pdf)

---

## 🌟 About the Project

The primary goal of this project was to create a tool that minimizes the effort required for calorie tracking. The application enables automatic identification of food items on a plate from a photo, calculates personalized energy requirements (BMR/TDEE), and supports users in achieving their fitness goals.

### Key Features:

- **AI Food Detection:** Recognition of multiple food products in a single image using a two-stage architecture (YOLOv11m detection + specialized classification).
- **Meal Diary:** Fast product entry via search, barcode scanner (Open Food Facts API), or the AI module.
- **Intelligent Calculator:** Automatic calculation of macronutrient needs based on the Mifflin-St Jeor equation and anthropometric parameters.
- **Progress Monitoring:** Interactive weight charts, BMI indicator, and goal achievement history.
- **AI Recipe Recommender:** Suggests recipes based on available ingredients using the Gemini-2.0-Flash model.
- **Offline Mode:** Local SQLite database allows for usage without an active internet connection.

---

## 🛠️ Technical Architecture

The system consists of three main components:

1. **Frontend:** Mobile application built with **Flutter / Dart**.
2. **Backend:** REST API built with **FastAPI / Python** for business logic and AI model inference.
3. **Database:** Relational database (**PostgreSQL**) and **Firebase** (Authentication).

---

## 🚀 Installation Guide

### 1. Backend (API Server & Models)

The backend is best run using Docker.

```bash
# Clone the repository
git clone [https://github.com/tomaszzywicki/cal-cones.git](https://github.com/tomaszzywicki/cal-cones.git)
cd cal-cones/backend

# Configure environment variables
cp .env.example .env

# Start containers (API + PostgreSQL)
docker-compose up -d

# Run database migrations
docker-compose exec backend alembic upgrade head
```

### 2. Mobile Application (Flutter)

Requires `Flutter SDK` installed on your machine.

```bash
cd cal-cones/frontend

# Fetch dependencies
flutter pub get

# Configure server address in lib/core/network/api_client.dart
# static const String baseUrl = 'http://<YOUR_IP>:8000';

# Run the app
flutter run
```

## 📊 AI Model Results

The implemented **YOLOv11m** model achieved a detection precision of **0.808 (mAP50: 0.702).** Average image analysis time is approximately **2.5 seconds**, ensuring a smooth user experience.

© 2026 Warsaw University of Technology
