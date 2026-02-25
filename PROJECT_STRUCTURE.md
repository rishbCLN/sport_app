# VIT Sports App - Project Structure

## Complete File Structure

```
vit_sports_app/
├── lib/
│   ├── main.dart                          # App entry point with Firebase initialization
│   │
│   ├── config/
│   │   └── theme.dart                     # Material 3 theme configuration (light & dark)
│   │
│   ├── screens/
│   │   ├── home_screen.dart               # Bottom navigation controller (5 tabs)
│   │   ├── football_screen.dart           # ⭐ Main feature - Team formation with polished UI
│   │   ├── badminton_screen.dart          # Placeholder - Coming Soon
│   │   ├── cricket_screen.dart            # Placeholder - Coming Soon
│   │   ├── tournaments_screen.dart        # Placeholder - Coming Soon
│   │   └── profile_screen.dart            # Placeholder - Coming Soon
│   │
│   ├── models/
│   │   ├── team_request.dart              # Team request data model with JSON serialization
│   │   └── user_profile.dart              # User profile data model with JSON serialization
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Firebase Auth service (stub)
│   │   └── firestore_service.dart         # Firestore CRUD operations (stub)
│   │
│   ├── widgets/
│   │   └── README.md                      # Guide for reusable widgets
│   │
│   └── utils/
│       └── constants.dart                 # App constants and configuration
│
├── pubspec.yaml                           # Project dependencies (complete)
├── analysis_options.yaml                  # Linting rules
├── README.md                              # Project documentation
├── .gitignore                             # Git ignore rules (Flutter standard)
└── PROJECT_STRUCTURE.md                   # This file
```

## Architecture Overview

### Layer Organization

```
Presentation (UI)
    ↓
Screens & Widgets
    ↓
State Management (Provider - configured)
    ↓
Service Layer (Firebase)
    ↓
Data Models (Firestore Documents)
```

### Key Components

#### 1. **main.dart**
- Firebase initialization point
- Material 3 theme setup
- Provider configuration
- MaterialApp setup with light/dark mode support

#### 2. **config/theme.dart**
- Light theme with Material 3 colors
- Dark theme with Material 3 colors
- Centralized styling for:
  - AppBar
  - Cards
  - FloatingActionButton
  - NavigationBar
  - Text styles

#### 3. **screens/home_screen.dart**
```
HomeScreen (StatefulWidget)
├─ _selectedIndex (int)
├─ _screens (List<Widget>) - 5 screens
├─ _onNavigationItemSelected()
├─ Scaffold
│  ├─ body: _screens[_selectedIndex]
│  └─ bottomNavigationBar: NavigationBar (5 destinations)
```

Destinations:
- Football (sports_soccer icon)
- Badminton (sports_tennis icon)
- Cricket (sports_cricket icon)
- Tournaments (emoji_events icon)
- Profile (person icon)

#### 4. **screens/football_screen.dart** ⭐ (Main Feature)
```
FootballScreen (StatefulWidget)
├─ _activeGames (List<Map>)
├─ _teamRequests (List<TeamRequest>)
├─ _selectedGround (int)
├─ _selectedPlayers (int)
├─ _showCreateTeamSheet()
├─ Scaffold
│  ├─ AppBar
│  │  ├─ Title: "Football"
│  │  └─ Actions: Refresh button (with loading state)
│  ├─ body: RefreshIndicator
│  │  └─ ListView with:
│  │     ├─ Active Games Section
│  │     │  └─ ActiveGameCard (show Ground, Teams, Duration, Waiting Teams)
│  │     └─ Looking for Players Section
│  │        ├─ TeamRequestCard (complex, see below)
│  │        └─ Empty state (if no requests)
│  └─ FAB: "Find Players" (opens bottom sheet)
└─ BottomSheet Modal
   ├─ Ground dropdown (1-5)
   ├─ Players needed dropdown (1-5)
   └─ Create button
```

**LookingForPlayersCard Features:**
- Ground number badge
- Posted time ("X mins ago")
- Players needed status (3/6)
- Circular progress indicator (0-100%)
- Stacked player avatars (circles)
- Join button (disabled when full)

#### 5. **models/team_request.dart**
```
TeamRequest (const constructor)
├─ Immutable fields:
│  ├─ id: String
│  ├─ sport: String
│  ├─ groundNumber: int (1-5)
│  ├─ playersNeeded: int
│  ├─ currentPlayers: int
│  ├─ playerIds: List<String>
│  ├─ creatorId: String
│  ├─ createdAt: DateTime
│  └─ status: String
├─ fromJson() / toJson() methods
├─ copyWith() method
├─ Computed properties:
│  ├─ playersStillNeeded: int
│  ├─ progress: double (0.0-1.0)
│  └─ isFull: bool
```

