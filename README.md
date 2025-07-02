# NFC Card Clone

A Flutter application that allows users to read and clone NFC cards.

## Features

- Biometric authentication for app security
- Read NFC card data
- Clone NFC card data to a target card
- Demo mode for testing on devices without NFC

## Requirements

- Flutter SDK
- Android device with NFC support (Android 5.0 or higher)
- iOS device with NFC support (iPhone 7 or newer, iOS 13 or higher)

## Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure your device has NFC enabled
4. Run the app using `flutter run`

## Usage

1. Launch the app
2. If available, authenticate using biometrics (fingerprint or Face ID)
3. Place an NFC card near your device to read its data
4. After reading, you can clone the data to another card by pressing "CLONE CARD"
5. Place the target card near your device when prompted

## Web Support

Note that NFC functionality is not available in web browsers. When running in a web browser, the app will show a demo mode that simulates NFC card reading.

## Android Permissions

The app requires the following permissions on Android:
- NFC
- Biometric Authentication

## iOS Permissions

The app requires the following permissions on iOS:
- NFC
- Face ID/Touch ID

## Known Issues

- The cloning feature is intended for educational purposes only and may not work with all NFC card types
- Some cards have security features that prevent cloning
- NFC functionality is not available on web browsers or desktop platforms

## License

This project is licensed under the MIT License.
