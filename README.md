# Orienteering Game (iOS) – README

A scavenger-hunt style iOS game built with SwiftUI that uses GPS to guide players through real-world locations, perform check-ins, and track progress.

This document provides an overview of the iOS project, its architecture, setup instructions, and current capabilities.

## Tech stack
- Swift
- SwiftUI
- MapKit
- Core Location
- MVVM architecture with ObservableObject-based ViewModels
- MockDataService (no real backend yet)

## Requirements
- iOS 16+ / macOS with Xcode 15+ for development and building
- Xcode 15 or newer
- A device or simulator with location services enabled for GPS-based gameplay

## Getting started

- Open the iOS project in Xcode:
  - Navigate to ios/ in the repository and open the .xcodeproj file.
- Build and run on a simulator or a real device (Location services must be allowed).
- On first launch, grant Location Permissions when prompted.

## Architecture overview
- The app follows the MVVM pattern:
  - Views: SwiftUI views that render UI and bind to ViewModels.
  - ViewModels: ObservableObject classes that expose @Published properties and handle business logic.
  - Models: Plain Swift structures/models representing the domain (Hunt, CheckIn, Waypoint, UserProgress, etc.).
  - Services: Abstractions for data retrieval and location-related operations. MockDataService currently provides sample data.
- Data flow:
  - Views observe their corresponding ViewModels.
  - ViewModels interact with Services to fetch data and perform actions (e.g., check-ins, progress updates).
  - UI updates automatically via Combine publishers.

## Project structure
- Views/            – SwiftUI view files, screens, and components
- ViewModels/       – ObservableObject-based view models for each screen
- Models/           – Domain models (Hunt, CheckIn, Waypoint, Progress, etc.)
- Services/         – Protocols and concrete implementations (e.g., MockDataService)
- Resources/        – Assets, localized strings, and other resources
- Helpers/          – Utilities and extensions used across the app
- Tests/            – (Optional) unit and UI tests (if present in the project)

> Note: The project currently uses MockDataService and does not have a live backend integration yet.

## Features
- Hunt selection: Choose a scavenger hunt to participate in and view related waypoints.
- GPS tracking: Location updates via Core Location to guide players through the hunt.
- Check-ins: Mark visits at specific waypoints to progress through the hunt.
- Progress tracking: Real-time updates of completed checkpoints and overall progress percentage.

## Screenshots
- Placeholder for screenshots:
- [Insert screenshots of Map view, Hunt selection, and Check-in screens here]

## Future improvements
- API integration: Replace MockDataService with a real backend API for hunts, checkpoints, and user progress.
- Authentication: User accounts, sessions, and personalized progress tracking.
- Real-time multiplayer or cooperative hunts (optional).
- Additional game modes, hints, and treasure rewards.
- Expanded analytics and telemetry to understand user engagement.

## Notes and assumptions
- Location permissions are configured in the app and are required for GPS-based gameplay.
- Currently uses MockDataService for data; no real backend integration is implemented yet.
- Architecture is MVVM with ObservableObject-based ViewModels to ensure a clean separation of concerns.
