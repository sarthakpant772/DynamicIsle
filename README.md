# DynamicIsle

A free, open-source macOS app that brings the Dynamic Island experience to your Mac. A floating, animated overlay at the top-center of your screen that shows music, timers, meetings, AI chat, and more.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-purple)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Now Playing
Shows currently playing music from Spotify or Apple Music with full playback controls.

### Voice Notes with AI
Record voice memos, transcribe them automatically, and use local AI (Ollama) to make them concise. Save and view your note history.

### AI Quick Access
Press ⌘J to instantly ask questions. Supports Claude and OpenAI APIs.

### Meeting Join Button
Automatically detects Zoom, Google Meet, Teams, and Webex meetings from your calendar. One-click join button appears 5 minutes before.

### Timer
Countdown timers with visual progress ring and quick presets.

### Calendar
Upcoming events from your calendar with time-until indicators.

### Pomodoro Focus Mode
Full Pomodoro timer (25/5/15 minute cycles) with app blocking. Hides distracting apps during focus sessions.

### Clipboard History
Tracks your last 10 clipboard items. Click to copy back.

## Demo

```
         ┌────────────────────────────┐
         │     🎵  Dynamic Isle       │  ← Hover to reveal
         └────────────────────────────┘

    ┌────────────────────────────────────────┐
    │  ← Back                                │
    │                                        │
    │  🎵 Now Playing                        │
    │  Song Title - Artist Name              │
    │   advancement                            │
    │       ◀️    ▶️    ▶️▶️                  │
    └────────────────────────────────────────┘
```

## Installation

### Download
Download the latest release from [Releases](https://github.com/yourusername/DynamicIsle/releases).

### Build from Source

```bash
git clone https://github.com/yourusername/DynamicIsle.git
cd DynamicIsle
open DynamicIsle.xcodeproj
```

Then press ⌘R to build and run.

### Voice Notes Setup (Optional)
For the AI-powered voice notes feature, install Ollama:

```bash
brew install ollama
ollama serve
ollama pull llama3.2
```

## Usage

- **Move cursor to top-center** of screen to reveal the island
- **Click features** to switch between them
- **Press ⌘J** for AI quick access
- **Click Back** to return to home

### Quick Actions
| Icon | Feature |
|------|---------|
| 🎵 | Music controls |
| ✨ | AI chat |
| 🧠 | Focus mode |
| ⏱️ | Timer |
| 🎙️ | Voice notes |
| 📅 | Calendar |
| 📹 | Meetings |

## Permissions

| Permission | Purpose |
|------------|---------|
| Microphone | Voice notes recording |
| Speech Recognition | Transcription |
| Calendar | Events and meeting detection |
| Automation | Spotify/Apple Music control |

## Project Structure

```
DynamicIsle/
├── App/                    # App entry point
├── Core/Window/            # Floating window management
├── Features/
│   ├── Island/             # Main container
│   ├── NowPlaying/         # Spotify/Apple Music
│   ├── VoiceNotes/         # Voice recording + AI
│   ├── AI/                 # Claude/OpenAI chat
│   ├── Timer/              # Countdown timers
│   ├── Calendar/           # Calendar events
│   ├── Meeting/            # Meeting detection
│   ├── Focus/              # Pomodoro + app blocking
│   └── Clipboard/          # Clipboard history
├── Settings/
├── MenuBar/
└── Resources/
```

## Tech Stack

- **SwiftUI** - UI framework
- **AppKit** - Window management
- **Speech** - Voice recognition
- **EventKit** - Calendar integration
- **Ollama** - Local LLM for voice notes

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## License

MIT License - free to use, modify, and distribute.

## Author

Built by [Sarthak Pant](https://linkedin.com/in/yourprofile)

---

If you find this useful, give it a ⭐ on GitHub!
