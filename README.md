# Ago Timer — watchOS Stopwatch App

A standalone watchOS stopwatch app with support for multiple concurrent stopwatches, editable time, and pause-aware display. Built with SwiftUI.

## Requirements

- Xcode 16+
- watchOS 10.0+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (only needed to regenerate the `.xcodeproj`)

## Running the App

1. Open `AgoTimer.xcodeproj` in Xcode.
2. Select the **AgoTimer Watch App** scheme.
3. Choose an Apple Watch simulator (e.g. Apple Watch Series 10 46mm).
4. Hit **Run** (Cmd+R).

### Regenerating the Xcode project

The project file is generated from `project.yml` using XcodeGen. If you modify the project structure (add/remove files, change settings), regenerate it:

```bash
brew install xcodegen   # if not already installed
xcodegen generate
```

## Project Structure

```
AgoTimer Watch App/
├── AgoTimerApp.swift          # App entry point (@main)
├── ContentView.swift          # Root view — vertical-paging TabView
├── Models/
│   ├── StopwatchModel.swift   # Single stopwatch: timing logic & state
│   └── StopwatchManager.swift # Manages the collection of stopwatches
├── Views/
│   ├── StopwatchView.swift    # Individual stopwatch UI (display + controls)
│   └── EditTimeView.swift     # Sheet for editing stopwatch time
├── Assets.xcassets/           # App icon & accent color
└── Preview Content/           # SwiftUI preview assets
```

## Architecture

### Models

**`Stopwatch`** (`ObservableObject`) — The core timing engine. Tracks elapsed time by recording a start date and accumulating intervals on pause. Exposes a computed `currentTime` property that gives the live elapsed time. Also stores `pausedAtTime` so the UI can show exactly when the stopwatch was paused.

**`StopwatchManager`** (`ObservableObject`) — Holds the array of `Stopwatch` instances and the currently selected tab index. Propagates child object changes up so SwiftUI views re-render correctly.

### Views

**`ContentView`** — A `TabView` with `.verticalPage` style. Each existing stopwatch gets a page, and the final page is a "+" button to create a new one. Swipe up/down to navigate between stopwatches.

**`StopwatchView`** — Displays the time in `MM:SS.cc` format (or `H:MM:SS.cc` when hours > 0). Uses `TimelineView` at 30fps for smooth centisecond updates — the timeline automatically pauses when the stopwatch isn't running to save battery. Controls change based on state:
- **Running:** pause button
- **Paused:** play, reset, and edit buttons
- Shows a "Paused at ..." label when paused with accumulated time

**`EditTimeView`** — Presented as a sheet with hour/minute/second pickers. Pre-fills with the current stopwatch time. Useful for two scenarios: starting a stopwatch from a non-zero time (e.g. "I forgot to start 3 minutes ago"), or adjusting after an accidental pause.

## Key Design Decisions

- **`TimelineView` over `Timer.publish`**: Ties updates to the display refresh cycle and automatically stops when paused, which is more battery-efficient on watchOS.
- **Vertical paging**: Uses watchOS's native `.verticalPage` tab style (swipe up/down) which is the standard navigation pattern for watch apps.
- **No companion iOS app**: This is a fully standalone watchOS app — no iPhone required.
