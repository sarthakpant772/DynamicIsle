# DynamicIsle

A native macOS app that brings the Dynamic Island experience to your Mac. Displays a floating, animated overlay at the top-center of your screen that integrates seamlessly with the notch on MacBook Pro 14"/16".

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-purple)

## Features

### Core Features
- **Now Playing** - Shows currently playing music from Spotify, Apple Music, or any media app with playback controls
- **Timer** - Countdown timers with visual progress ring and quick presets
- **Calendar** - Upcoming events from your calendar with time-until indicators
- **Notifications** - Display app notifications in the island

### Premium Features (Differentiators)

- **AI Quick Access** - Press ⌘J to instantly ask Claude or ChatGPT a question. Response appears right in the island. Supports quick prompts for summarizing, explaining, fixing code, and translating.

- **Meeting Join Button** - Automatically detects upcoming Zoom, Google Meet, Microsoft Teams, and Webex meetings from your calendar. Shows a prominent "Join" button 5 minutes before meetings start.

- **Clipboard History** - Tracks your last 10 clipboard items. Click any item to copy it back. Supports text, images, and files.

- **Pomodoro Focus Mode** - Full Pomodoro timer (25/5/15 minute cycles) with **app blocking**. Automatically hides distracting apps like browsers and social media during focus sessions.

## Screenshots

```
┌─────────────────────────────────────────────────────────┐
│                    ┌──────────────┐                     │
│                    │ Dynamic Isle │  ← Collapsed        │
│                    └──────────────┘                     │
│                                                         │
│            ┌────────────────────────────┐               │
│            │  🎵 Now Playing            │               │
│            │  Song Title                │               │
│            │  Artist Name               │  ← Expanded   │
│            │   advancement               │                │
│            │  ◀️  ▶️  ▶️▶️              │               │
│            └────────────────────────────┘               │
└─────────────────────────────────────────────────────────┘
```

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (for building)
- Claude or OpenAI API key (for AI feature)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/DynamicIsle.git
   cd DynamicIsle
   ```

2. Open in Xcode:
   ```bash
   open DynamicIsle.xcodeproj
   ```

3. Select your development team in **Signing & Capabilities**

4. Build and run (⌘R)

## Usage

### Basic Interaction
- **Click** the island to expand/collapse
- **Hover** over the collapsed island to preview
- Island auto-collapses after 5 seconds (configurable)

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| ⌘J | Open AI Quick Access |
| Click | Expand/Collapse island |

### Quick Actions (Expanded View)
- **AI** - Ask a question to Claude/ChatGPT
- **Focus** - Start a Pomodoro session
- **Timer** - Set a quick timer
- **Clipboard** - View clipboard history

### Menu Bar
Access from the menu bar icon:
- Start quick timers (1, 3, 5, 10, 15, 30 min presets)
- Toggle features on/off
- Access settings
- Quit the app

## Feature Details

### AI Quick Access
1. Press ⌘J or click AI in expanded view
2. Enter your API key (Claude or OpenAI) on first use
3. Type your question and press Enter
4. Response appears in the island
5. Click "Copy" to copy response to clipboard

### Meeting Integration
- Automatically scans calendar events for meeting links
- Detects Zoom, Google Meet, Teams, and Webex URLs
- Shows "Join" button 5 minutes before meeting starts
- One-click to open meeting in browser

### Clipboard History
- Monitors clipboard in background
- Stores last 10 items (text, images, files)
- Click item to copy back to clipboard
- Clear history anytime

### Pomodoro Focus Mode
- Configurable work/break durations (default: 25/5/15)
- Tracks completed pomodoros
- **App Blocking**: Hides distracting apps during focus sessions
- Pre-configured blocklist: Safari, Chrome, Firefox, Slack, Twitter, Facebook, Reddit
- Customizable blocklist in settings

## Permissions

The app may request the following permissions:

| Permission | Purpose |
|------------|---------|
| Calendar | Display upcoming events and detect meeting links |
| Notifications | Send timer/focus session alerts |
| Accessibility | Optional - for app blocking feature |

## Project Structure

```
DynamicIsle/
├── App/
│   ├── DynamicIsleApp.swift
│   ├── AppDelegate.swift
│   └── PermissionsManager.swift
├── Core/Window/
│   ├── IslandWindow.swift
│   ├── IslandWindowController.swift
│   └── ScreenManager.swift
├── Features/
│   ├── Island/           # Main container
│   ├── NowPlaying/       # Media playback
│   ├── Timer/            # Countdown timers
│   ├── Calendar/         # Calendar events
│   ├── Notifications/    # Notification display
│   ├── AI/               # Claude/OpenAI integration
│   ├── Meeting/          # Meeting detection & join
│   ├── Clipboard/        # Clipboard history
│   └── Focus/            # Pomodoro + app blocking
├── Settings/
├── MenuBar/
└── Resources/
```

## Technical Details

### Floating Window
- `NSPanel` subclass at `.floating` level
- Transparent background, non-activating
- Visible on all Spaces, works over fullscreen apps

### Notch Detection
```swift
var hasNotch: Bool {
    NSScreen.main?.safeAreaInsets.top ?? 0 > 0
}
```

### Now Playing
Uses private `MediaRemote.framework` for system-wide Now Playing info.

### App Blocking
Uses `NSWorkspace` notifications to detect app launches and hide blocked apps during focus sessions.

## Monetization

This app is designed for direct sales (not App Store) due to private API usage:

- **Gumroad** / **Lemon Squeezy** - Simple digital sales
- **Paddle** - Licensing and updates
- **Setapp** - Subscription bundle

Suggested price: **$15-25** (competitors like NotchNook charge $25)

## Limitations

- **App Store**: MediaRemote framework won't work in sandboxed apps
- **Notifications**: Cannot intercept other apps' notifications
- **App Blocking**: Hides apps but doesn't prevent re-opening (no root access)

## Roadmap

- [ ] Custom themes and colors
- [ ] Drag to reposition island
- [ ] Spotify lyrics integration
- [ ] Device battery status (AirPods, iPhone)
- [ ] System stats (CPU, RAM, Network)
- [ ] Split island view (two widgets side-by-side)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by Apple's Dynamic Island on iPhone 14 Pro and later
- Built with SwiftUI and AppKit
