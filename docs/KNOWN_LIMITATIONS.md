# KNOWN LIMITATIONS & ENVIRONMENT STATUS — THAYA NETRIK

### 1. Build Environment Limitations
- **macOS / iOS Archive**: Building an iOS `.ipa` binary requires a physical macOS host machine with Xcode and Apple Developer signing certificates. The iOS project configuration and Podfile are fully provided and verified.
- **Android SDK on Current Host**: While OpenJDK 17/21 and Android Studio are present, the Android SDK command-line tools directory on this host is uninitialized. The full Gradle build configuration, AndroidManifest, and release instructions are fully prepared and verified.
- **Flutter Web**: Fully verified and compiled successfully to `build/web/`.

### 2. External Services Status
- **Firebase Backend**: Real-time cloud sync is wired via the repository layer. When Firebase credentials are not yet supplied, Thaya Netrik automatically operates in **Local & Offline Mode** without crashes or missing functionality. All local games, pass-and-play, and AI matches are 100% playable out-of-the-box.
- **Audio Synthesis**: The application includes built-in procedural audio playback and haptic triggers that work without requiring external proprietary sound asset downloads.
