# Student Planner

A Flutter-based student productivity application designed to help students organise their academic lives in one place.

## 📱 Project Overview

**Student Planner** is a cross-platform mobile application being developed using **Flutter and Dart**.

The application is designed to provide students with a centralised platform for managing academic schedules, tasks, assignments, notes, documents, reminders and, in future development, AI-powered study tools.

The project is being developed incrementally over a three-month development period, with a focus on usability, reliability, privacy, security and maintainable application architecture.

---

## 🎯 Project Goals

The main goals of Student Planner are to:

* Organise student timetables and schedules.
* Track academic tasks and assignments.
* Manage examination-related activities.
* Store and manage academic notes and documents.
* Provide reminders and notifications for important academic activities.
* Provide a simple and intuitive student-focused experience.
* Introduce AI-powered study assistance in a later development stage.
* Support personalised study planning and document-based learning tools in future releases.

---

## 🚧 Development Status

**Current stage:** Core student productivity features implemented — active development

The Flutter application has been successfully configured for Android development and several core features have now been implemented.

### ✅ Completed

#### Application Foundation

* Flutter development environment configured.
* Android development environment configured.
* Android emulator configured and tested.
* Flutter project created and structured.
* Application theme and visual foundation implemented.
* Main application entry point configured.
* Feature-oriented project architecture established.
* Git version control configured.
* GitHub repository created and maintained.

#### Navigation & Application Structure

* Main application navigation implemented.
* Bottom navigation using Flutter's `NavigationBar`.
* Separate screens for:

  * Home
  * Schedule
  * Tasks
  * Notes
  * Settings
* `IndexedStack` used to maintain navigation state between sections.
* Feature-based folder structure established to keep the application modular and maintainable.

#### Home Dashboard

* Student-focused home dashboard implemented.
* Dashboard displays relevant student productivity information.
* Task and notes information is integrated into the dashboard.
* Dashboard automatically refreshes information from local storage.
* The interface has been intentionally kept focused rather than overloaded with unnecessary information.

#### Tasks & Assignment Management

* Task management functionality implemented.
* Tasks can contain information such as:

  * Task title
  * Subject
  * Due date
  * Priority
  * Completion status
  * Reminder settings
* Task progress tracking implemented.
* Task completion status can be managed.
* Upcoming task information is displayed within the application.
* Task data is stored locally using `SharedPreferences`.

#### Notes & Document Management

* Notes functionality implemented.
* Document management functionality implemented.
* Users can select academic documents from their device.
* Supported document formats include:

  * PDF
  * DOC
  * DOCX
  * PPT
  * PPTX
  * XLS
  * XLSX
  * TXT
  * CSV
* Selected documents are stored within the application's local document storage.
* Document information such as name, subject, file type and size is managed by the application.
* File selection and storage functionality has been tested during development.

#### Notifications & Reminders

* Local notification system implemented.
* Notification service created as a reusable application service.
* Notification permissions are requested during application startup.
* Task reminders can be scheduled based on the task's due date.
* Supported reminder options include:

  * 15 minutes before
  * 30 minutes before
  * 1 hour before
  * 1 day before
* Timezone-aware notification scheduling implemented.
* Notification functionality has been integrated with task management.

#### Local Data Storage

The current version uses local storage for several application features.

Implemented storage includes:

* `SharedPreferences` for application data such as tasks and notes.
* Local application document storage for uploaded academic documents.
* JSON-based storage for schedule information.

This approach allows the current application to operate without requiring a cloud backend.

---

## 🛠️ Technology Stack

### Frontend / Mobile Development

* **Flutter**
* **Dart**

### Local Storage

* **SharedPreferences**
* Local application document storage
* JSON-based local data

### Notifications

* **Flutter Local Notifications**
* **Timezone**

### File Management

* **File Picker**
* **Path Provider**

### Development Environment

* **Android Studio**
* **Visual Studio Code**
* **Android Emulator**
* **Git**
* **GitHub**

### Planned Backend & Services

Future versions may introduce:

* Secure user authentication
* Cloud database
* Cloud storage
* Backend/Edge Functions
* AI services
* Push notifications
* Text-to-speech services

Specific services will be selected based on security, scalability, cost and project requirements.

---

## 📂 Project Structure

The project follows a feature-oriented Flutter architecture.

```text
student_planner/
│
├── android/
├── ios/
├── lib/
│   │
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── features/
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   │
│   │   ├── navigation/
│   │   │   └── main_navigation_screen.dart
│   │   │
│   │   ├── notifications/
│   │   │   └── notification_service.dart
│   │   │
│   │   ├── notes/
│   │   │   └── ...
│   │   │
│   │   ├── schedule/
│   │   │   └── ...
│   │   │
│   │   ├── tasks/
│   │   │   └── ...
│   │   │
│   │   └── assignments/
│   │       └── ...
│   │
│   ├── app.dart
│   └── main.dart
│
├── test/
├── web/
├── windows/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

The structure is designed so that new features can be added without placing the application's functionality into a single large collection of files.

---

## 🔔 Notifications & Reminder System

The notification system is implemented as a dedicated service:

```text
lib/
└── features/
    └── notifications/
        └── notification_service.dart
