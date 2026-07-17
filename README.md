# 🎵 Modern Flutter Music App

A fully featured, beautiful, and highly responsive local and online music player built with Flutter. Designed with a modern, glassmorphic UI, this app brings your favorite local music files and online streams (SoundCloud, iTunes) together into one unified experience.

![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.19.0-02569B?style=for-the-badge&logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-%E2%89%A53.3.0-0175C2?style=for-the-badge&logo=dart)
![CI/CD Status](https://img.shields.io/github/actions/workflow/status/FaturHaan/music-app/flutter-build.yml?style=for-the-badge&logo=github)

---

## ✨ Key Features

- 🎧 **Unified Library**: Play local audio files or stream online music seamlessly from a single unified player interface.
- 🌐 **Multi-Source Search & Aggregation**: Discover and stream music from multiple platforms (SoundCloud, iTunes). Features smart deduplication so you only see the best version of each track.
- 🎤 **Live Lyrics**: Synchronized and static lyrics support. Uses in-memory caching and intelligent fallback APIs (`lyrics.ovh` & `lyrist.vercel.app`) for maximum reliability.
- 💾 **Smart Caching**: Stream URLs are intelligently cached with 5-hour expiration logic to minimize network requests and optimize performance.
- 🗂️ **Playlist & Favorites Management**: Create custom playlists, mark tracks as favorites, and persist online songs automatically to your local SQLite database for offline cataloging.
- 🎨 **Dynamic UI/UX**: State-of-the-art "glassmorphism" design, dynamic genre discovery cards, robust state handling, and persistent user preferences.
- 🛡️ **Robust Error Handling**: Graceful error recovery for playback and network issues, keeping the user informed without breaking the experience.

---

## 📸 Screenshots

*(Add screenshots of your application here to showcase the Home, Search, Now Playing, and Lyrics screens)*

---

## 🚀 Getting Started

Follow these steps to get the app running on your local machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- Android Studio / Xcode for emulators and building
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FaturHaan/music-app.git
   cd music-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Environment Variables (API Keys)**
   This app uses Last.fm and SoundCloud for online music metadata enrichment and streaming.
   - Copy the example environment file:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and fill in your keys:
     ```env
     LASTFM_API_KEY=your_lastfm_api_key_here
     SOUNDCLOUD_CLIENT_ID=your_soundcloud_client_id_here
     ```
   *(Note: You can obtain these keys for free from the [Last.fm API](https://www.last.fm/api) and [SoundCloud API](https://developers.soundcloud.com/).)*

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🛠️ Architecture & Tech Stack

This project is built focusing on clean architecture principles, testability, and smooth performance:
- **State Management**: `Provider` architecture for efficient, predictable UI rebuilds.
- **Audio Engine**: `just_audio` for robust, gapless audio playback, streaming, and background capabilities.
- **Local Storage**: `sqflite` for relational metadata storage (playlists, favorite flags, offline catalog) and `shared_preferences` for UI state persistence (sorting/filters).
- **Network & CI/CD**: Seamless GitHub Actions CI/CD pipeline ensuring code health (lints, unit tests, and automated APK releases).

## 🧪 Testing

The app is covered by a suite of unit and widget tests targeting core business logic (e.g., `PlayerProvider`, `SourceAggregator`, and `SearchProvider`).
Run the test suite using:
```bash
flutter test
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 
Feel free to check the [issues page](https://github.com/FaturHaan/music-app/issues) if you want to contribute.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
