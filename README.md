# 🔥 HAR Extractor

**Ultra-fast HAR file analyzer that extracts APIs, skips static assets, and exports clean request/response data.**

[![Termux](https://img.shields.io/badge/Termux-✓-green)](https://termux.com)
[![Bash](https://img.shields.io/badge/Bash-4.0+-blue)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Version](https://img.shields.io/badge/version-8.0.0-orange)](CHANGELOG.md)

---

## ✨ Features

- ⚡ **Ultra Fast** — Processes 500+ entries in seconds
- 🎯 **Smart Filtering** — Auto-skips images, CSS, JS, fonts, and media
- 🌐 **Domain Grouping** — Auto-groups by host with request counts
- 📝 **Full Request/Response** — Headers, body, status codes, pretty-printed JSON
- 🎨 **Beautiful UI** — Color-coded, professional terminal output
- 🔧 **Interactive** — Choose what to filter and which domains to export
- 📱 **Termux Ready** — No `/tmp` dependency, works on Android
- 🚀 **Persistent Config** — Saves your preferences in `~/.har_extractor.conf`

---

## 📦 Installation

### Requirements

- **Bash** 4.0+
- **jq** (auto-installed on Termux/apt/brew when missing)

### Clone & Run

```bash
git clone https://github.com/YOUR_USER/har-extractor.git
cd har-extractor
chmod +x har.sh
./har.sh
```

### Optional: Add alias

Add to `~/.bashrc`:

```bash
alias har='$HOME/har-extractor/har.sh'
```

Then restart shell:

```bash
source ~/.bashrc
har
```

---

## 🚀 Usage

```bash
./har.sh
```

### Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |
| `-c`, `--config` | Print config file path |
| `--reset-config` | Reset saved preferences |

### Workflow

1. **Filter Configuration** — Choose which asset types to skip
2. **Enter HAR file path** — Any valid HAR file
3. **Select domains** — `1`, `1,3,5`, `1-3`, or `all`
4. **Get export** — Clean `.txt` file with all requests/responses

---

## 📸 Example Output

```
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║  🌐 DOMAIN: https://api.example.com
║  📊 Total Requests: 12
╚═══════════════════════════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────────────────────────────────────┐
│  📤 REQUEST #1
└────────────────────────────────────────────────────────────────────────────────────┘

URL :- https://api.example.com/v1/users

Method :- GET

Headers :-
  accept: application/json
  authorization: Bearer eyJhbGc...

Body :-

RAW :-
(No request body)

┌────────────────────────────────────────────────────────────────────────────────────┐
│  📥 RESPONSE #1
└────────────────────────────────────────────────────────────────────────────────────┘

Status :-

RAW :-
HTTP/2 200 OK
content-type: application/json
content-length: 512

BODY :-
{
  "users": [
    {"id": 1, "name": "Alice"},
    {"id": 2, "name": "Bob"}
  ]
}

┌────────────────────────────────────────────────────────────────────────────────────┐
│  ✓ END OF REQUEST/RESPONSE #1
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 What Gets Filtered

| Category | Extensions |
|----------|-----------|
| 🖼️ Images | `.svg`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.ico` |
| 🎨 Styles | `.css`, `.scss`, `.sass`, `.less` |
| 📜 Scripts | `.js`, `.mjs`, `.ts`, `.jsx`, `.tsx` |
| 🔤 Fonts | `.woff`, `.woff2`, `.ttf`, `.eot`, `.otf` |
| 🎬 Media | `.mp4`, `.mp3`, `.webm`, `.ogg`, `.avi` |
| 📁 Paths | `/assets/`, `/static/`, `/images/`, `/img/`, `/fonts/`, `/media/`, `favicon` |

**Kept:** All API endpoints, WebSocket, Socket.io, GraphQL, JSON responses, navigation requests.

---

## 🗂️ Repository

```
har-extractor/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── .gitignore
└── har.sh
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

MIT © [ZexAsura](LICENSE).