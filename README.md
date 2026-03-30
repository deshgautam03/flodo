# Flodo - Task Management App

## Overview
Flodo is a premium, high-performance task management application designed with a "Digital Obsidian" aesthetic. It empowers users to organize their daily focus with a streamlined interface, supporting complex task dependencies and real-time status tracking.

## Track
Track B: Mobile Specialist

## Stretch Goal
**Debounced Autocomplete Search** — As the user types in the search bar, the list filters after a 300ms debounce delay to optimize performance. Matching text in task titles is dynamically highlighted in yellow/bold using a custom high-performance text rendering widget.

## Prerequisites
- **Flutter SDK**: ^3.27.0
- **Dart SDK**: ^3.11.0
- **Android Studio** or **VS Code**
- An Android/iOS emulator or physical device

## Setup Instructions
1. **Clone the repository**:
   ```bash
   git clone https://github.com/deshgautam03/flodo.git
   ```
2. **Navigate to project folder**:
   ```bash
   cd flodo
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Generate database code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. **Run the app**:
   ```bash
   flutter run
   ```

## Features
- **Full CRUD operations**: Create, Read, Update, and Delete tasks with ease.
- **Comprehensive Task Metadata**: Support for Title, Description, Due Date, Status (To-Do, In Progress, Done), and Blocked By dependencies.
- **Reactive Blocked Task UI**: Blocked tasks are visually distinguished with a grey overlay, a muted status badge, and an amber lock icon. Interaction is disabled until the blocking task is completed.
- **Draft Persistence**: Form data is automatically cached, ensuring that unsaved drafts are restored even if the app process is interrupted.
- **Simulated Network Latency**: Implements a 2-second simulated delay on Create/Update operations with a global loading state to demonstrate production-ready UI feedback.
- **Advanced Search**: 300ms debounced search bar with real-time text highlighting for immediate visual feedback.
- **Smart Filtering**: Quick-access horizontal chips to filter by "All", "To-Do", "In Progress", or "Done" status.
- **Offline First**: All data persists across app restarts using the high-performance **Isar** local database.

## AI Usage Report
### Tools Used
- **Google Antigravity**: Primary agent used for architecture design, complex logic implementation (like reactive dependencies), and automated code refactoring.
- **Google Stitch**: Used to generate and refine the initial UI/UX designs, ensuring a premium "Digital Obsidian" look across all components.
- **Claude AI (claude.ai)**: Used for high-level prompt engineering, crafting technical documentation, and providing strategic debugging guidance.

### Most Helpful Prompts
- "The initial architecture prompt that generated the entire project structure, state management, and database layer in one shot."
- "The blocked task UI fix prompt that implemented the grey overlay and lock icon logic, ensuring the UI reactively responds to database changes."

### AI Hallucination / Bad Code Example
- **Redundant Screens**: Antigravity initially generated "Calendar" and "Profile" screens that were outside the assignment scope, requiring manual intervention to prune the navigation.
- **Keyboard Overflow**: The initial form layout did not account for fixed heights, leading to a "BOTTOM OVERFLOWED BY 272 PIXELS" error when the keyboard appeared. This was resolved by implementing a `SingleChildScrollView` with `resizeToAvoidBottomInset: true`.

## Technical Decisions
- **Isar Database**: Chosen for its blazing-fast performance and type-safe Dart API, making it the superior choice for modern Flutter applications.
- **Riverpod State Management**: Provides a predictable, testable, and highly reactive state layer that separates business logic from UI concerns.
- **Asynchronous Search**: Implemented using `dart:async`'s `Timer` class to debounce character input, significantly reducing unnecessary database queries and UI rebuilds during active typing.
