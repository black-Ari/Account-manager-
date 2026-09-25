# AccountMate

All-in-one accounting app — 100% free, fully offline (no paid APIs, no cloud server).

## Modules
1. **Tax Calculator** — GST (add/remove, CGST/SGST/IGST split), TDS (common sections), Income Tax (new regime slabs)
2. **Expense Tracker** — Add/view/delete income & expense transactions, stored locally
3. **Bookkeeping** — Auto-generated ledger summary + category-wise breakdown
4. **Compliance Reminders** — GST/TDS/ITR/MCA deadline tracker with due-date coloring

## Tech Stack (all free & open-source)
- Flutter (UI framework)
- sqflite (local SQLite database — no cloud, no cost)
- intl (date formatting)

## How to Run

You need Flutter SDK installed on your own computer (this was built in a sandbox without Flutter installed, so it hasn't been compiled/tested here — please build and test it yourself).

```bash
# 1. Install Flutter: https://docs.flutter.dev/get-started/install

# 2. Get dependencies
flutter pub get

# 3. Run on connected device/emulator
flutter run

# 4. Build a release APK (free to distribute directly)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Notes / Next Steps
- TDS section list and Income Tax slabs are illustrative — update them in
  `lib/screens/tax_calculator_screen.dart` to match the latest Finance Act/Budget before real use.
- To publish on Play Store, a one-time $25 Google Play Developer fee applies (optional —
  you can distribute the APK directly for free without this).
- Invoice PDF generation (GST-compliant invoices) module can be added next using the
  free `pdf` and `printing` Flutter packages.
- Local push notifications for reminders can be added using `flutter_local_notifications` (free).