```

The service is responsible for:

* Initialising local notifications.
* Creating the notification channel.
* Requesting notification permissions.
* Displaying test notifications.
* Scheduling future notifications.
* Handling timezone-aware scheduling.

Task reminders connect the task due date with the notification service.

For example:

```text
Task
 ↓
Due Date
 ↓
Reminder Selection
 ↓
Notification Service
 ↓
Scheduled Local Notification
```

This allows reminders to be managed separately from the user interface.

---

## 💾 Local Data Architecture

At the current development stage, Student Planner does not require a cloud backend to manage its core functionality.

The application currently uses local persistence.

```text
Flutter Application
        │
        ├── SharedPreferences
        │      ├── Tasks
        │      └── Notes
        │
        ├── Local JSON Storage
        │      └── Schedule
        │
        └── Application Documents
               └── Academic Documents
```

This architecture allows the application to function locally while the backend and cloud architecture are developed at a later stage.

---

## 🔐 Security & Privacy

Security and privacy are considered during development rather than being treated as features that are only added before release.

Current and planned security principles include:

* No privileged API keys embedded directly inside the Flutter application.
* Sensitive credentials will be stored outside the client application.
* Authentication and authorisation will be implemented for protected resources.
* Database access will use appropriate security policies.
* Input validation will be applied where appropriate.
* Uploaded documents will be handled carefully.
* Development, staging and production environments will be separated.
* Production credentials will not be committed to GitHub.
* `.env` files and sensitive configuration will be excluded from version control.
* Privacy considerations will be incorporated into the application's architecture.
* A privacy policy will be provided before production release.

As the application progresses towards cloud and AI functionality, additional security controls will be introduced.

---

## 🧪 Testing & Quality Assurance

Testing is being performed throughout development rather than only at the final release stage.

Current development checks include:

* Running the application on an Android emulator.
* Testing navigation between application sections.
* Testing task creation and completion.
* Testing local data persistence.
* Testing document selection and storage.
* Testing notification permissions.
* Testing scheduled reminders.
* Debugging runtime issues during development.
* Flutter static analysis.

The project has also been checked using Flutter's analysis tooling during development.

Future testing will include:

* Unit testing
* Widget testing
* Integration testing
* Authentication testing
* Database security testing
* API testing
* Input validation testing
* UI and usability testing
* Performance testing
* Security testing

---

## 🌱 Development Approach

The application is being developed incrementally rather than attempting to build every feature simultaneously.

Each major feature follows a development cycle:

```text
Plan
 ↓
Design
 ↓
Implement
 ↓
Test
 ↓
Debug
 ↓
Review
 ↓
Git Commit
 ↓
Continue Development
```

This approach allows problems to be identified early and provides a clear development history throughout the project.

---

## 📅 Development Timeline

The project is being developed across approximately three months.

### Phase 1 — Foundation

**Status: Mostly completed**

* Project architecture
* Application theme
* Navigation
* Home dashboard
* Development environment
* Git/GitHub setup
* Initial application structure

### Phase 2 — Core Student Features

**Status: In progress / major features implemented**

* Schedule management
* Task management
* Assignment functionality
* Notes
* Document management
* Local storage
* Notifications
* Task reminders

### Phase 3 — AI & Finalisation

**Status: Planned**

* AI study assistant
* Personalised study-plan generation
* Lecture-note summarisation
* Document summarisation
* Document question answering
* AI-powered text-to-speech
* Additional testing
* Security review
* Backend/cloud integration
* Production deployment

---

## 🤖 Planned AI Features

AI functionality is **not yet implemented** in the current version.

The planned AI component is intended to eventually provide:

* Personalised study plans.
* Lecture-note summarisation.
* Document summarisation.
* Questions and answers based on uploaded academic documents.
* AI-assisted study recommendations.
* Text-to-speech conversion of notes.
* Personalised academic assistance.

AI features will be introduced only after the core application functionality and supporting architecture are sufficiently stable.

---

## 🚀 Future Development

Future development is expected to include:

### Backend

* User authentication.
* Secure API.
* Cloud database integration.
* User account management.
* Cloud synchronisation.

### Student Features

* Improved assignment management.
* Examination management.
* Calendar integration.
* Additional reminder options.
* Improved document organisation.
* Cross-device synchronisation.

### AI

* AI study assistant.
* Personalised study plans.
* Document summarisation.
* Document question answering.
* AI text-to-speech.

### Production

* Expanded testing.
* Security review.
* Performance optimisation.
* Staging environment.
* Production deployment.
* Privacy policy.
* Application release preparation.

---

## 🌐 Deployment Strategy

The application is intended to progress through separate development stages:

```text
Development
     ↓
Testing
     ↓
Staging
     ↓
Production
```

Development features are tested locally before being considered for staging or production.

The staging environment will remain separate from production and will not be treated as a live production service until the required security and testing processes have been completed.

---

## 📌 Current Project Status

**Student Planner is currently under active development.**

The project has progressed from its initial Flutter setup into a functional student productivity application with implemented:

* Application navigation
* Home dashboard
* Schedule functionality
* Task management
* Assignment-related functionality
* Notes
* Document management
* Local data persistence
* Local notifications
* Configurable task reminders

The backend, cloud synchronisation, authentication and AI functionality remain part of the future development roadmap.

---

## 👨‍💻 Developer

**Kaleb Yirdaw**

Computer Science & Application Development Student

Built with **Flutter and Dart**.
