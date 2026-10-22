# WEB DEPLOYMENT GUIDE — THAYA NETRIK

### Performance & Configuration
Thaya Netrik Web is compiled with Flutter Web:
- **Renderer**: CanvasKit / HTML auto-switching for optimal balance between rendering fidelity and quick initial load time.
- **Responsive Layout**: Adapts gracefully from mobile portrait browser windows to 4K widescreen desktop viewports.

### Build Production Web Artifacts
```powershell
flutter build web --release --base-href /
```
Target directory: `build/web/`

### Testing Locally
You can serve the web build using any HTTP server:
```powershell
npx serve build/web -p 8080
```
Or run directly in debug mode:
```powershell
flutter run -d chrome
```
