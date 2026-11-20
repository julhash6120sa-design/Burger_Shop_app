# Burger Shop Flutter App

A small offline-first order-taking app based on the supplied Excel menu.

## Included
- 18 menu rows copied from the spreadsheet, including repeated M1/M2/M3 codes across different categories.
- Bengali spelling, Arabic name, item code and Saudi Riyal (⃁) price fields.
- Category filters, tap-to-add menu cards, quantity controls and automatic total.
- Cash/Card are record-only payment choices (no POS terminal or payment integration).
- Receipt dialog and simple daily order/sales summary stored locally with SharedPreferences.

## Run
1. Install Flutter SDK and Android Studio.
2. Extract this ZIP.
3. In this folder run:
   `flutter pub get`
   `flutter run`

## Product photos
The menu cards currently use a food icon placeholder because the spreadsheet contains no product photos. Add each real photo under `assets/images/` and replace the placeholder widget in `lib/main.dart` with an `Image.asset(...)`. No item names or prices have been invented.

## Important
D2 has a blank Bengali spelling and Arabic name in the Excel file; it is displayed as D2 and priced at 2 ⃁ until you provide its names.
