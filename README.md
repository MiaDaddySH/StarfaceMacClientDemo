# STARFACE macOS Client Demo

Native macOS communication-client prototype built with Swift, SwiftUI, and selected AppKit integration.

This demo is not a production VoIP client. It is a focused interview project that shows how a macOS softphone-style client could be structured: contacts, call state handling, call history, settings, menu bar integration, async mock services, and testable business logic.

## Features

- SwiftUI dashboard with contacts, call controls, and call history
- AppKit application bootstrap and explicit `NSWindow` lifecycle
- AppKit main menu commands for window and settings actions
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

## Interview Discussion Points

This project is intentionally SwiftUI-first for product screens, while AppKit is used for macOS-specific integration. The dashboard, contacts, call controls, call history, and settings form are SwiftUI views. AppKit remains responsible for `NSApplication` setup, `NSWindow` lifecycle, the main menu, the menu bar item, and foreground notification presentation.

The feature code follows a lightweight MVVM structure. Views render observable state, while view models coordinate services, call-state transitions, and user actions. This keeps UI code small and makes behavior easier to test.

Backend-facing behavior is represented by protocols such as `ContactServicing`, `CallHistoryServicing`, `PresenceServicing`, and `NotificationServicing`. The current implementations use mock data, async delays, `AsyncStream`, and local notifications. In a production client, these protocols could be backed by REST APIs, WebSocket event streams, SIP/VoIP adapters, or shared Swift packages used by both iOS and macOS.

Call behavior is modeled with `CallStateMachine` instead of being scattered through button handlers. This makes states such as idle, ringing, dialing, connecting, active, held, and ended explicit, and it gives the test suite a stable place to verify valid and invalid transitions.

The demo also includes a small refactoring story: early AppKit prototype view controllers were removed once the SwiftUI dashboard became the primary UI. AppKit is still present, but only where it adds platform value.

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
