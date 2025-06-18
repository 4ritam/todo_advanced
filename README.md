# ToDoList App

A Flutter-based ToDoList application built with the MVC pattern and GetX for state management, featuring local persistence, cross-platform notifications, and a clean modal-driven UI.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture & Patterns](#architecture--patterns)
3. [Key Libraries](#key-libraries)
4. [Thought Process](#thought-process)
5. [Features](#features)
6. [Getting Started](#getting-started)
7. [Folder Structure](#folder-structure)
8. [Future Improvements](#future-improvements)

---

## Overview

The ToDoList App allows users to create, manage, and prioritize tasks. It supports reminders (with optional date/time), local data persistence, and clear separation of concerns for maintainability.

---

## Architecture & Patterns

- **MVC Pattern**: Models (`Task`), Views (Flutter widgets), Controllers (`TaskController`).
- **GetX**: State management, dependency injection, routing, snackbars, and bottom sheets.
- **Clean Separation**: Services for storage (`StorageService`), notifications (`NotificationService`).

---

## Key Libraries

- **get**: Routing, state management, UI utilities
- **shared_preferences**: Local JSON persistence
- **flutter_local_notifications**: Cross-platform notifications
- **fpdart**: Functional error handling with `Either`
- **intl**: Date formatting
- **uuid**: Unique ID generation (if needed)

---

## Thought Process

1. **Model Design**: Started with a simple `Task` model, then expanded to include:
   - `hasReminder` (bool) — whether a reminder should be scheduled
   - `reminderDateTime` (DateTime?) — when the local notification should fire
2. **Persistence**: Used `shared_preferences` with JSON serialization. Wrapped read/write in `Either` for robust error handling.
3. **State Management**: Chose GetX for minimal boilerplate, reactive lists (`RxList<Task>`), and easy access to snackbars & bottom sheets.
4. **Notifications**: Centralized in `NotificationService`, supported Android & iOS initialization, and scheduled/canceled reminders based on task state.
5. **UI Flow**:
   - **HomeView**: Two lists (incomplete, completed), search filter, modal bottom sheet for details and form.
   - **TaskFormModal**: Stateful widget for add/edit, date-only due date, optional reminder toggle + date/time picker.
   - **TaskDetailModal**: Displays task details, actions to mark done/undo, edit, delete.
6. **Sorting Logic**: For incomplete tasks, sort by date (calendar day only), then by priority descending when dates match.

---

## Features

- Create, edit, delete tasks
- Mark tasks complete/incomplete
- Priority levels: High, Medium, Low
- Due date (date-only)
- Optional reminders with custom date & time
- Local notifications (Android & iOS)
- Persistent data across app restarts
- Search and filter tasks by keyword
- Automatic sorting for incomplete tasks
- Modular, maintainable codebase

## Folder Structure

```
/lib
  /controllers      # GetX controllers (business logic)
  /models           # Data models (Task)
  /services         # Storage & Notification services
  /views
    home_view.dart
    task_detail_modal.dart
    task_form_modal.dart
  main.dart         # App entry & routing
```

---

## Future Improvements

- Dark mode / theming support
- Task categories or tags
- Recurring tasks
- Export/Import JSON backup
- Integration tests for UI flows
- Overdue task highlighting and notifications

_Quantum IT Innovation Flutter Assignment_
