# Social Media Clone

A modern Flutter social media application built with MVVM architecture, featuring user authentication, post creation, and social interactions.

## Features

### 🔐 Authentication
- **Mock Authentication**: Login and signup with static credentials
- **Persistent Session**: User sessions are maintained using Hive local storage
- **Form Validation**: Email, username, and password validation
- **Demo Credentials**: 
  - Email: `demo@example.com`
  - Password: `demo123`

### 📱 Core Features
- **Post Feed**: View all posts in chronological order with sample data
- **Create Posts**: Add images from gallery/camera with captions
- **Like System**: Like and unlike posts with real-time count updates
- **User Profiles**: Display user information and post ownership
- **Image Management**: Automatic image storage and retrieval
- **Sample Data**: Pre-loaded mock posts for immediate demonstration

### 🏗️ Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Provider State Management**: Reactive UI updates
- **Hive Local Storage**: Fast, efficient data persistence
- **Service Layer**: Business logic abstraction

## Tech Stack

- **Framework**: Flutter 3.9.0+
- **State Management**: Provider
- **Local Storage**: Hive
- **Image Handling**: Image Picker
- **Architecture**: MVVM (Model-View-ViewModel)

## Project Structure

```
lib/
├── models/           # Data models with Hive annotations
│   ├── user.dart
│   ├── post.dart
│   └── auth_state.dart
├── viewmodels/       # Business logic and state management
│   ├── auth_viewmodel.dart
│   └── post_viewmodel.dart
├── views/            # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── feed_screen.dart
│   │   └── add_post_screen.dart
│   └── splash_screen.dart
├── services/         # Data and business services
│   ├── hive_service.dart
│   ├── auth_service.dart
│   └── post_service.dart
├── widgets/          # Reusable UI components
│   └── post_card.dart
└── main.dart         # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd social_media_clone
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### First Time Setup
1. Launch the app
2. Use the demo credentials to sign in:
   - Email: `demo@example.com`
   - Password: `demo123`
3. Or create a new account using the signup screen

### Creating Posts
1. Tap the "+" floating action button
2. Add a caption (required)
3. Optionally add an image from gallery or camera
4. Tap "Post" to publish

### Interacting with Posts
- **Like**: Tap the heart icon to like/unlike posts
- **Delete**: Tap the three dots menu on your own posts to delete them
- **Refresh**: Pull down on the feed to refresh posts
- **Add Sample Posts**: Use the menu (three dots) to add more sample posts for demonstration

## Demo Credentials

The app includes several demo accounts for testing:

| Email | Password | Username |
|-------|----------|----------|
| demo@example.com | demo123 | demo_user |
| john@example.com | password123 | john_doe |
| jane@example.com | password123 | jane_smith |

## Data Persistence

- **User Data**: Stored locally using Hive
- **Posts**: Persisted with images and metadata
- **Sessions**: Automatic login state management
- **Images**: Stored in app documents directory
- **Sample Data**: Pre-loaded mock posts and users for immediate demonstration

## Key Features Implementation

### MVVM Architecture
- **Models**: Data structures with Hive annotations
- **ViewModels**: Business logic and state management
- **Views**: UI screens with reactive updates

### State Management
- Provider pattern for reactive UI
- Centralized state in ViewModels
- Automatic UI updates on data changes

### Local Storage
- Hive for fast key-value storage
- Type-safe data models
- Automatic serialization/deserialization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Enhancements

- [ ] Real-time notifications
- [ ] Comments system
- [ ] User profiles and following
- [ ] Push notifications
- [ ] Dark mode support
- [ ] Post sharing
- [ ] Search functionality
- [ ] Firebase integration for cloud storage

## Support

For support or questions, please open an issue in the repository.