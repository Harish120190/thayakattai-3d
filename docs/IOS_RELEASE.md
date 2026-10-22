# IOS RELEASE GUIDE — THAYA NETRIK

### Bundle Identifier & Provisioning
- **Bundle ID**: `ai.netrik.thayaNetrik`
- **Minimum iOS Version**: iOS 13.0
- **Supported Devices**: iPhone, iPad (Universal app)

### Capabilities Required
- Network state access for real-time multiplayer
- Push notifications (APNs / FCM) for match invitations

### Xcode Archive & Export
1. On a macOS workstation with Xcode installed, navigate to the project directory.
2. Run `pod install` in `ios/`.
3. Execute:
   ```bash
   flutter build ipa --export-options-plist=ios/ExportOptions.plist
   ```
4. Upload the generated `.ipa` to App Store Connect using Transporter or `xcrun altool`.
