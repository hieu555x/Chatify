# Chatify - Real-Time Chat Application

## 📱 Project Overview

**Chatify** is a modern, feature-rich cross-platform messaging application built with **Flutter** and powered by **Firebase**. It provides seamless real-time communication between users with a beautiful, intuitive user interface. The application is designed to work across multiple platforms including iOS, Android, Web, macOS, Windows, and Linux, ensuring users can connect and communicate regardless of their device.

## 🎯 Project Purpose

Chatify is a complete chat solution that enables users to:

- Create accounts and authenticate securely
- Connect with other users in real-time
- Exchange messages instantly
- Share media files (images, videos)
- Manage user profiles
- Navigate between different sections of the application seamlessly

## ✨ Key Features

### Authentication & Security

- **User Registration**: New users can create accounts with email and password
- **Login System**: Secure authentication powered by Firebase Authentication
- **Profile Management**: Users can view and edit their profile information
- **Password Security**: Encrypted password storage and secure authentication protocols

### Real-Time Messaging

- **Instant Messaging**: Send and receive messages in real-time using Firebase Firestore
- **Message History**: Access complete conversation history with other users
- **Message Status**: View sent and read status indicators
- **Typing Indicators**: See when other users are typing

### Media Sharing

- **Image Sharing**: Share images from gallery or take new photos
- **Media Storage**: Secure storage using Firebase Cloud Storage
- **Image Preview**: Preview shared images before sending
- **Gallery Integration**: Seamless integration with device gallery

### User Management

- **User Discovery**: Browse and search for other users
- **User Profiles**: Detailed user profiles with profile pictures
- **Online Status**: See which users are currently online
- **User Blocking**: Control who can message you

### User Interface

- **Custom Widgets**: Beautifully designed custom input fields and buttons
- **Responsive Design**: Optimized for different screen sizes
- **Intuitive Navigation**: Easy-to-use navigation between pages
- **Modern UI Elements**: Rounded buttons, custom image containers, and top navigation bars

## 🏗️ Project Architecture

### Technology Stack

**Frontend Framework:**

- **Flutter**: Modern UI framework for building beautiful, natively compiled applications
- **Dart**: Programming language for Flutter development

**Backend Services:**

- **Firebase Authentication**: Handles user authentication and account management
- **Firebase Firestore**: Real-time NoSQL database for storing messages and user data
- **Firebase Cloud Storage**: Stores user profile images and media files
- **Firebase App Check**: Adds security to protect against abuse

**Supporting Libraries:**

- **Provider**: State management for managing application state
- **Image Picker**: Native plugin for selecting images from gallery or camera
- **SDWebImage**: Efficient image loading and caching
- **SwiftyGif**: GIF image support

### Folder Structure

```
lib/
├── main.dart                      # Application entry point
├── firebase_options.dart          # Firebase configuration
├── local_env.dart                 # Local environment variables
├── models/
│   └── chat_user.dart            # User data model
├── pages/
│   ├── splash_page.dart          # Splash screen/loading page
│   ├── login_page.dart           # User login interface
│   ├── register_page.dart        # User registration interface
│   ├── home_page.dart            # Main chat list view
│   ├── chat_page.dart            # Individual chat conversation
│   └── user_page.dart            # User profile management
├── providers/
│   └── authentication_provider.dart # Authentication state management
├── services/
│   ├── authentication_service.dart # Authentication logic
│   ├── database_service.dart      # Firestore operations
│   ├── cloud_storage_service.dart # Firebase Storage operations
│   ├── media_services.dart        # Image/media handling
│   └── navigation_services.dart   # App navigation logic
└── widget/
    ├── custom_input_field.dart    # Reusable text input field
    ├── rounded_button.dart        # Reusable button widget
    ├── rounded_image.dart         # Reusable image container
    └── top_bar.dart               # App header/navigation bar
```

## 🚀 Getting Started

### Prerequisites

Before running this project, ensure you have installed:

- **Flutter SDK** (latest stable version)
- **Dart SDK** (comes with Flutter)
- **Xcode** (for iOS development on macOS)
- **Android Studio** (for Android development)
- **CocoaPods** (for iOS dependency management)
- **Git** (for version control)

### Installation Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/Chatify.git
   cd Chatify
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a Firebase project in Firebase Console
   - Generate `google-services.json` for Android
   - Generate `GoogleService-Info.plist` for iOS
   - Place these files in their respective platform directories

4. **Install iOS Pods**

   ```bash
   cd ios
   pod install
   cd ..
   ```

5. **Run the Application**
   ```bash
   flutter run
   ```

### Build for Different Platforms

**Android:**

```bash
flutter build apk           # Build APK
flutter build appbundle     # Build App Bundle
```

**iOS:**

```bash
flutter build ios           # Build for iOS
```

**Web:**

```bash
flutter build web           # Build for web
```

## 📋 Application Flow

### User Journey

1. **Splash Screen** → Initial loading and app initialization
2. **Authentication** → Login or Register based on user status
3. **Home Page** → View list of all conversations and recent chats
4. **Chat Page** → Open conversation with specific user and exchange messages
5. **User Profile** → Manage personal information and profile settings

### Data Flow

```
User Input → Service Layer → Firebase Services → UI Update
                ↓
            Provider (State Management)
                ↓
            UI Rebuilds with New Data
```

## 🔐 Security Features

- **Authentication**: Firebase Authentication with email/password
- **Data Encryption**: Secure transmission of data over HTTPS
- **Firebase Rules**: Firestore security rules restrict unauthorized access
- **App Check**: Firebase App Check prevents API abuse
- **Credential Management**: Secure storage of authentication tokens

## 📱 Supported Platforms

| Platform    | Status             | Notes                   |
| ----------- | ------------------ | ----------------------- |
| **Android** | ✅ Fully Supported | Requires API 21+        |
| **iOS**     | ✅ Fully Supported | Requires iOS 11.0+      |
| **Web**     | ✅ Supported       | Chrome, Firefox, Safari |
| **macOS**   | ✅ Supported       | Intel & Apple Silicon   |
| **Windows** | ✅ Supported       | Windows 10+             |
| **Linux**   | ✅ Supported       | Ubuntu, Fedora, etc.    |

## 🛠️ Development

### Project Dependencies

Core dependencies are defined in `pubspec.yaml`:

- **firebase_core**: Firebase core functionality
- **firebase_auth**: Authentication services
- **cloud_firestore**: Real-time database
- **firebase_storage**: Cloud file storage
- **provider**: State management solution
- **image_picker**: Media selection capability
- **sdwebimage**: Advanced image caching
- **swiftygif**: Animated GIF support

### Code Structure

- **Models**: Define data structures for Chat Users and Messages
- **Pages**: Complete screens with UI and logic
- **Widgets**: Reusable UI components
- **Services**: Business logic and external API calls
- **Providers**: State management and data flow control

## 🧪 Testing

To run tests in the project:

```bash
flutter test
```

The project includes widget tests in the `test/` directory for UI testing.

## 🔧 Configuration

### Environment Variables

- `local_env.dart` contains local configuration settings
- `firebase_options.dart` contains Firebase initialization parameters
- Environment-specific settings can be managed through local_env.dart

### Firebase Configuration

Firebase is configured for:

- Email/Password Authentication
- Firestore Database for messages and user data
- Cloud Storage for media files
- App Check for security

## 📦 Building and Deployment

### Generate Release Builds

**Android Release:**

```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS Release:**

```bash
flutter build ios --release
```

**Web Release:**

```bash
flutter build web --release
```

## 🤝 Contributing

To contribute to Chatify:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support & Contact

For issues, questions, or suggestions:

- Open an issue on GitHub
- Contact the development team
- Check the Flutter documentation: https://docs.flutter.dev/

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Firebase Team**: For excellent backend services
- **Flutter Community**: For helpful packages and support
- **Contributors**: Everyone who has helped in development

## 🔗 Useful Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

---

**Last Updated**: December 2025
**Version**: 1.0.0
**Status**: Active Development
