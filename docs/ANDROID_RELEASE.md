# ANDROID RELEASE GUIDE — THAYA NETRIK

### Package Details
- **Application ID**: `ai.netrik.thaya_netrik`
- **Min SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 35 (Android 15)
- **Compile SDK**: 35

### Keystore Generation for Play Store
To generate a release signing key:
```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:
```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

### Production Build Command
```powershell
flutter build appbundle --release
```
Artifact generated at: `build/app/outputs/bundle/release/app-release.aab`
