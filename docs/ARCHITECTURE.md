# Architecture Notes

## Goal

This project demonstrates the foundation of a macOS communication client. The goal is not to implement real SIP signaling, but to show how a desktop client can be organized so that UI, state transitions, platform integration, and backend-facing services stay separated.

## UI Strategy

The main product UI is built with SwiftUI:

- `DashboardView`
- `ContactsSidebarView`
- `CallPanelView`
- `CallHistoryView`
- `PreferencesView`

SwiftUI is a good fit for the dashboard because the UI is state-driven and composed from reusable views.

AppKit is still used for macOS-specific behavior:

- `main.swift` creates and runs `NSApplication`
- `AppDelegate` owns `NSWindow` lifecycle
- `StatusBarController` owns `NSStatusItem` and `NSMenu`
- settings are shown in a separate AppKit-managed `NSWindow`

This split keeps the app modern while still showing practical macOS platform knowledge.

## State And Business Logic

Call behavior is modeled with a dedicated state machine:

```text
idle
ringing
dialing
connecting
active
held
ended
```

`CallStateMachine` validates transitions and keeps call rules outside the UI. This makes the behavior easier to test and easier to extend.

`ClientStatusStore` maps call state to client-level status for the menu bar:

```text
idle / ended       -> Available
ringing            -> Ringing
dialing/active/... -> In Call
```

## MVVM Structure

Each feature owns its view model:

- `ContactsViewModel`
- `CallPanelViewModel`
- `CallHistoryViewModel`
- `PreferencesViewModel`

View models expose observable state to SwiftUI and hide service calls or state-machine logic from the views.

`PreferencesViewModel` also owns lightweight local persistence with `UserDefaults`, so settings can be edited in SwiftUI and restored when the app opens the settings window again.

## Services

Services are protocol-based:

- `ContactServicing`
- `CallHistoryServicing`

Current implementations use mock data and short async delays to simulate backend behavior. This allows the UI and view models to use `async/await` without requiring a real server.

Later, the mock services could be replaced by:

- REST API clients
- WebSocket event streams
- SIP/VoIP signaling adapters
- shared Swift packages used by both iOS and macOS clients

## Data Flow

Typical contact loading flow:

```text
ContactsSidebarView
-> ContactsViewModel
-> ContactServicing
-> ContactService mock data
```

Typical demo call flow:

```text
CallPanelView
-> CallPanelViewModel
-> CallStateMachine
-> DashboardView callback
-> CallHistoryViewModel
-> CallHistoryView
```

Menu bar status flow:

```text
CallPanelViewModel.currentState
-> DashboardView.onChange
-> ClientStatusStore
-> AppDelegate Combine subscription
-> StatusBarController
-> NSStatusItem menu/title
```

## Testing

The test suite focuses on behavior that should remain stable during refactoring:

- valid outgoing and incoming call transitions
- invalid transition handling
- hold and resume behavior
- end and reset behavior
- async view model loading with mock services
- call history insertion order
- preference persistence and reset behavior

This is intentionally more valuable than snapshot-style UI tests for the current prototype stage.

## Future Improvements

Potential next steps:

- add real notification handling with `UNUserNotificationCenter`
- extract shared domain code into a Swift package
- add a mock WebSocket event stream for presence changes
- add integration tests around service adapters
- remove unused AppKit prototype view controllers after the SwiftUI migration is complete