#### 6. **models/user_profile.dart**
```
UserProfile (const constructor)
├─ Immutable fields:
│  ├─ id: String
│  ├─ name: String
│  ├─ email: String
│  ├─ registrationNumber: String
│  ├─ preferredSports: List<String>
│  ├─ profileImageUrl: String?
│  └─ createdAt: DateTime
├─ fromJson() / toJson() methods
├─ copyWith() method
├─ hasSportPreference() method
```

## UI/UX Design Decisions

### Material 3 Implementation
- Uses `useMaterial3: true` in theme
- Color scheme from seed color (blue)
- Proper elevation and shadows
- Rounded corners (8-16px)

### Spacing System
- Small padding: 8px
- Default padding: 16px
- Large padding: 24px
- Consistent vertical spacing in ListViews

### Cards & Elevation
- Default elevation: 1
- FAB elevation: 4
- NavigationBar elevation: 8
- Border radius: 12px (cards), 16px (FAB/buttons)

### Color Scheme
- Primary: Blue (#2196F3)
- Primary containers for badges
- Secondary containers for alternate styling
- Outline color for hints/labels
- Surface colors for backgrounds

### Dark Mode
- Automatic based on system preference
- ThemeMode.system in MaterialApp
- Custom color schemes for light/dark
- Proper contrast maintained

## Data Flow

### Team Request Creation
```
User taps FAB
    ↓
Bottom sheet opens
    ↓
Select ground & players
    ↓
Tap Create
    ↓
New TeamRequest added to list
    ↓
Success SnackBar shown
    ↓
Sheet closes
```

### Team Request Joining
```
User taps Join on card
    ↓
Check if team is full
    ↓
If not full: Show success SnackBar
If full: Disable button
```

### Data Refresh
```
User taps refresh icon
    ↓
Loading spinner appears
    ↓
1 second delay (simulated)
    ↓
Loading spinner disappears
    ↓
List updates
```

## Firebase Integration Points

### To be implemented:

#### Authentication Service
- User registration
- Email/password login
- Social login (optional)
- Session management

#### Firestore Collections
```
/users/{userId}
  ├─ name: String
  ├─ email: String
  ├─ registrationNumber: String
  ├─ preferredSports: List<String>
  ├─ profileImageUrl: String (optional)
  └─ createdAt: Timestamp

/teamRequests/{requestId}
  ├─ sport: String
  ├─ groundNumber: int
  ├─ playersNeeded: int
  ├─ currentPlayers: int
  ├─ playerIds: List<String>
  ├─ creatorId: String
  ├─ createdAt: Timestamp
  └─ status: String
```

#### Real-time Listeners
- Team requests stream (by sport)
- Active games stream
- User profile updates
- Team request joining notifications

## State Management Setup

Provider is configured in main.dart but ready for use:

```dart
MultiProvider(
  providers: [
    // Add your providers here:
    // ChangeNotifierProvider(create: (_) => UserProvider()),
    // ChangeNotifierProvider(create: (_) => TeamRequestProvider()),
    // StreamProvider(create: (_) => firebaseService.getTeamRequests()),
  ],
)
```

## Dependencies Summary

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^2.24.0 | Firebase initialization |
| firebase_auth | ^4.14.0 | Authentication |
| cloud_firestore | ^4.13.0 | Database |
| provider | ^6.1.0 | State management |
| go_router | ^12.0.0 | Advanced routing |
| google_fonts | ^6.1.0 | Custom fonts |
| intl | ^0.19.0 | Date formatting |
| cupertino_icons | ^1.0.6 | iOS icons |

## Code Quality Features

- ✅ Null safety enabled
- ✅ Const constructors throughout
- ✅ Proper immutability in models
- ✅ JSON serialization with null handling
- ✅ Strong typing everywhere
- ✅ Material 3 adherence
- ✅ Comprehensive linting rules
- ✅ Comments on complex sections
- ✅ Clean separation of concerns

## Next Development Phases

### Phase 1: Firebase Integration
- [ ] Configure firebase_options.dart
- [ ] Implement AuthService
- [ ] Implement FirestoreService
- [ ] Add authentication flow

### Phase 2: State Management
- [ ] Create UserProvider
- [ ] Create TeamRequestProvider
- [ ] Integrate Provider with Firebase
- [ ] Real-time data streams

### Phase 3: Feature Enhancement
- [ ] Implement Badminton, Cricket screens
- [ ] Add profile editing
- [ ] Implement tournaments
- [ ] Add messaging

### Phase 4: Advanced Features
- [ ] Location-based matching
- [ ] User ratings/reviews
- [ ] Push notifications
- [ ] Analytics integration

## Getting Started

1. Run `flutter pub get`
2. Run `flutterfire configure`
3. Update Firebase credentials
4. Run `flutter run`

The app is fully functional with mock data and ready for Firebase integration!

---

**Version:** 1.0.0  
**Created:** February 2026  
**Status:** Ready for development
