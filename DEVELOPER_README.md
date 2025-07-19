# EverySo Technical Overview

This document provides a technical introduction to the EverySo application. It is intended for developers who want to understand how the project is organized and how the main pieces fit together before diving into the codebase.

## Purpose

EverySo helps users track recurring tasks using customizable countdown timers. Each entry records when a task was last completed and reminds the user when it is ready again. Notifications are used to alert the user when a timer completes.

## Architecture at a Glance

The application is written entirely in **Swift** using **SwiftUI** for the UI layer and **SwiftData** for persistence. Below is a high-level view of the core components:

- **EverySoApp** (`EverySoApp.swift`)
  - Entry point of the app. Injects a `NotificationPermissionViewModel` and displays `PermissionPromptView` on launch.
- **ContentView** (`ContentView.swift`)
  - Main screen showing a list of `CountdownEntry` items.
  - Uses `@Query` to fetch entries from SwiftData and a custom `Clock` object to update progress every second.
  - Allows adding entries, editing existing ones, and toggling light/dark mode.
- **CountdownEntry** (`CountdownEntry.swift`)
  - `@Model` object managed by SwiftData. Stores title, description, interval components, and notification preferences.
  - Provides convenience methods for time calculations and scheduling local notifications when a timer completes.
- **AddEntryView** (`AddEntryView.swift`)
  - Form used for creating or editing a `CountdownEntry`.
  - Validates input and optionally resets the timer when saved.
- **CountdownRowView** (`CountdownRowView.swift`)
  - View representing a single countdown in the list with progress, time remaining, and reset/edit actions.
- **NotificationPermissionViewModel** (`NotificationPermissionViewModel.swift`)
  - Manages requesting notification permission and tracks whether the permission prompt should be shown.
- **SidebarContainerView** (`SidebarContainerView.swift`)
  - Wrapper view that displays a simple slide-in sidebar menu.
- **Clock** (`Clock.swift`)
  - Publishes the current `Date` every second for real-time countdown updates.

The Xcode project also includes basic unit test and UI test targets under `EverySoTests` and `EverySoUITests`.

## Data Persistence

`CountdownEntry` objects are stored using SwiftData's model container. `ContentView` uses `@Query` to fetch entries and automatically updates the UI when the data changes. Data is saved in the app's local database on device.

## Notifications

Local notifications are scheduled through `UNUserNotificationCenter` whenever a countdown is created or reset. The `NotificationPermissionViewModel` checks and requests authorization on launch. `CountdownEntry` contains `scheduleNotification()` and `resetCountdown()` helpers to manage these notifications.

## Building and Running

1. Open `EverySo.xcodeproj` in Xcode (tested with Xcode 16 or later).
2. Build and run on iOS 17 or later. The project uses Swift 5 and the SwiftData framework which requires a modern SDK.
3. On first launch, the app will prompt for notification permission.

## Key Points for New Developers

- The entire UI is implemented in SwiftUI; there are no storyboards or XIBs.
- Persistence relies on SwiftData (`@Model`, `modelContainer`, and `@Query`). Familiarity with these APIs will help when modifying data-related code.
- Notifications are optional per entry (`notifyOnReady`) and scheduled immediately after creating or resetting a countdown.
- The project uses a simple MVVM-style separation where views are lightweight and most logic resides in models or small view models like `NotificationPermissionViewModel`.
- Unit tests and UI tests are provided as placeholders. Expanding them will improve reliability as the app grows.

## Repository Structure

```
EverySo/              # SwiftUI source files and assets
EverySo.xcodeproj/    # Xcode project configuration
EverySoTests/         # Unit tests
EverySoUITests/       # UI tests
```

This overview should give you enough context to start exploring the codebase. Happy coding!
