# STARFACE macOS Client Demo

Native macOS communication-client prototype built with Swift, SwiftUI, and selected AppKit integration.

This demo is not a production VoIP client. It is a focused interview project that shows how a macOS softphone-style client could be structured: contacts, call state handling, call history, settings, menu bar integration, async mock services, and testable business logic.

## Features

- SwiftUI dashboard with contacts, call controls, and call history
- AppKit application bootstrap and explicit `NSWindow` lifecycle
- AppKit menu bar integration with `NSStatusItem`
- Settings window hosted in a separate AppKit-managed window
- Preferences are persisted with `UserDefaults`
- Contact search across name, department, phone number, and presence state
- Simulated backend presence updates with `AsyncStream`
- Simulated incoming calls with local macOS notifications
- Simulated call states: idle, ringing, dialing, connecting, active, held, ended
- Completed demo calls are inserted into call history
- Protocol-based async mock services for contacts and call history
- Unit tests for the call state machine and view models

## Technology

- Swift
- SwiftUI
- AppKit / Cocoa
- Combine
- Swift Concurrency
- AsyncStream-based event updates
- UserNotifications integration
- UserDefaults persistence
- STARFACE brand accent color `#F59C00`
- MVVM-style feature structure
- Protocol-based dependency injection
- Swift Testing

## Project Structure

```text
StarfaceMacClientDemo
├── App
│   ├── AppDelegate.swift
│   ├── main.swift
│   └── StatusBarController.swift
├── Core
│   ├── Models
│   ├── Services
│   └── StateMachine
├── Features
│   ├── CallHistory
│   ├── Calls
│   ├── Contacts
│   ├── Dashboard
│   └── preferences
└── StarfaceMacClientDemoTests
```

## Running

Open `StarfaceMacClientDemo.xcodeproj` in Xcode and run the `StarfaceMacClientDemo` scheme on macOS.

The app starts with a main desktop window and a menu bar status item. Use the contact list to select a person, start a demo call, hang up, and inspect the generated call history entry.

## Testing

The project includes Swift Testing coverage for:

- valid and invalid call state transitions
- hold and resume behavior
- async contact loading through a mock service
- async call history loading through a mock service
- applying simulated presence updates to matching contacts
- simulated incoming call, answer, and missed-call behavior
- inserting completed calls into call history
- saving and restoring preferences

Run tests from Xcode with `Product > Test`.

## Design Notes

The UI is SwiftUI-first, while AppKit is used where macOS-specific behavior matters:

- application bootstrap
- window lifecycle
- menu bar status item
- separate settings window

This mirrors a practical migration-friendly approach for macOS applications: product UI can be modern SwiftUI, while mature AppKit APIs remain useful for platform integration.

More details are available in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
