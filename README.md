# Automated Candidate Onboarding System

This repository contains a **Flutter frontend** and a **Django backend** integrated with MongoDB. Follow the steps below to set up the project locally and view the demo.

## Table of Contents
1. [Demo Video](#demo-video)
2. [Project Overview](#project-overview)
3. [Frontend - Flutter Setup](#frontend---flutter-setup)
4. [Backend - Django Setup](#backend---django-setup)
5. [Environment Variables](#environment-variables)

---

## Demo Video
Watch the project demo video here:

[![Project Demo](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=oGSM1IDRRDo)

---

## Project Overview
This project is a full-stack application with:
- **Frontend**: Flutter (Dart)
- **Backend**: Django (Python)
- **Database**: MongoDB

---

## Frontend - Flutter Setup
Follow these steps to set up the Flutter frontend:

1. **Install Flutter SDK**
   - Download Flutter from the [official Flutter website](https://flutter.dev/docs/get-started/install).
   - Verify installation:
     ```bash
     flutter --version
     ```

2. **Clone the repository**:
   ```bash
   git clone git@github.com:jayPatel029/Automated-Candidate-Onboarding-System.git
   cd frontend
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the Flutter app**:
   ```bash
   flutter run
   ```
   Ensure you have an emulator or connected device to test the app.

---

## Backend - Django Setup
Follow these steps to set up the Django backend:

1. **Install Python** (Ensure Python 3.8+ is installed):
   - Verify installation:
     ```bash
     python --version
     ```

2. **Create a virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. **Install project dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up MongoDB URI**:
   - Create a `.env` file in the backend directory:
     ```bash
     MONGO_URI=mongodb://username:password@localhost:27017/dbname
     ```

5. **Run the server**:
   ```bash
   python app.py
   ```

6. **Verify the server**:
   - Open `http://127.0.0.1:8000` in your browser.

---

## Environment Variables
To configure environment variables for the backend:
- Create a `.env` file in the Django backend root directory.
- Add the following keys:
   ```dotenv
   MONGO_URI=mongodb://<username>:<password>@<host>:<port>/<dbname>
   ```

---

## Contributing
Feel free to contribute to this project by submitting a pull request or creating an issue.

