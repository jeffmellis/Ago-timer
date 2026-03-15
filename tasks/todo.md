# Pre-iOS Refactoring

Extract shared logic from the watchOS app so both platforms can reuse it.

## Tasks

- [x] Move `StopwatchModel.swift` → `Shared/`
- [x] Move `StopwatchManager.swift` → `Shared/`
- [x] Delete empty `AgoTimer Watch App/Models/` directory
- [x] Create `Shared/Theme.swift` — shared color constants
- [x] Move `formatComplicationTime` from widget → `Shared/` (rename to `formatStopwatchTimeCompact`)
- [x] Update `StopwatchView.swift` to use theme colors
- [x] Update `ContentView.swift` to use theme colors
- [x] Update widget to use shared formatting function
- [x] Regenerate Xcode project with `xcodegen`
- [x] Verify build compiles

## Rationale

- **Models are platform-agnostic**: `Stopwatch` uses only Foundation/Combine. `StopwatchManager` adds WidgetKit (available on both platforms). No reason to keep them watch-specific.
- **Colors are scattered**: The amber accent `Color(red: 1.0, green: 0.78, blue: 0.28)` is hardcoded in StopwatchView and duplicated in the asset catalog. Other grays are inline too. A shared theme file means the iOS app gets the same palette for free.
- **Two time formatters exist**: `formatStopwatchTime` (with centiseconds, in Shared) and `formatComplicationTime` (seconds-only, in widget). Both should live together in Shared.
