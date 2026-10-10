# TypeRacer — Firebase Backend Setup Guide

This guide walks you through connecting your Firebase project to **TypeRacer** for online multiplayer rooms.

---

## 1. Firebase Console Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/) and click **Add Project**.
2. Name your project (e.g., `typeracer-arcade`).
3. Under **Build > Authentication**:
   - Click **Get Started**.
   - Enable **Anonymous** sign-in under the **Sign-in method** tab.
4. Under **Build > Realtime Database**:
   - Click **Create Database**.
   - Choose your preferred server location (e.g., `us-central1` or `asia-southeast1`).
   - Start in **Test Mode** (or proceed to step 3 to deploy production security rules).

---

## 2. Connect Flutter to Firebase

### Option A: Using FlutterFire CLI (Recommended)

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. In the project root, run:
   ```bash
   flutterfire configure
   ```
3. Select your Firebase project and platforms (**Android**, iOS, Web). This automatically generates `lib/firebase_options.dart` and configures Android Gradle files.

### Option B: Manual Android Setup

1. In the Firebase Console, go to **Project Settings > General**.
2. Under **Your apps**, click the **Android** icon.
3. Package name: `com.typeracer.app`
4. Download `google-services.json` and place it in:
   ```
   android/app/google-services.json
   ```

---

## 3. Deploy Security Rules

In the Firebase Console under **Realtime Database > Rules**, paste the contents of `database.rules.json` and click **Publish**.

Alternatively, if you have the Firebase CLI installed:
```bash
firebase deploy --only database
```

---

## 4. Local Simulation / Offline Demo Mode

**Note:** If Firebase credentials are not yet configured, the app **automatically operates in Local Demo Mode**:
- You can create rooms with AI bot racers.
- You can test full room lobbies, live 2–8 player tracks, synchronized countdowns, and results screens.
- Offline Practice mode works 100% without an internet connection.
- You can switch between Firebase Live Mode and Local Demo Mode anytime from the **Backend Status** pill on the Home Screen!
