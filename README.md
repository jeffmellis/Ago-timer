# Ago Timer — iOS & watchOS Stopwatch App

Multiple concurrent stopwatches with editable time, pause-aware display, and cross-device sync. Built with SwiftUI.

## Requirements

- Xcode 16+
- iOS 17+ / watchOS 10+ deployment targets
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (only needed to regenerate the `.xcodeproj`)

## Running the App

1. Open `AgoTimer.xcodeproj` in Xcode.
2. Select a scheme:
   - **AgoTimer iOS App** — run on an iPhone simulator
   - **AgoTimer Watch App** — run on an Apple Watch simulator
3. Hit **Run** (Cmd+R).

The Watch app runs standalone — no iPhone required. When both apps are available, stopwatches sync automatically via WatchConnectivity.

### Regenerating the Xcode project

The project file is generated from `project.yml` using XcodeGen. If you modify the project structure (add/remove files, change settings), regenerate it:

```bash
brew install xcodegen   # if not already installed
xcodegen generate
```

## Project Structure

```
Shared/                                # Cross-platform code (iOS, watchOS, Widget)
├── StopwatchModel.swift               # Timing engine & snapshot serialization
├── StopwatchManager.swift             # Stopwatch collection, App Group & Widget sync
├── SharedStopwatchState.swift         # Codable state for App Group + time formatters
├── SyncManager.swift                  # WatchConnectivity (iOS ↔ watchOS)
└── Theme.swift                        # Shared color palette

AgoTimer iOS App/
├── AgoTimerIOSApp.swift               # App entry point
├── ContentView.swift                  # Root view — stopwatch list
└── Views/
    ├── StopwatchDetailView.swift      # Full-screen stopwatch with controls
    ├── TimerRowView.swift             # List row with inline quick actions
    └── EditTimeView.swift             # Time edit sheet (wheel pickers)

AgoTimer Watch App/
├── AgoTimerApp.swift                  # App entry point
├── ContentView.swift                  # Root view — vertical-paging TabView
└── Views/
    ├── StopwatchView.swift            # Stopwatch display & controls
    ├── EditTimeView.swift             # Time edit sheet (compact pickers)
    └── NameInputView.swift            # Rename sheet

AgoTimer Widget/                       # watchOS complication
├── AgoTimerWidget.swift               # Accessory rectangular widget
└── Assets.xcassets/
```

## Architecture

### Shared Layer

All models and services live in `Shared/` and are compiled into every target.

**`Stopwatch`** (`ObservableObject`) — The core timing engine. Tracks elapsed time by recording a start date and accumulating intervals on pause. Exposes a computed `currentTime` for live elapsed time and `pausedAtTime` so the UI can show exactly when a stopwatch was paused. Supports serialization to `StopwatchSnapshot` for sync.

**`StopwatchManager`** (`ObservableObject`) — Manages the array of `Stopwatch` instances and the selected tab. Writes state to the App Group for the Widget and triggers `WidgetCenter.reloadAllTimelines()`. On iOS, kicks off WatchConnectivity sync after every change.

**`SharedStopwatchState`** — Codable struct persisted to `UserDefaults(suiteName: "group.com.agotimer.shared")`. Provides `load()`/`save()` plus time formatting helpers used by both apps and the Widget.

**`SyncManager`** — `WCSessionDelegate` that sends `[StopwatchSnapshot]` between iOS and watchOS via `updateApplicationContext` and `sendMessage`. On receive, `StopwatchManager.applySnapshots` merges incoming state.

**`AgoTheme`** — Shared color definitions (accent, running, paused, button colors).

### iOS App

**`ContentView`** — A `List` of all stopwatches with inline quick actions (play/pause, reset, resume from pause). Tap a row to navigate to the detail view. Toolbar button to add new stopwatches.

**`StopwatchDetailView`** — Full-screen view for a single stopwatch. Large time display, start/pause/reset/edit controls, and a toolbar rename option.

**`EditTimeView`** — Wheel pickers for hours, minutes, and seconds. Pre-fills with the current time for adjustments.

### watchOS App

**`ContentView`** — A `TabView` with `.verticalPage` style. Each stopwatch gets a page; the final page is a "+" button. Swipe up/down to navigate.

**`StopwatchView`** — Time in `MM:SS.cc` (or `H:MM:SS.cc`). Uses `TimelineView` at 30fps for smooth updates that automatically pause when idle. Controls adapt to state: pause button when running; play, reset, and edit buttons when paused.

**`EditTimeView`** — Compact hour/minute/second pickers sized for the watch.

**`NameInputView`** — Sheet for naming a stopwatch.

### watchOS Widget

An accessory rectangular complication that shows the selected stopwatch's name, time, and running/paused state. Reads from the App Group — no WatchConnectivity needed. Generates ~60 timeline entries when a stopwatch is running for near-live updates.

## Data Flow

```
┌─────────┐  WatchConnectivity  ┌───────────┐
│ iOS App │ ◄─────────────────► │ Watch App │
└────┬────┘                     └─────┬─────┘
     │                                │
     │   App Group (UserDefaults)     │
     └──────────┐  ┌──────────────────┘
                ▼  ▼
          ┌──────────────┐
          │ Watch Widget │
          └──────────────┘
```

Both apps write to a shared App Group. The Widget reads from it. Cross-device sync happens over WatchConnectivity.

## Key Design Decisions

- **Shared `Shared/` folder**: All models, sync logic, and theming live in one place, compiled into every target. No Swift Package overhead.
- **`TimelineView` over `Timer.publish`**: Ties updates to the display refresh cycle and stops automatically when paused — more battery-efficient on watchOS.
- **Vertical paging on Watch**: Uses watchOS's native `.verticalPage` tab style, the standard navigation pattern for watch apps.
- **List-based UI on iOS**: Stopwatches live in a `List` with navigation to a detail view, following iOS conventions.
- **App Group + WatchConnectivity**: Two-layer sync — App Group for on-device sharing (Watch ↔ Widget), WatchConnectivity for cross-device (iOS ↔ Watch).
