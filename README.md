# SecurePass – Encrypted On-Device Pass & Key Manager

A minimal, Apple Wallet–style SwiftUI experience for storing event passes, loyalty cards, transit tickets, and digital keys entirely on-device.

## Features
- 🔐 **AES-encrypted vault**: Pass payloads are serialized to JSON, wrapped with AES-GCM, and persisted in the Keychain with a hardware-bound key.
- 🛡️ **Biometric guardrails**: Face ID / Touch ID required to unlock the vault, with optional per-pass Face ID for keys or sensitive items.
- 📷 **Vision-powered import**: Live QR/Barcode + text scanning via `VisionKit.DataScannerViewController` for quick pass ingestion.
- 🎟️ **Wallet-like UI**: Stacked, animated cards with previews, gestures, and pass details.
- 📴 **Local-only**: Zero networking; every operation happens on-device for maximum privacy.

## Running
Open `SecurePass.xcodeproj` in Xcode 15+ and run on a Face ID/Touch ID–capable device (Vision scanning requires iOS 17+).
