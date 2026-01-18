# HalalSure (iOS – SwiftUI)

Trusted halal verification app.

## Features (MVP)
- Splash & onboarding (XD-inspired)
- Verify tab with search & details
- Scanner screen scaffold (VisionKit DataScanner-ready)

## Requirements
- Xcode 15+, iOS 17+
- Real device for barcode scanning (camera)

## Getting Started
1. Open `HalalSure.xcodeproj` in Xcode.
2. Run on a device (set Camera usage description in Info).
3. Roadmap below.

## Roadmap
- [ ] Barcode scanning with VisionKit DataScanner
- [ ] Local product repo → SwiftData (offline cache)
- [ ] RemoteProductRepository (connect to backend API)
- [ ] XD-matching colors/typography
- [ ] App Icon & Launch Screen

## HMA Popular Proxy (Optional)

The app can fetch “Popular Categories” labels via a local PHP proxy (to avoid CORS).

**Quick setup (macOS + XAMPP):**
1. Open **XAMPP Control** → start **Apache**.
2. Copy the proxy into htdocs:
   - `Server/deploy-proxy.sh` (provided in this repo) will copy `Server/proxy.php` to:
     `/Applications/XAMPP/xamppfiles/htdocs/halalsure-api/proxy.php`
3. Run:
   ```bash
   bash Server/deploy-proxy.sh



## Changelog
- v0.1.1: App icon added
