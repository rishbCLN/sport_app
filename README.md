# VIT Sports App

A Flutter-based college sports team formation app for VIT (Vellore Institute of Technology). Players can easily find teammates for their favorite sports through an intuitive interface.

## Features

- **Bottom Navigation** - Easy access to 5 sports categories: Football, Badminton, Cricket, plus Tournaments and Profile
- **Team Matching** - Find and join other players looking for teammates
- **Active Games** - View currently active games and waiting teams
- **Material 3 Design** - Modern UI with support for light and dark modes
- **Real-time Updates** - Powered by Firebase Firestore
- **User Authentication** - Secure login with Firebase Auth
- **Team Formation** - Create team requests and manage player recruitment

## Project Structure

```
lib/
├── main.dart           # App entry point with Firebase initialization
├── config/
│   └── theme.dart      # Material 3 theme configuration
├── screens/
│   ├── home_screen.dart           # Bottom navigation controller
│   ├── football_screen.dart       # Football team formation screen (fully implemented)
│   ├── badminton_screen.dart      # Badminton placeholder
│   ├── cricket_screen.dart        # Cricket placeholder
│   ├── tournaments_screen.dart    # Tournaments placeholder
│   └── profile_screen.dart        # Profile placeholder
├── models/
│   ├── team_request.dart    # Team request data model
│   └── user_profile.dart    # User profile data model
├── services/
│   └── (auth_service.dart, firestore_service.dart - to be implemented)
├── widgets/
│   └── (reusable components - to be added)
└── utils/
    └── (constants, helpers - to be added)
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vit_sports_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
   This generates `firebase_options.dart` which is already imported in `main.dart`.

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

- **firebase_core** (^2.24.0) - Firebase core functionality
- **firebase_auth** (^4.14.0) - User authentication
- **cloud_firestore** (^4.13.0) - Cloud database
- **provider** (^6.1.0) - State management
- **go_router** (^12.0.0) - Advanced routing (ready for implementation)
- **google_fonts** (^6.1.0) - Custom fonts
- **intl** (^0.19.0) - Date/time formatting
- **cupertino_icons** (^1.0.6) - iOS-style icons

## Architecture

### Design Patterns
- **Material Design 3** - Modern material design system
- **Provider Pattern** - State management (configured, ready to use)
- **Repository Pattern** - Service layer for data operations
- **Model Classes** - Strongly typed data models with JSON serialization

### Key Features

#### HomeScreen
Controls bottom navigation between 5 destinations, maintaining state across navigation.

#### FootballScreen
- **Active Games Section** - Shows live matches with duration and waiting teams
- **Team Requests Section** - Browse team requests looking for players
- **Create Team Request** - FAB opens bottom sheet to create new team requests
- **UI Components**:
  - Team request cards with progress indicators
  - Player avatars stacked visualization
  - Ground and player count information
  - Join button with status checking

#### Data Models
- **TeamRequest** - Complete team request data with JSON serialization
- **UserProfile** - User information with preferences

## UI/UX Features

- **Dark Mode Support** - Automatic light/dark theme based on system preference
- **Material 3 Components** - NavigationBar, Cards, FloatingActionButton with Material 3 styling
- **Responsive Design** - Adapts to different screen sizes
- **Loading States** - Refresh indicator and loading spinners
- **Empty States** - Friendly messages when no data available
- **Smooth Animations** - Material transitions and custom animations

## Next Steps (To-Do)

- [ ] Implement Firebase Authentication service
- [ ] Implement Firestore CRUD operations
- [ ] Add state management with Provider
- [ ] Implement Go Router for advanced navigation
- [ ] Add profile editing functionality
- [ ] Implement team request joining logic
- [ ] Add user profile uploads
- [ ] Implement notifications for team requests
- [ ] Add mapping/location services for grounds
- [ ] Implement team chat functionality

## Firebase Setup

Make sure you have:
1. Created a Firebase project
2. Enabled Firebase Authentication (Email/Password)
3. Created a Firestore database
4. Run `flutterfire configure` to set up the project
5. Updated security rules in Firebase Console

### Sample Firestore Collections

```
/users/{userId}
  - name: String
  - email: String
  - registrationNumber: String
  - preferredSports: List<String>
  - profileImageUrl: String
  - createdAt: Timestamp

/teamRequests/{requestId}
  - sport: String
  - groundNumber: int
  - playersNeeded: int
  - currentPlayers: int
  - playerIds: List<String>
  - creatorId: String
  - createdAt: Timestamp
  - status: String
```

## Code Style

- Uses const constructors where possible
- Null-safe code throughout
- Clear widget naming conventions
- Comments for complex sections
- Proper separation of concerns

## License

This project is part of VIT's initiative to build community sports engagement.

## Support

For issues or feature requests, please create an issue in the repository.

---

**Last Updated:** February 2026
**Version:** 1.0.0
