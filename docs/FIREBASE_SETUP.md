# FIREBASE SETUP GUIDE — THAYA NETRIK
## Production Backend Provisioning & Environment Configuration

### 1. Prerequisites
- Node.js >= 18 installed
- Firebase CLI installed: `npm install -g firebase-tools`
- A Google Cloud / Firebase account

---

### 2. Creating Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project**, and name it `thaya-netrik`.
3. Enable or disable Google Analytics as desired.
4. Click **Create project**.

---

### 3. Enabling Authentication Providers
In Firebase Console -> Build -> **Authentication**:
1. Click **Get Started**.
2. Enable the **Email/Password** sign-in method.
3. Enable **Anonymous** authentication (for Guest mode).
4. Optionally enable **Google** sign-in with your support email.

---

### 4. Setting up Cloud Firestore
In Firebase Console -> Build -> **Firestore Database**:
1. Click **Create database**.
2. Select standard multi-region or region (e.g., `asia-south1` for optimal India latency).
3. Start in **Production Mode**.
4. Deploy the Security Rules from `docs/DATABASE_SCHEMA.md` or `firestore.rules`.

---

### 5. Configuring Flutter Client (`flutterfire configure`)
Run the FlutterFire CLI to automatically register apps and generate `lib/firebase_options.dart`:
```powershell
dart pub global activate flutterfire_cli
flutterfire configure --project=thaya-netrik
```
Select the platforms:
- Android (Package: `ai.netrik.thaya_netrik`)
- iOS (Bundle ID: `ai.netrik.thayaNetrik`)
- Web (App name: `Thaya Netrik Web`)

---

### 6. Local Development Mode (No Backend Credentials Required)
Thaya Netrik includes an automated **Offline & In-Memory Mode**:
- If `firebase_options.dart` is not configured, the app seamlessly runs with local mock/in-memory data and full local pass-and-play and AI play.
- Local high scores, match history, and player profiles persist to local `SharedPreferences`.
