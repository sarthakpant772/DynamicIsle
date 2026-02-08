<div align="center">

# 🏝️ DynamicIsle

### Dynamic Island for macOS — Free & Open Source

**Bring the iPhone's Dynamic Island to your Mac. Music controls, voice notes with AI, meeting alerts, timers, and more — all in a beautiful floating pill.**

[![macOS 13+](https://img.shields.io/badge/macOS-13.0+-black?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/sarthakpant772/DynamicIsle?style=for-the-badge&color=gold)](https://github.com/sarthakpant772/DynamicIsle/stargazers)

[**Download**](https://github.com/sarthakpant772/DynamicIsle/releases/latest) · [Report Bug](https://github.com/sarthakpant772/DynamicIsle/issues) · [Request Feature](https://github.com/sarthakpant772/DynamicIsle/issues)

---

<!-- Add a GIF/video demo here for maximum impact -->
<!-- ![DynamicIsle Demo](assets/demo.gif) -->

</div>

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎵 **Now Playing** | Control Spotify & Apple Music right from the island |
| 🎙️ **Voice Notes + AI** | Speak → Transcribe → AI makes it concise (local Ollama) |
| 💬 **AI Chat** | Press `⌘J` for instant Claude/ChatGPT access |
| 📅 **Calendar** | See upcoming events at a glance |
| 📹 **Meeting Join** | One-click join for Zoom, Meet, Teams, Webex |
| ⏱️ **Timer** | Beautiful countdown with progress ring |
| 🧠 **Focus Mode** | Pomodoro timer + blocks distracting apps |
| 📋 **Clipboard** | History of your last 10 copies |

## 🚀 Quick Start

### Download

👉 **[Download Latest Release](https://github.com/sarthakpant772/DynamicIsle/releases/latest)**

> ⚠️ **First launch (important):**
> ```bash
> xattr -cr /Applications/DynamicIsle.app
> ```
> Then double-click to open. This removes macOS quarantine for unsigned apps.

### Build from Source

```bash
git clone https://github.com/sarthakpant772/DynamicIsle.git
cd DynamicIsle
open DynamicIsle.xcodeproj
# Press ⌘R to build and run
```

### Enable Voice Notes AI (Optional)

```bash
brew install ollama
ollama serve
ollama pull llama3.2  # or any model you prefer
```

## 🎯 How It Works

1. **Move cursor to top-center** of your screen → Island appears
2. **Click any feature** to use it
3. **Press `⌘J`** for instant AI chat
4. **Move cursor away** → Island hides

## 🛠️ Tech Stack

- **SwiftUI** — Modern declarative UI
- **AppKit** — Native window management
- **Speech Framework** — Voice transcription
- **EventKit** — Calendar integration
- **Ollama** — Local LLM for AI features

## 📸 Screenshots

<details>
<summary>Click to expand</summary>

```
    ┌────────────────────────────────────────┐
    │  🎵 Now Playing                        │
    │  Bohemian Rhapsody - Queen             │
    │   advancement━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
    │       ◀◀    ▶    ▶▶                    │
    └────────────────────────────────────────┘

    ┌────────────────────────────────────────┐
    │  🎙️ Voice Notes                        │
    │  "Meeting with John about the..."      │
    │                                        │
    │     🔴 Recording...    ✨ Make Concise │
    └────────────────────────────────────────┘
```

</details>

## 🤝 Contributing

Contributions make open source amazing! Any contributions are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🗺️ Roadmap

- [ ] Custom themes & colors
- [ ] Spotify lyrics integration
- [ ] System stats (CPU, RAM, Network)
- [ ] AirPods battery status
- [ ] Widgets API for custom extensions
- [ ] iPhone mirroring integration

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 💖 Support

If you like this project, please consider:
- ⭐ **Starring** this repository
- 🐛 **Reporting bugs** to help improve it
- 📢 **Sharing** with friends and on social media

## 👨‍💻 Author

**Sarthak Pant**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/pant-sarthak/)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sarthakpant772)

---

<div align="center">

**If this project helped you, please ⭐ star it!**

Made with ❤️ and mass amounts of ☕

</div>
