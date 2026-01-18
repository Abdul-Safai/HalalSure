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

### Running the HMA proxy (required for Popular data)

This app fetches "Popular Categories" via a small PHP proxy.

Option A — XAMPP (matches current code):
1) Copy `Server/proxy.php` to:
   /Applications/XAMPP/xamppfiles/htdocs/halalsure-api/proxy.php
2) Start Apache in XAMPP.
3) Done. The app calls:
   http://localhost/halalsure-api/proxy.php?url=...

Option B — PHP built-in server:
1) In Terminal:
   cd /path/to/HalalSure/Server
   php -S localhost:8081
2) Change the URL in `HomeView.loadPopularFromWeb()` to:
   http://localhost:8081/proxy.php?url=...


## Changelog
- v0.1.1: App icon added
