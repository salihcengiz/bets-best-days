# Bet's Best Days

A personal iOS app made for a couple. It counts down to special days, keeps track of the days spent together, and includes surprise notes, coupons, and a shared playlist. Built with SwiftUI and WidgetKit, and runs entirely on-device.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![Xcode](https://img.shields.io/badge/Xcode-27-blue)

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Architecture Notes](#architecture-notes)
- [Status](#status)

## Features
- **Countdowns:** time remaining until the next birthday and anniversary, in days, hours, minutes, and seconds. Repeats automatically every year. On the special day, the countdown is replaced by a celebration screen.
- **Together counter:** total number of days together ("Birlikte 482 gün") with a years / months / days breakdown.
- **Widgets:** Home Screen (small, medium) and Lock Screen (circular, rectangular, inline) sizes. Updated every midnight.
- **Local notifications:** reminders 7 days and 1 day before each special day, and on the day itself. A notification is also sent when a surprise note unlocks.
- **Surprise notes:** messages that unlock on a specific date. They are read with an envelope-opening animation.
- **Coupons:** single-use cards such as "a dinner out", "movie night, your pick", or "the right to win an argument". Redeeming one asks for confirmation and the state is saved permanently.
- **Playlist:** opens the shared Spotify playlist with a single tap.

The app requires no server, account, or internet connection; the only exception is the playlist link. All state is stored on the device.

## Tech Stack
| Area          | Used                                      |
|---------------|-------------------------------------------|
| UI            | SwiftUI, Observation (`@Observable`)      |
| Widgets       | WidgetKit                                 |
| Notifications | UserNotifications (local only)            |
| Persistence   | UserDefaults                              |
| Dependencies  | None (no third-party packages)            |

## Requirements
- Xcode 27 or later
- An iPhone running iOS 17.0 or later (portrait only)
- An Apple Account for installing on a physical device. A free Personal Team is enough, but the signature must then be renewed every 7 days.

## Getting Started
```bash
git clone <repository-url>
cd bets-best-days/src/BetsBestDays

# Create your local, git-ignored content file from the template
cp Config/BetContent.example.swift BetsBestDays/Shared/BetContent.swift

open BetsBestDays.xcodeproj
```

Fill in `BetsBestDays/Shared/BetContent.swift` with your own content. It is listed in `.gitignore` and is never committed.

**On the Simulator:** in Xcode, select the `BetsBestDays` scheme and an iPhone simulator, then press ⌘R.

**On a device:**
1. In the **Signing & Capabilities** tab of both targets (`BetsBestDays` and `BetsBestDaysWidgetExtension`), select your own Team.
2. Change the Bundle Identifier to a value you own. The widget's Bundle Identifier must start with the app's.
3. Connect your iPhone, enable Developer Mode, and press ⌘R.

**Build check from the command line:**
```bash
xcodebuild -project src/BetsBestDays/BetsBestDays.xcodeproj \
  -scheme BetsBestDays \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  CODE_SIGNING_ALLOWED=NO build
```

## Configuration
Personal content is kept out of the repository, similar to a `.env` / `.env.example` setup:

| Local file (git-ignored) | Committed template |
|---|---|
| `BetsBestDays/Shared/BetContent.swift` | `Config/BetContent.example.swift` |

All content and settings live in this single file. It contains:
- The birth date and the relationship start date (the anniversary is calculated from this date)
- Surprise notes (unlock date, title, text), coupons, and the playlist link
- Celebration and welcome texts, and the notification time

Places that need to be filled in are marked with `TODO` comments.

- **Adding a new note or coupon:** give each item a new UUID (run `uuidgen` in Terminal).
- **Existing UUIDs:** do not change them; read and redeemed states are tied to these IDs.
- **After changing content:** simply reinstall the app; the widgets update as well.

## Project Structure
```
bets-best-days/
├── README.md
├── .gitignore
└── src/BetsBestDays/
    ├── BetsBestDays.xcodeproj
    ├── Config/                    # Templates for git-ignored local files
    ├── BetsBestDays/              # App target
    │   ├── MyApp.swift            # Entry point
    │   ├── ContentView.swift      # Root view
    │   ├── Shared/                # Code shared by the app and the widget
    │   └── Views/                 # Screens and components
    └── BetsBestDaysWidget/        # Widget Extension target
```

## Architecture Notes
- **The widget computes its own data:** App Groups are not used. The files under `Shared/` (theme, models, content, date calculations) are compiled into both the app and the widget targets via target membership. Since the dates are fixed, the widget produces its own values without sharing data with the app.
- **Single source of data:** views access data only through `DataStore` (`@Observable`).
- **Models:** `Identifiable` and `Codable`, with fixed `UUID` identifiers.
- **Notifications:** rescheduled every time the app is opened, respecting iOS's limit of 64 pending notifications.
- **Language:** the UI is Turkish only; dates are formatted with `tr_TR`.

## Status
In development. Built for personal use; it will not be published on the App Store.
