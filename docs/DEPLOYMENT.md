# DEPLOYMENT GUIDE — THAYA NETRIK
## Multi-Platform Release & Distribution

### 1. Web Deployment
Build the release bundle:
```powershell
flutter build web --release --base-href /
```
The output files are generated in `build/web/`.
Deploy to Firebase Hosting:
```powershell
firebase deploy --only hosting
```
Or deploy to Vercel, Netlify, or GitHub Pages.

---

### 2. Android Deployment
Build the Google Play App Bundle:
```powershell
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

Build standalone universal APK for direct testing:
```powershell
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### 3. iOS Deployment
Build the iOS archive:
```bash
flutter build ipa --release
```
Open `ios/Runner.xcworkspace` in Xcode on macOS, configure Code Signing with your Apple Developer Team, and upload to TestFlight / App Store Connect.
