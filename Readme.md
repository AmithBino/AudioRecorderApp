# Audio Flow Recorder App

A modern SwiftUI audio recording application with real-time waveform visualization, playback controls, and recording management.

## Features

- 🎙 Real-time audio recording
- 🌊 Live waveform visualization
- ⏸ Pause and resume recording
- ▶️ Audio playback with seek support
- ✏️ Rename recordings
- 🗑 Delete recordings
- 📤 Share recordings
- 🔍 Search recordings
- 🎨 Modern SwiftUI UI

---

# Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

# Setup Instructions

## 1. Clone Repository

```bash
git clone https://github.com/AmithBino/AudioRecorderApp.git
```

## 2. Open Project

Open the project in Xcode:

```bash
open AudioRecorderApp.xcodeproj
```

## 3. Run App

- Select Simulator or Physical Device
- Press `Cmd + R`

---

# Permissions

The app requires microphone permission.

Add the following key in `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access for recording audio.</string>
```

---

# Project Structure

```text
├── Models
├── Services
├── ViewModels
├── Views
└── Utilities
```

---

# Technologies Used

- SwiftUI
- AVFoundation
- Combine
- MVVM Architecture

---

# Recording Features

- Live waveform updates
- Pause/resume recording
- Audio playback progress tracking
- File persistence using UserDefaults

