# Student Planner

A Flutter-based student productivity and AI study assistant application designed to help students organise their academic lives in one place.

## 📱 Project Overview

Student Planner is being developed as a cross-platform application using **Flutter**. The goal is to provide students with a centralised platform for managing academic schedules, assignments, examinations, notes, documents, reminders, and AI-powered study tools.

The application is being developed gradually over a three-month development period, with a strong focus on usability, reliability, privacy, and security.

## 🎯 Project Goals

The main goals of Student Planner are to:

* Organise student timetables and schedules.
* Track assignments and examinations.
* Store and manage academic notes and documents.
* Provide intelligent reminders for important academic activities.
* Generate personalised AI study plans.
* Summarise lecture notes and uploaded documents.
* Allow students to ask questions about their uploaded documents.
* Convert written notes into audio using AI-powered text-to-speech.
* Provide a simple and intuitive student-focused experience.

## 🚧 Development Status

**Current stage:** Initial application setup

The Flutter project has been created and successfully configured for Android development.

### Completed

* Flutter development environment configured.
* Android emulator configured.
* Flutter project created.
* Initial application architecture established.
* Initial application theme created.
* Home screen structure created.
* Navigation structure created.
* Git version control configured.
* Initial GitHub repository created.
* Initial project commit completed.

### In Development

* Application UI and design system.
* User authentication.
* Student profile management.
* Timetable and schedule management.
* Assignment tracking.
* Examination tracking.
* Reminders and notifications.
* Notes and document management.
* Secure cloud database integration.
* AI study assistant.
* AI study-plan generation.
* Document summarisation.
* Document question answering.
* AI text-to-speech functionality.
* Testing and quality assurance.
* Production deployment.

## 🛠️ Technology Stack

### Frontend

* **Flutter**
* **Dart**

### Development Environment

* **Visual Studio Code**
* **Android Studio**
* **Android Emulator**
* **Git**
* **GitHub**

### Planned Backend & Services

The backend architecture will be introduced progressively during development.

Planned technologies and services may include:

* Secure authentication
* Cloud database
* Cloud storage
* Backend/Edge Functions
* AI services
* Push notifications
* Text-to-speech services

Specific services will be selected and configured based on security, scalability, cost, and project requirements.

## 🔐 Security & Privacy

Security and privacy are core requirements of the project rather than features that will be added at the end of development.

The application will be developed with the following principles:

* No privileged API keys embedded directly in the Flutter application.
* Sensitive credentials stored securely outside the client application.
* Authentication and authorisation checks for protected resources.
* Database access protected using appropriate security policies.
* Rate limiting for sensitive and resource-intensive operations.
* Input validation on client and server sides where appropriate.
* Secure handling of uploaded documents.
* Separation between development, staging, and production environments.
* No production credentials committed to GitHub.
* Environment variables and secret configuration excluded from version control.
* Privacy considerations incorporated into the application architecture.
* A privacy policy will be provided before production release.

## 🌱 Development Approach

The application is being developed incrementally rather than attempting to build every feature simultaneously.

Each major feature will be:

1. Planned.
2. Designed.
3. Implemented.
4. Tested.
5. Reviewed for security and reliability.
6. Committed to Git.
7. Documented where necessary.

This approach allows problems to be identified early and provides a clear development history throughout the project.

## 📂 Project Structure

The project currently follows a feature-oriented Flutter structure:

```text
student_planner/
│
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── features/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   │
│   │   └── navigation/
│   │       └── main_navigation_screen.dart
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

The structure will evolve as additional features are introduced.

## 🧪 Testing

Testing will be performed throughout development rather than only before release.

Planned testing includes:

* Unit testing
* Widget testing
* Integration testing
* Authentication testing
* Database security testing
* API and rate-limit testing
* Input validation testing
* UI and usability testing
* Performance testing
* Security testing

## 🚀 Future Deployment

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

The staging environment will remain separate from production and will not be treated as a live production service until it has been properly secured and tested.

## 📅 Development Timeline

The project is planned across approximately three months.

### Phase 1 — Foundation

* Project architecture
* UI foundation
* Navigation
* Authentication
* Database architecture
* Security foundations

### Phase 2 — Core Student Features

* Timetable
* Assignments
* Exams
* Reminders
* Notes
* Document management

### Phase 3 — AI & Finalisation

* AI study assistant
* Study-plan generation
* Document summarisation
* Document question answering
* Text-to-speech
* Testing
* Security review
* Deployment preparation

## 📌 Project Status

This project is currently under active development.

Features and technologies described as planned may change as development progresses and requirements are evaluated.

---

**Student Planner**
Built with Flutter and Dart.
