# SaccoSecure Alarm Monitoring App

## Overview

This project is a Flutter application designed for offline-first alarm monitoring with a focus on security and reporting. It features multi-user authentication with optional biometrics, SQLite database for local data storage, SMS parsing for receiving alarm events, scheduled daily summaries, and PDF report generation.

## Design and Features

- **Offline-first:** Utilizes a local SQLite database for storing logs and user data, ensuring functionality even without internet connectivity.
- **Multi-user Authentication:** Supports multiple users with different roles (admin, operator) stored securely with hashed passwords.
- **Optional Biometrics:** Allows for quick and secure login using biometric authentication (fingerprint).
- **SMS Parsing:** Processes incoming SMS messages to extract alarm events and classify them based on predefined rules.
- **Daily Summary:** Schedules a daily notification at 07:30 to provide a summary of trouble events from the previous day.
- **PDF Reports:** Generates PDF reports for specific branches and time periods, listing relevant log entries.
- **Theming:** Includes support for light and dark themes.
- **UI Components:** Uses standard Material Design widgets and includes a custom `AlertBanner` widget.

## Plan for current request

The current request is to build the complete SaccoSecure application based on the provided flow. The plan is as follows:

1. Create the specified folder structure.
2. Update `pubspec.yaml` with the required dependencies.
3. Add necessary Android permissions to `AndroidManifest.xml`.
4. Create and populate all the Dart files for core app, data models, database helpers, data access objects, business rules, services (auth, sms parsing, notifications, scheduler, pdf), UI widgets, and UI screens.
5. Run `flutter pub get`.
6. Provide instructions on how to build and run the app.